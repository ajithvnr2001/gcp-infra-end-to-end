# services/catalog/tests/test_catalog.py
import pytest
from fastapi.testclient import TestClient
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from main import app

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "healthy"

def test_ready():
    r = client.get("/ready")
    assert r.status_code == 200

def test_list_products():
    r = client.get("/products")
    assert r.status_code == 200
    assert len(r.json()) > 0

def test_list_products_by_category():
    r = client.get("/products?category=electronics")
    assert r.status_code == 200
    for p in r.json():
        assert p["category"] == "electronics"

def test_get_product():
    r = client.get("/products/p1")
    assert r.status_code == 200
    assert r.json()["id"] == "p1"

def test_get_product_not_found():
    r = client.get("/products/doesnotexist")
    assert r.status_code == 404

def test_search_products():
    r = client.get("/products/search/shoes")
    assert r.status_code == 200
    assert len(r.json()) >= 1
