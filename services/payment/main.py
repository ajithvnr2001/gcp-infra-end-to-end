# services/payment/main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import os, logging, time, uuid

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"),
                    format="%(asctime)s %(levelname)s %(name)s %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(title="Payment Service", version="1.0.0")
START_TIME = time.time()

# In-memory order store (use Cloud SQL in real prod)
orders: dict = {}

class OrderItem(BaseModel):
    product_id: str
    product_name: str
    price: float
    quantity: int

class OrderRequest(BaseModel):
    user_id: str
    items: List[OrderItem]
    address: str
    payment_method: str = "razorpay"

class OrderResponse(BaseModel):
    order_id: str
    user_id: str
    status: str
    total: float
    payment_status: str
    created_at: float

@app.get("/health")
def health():
    return {"status": "healthy", "uptime": time.time() - START_TIME}

@app.get("/ready")
def ready():
    return {"status": "ready"}

@app.post("/orders", response_model=OrderResponse)
def create_order(req: OrderRequest):
    order_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    total = sum(i.price * i.quantity for i in req.items)
    order = {
        "order_id": order_id,
        "user_id": req.user_id,
        "status": "confirmed",
        "total": total,
        "payment_status": "paid",     # In real code: call Razorpay API here
        "created_at": time.time(),
        "items": [i.dict() for i in req.items],
        "address": req.address,
    }
    orders[order_id] = order
    logger.info(f"Order created order_id={order_id} user={req.user_id} total={total}")
    return order

@app.get("/orders/{order_id}", response_model=OrderResponse)
def get_order(order_id: str):
    order = orders.get(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@app.get("/orders/user/{user_id}")
def get_user_orders(user_id: str):
    user_orders = [o for o in orders.values() if o["user_id"] == user_id]
    return {"user_id": user_id, "orders": user_orders, "count": len(user_orders)}
