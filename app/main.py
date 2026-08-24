from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def hello():
    return "Hello World from AWS EKS! -- version 2\n"


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000) # nosec B104