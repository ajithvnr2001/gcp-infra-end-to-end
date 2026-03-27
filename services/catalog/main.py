# services/catalog/main.py
# Production-ready FastAPI with:
#   Structured JSON logging  (GCP Cloud Logging compatible)
#   Prometheus metrics       (request rate, latency, error rate)
#   Distributed tracing      (OpenTelemetry -> GCP Cloud Trace)
#   Health & readiness probes

from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os, time, json, logging, sys

# ── Structured JSON Logging (GCP Cloud Logging format) ────────────────────────
class GCPJsonFormatter(logging.Formatter):
    """Formats logs as JSON — GCP Cloud Logging picks these up automatically"""
    def format(self, record: logging.LogRecord) -> str:
        log_entry = {
            "timestamp":   self.formatTime(record),
            "severity":    record.levelname,
            "message":     record.getMessage(),
            "logger":      record.name,
            "service":     "catalog-service",
            "version":     os.getenv("APP_VERSION", "1.0.0"),
            "environment": os.getenv("APP_ENV", "production"),
        }
        # Attach trace ID — links this log line to Cloud Trace span automatically
        current_span = trace.get_current_span()
        if current_span and current_span.get_span_context().is_valid:
            ctx = current_span.get_span_context()
            project_id = os.getenv("GCP_PROJECT_ID", "unknown")
            log_entry["logging.googleapis.com/trace"] = f"projects/{project_id}/traces/{format(ctx.trace_id, '032x')}"
            log_entry["logging.googleapis.com/spanId"] = format(ctx.span_id, '016x')
        if hasattr(record, "xtra"):
            log_entry.update(record.xtra)
        return json.dumps(log_entry)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(GCPJsonFormatter())
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"), handlers=[handler])
logger = logging.getLogger(__name__)

# ── OpenTelemetry Tracing ─────────────────────────────────────────────────────
OTEL_ENDPOINT = os.getenv(
    "OTEL_EXPORTER_OTLP_ENDPOINT",
    "http://otel-collector.monitoring.svc.cluster.local:4317"
)
provider = TracerProvider()
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint=OTEL_ENDPOINT, insecure=True))
)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer("catalog-service")

# ── Prometheus Metrics ────────────────────────────────────────────────────────
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status", "service"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint", "service"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5]
)

# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="Catalog Service", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])
FastAPIInstrumentor.instrument_app(app)
START_TIME = time.time()

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start    = time.time()
    response = await call_next(request)
    duration = time.time() - start
    endpoint = request.url.path
    REQUEST_COUNT.labels(method=request.method, endpoint=endpoint,
                         status=str(response.status_code), service="catalog-service").inc()
    REQUEST_LATENCY.labels(method=request.method, endpoint=endpoint,
                           service="catalog-service").observe(duration)
    return response

# ── Models & Data ─────────────────────────────────────────────────────────────
class Product(BaseModel):
    id: str; name: str; price: float; category: str; stock: int; rating: float

PRODUCTS = [
    Product(id="p1", name="Wireless Headphones", price=1999.0, category="electronics", stock=150, rating=4.5),
    Product(id="p2", name="Running Shoes",        price=2499.0, category="footwear",    stock=80,  rating=4.3),
    Product(id="p3", name="Cotton T-Shirt",        price=499.0,  category="clothing",    stock=500, rating=4.1),
    Product(id="p4", name="Smartphone Case",       price=299.0,  category="accessories", stock=200, rating=4.6),
    Product(id="p5", name="Yoga Mat",              price=799.0,  category="sports",      stock=60,  rating=4.4),
]

# ── Routes ────────────────────────────────────────────────────────────────────
@app.get("/metrics")
def metrics():
    """Prometheus scrape endpoint — auto-discovered by kube-prometheus-stack"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
def health():
    return {"status": "healthy", "uptime": round(time.time() - START_TIME, 2)}

@app.get("/ready")
def ready():
    return {"status": "ready"}

@app.get("/products", response_model=List[Product])
def list_products(category: Optional[str] = None, limit: int = 20):
    with tracer.start_as_current_span("list_products") as span:
        span.set_attribute("filter.category", category or "all")
        span.set_attribute("filter.limit", limit)
        products = [p for p in PRODUCTS if not category or p.category == category]
        logger.info(f"products listed count={len(products)} category={category}")
        span.set_attribute("result.count", len(products))
        return products[:limit]

@app.get("/products/{product_id}", response_model=Product)
def get_product(product_id: str):
    with tracer.start_as_current_span("get_product") as span:
        span.set_attribute("product.id", product_id)
        product = next((p for p in PRODUCTS if p.id == product_id), None)
        if not product:
            span.set_attribute("error", True)
            logger.warning(f"product not found product_id={product_id}")
            raise HTTPException(status_code=404, detail=f"Product {product_id} not found")
        return product

@app.get("/products/search/{query}", response_model=List[Product])
def search_products(query: str):
    with tracer.start_as_current_span("search_products") as span:
        span.set_attribute("search.query", query)
        results = [p for p in PRODUCTS if query.lower() in p.name.lower()]
        span.set_attribute("search.results", len(results))
        logger.info(f"search query={query} results={len(results)}")
        return results
