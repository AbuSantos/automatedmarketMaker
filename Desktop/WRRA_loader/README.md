# HTTP_loadBalancer.py
# for our http test: we designed a Flask application that listens on a specified route (in this case, /) and redirects incoming requests to one of the backend servers based on their weights using the Weighted Round Robin algorithm.
pip install Flask
pip show Flask
python your_script.py
curl http://localhost:5000/  #basic test: output is 127.0.0.1 - - [08/Oct/2023 15:31:14] "GET / HTTP/1.1" 302 
for i in {1..5}; do curl http://localhost:5000/; done             # sending multiple request

we extended the code to handled additional http_request 
        1. The /api/resource route is defined with support for both GET and POST HTTP methods using methods=['GET', 'POST'] in the @app.route decorator, it checks the HTTP method using request.method and handles GET and POST requests separately.
# curl -X POST http://localhost:5000/api/resource -H "Content-Type: application/json" -d '{"key": "value"}'


The /user/profile route is defined with support for both GET and POST HTTP methods using methods=['GET', 'POST'] in the @app.route decorator.

#  curl http://localhost:5000/user/profile
# curl -X POST http://localhost:5000/user/profile -H "Content-Type: application/json" -d '{"username": "new_username"}'



Access controls restrict access to certain routes or resources based on user authentication, roles, or other criteria. Flask-Security or Flask-Principal are popular extensions for implementing access control. 

#load_balancer function 
   """
    Load Balancer Route

    This route implements a simple weighted round-robin load balancing algorithm
    to distribute incoming requests among backend servers based on their weights.

    Algorithm:
    - Requests are redirected to backend servers in a round-robin fashion.
    - Servers with higher weights receive a proportionally higher number of requests.

    Returns:
    - Redirects the request to one of the backend servers.
    """


    # admin function 
    
        Admin Dashboard Route

        This route handles access to the admin dashboard, ensuring that only users with
        admin permissions can access it.

        Access Control:
        - Requires admin permissions; users without admin permissions receive a 403 Forbidden error.

        Returns:
        - Returns the admin dashboard page if the user has admin permissions.
        - Returns a 403 Forbidden error if the user does not have admin permissions.
    

    #exempt users
       """
    Exempt Users from Rate Limiting

    This function is used to determine whether a specific user or condition should be exempted
    from rate limiting. Rate limiting restricts the number of requests a user can make within
    a certain time frame.

    Exemption Criteria:
    - This function checks the user's User-Agent header to identify trusted bots.
    - If the User-Agent contains "trusted_bot," the function returns True, indicating exemption.
    - If no exemption criteria are met, the function returns False, indicating no exemption.

    Returns:
    - True if the user or condition is exempt from rate limiting.
    - False if the user or condition is not exempt from rate limiting.
    """