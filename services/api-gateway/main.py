# services/api-gateway/main.py
# Single entry point — routes all traffic to downstream services
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx, os, logging, time

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"),
                    format="%(asctime)s %(levelname)s %(name)s %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(title="API Gateway", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

CATALOG_URL = os.getenv("CATALOG_URL", "http://catalog-service:8000")
CART_URL    = os.getenv("CART_URL",    "http://cart-service:8001")
PAYMENT_URL = os.getenv("PAYMENT_URL", "http://payment-service:8002")
START_TIME  = time.time()

@app.get("/health")
def health():
    return {"status": "healthy", "uptime": time.time() - START_TIME}

@app.get("/ready")
async def ready():
    # Gateway is ready only when ALL downstream services are healthy
    async with httpx.AsyncClient(timeout=3.0) as client:
        try:
            await client.get(f"{CATALOG_URL}/health")
            await client.get(f"{CART_URL}/health")
            await client.get(f"{PAYMENT_URL}/health")
        except Exception as e:
            logger.warning(f"Downstream not ready: {e}")
            raise HTTPException(status_code=503, detail="Downstream service unavailable")
    return {"status": "ready"}

@app.get("/products")
async def get_products(category: str = None, limit: int = 20):
    async with httpx.AsyncClient(timeout=10.0) as client:
        params = {}
        if category: params["category"] = category
        if limit:    params["limit"] = limit
        r = await client.get(f"{CATALOG_URL}/products", params=params)
        return r.json()

@app.get("/products/{product_id}")
async def get_product(product_id: str):
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(f"{CATALOG_URL}/products/{product_id}")
        if r.status_code == 404:
            raise HTTPException(status_code=404, detail="Product not found")
        return r.json()

@app.get("/cart/{user_id}")
async def get_cart(user_id: str):
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(f"{CART_URL}/cart/{user_id}")
        return r.json()

@app.post("/cart/{user_id}/add")
async def add_to_cart(user_id: str, request: Request):
    body = await request.json()
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.post(f"{CART_URL}/cart/{user_id}/add", json=body)
        return r.json()

@app.post("/orders")
async def create_order(request: Request):
    body = await request.json()
    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.post(f"{PAYMENT_URL}/orders", json=body)
        return r.json()

@app.get("/orders/{order_id}")
async def get_order(order_id: str):
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get(f"{PAYMENT_URL}/orders/{order_id}")
        if r.status_code == 404:
            raise HTTPException(status_code=404, detail="Order not found")
        return r.json()
