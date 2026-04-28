# services/cart/tests/test_cart.py
from fastapi.testclient import TestClient
import importlib.util
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "main.py"
SPEC = importlib.util.spec_from_file_location("cart_service_main", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)

client = TestClient(MODULE.app)

def test_health():
    assert client.get("/health").status_code == 200

def test_empty_cart():
    r = client.get("/cart/user123")
    assert r.status_code == 200
    assert r.json()["items"] == []
    assert r.json()["total"] == 0
    assert r.json()["item_count"] == 0

def test_add_to_cart():
    r = client.post("/cart/user123/add", json={
        "product_id": "p1", "product_name": "Headphones",
        "price": 1999.0, "quantity": 2
    })
    assert r.status_code == 200
    assert r.json()["cart_size"] == 1
    assert r.json()["item_count"] == 2

def test_cart_total():
    r = client.get("/cart/user123")
    assert r.json()["total"] == 3998.0

def test_update_cart_item_quantity():
    r = client.put("/cart/user123/items/p1", json={"quantity": 1})
    assert r.status_code == 200
    assert r.json()["item_count"] == 1
    assert r.json()["total"] == 1999.0

def test_clear_cart():
    client.delete("/cart/user123/clear")
    r = client.get("/cart/user123")
    assert r.json()["items"] == []
