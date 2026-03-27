# services/payment/tests/test_payment.py
from fastapi.testclient import TestClient
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from main import app

client = TestClient(app)

def test_health():
    assert client.get("/health").status_code == 200

def test_create_order():
    r = client.post("/orders", json={
        "user_id": "user123",
        "items": [{"product_id": "p1", "product_name": "Headphones", "price": 1999.0, "quantity": 1}],
        "address": "123 MG Road, Bangalore",
        "payment_method": "razorpay"
    })
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "confirmed"
    assert data["total"] == 1999.0
    assert data["order_id"].startswith("ORD-")

def test_get_order():
    r = client.post("/orders", json={
        "user_id": "user456",
        "items": [{"product_id": "p2", "product_name": "Shoes", "price": 2499.0, "quantity": 2}],
        "address": "456 Anna Salai, Chennai",
        "payment_method": "razorpay"
    })
    order_id = r.json()["order_id"]
    r2 = client.get(f"/orders/{order_id}")
    assert r2.status_code == 200
    assert r2.json()["order_id"] == order_id

def test_order_not_found():
    assert client.get("/orders/INVALID").status_code == 404
