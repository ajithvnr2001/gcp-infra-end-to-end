from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx
import logging
import os
import time


logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title="API Gateway", version="1.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

CATALOG_URL = os.getenv("CATALOG_URL", "http://catalog-service:8000")
CART_URL = os.getenv("CART_URL", "http://cart-service:8001")
PAYMENT_URL = os.getenv("PAYMENT_URL", "http://payment-service:8002")
START_TIME = time.time()


async def request_json(method: str, url: str, timeout: float = 10.0, **kwargs):
    try:
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.request(method, url, **kwargs)
    except httpx.HTTPError as exc:
        logger.warning("Upstream request failed url=%s error=%s", url, exc)
        raise HTTPException(status_code=503, detail="Upstream service unavailable") from exc

    try:
        payload = response.json()
    except ValueError:
        payload = {"detail": response.text or "Invalid upstream response"}

    if response.is_error:
        detail = payload["detail"] if isinstance(payload, dict) and "detail" in payload else payload
        raise HTTPException(status_code=response.status_code, detail=detail)

    return payload


@app.get("/health")
def health():
    return {"status": "healthy", "uptime": round(time.time() - START_TIME, 2)}


@app.get("/ready")
async def ready():
    await request_json("GET", f"{CATALOG_URL}/health", timeout=3.0)
    await request_json("GET", f"{CART_URL}/health", timeout=3.0)
    await request_json("GET", f"{PAYMENT_URL}/health", timeout=3.0)
    return {"status": "ready"}


@app.get("/products")
async def get_products(category: str | None = None, limit: int = 20):
    params = {}
    if category:
        params["category"] = category
    if limit:
        params["limit"] = limit
    return await request_json("GET", f"{CATALOG_URL}/products", params=params)


@app.get("/products/{product_id}")
async def get_product(product_id: str):
    return await request_json("GET", f"{CATALOG_URL}/products/{product_id}")


@app.get("/cart/{user_id}")
async def get_cart(user_id: str):
    return await request_json("GET", f"{CART_URL}/cart/{user_id}")


@app.post("/cart/{user_id}/add")
async def add_to_cart(user_id: str, request: Request):
    body = await request.json()
    return await request_json("POST", f"{CART_URL}/cart/{user_id}/add", json=body)


@app.put("/cart/{user_id}/items/{product_id}")
async def update_cart_item(user_id: str, product_id: str, request: Request):
    body = await request.json()
    return await request_json("PUT", f"{CART_URL}/cart/{user_id}/items/{product_id}", json=body)


@app.delete("/cart/{user_id}/remove/{product_id}")
async def remove_from_cart(user_id: str, product_id: str):
    return await request_json("DELETE", f"{CART_URL}/cart/{user_id}/remove/{product_id}")


@app.delete("/cart/{user_id}/clear")
async def clear_cart(user_id: str):
    return await request_json("DELETE", f"{CART_URL}/cart/{user_id}/clear")


@app.post("/orders")
async def create_order(request: Request):
    body = await request.json()
    order = await request_json("POST", f"{PAYMENT_URL}/orders", timeout=30.0, json=body)

    user_id = body.get("user_id")
    if user_id:
        try:
            await request_json("DELETE", f"{CART_URL}/cart/{user_id}/clear")
        except HTTPException as exc:
            logger.warning(
                "Order created but cart clear failed user_id=%s status=%s",
                user_id,
                exc.status_code,
            )

    return order


@app.get("/orders/{order_id}")
async def get_order(order_id: str):
    return await request_json("GET", f"{PAYMENT_URL}/orders/{order_id}")


@app.get("/orders/user/{user_id}")
async def get_user_orders(user_id: str):
    return await request_json("GET", f"{PAYMENT_URL}/orders/user/{user_id}")
