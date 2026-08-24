# Service Catalog API on EKS

This repository deploys a stateless Flask API to Amazon EKS using Terraform, GitHub Actions, and Argo CD.

## API

| Endpoint | Purpose |
| --- | --- |
| `GET /` | API metadata |
| `GET /health` | Liveness check |
| `GET /ready` | Readiness check |
| `GET /api/v1/services` | Example service catalog entries |
| `POST /api/v1/services/validate` | Validates and normalizes a service definition |

## Local development

```powershell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest
bandit -r app -ll
python -m flask --app app.main run --host 0.0.0.0 --port 5000
```

## Container

```powershell
docker build -t service-catalog-api .
docker run --rm -p 5000:5000 service-catalog-api
```

The image runs Gunicorn as an unprivileged user. Kubernetes uses separate liveness and readiness probes with a restricted security context.
