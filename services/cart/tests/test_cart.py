# services/cart/tests/test_cart.py
import pytest
from fastapi.testclient import TestClient
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from main import app

client = TestClient(app)

def test_health():
    assert client.get("/health").status_code == 200

def test_empty_cart():
    r = client.get("/cart/user123")
    assert r.status_code == 200
    assert r.json()["items"] == []
    assert r.json()["total"] == 0

def test_add_to_cart():
    r = client.post("/cart/user123/add", json={
        "product_id": "p1", "product_name": "Headphones",
        "price": 1999.0, "quantity": 2
    })
    assert r.status_code == 200
    assert r.json()["cart_size"] == 1

def test_cart_total():
    r = client.get("/cart/user123")
    assert r.json()["total"] == 3998.0

def test_clear_cart():
    client.delete("/cart/user123/clear")
    r = client.get("/cart/user123")
    assert r.json()["items"] == []
