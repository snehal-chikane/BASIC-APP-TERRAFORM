from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Flask running on EC2!"

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    # Listen on all interfaces so EC2 can access it
    app.run(host="0.0.0.0", port=5000)