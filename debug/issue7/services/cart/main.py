from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, List, Optional
import logging
import os
import time


logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Cart Service", version="1.1.0")
START_TIME = time.time()

# In-memory cart store keyed by user_id. Replace with Redis for real production.
carts: Dict[str, List[dict]] = {}


class CartItem(BaseModel):
    product_id: str
    product_name: str
    price: float
    quantity: int = Field(gt=0)
    category: Optional[str] = None


class CartItemQuantityUpdate(BaseModel):
    quantity: int = Field(ge=0)


class CartResponse(BaseModel):
    user_id: str
    items: List[CartItem]
    total: float
    item_count: int


def build_cart_response(user_id: str) -> dict:
    items = carts.get(user_id, [])
    total = sum(item["price"] * item["quantity"] for item in items)
    item_count = sum(item["quantity"] for item in items)
    return {
        "user_id": user_id,
        "items": items,
        "total": total,
        "item_count": item_count,
    }


def get_existing_item(user_id: str, product_id: str) -> Optional[dict]:
    return next((item for item in carts.get(user_id, []) if item["product_id"] == product_id), None)


@app.get("/health")
def health():
    return {"status": "healthy", "uptime": round(time.time() - START_TIME, 2)}


@app.get("/ready")
def ready():
    return {"status": "ready"}


@app.get("/cart/{user_id}", response_model=CartResponse)
def get_cart(user_id: str):
    cart_state = build_cart_response(user_id)
    logger.info(
        "cart fetched user=%s items=%s total=%s",
        user_id,
        cart_state["item_count"],
        cart_state["total"],
    )
    return cart_state


@app.post("/cart/{user_id}/add")
def add_to_cart(user_id: str, item: CartItem):
    if user_id not in carts:
        carts[user_id] = []

    existing = get_existing_item(user_id, item.product_id)
    if existing:
        existing["quantity"] += item.quantity
        existing["price"] = item.price
        existing["product_name"] = item.product_name
        existing["category"] = item.category
    else:
        carts[user_id].append(item.model_dump())

    cart_state = build_cart_response(user_id)
    logger.info("item added user=%s product=%s quantity=%s", user_id, item.product_id, item.quantity)
    return {
        "message": "Item added",
        "cart_size": len(cart_state["items"]),
        **cart_state,
    }


@app.put("/cart/{user_id}/items/{product_id}", response_model=CartResponse)
def update_cart_item_quantity(user_id: str, product_id: str, update: CartItemQuantityUpdate):
    if user_id not in carts:
        raise HTTPException(status_code=404, detail="Cart not found")

    existing = get_existing_item(user_id, product_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Item not found")

    if update.quantity == 0:
        carts[user_id] = [item for item in carts[user_id] if item["product_id"] != product_id]
    else:
        existing["quantity"] = update.quantity

    logger.info("item quantity updated user=%s product=%s quantity=%s", user_id, product_id, update.quantity)
    return build_cart_response(user_id)


@app.delete("/cart/{user_id}/remove/{product_id}", response_model=CartResponse)
def remove_from_cart(user_id: str, product_id: str):
    if user_id not in carts:
        raise HTTPException(status_code=404, detail="Cart not found")

    carts[user_id] = [item for item in carts[user_id] if item["product_id"] != product_id]
    logger.info("item removed user=%s product=%s", user_id, product_id)
    return build_cart_response(user_id)


@app.delete("/cart/{user_id}/clear", response_model=CartResponse)
def clear_cart(user_id: str):
    carts[user_id] = []
    logger.info("cart cleared user=%s", user_id)
    return build_cart_response(user_id)
