# Cloud & DevOps Portfolio on EKS

A single-page portfolio site built with Flask and deployed to Amazon EKS using Docker, Terraform, GitHub Actions, and Argo CD.

The public site is available at [app.alffino.online](https://app.alffino.online).

## What is included

- Responsive portfolio landing page with project, skills, and contact sections
- Flask JSON endpoints for health, readiness, catalog data, and validation
- Gunicorn container running as an unprivileged user
- Kubernetes readiness and liveness probes with a restricted security context
- Terraform infrastructure for the VPC and EKS cluster
- GitHub Actions checks for pytest, Bandit, Docker, and Trivy
- GitOps delivery through Argo CD, including post-deploy verification and automated rollback

## Application routes

| Route | Purpose |
| --- | --- |
| `GET /` | Portfolio website |
| `GET /health` | Liveness probe |
| `GET /ready` | Readiness probe |
| `GET /api/v1` | API metadata and deployed version |
| `GET /api/v1/services` | Example service catalog data |
| `POST /api/v1/services/validate` | Validates a service definition |

## Run locally

Requires Python 3.12 or newer.

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest
python -m flask --app app.main run --host 0.0.0.0 --port 5000
```

Open `http://localhost:5000` in a browser.

To run the same application security scan used by CI:

```powershell
pip install bandit
bandit -r app -ll
```

## Run with Docker

```powershell
docker build -t cloud-portfolio .
docker run --rm -p 5000:5000 cloud-portfolio
```

The image uses Alpine Python and starts Gunicorn on port `5000` as the non-root `app` user.

## Deployment flow

1. Push a commit to `main`.
2. GitHub Actions runs pytest and Bandit.
3. The workflow builds the image and scans it with Trivy.
4. On success, it pushes an immutable image tagged with the commit SHA to Amazon ECR.
5. The Kubernetes deployment manifest is updated with that image tag.
6. Argo CD detects the manifest change and syncs it to EKS.
7. The workflow checks `/health` and `/api/v1`; if the deployment does not become healthy, it restores the prior image tag automatically.

## Repository layout

```text
app/                 Flask application, page template, and static assets
tests/               Pytest suite
k8s/                 Kubernetes deployment, service, and ingress manifests
argocd/              Argo CD application definition
terraform/           AWS VPC and EKS infrastructure
.github/workflows/   CI/CD and Terraform workflows
```

## Infrastructure configuration

Terraform inputs are documented in `terraform/terraform.tfvars.example`. Copy it to `terraform/terraform.tfvars`, set the required AWS values, then use the Terraform workflow or run Terraform from the `terraform/` directory.
