from flask import Flask, render_template, request

from .ip_service import get_client_ip

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get():
    client_ip = get_client_ip(request.environ)
    return render_template("index.html", public_ip=client_ip)