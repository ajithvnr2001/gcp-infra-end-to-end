# services/cart/main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict
import os, logging, time

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"),
                    format="%(asctime)s %(levelname)s %(name)s %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(title="Cart Service", version="1.0.0")
START_TIME = time.time()

# In-memory cart store keyed by user_id (use Redis in real prod)
carts: Dict[str, List[dict]] = {}

class CartItem(BaseModel):
    product_id: str
    product_name: str
    price: float
    quantity: int

class CartResponse(BaseModel):
    user_id: str
    items: List[CartItem]
    total: float

@app.get("/health")
def health():
    return {"status": "healthy", "uptime": time.time() - START_TIME}

@app.get("/ready")
def ready():
    return {"status": "ready"}

@app.get("/cart/{user_id}", response_model=CartResponse)
def get_cart(user_id: str):
    items = carts.get(user_id, [])
    total = sum(i["price"] * i["quantity"] for i in items)
    logger.info(f"Get cart user={user_id} items={len(items)} total={total}")
    return {"user_id": user_id, "items": items, "total": total}

@app.post("/cart/{user_id}/add")
def add_to_cart(user_id: str, item: CartItem):
    if user_id not in carts:
        carts[user_id] = []
    existing = next((i for i in carts[user_id] if i["product_id"] == item.product_id), None)
    if existing:
        existing["quantity"] += item.quantity
    else:
        carts[user_id].append(item.dict())
    logger.info(f"Added to cart user={user_id} product={item.product_id}")
    return {"message": "Item added", "cart_size": len(carts[user_id])}

@app.delete("/cart/{user_id}/remove/{product_id}")
def remove_from_cart(user_id: str, product_id: str):
    if user_id not in carts:
        raise HTTPException(status_code=404, detail="Cart not found")
    carts[user_id] = [i for i in carts[user_id] if i["product_id"] != product_id]
    return {"message": "Item removed"}

@app.delete("/cart/{user_id}/clear")
def clear_cart(user_id: str):
    carts[user_id] = []
    return {"message": "Cart cleared"}
