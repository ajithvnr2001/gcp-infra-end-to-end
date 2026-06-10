# services/catalog/tests/test_catalog.py
from fastapi.testclient import TestClient
import importlib.util
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "main.py"
SPEC = importlib.util.spec_from_file_location("catalog_service_main", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)

client = TestClient(MODULE.app)

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
    r = client.get("/products?category=workspace")
    assert r.status_code == 200
    for p in r.json():
        assert p["category"] == "workspace"

def test_get_product():
    r = client.get("/products/p1")
    assert r.status_code == 200
    assert r.json()["id"] == "p1"

def test_get_product_not_found():
    r = client.get("/products/doesnotexist")
    assert r.status_code == 404

def test_search_products():
    r = client.get("/products/search/keyboard")
    assert r.status_code == 200
    assert len(r.json()) >= 1
