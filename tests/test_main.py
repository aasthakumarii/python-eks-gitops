import sys
sys.path.insert(0, ".")

from app.main import app
def test_hello():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert b"Hello World from AWS EKS!" in response.data


def test_health():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"status": "healthy"}