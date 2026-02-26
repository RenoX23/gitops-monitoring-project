from flask import Flask
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import psutil
import time

app = Flask(__name__)

REQUEST_COUNT = Counter('app_request_count', 'Total request count', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency', ['endpoint'])

@app.route('/')
def home():
    start = time.time()
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    REQUEST_LATENCY.labels(endpoint='/').observe(time.time() - start)
    return {"status": "ok", "message": "GitOps Monitoring App Running"}

@app.route('/health')
def health():
    REQUEST_COUNT.labels(method='GET', endpoint='/health').inc()
    return {"status": "healthy"}

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/stress')
def stress():
    REQUEST_COUNT.labels(method='GET', endpoint='/stress').inc()
    total = sum(i*i for i in range(1000000))
    return {"status": "stress done", "result": total}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
