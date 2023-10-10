# This algorithm distributes tasks to workers based on their weights.
# Its suitable for task allocation to workers efficiently, considering their different processing capacities.
# It calculates the Greatest Common Divisor (GCD) of weights to determine step size for task allocation,


class RoundRobinBalancer:
    def __init__(self, tasks):
        self.tasks = tasks
        self.current_index = 0
        self.current_weight = self.gcd_weights()
        self.max_weight = max(tasks, key=lambda x: x["weight"])["weight"]

    def gcd(self, a, b):
        while b:
            a, b = b, a % b
        return a

    def gcd_weights(self):
        gcd = self.tasks[0]["weight"]
        for task in self.tasks[1:]:
            gcd = self.gcd(gcd, task["weight"])
        return gcd

    def get_next_task(self):
        while True:
            self.current_index = (self.current_index + 1) % len(self.tasks)
            if self.current_index == 0:
                self.current_weight -= self.gcd_weights()
                if self.current_weight <= 0:
                    self.current_weight = self.max_weight
            if self.tasks[self.current_index]["weight"] >= self.current_weight:
                return self.tasks[self.current_index]
