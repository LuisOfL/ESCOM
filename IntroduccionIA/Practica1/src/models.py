class EnvironmentModel:
    def __init__(self, rows=10, cols=10):
        self.rows = rows
        self.cols = cols
        self.grid = [[0 for _ in range(self.cols)] for _ in range(self.rows)]
        self.mothership_pos = None
        self.agent_pos = None
        self.carrying_sample = False
        self.samples_collected = 0

    def reset(self):
        self.grid = [[0 for _ in range(self.cols)] for _ in range(self.rows)]
        self.mothership_pos = [0, 0]
        self.agent_pos = [2, 2]
        self.grid[0][0] = 1
        self.samples_collected = 0
        self.carrying_sample = False