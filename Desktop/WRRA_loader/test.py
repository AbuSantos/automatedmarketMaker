import unittest
from load_balancer import RoundRobinBalancer
from HTTP_loadBalancer import app  # Import your Flask app
from flask import request
from flask.testing import FlaskClient

# class TestWeightedRoundRobinBalancer(unittest.TestCase):
#     def test_task_allocation(self):
#         tasks = [
#             {"name": "Task1", "weight": 3},
#             {"name": "Task2", "weight": 2},
#             {"name": "Task3", "weight": 1},
#         ]

#         balancer = RoundRobinBalancer(tasks)

#         # Test allocation of tasks
#         allocated_tasks = [balancer.get_next_task()["name"] for _ in range(10)]

#         # Assert that the allocated tasks follow the weighted round-robin pattern
#         expected_result = [
#             "Task1",
#             "Task1",
#             "Task2",
#             "Task1",
#             "Task3",
#             "Task1",
#             "Task2",
#             "Task1",
#             "Task1",
#             "Task2",
#         ]
#         self.assertEqual(allocated_tasks, expected_result)





class TestLoadBalancer(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.backend_servers = [
            {"ip": "192.168.1.10", "weight": 3},
            {"ip": "192.168.1.11", "weight": 2},
            {"ip": "192.168.1.12", "weight": 1},
        ]
        self.current_server = 0
        self.current_weight = 0

    def test_load_balancer(self):
        # Simulate multiple requests to the load balancer
        for _ in range(len(self.backend_servers)):
            response = self.app.get("/")
            self.assertEqual(response.status_code, 302)  # Ensure it redirects
            selected_server = self.backend_servers[self.current_server]
            expected_redirect_url = f"http://{selected_server['ip']}"
            self.assertEqual(response.location, expected_redirect_url)


if __name__ == "__main__":
    unittest.main()
