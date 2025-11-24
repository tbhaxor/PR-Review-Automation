from flask import Flask, request, make_response

app = Flask(__name__)

@app.get("/")
def hello_world():
    return "Hello World!"

@app.get("/greet")
def greet_user():
    name = request.args.get("name", "Guest")
    return f"Hello, {name}!"

@app.get("/sitemap")
def sitemap():
    links = []
    for rule in app.url_map.iter_rules():
        if rule.endpoint != "static":
            links.append(rule.rule)

    response = make_response(200, "\n".join(sorted(links)))
    response.headers['Content-Type'] = 'text/plain'

    return response