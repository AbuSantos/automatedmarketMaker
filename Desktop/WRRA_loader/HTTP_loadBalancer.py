from flask import Flask, redirect, request, jsonify
from flask_limiter import Limiter
from flask_principal import Principal, Permission


app = Flask(__name__)
# limiter = Limiter(app, key_func=lambda: request.remote_addr)
principal = Principal(app)
admin_permission = Permission()

# Defining the list of backend servers with their weights
backend_servers = [
    {"ip": "192.168.1.10", "weight": 3},
    {"ip": "192.168.1.11", "weight": 2},
    {"ip": "192.168.1.12", "weight": 1},
]

# Initializing variables for Weighted Round Robin
current_server = 0
current_weight = 0


@app.route("/")
def load_balancer():
    global current_server, current_weight
    # Choosing the next backend server based on Weighted Round Robin
    while True:
        current_server = (current_server + 1) % len(backend_servers)
        if current_server == 0:
            current_weight = max(backend_servers, key=lambda x: x["weight"])["weight"]
        if backend_servers[current_server]["weight"] >= current_weight:
            break

    selected_server = backend_servers[current_server]
    print(
        f"Selected Server: {selected_server['ip']}, Weight: {selected_server['weight']}"
    )
    return redirect(f"http://{selected_server['ip']}", code=302)


# Route handling logic for admin access
@app.route("/admin", methods=["GET"])
@admin_permission.require(http_exception=403)
def admin_dashboard():
    return "Admin Dashboard"


# Defining rate limiting rules
# @limiter.request_filter
def exempt_users():
    # exempting certain users or conditions from rate limiting
    user_agent = request.headers.get("User-Agent")
    if user_agent and "trusted_bot" in user_agent:
        # Exempt requests from a trusted bot
        return True
    return False


@app.route("/api/resource", methods=["GET", "POST"])
def resource():
    if request.method == "GET":
        # Handles GET requests to /api/resource
        # Implements logic to retrieve and return resource data
        return jsonify({"message": "GET request to /api/resource"})

    elif request.method == "POST":
        # Handles POST requests to /api/resource
        data = request.json  # Assuming the request contains JSON data
    # Implements logic to process and store the data
    # return jsonify({'message': 'POST request to /api/resource'})
    return jsonify({"message": "POST request to /api/resource", "data_received": data})


@app.route("/user/profile", methods=["GET", "POST"])
# @limiter.limit("5 per minute")
def profile():
    if request.method == "GET":
        # Handles GET requests to /user/profile
        # Implements logic to retrieve and return user profile data
        return jsonify({"message": "GET request to /user/profile"})

    elif request.method == "POST":
        # Handles POST requests to /user/profile
        data = request.json  # Assuming the request contains JSON data
        # Implements logic to update user profile data
    return jsonify({"message": "POST request to /user/profile", "data_received": data})


if __name__ == "__main__":
    app.run(debug=True)
