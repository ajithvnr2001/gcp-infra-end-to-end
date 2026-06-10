# services/payment/tests/test_payment.py
from fastapi.testclient import TestClient
import importlib.util
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "main.py"
SPEC = importlib.util.spec_from_file_location("payment_service_main", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)

client = TestClient(MODULE.app)

def test_health():
    assert client.get("/health").status_code == 200

def test_create_order():
    r = client.post("/orders", json={
        "user_id": "user123",
        "items": [{"product_id": "p1", "product_name": "Headphones", "price": 1999.0, "quantity": 1}],
        "address": "123 MG Road, Bangalore",
        "payment_method": "razorpay",
        "customer_name": "Ajith Kumar"
    })
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "confirmed"
    assert data["total"] == 1999.0
    assert data["order_id"].startswith("ORD-")
    assert data["item_count"] == 1

def test_get_order():
    r = client.post("/orders", json={
        "user_id": "user456",
        "items": [{"product_id": "p2", "product_name": "Shoes", "price": 2499.0, "quantity": 2}],
        "address": "456 Anna Salai, Chennai",
        "payment_method": "razorpay",
        "customer_name": "Ajith Kumar"
    })
    order_id = r.json()["order_id"]
    r2 = client.get(f"/orders/{order_id}")
    assert r2.status_code == 200
    assert r2.json()["order_id"] == order_id

def test_get_user_orders():
    r = client.get("/orders/user/user456")
    assert r.status_code == 200
    assert r.json()["count"] >= 1

def test_order_not_found():
    assert client.get("/orders/INVALID").status_code == 404
