from flask import Flask, request
from flask_sitemap import Sitemap

app = Flask(__name__)
ext = Sitemap(app)

@app.get("/")
def hello_world():
    return "Hello World!"

@app.get("/greet")
def greet_user():
    name = request.args.get("name", "Guest")
    return f"Hello, {name}!"
