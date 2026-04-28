from fastapi.testclient import TestClient
import importlib.util
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "main.py"
SPEC = importlib.util.spec_from_file_location("api_gateway_main", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)

client = TestClient(MODULE.app)


def test_get_products(monkeypatch):
    async def fake_request_json(method, url, timeout=10.0, **kwargs):
        assert method == "GET"
        assert url.endswith("/products")
        return [{"id": "p1", "name": "Astra Wireless Headphones"}]

    monkeypatch.setattr(MODULE, "request_json", fake_request_json)

    response = client.get("/products")
    assert response.status_code == 200
    assert response.json()[0]["id"] == "p1"


def test_create_order_clears_cart(monkeypatch):
    calls = []

    async def fake_request_json(method, url, timeout=10.0, **kwargs):
        calls.append((method, url, kwargs.get("json")))
        if method == "POST" and url.endswith("/orders"):
            return {
                "order_id": "ORD-TEST123",
                "user_id": "guest-123",
                "status": "confirmed",
                "total": 1999.0,
                "payment_status": "paid",
                "payment_method": "razorpay",
                "created_at": 1713520000.0,
                "address": "123 MG Road, Bangalore",
                "item_count": 1,
            }

        if method == "DELETE" and url.endswith("/cart/guest-123/clear"):
            return {
                "user_id": "guest-123",
                "items": [],
                "total": 0,
                "item_count": 0,
            }

        raise AssertionError(f"Unexpected gateway call: {method} {url}")

    monkeypatch.setattr(MODULE, "request_json", fake_request_json)

    response = client.post(
        "/orders",
        json={
            "user_id": "guest-123",
            "items": [
                {
                    "product_id": "p1",
                    "product_name": "Astra Wireless Headphones",
                    "price": 1999.0,
                    "quantity": 1,
                }
            ],
            "address": "123 MG Road, Bangalore",
            "payment_method": "razorpay",
            "customer_name": "Ajith Kumar",
        },
    )

    assert response.status_code == 200
    assert response.json()["order_id"] == "ORD-TEST123"
    assert any(method == "DELETE" and url.endswith("/cart/guest-123/clear") for method, url, _ in calls)


def test_get_user_orders(monkeypatch):
    async def fake_request_json(method, url, timeout=10.0, **kwargs):
        assert method == "GET"
        assert url.endswith("/orders/user/guest-123")
        return {"user_id": "guest-123", "orders": [], "count": 0}

    monkeypatch.setattr(MODULE, "request_json", fake_request_json)

    response = client.get("/orders/user/guest-123")
    assert response.status_code == 200
    assert response.json()["count"] == 0
