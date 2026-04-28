from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
import logging
import os
import time
import uuid


logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Payment Service", version="1.1.0")
START_TIME = time.time()

# In-memory order store. Replace with Cloud SQL in real production.
orders: dict = {}


class OrderItem(BaseModel):
    product_id: str
    product_name: str
    price: float
    quantity: int = Field(gt=0)


class OrderRequest(BaseModel):
    user_id: str
    items: List[OrderItem]
    address: str = Field(min_length=10)
    payment_method: str = "razorpay"
    customer_name: str = Field(min_length=2)
    customer_email: Optional[str] = None


class OrderResponse(BaseModel):
    order_id: str
    user_id: str
    status: str
    total: float
    payment_status: str
    payment_method: str
    created_at: float
    address: str
    item_count: int


@app.get("/health")
def health():
    return {"status": "healthy", "uptime": round(time.time() - START_TIME, 2)}


@app.get("/ready")
def ready():
    return {"status": "ready"}


@app.post("/orders", response_model=OrderResponse)
def create_order(req: OrderRequest):
    if not req.items:
        raise HTTPException(status_code=400, detail="Order must include at least one item")

    order_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    total = sum(item.price * item.quantity for item in req.items)
    order = {
        "order_id": order_id,
        "user_id": req.user_id,
        "status": "confirmed",
        "total": total,
        "payment_status": "paid",
        "payment_method": req.payment_method,
        "created_at": time.time(),
        "items": [item.model_dump() for item in req.items],
        "address": req.address,
        "item_count": sum(item.quantity for item in req.items),
        "customer_name": req.customer_name,
        "customer_email": req.customer_email,
    }
    orders[order_id] = order

    logger.info(
        "order created order_id=%s user=%s total=%s payment_method=%s",
        order_id,
        req.user_id,
        total,
        req.payment_method,
    )
    return order


@app.get("/orders/{order_id}", response_model=OrderResponse)
def get_order(order_id: str):
    order = orders.get(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


@app.get("/orders/user/{user_id}")
def get_user_orders(user_id: str):
    user_orders = [order for order in orders.values() if order["user_id"] == user_id]
    return {"user_id": user_id, "orders": user_orders, "count": len(user_orders)}
