import random
import math
import time
import threading

class AgentController:
    def __init__(self, model):
        self.model = model
        self.is_running = False
        self.view_ref = None

    def set_view(self, view_obj):
        self.view_ref = view_obj

    def start(self):
        if not self.model.mothership_pos or not self.model.agent_pos:
            return False
        if self.is_running:
            return True
        self.is_running = True
        threading.Thread(target=self._reactive_agent_loop, daemon=True).start()
        return True

    def stop(self):
        self.is_running = False

    def _reactive_agent_loop(self):
        while self.is_running:
            r, c = self.model.agent_pos
            
            # Regla 1: if detect sample then pick up sample[cite: 13]
            if self.model.grid[r][c] == 3 and not self.model.carrying_sample:
                self.model.grid[r][c] = 0
                self.model.carrying_sample = True
                if self.view_ref:
                    self.view_ref.update_status_safe(
                        f"Estado: ¡Muestra detectada y recogida! | Muestras: {self.model.samples_collected} | Cargando: Sí"
                    )
                time.sleep(0.4)
                continue

            # Regla 2: if carrying samples & at mothership then drop samples[cite: 13]
            if self.model.carrying_sample and self.model.agent_pos == self.model.mothership_pos:
                self.model.carrying_sample = False
                self.model.samples_collected += 1
                if self.view_ref:
                    self.view_ref.update_status_safe(
                        f"Estado: Muestra entregada en la base. | Muestras: {self.model.samples_collected} | Cargando: No"
                    )
                time.sleep(0.4)
                continue

            directions = [(-1, 0), (1, 0), (0, -1), (0, 1)] # Norte, Sur, Oeste, Este[cite: 13]
            valid_moves = []

            for dr, dc in directions:
                nr, nc = r + dr, c + dc
                if 0 <= nr < self.model.rows and 0 <= nc < self.model.cols:
                    # Sensor de obstáculos: Verificar celdas transitables != 2[cite: 13]
                    if self.model.grid[nr][nc] != 2:
                        valid_moves.append((nr, nc))

            if not valid_moves:
                time.sleep(0.3)
                continue

            chosen_next_pos = None

            # Regla 3: if carrying samples & not at base then travel up gradient[cite: 13]
            if self.model.carrying_sample:
                best_dist = float('inf')
                for move in valid_moves:
                    dist = math.sqrt((move[0] - self.model.mothership_pos[0])**2 + (move[1] - self.model.mothership_pos[1])**2)
                    if dist < best_dist:
                        best_dist = dist
                        chosen_next_pos = move
            else:
                # Regla 4: if true then move randomly[cite: 13]
                chosen_next_pos = random.choice(valid_moves)

            if chosen_next_pos:
                self.model.agent_pos = list(chosen_next_pos)

            if self.view_ref:
                self.view_ref.update_ui_safe()
            time.sleep(0.35)