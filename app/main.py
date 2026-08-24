"""A small, stateless service-catalog API for the EKS deployment."""

from __future__ import annotations

import os
from http import HTTPStatus
from typing import Any

from flask import Flask, jsonify, render_template, request
from werkzeug.exceptions import HTTPException

MAX_SERVICE_NAME_LENGTH = 80
MAX_OWNER_LENGTH = 80
MAX_DESCRIPTION_LENGTH = 280
MAX_TAGS = 10
MAX_TAG_LENGTH = 30


def create_app() -> Flask:
    """Create and configure the Flask application."""
    application = Flask(__name__)
    application.config["JSON_SORT_KEYS"] = False

    @application.get("/")
    def index() -> str:
        return render_template("index.html", version=os.getenv("APP_VERSION", "dev"))

    @application.get("/api/v1")
    def api_index() -> tuple[Any, int]:
        return jsonify({"name": "service-catalog-api", "version": os.getenv("APP_VERSION", "dev"), "endpoints": ["GET /health", "GET /api/v1/services", "POST /api/v1/services/validate"]}), HTTPStatus.OK

    @application.get("/health")
    def health() -> tuple[Any, int]:
        return jsonify({"status": "healthy"}), HTTPStatus.OK

    @application.get("/ready")
    def ready() -> tuple[Any, int]:
        return jsonify({"status": "ready"}), HTTPStatus.OK

    @application.get("/api/v1/services")
    def list_services() -> tuple[Any, int]:
        catalog = _catalog()
        return jsonify({"services": catalog, "count": len(catalog)}), HTTPStatus.OK

    @application.post("/api/v1/services/validate")
    def validate_service() -> tuple[Any, int]:
        payload = request.get_json(silent=True)
        if not isinstance(payload, dict):
            return _error("Request body must be a JSON object.", HTTPStatus.BAD_REQUEST)
        errors = _validate_service(payload)
        if errors:
            return jsonify({"valid": False, "errors": errors}), HTTPStatus.UNPROCESSABLE_ENTITY
        return jsonify({"valid": True, "service": _normalise_service(payload)}), HTTPStatus.OK

    @application.errorhandler(HTTPException)
    def handle_http_error(error: HTTPException) -> tuple[Any, int]:
        return _error(error.description, error.code or HTTPStatus.INTERNAL_SERVER_ERROR)

    @application.errorhandler(Exception)
    def handle_unexpected_error(_: Exception) -> tuple[Any, int]:
        application.logger.exception("Unhandled application error")
        return _error("An unexpected error occurred.", HTTPStatus.INTERNAL_SERVER_ERROR)

    return application


def _catalog() -> list[dict[str, Any]]:
    return [{"name": "checkout-api", "owner": "payments", "description": "Processes checkout requests.", "tags": ["python", "tier-1"]}, {"name": "notifications-worker", "owner": "platform", "description": "Delivers customer notifications.", "tags": ["worker", "events"]}]


def _validate_service(payload: dict[str, Any]) -> dict[str, str]:
    errors: dict[str, str] = {}
    _validate_text(payload, "name", MAX_SERVICE_NAME_LENGTH, errors, required=True)
    _validate_text(payload, "owner", MAX_OWNER_LENGTH, errors, required=True)
    _validate_text(payload, "description", MAX_DESCRIPTION_LENGTH, errors, required=False)
    tags = payload.get("tags", [])
    if not isinstance(tags, list) or any(not isinstance(tag, str) or not tag.strip() for tag in tags):
        errors["tags"] = "must be a list of non-empty strings"
    elif len(tags) > MAX_TAGS or any(len(tag.strip()) > MAX_TAG_LENGTH for tag in tags):
        errors["tags"] = f"must contain at most {MAX_TAGS} tags of {MAX_TAG_LENGTH} characters"
    return errors


def _validate_text(payload: dict[str, Any], field: str, maximum_length: int, errors: dict[str, str], *, required: bool) -> None:
    value = payload.get(field)
    if value is None and not required:
        return
    if not isinstance(value, str) or not value.strip():
        errors[field] = "is required and must be a non-empty string"
    elif len(value.strip()) > maximum_length:
        errors[field] = f"must be at most {maximum_length} characters"


def _normalise_service(payload: dict[str, Any]) -> dict[str, Any]:
    return {"name": payload["name"].strip(), "owner": payload["owner"].strip(), "description": payload.get("description", "").strip(), "tags": [tag.strip().lower() for tag in payload.get("tags", [])]}


def _error(message: str, status: int) -> tuple[Any, int]:
    return jsonify({"error": {"message": message, "status": status}}), status


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104
