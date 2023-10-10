from load_balancer import RoundRobinBalancer




tasks = [
    {"name": "Task1", "weight": 3},
    {"name": "Task2", "weight": 2},
    {"name": "Task3", "weight": 1},
]

balancer = RoundRobinBalancer(tasks)

# Simulate task allocation
for _ in range(10):
    task = balancer.get_next_task()
    print(f"Task allocated to {task['name']}")