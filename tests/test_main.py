import pytest

from app.main import create_app


@pytest.fixture()
def client():
    app = create_app()
    app.config.update(TESTING=True)
    return app.test_client()


def test_index_renders_the_portfolio(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"Aastha Kumar" in response.data
    assert b"EKS GitOps" in response.data


def test_api_index_describes_the_api(client):
    response = client.get("/api/v1")
    assert response.status_code == 200
    assert response.json["name"] == "service-catalog-api"


def test_health_and_readiness_endpoints(client):
    assert client.get("/health").json == {"status": "healthy"}
    assert client.get("/ready").json == {"status": "ready"}


def test_lists_sample_services(client):
    response = client.get("/api/v1/services")
    assert response.status_code == 200
    assert response.json["count"] == 2
    assert response.json["services"][0]["name"] == "checkout-api"


def test_validates_a_service_definition(client):
    response = client.post("/api/v1/services/validate", json={"name": "orders-api", "owner": "commerce", "description": "Order processing.", "tags": ["Python", "API"]})
    assert response.status_code == 200
    assert response.json == {"valid": True, "service": {"name": "orders-api", "owner": "commerce", "description": "Order processing.", "tags": ["python", "api"]}}


def test_rejects_invalid_service_definition(client):
    response = client.post("/api/v1/services/validate", json={"name": "", "tags": "python"})
    assert response.status_code == 422
    assert response.json["valid"] is False
    assert set(response.json["errors"]) == {"name", "owner", "tags"}


def test_rejects_non_object_json(client):
    response = client.post("/api/v1/services/validate", json=["not", "an", "object"])
    assert response.status_code == 400
    assert response.json["error"]["message"] == "Request body must be a JSON object."
