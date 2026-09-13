import tkinter as tk
from tkinter import messagebox, ttk

class AgentView:
    def __init__(self, root, model, controller):
        self.root = root
        self.model = model
        self.controller = controller
        
        self.root.title("Práctica 01: Agentes Reactivos - ESCOM IPN")
        self.root.geometry("850x700")
        
        self.cell_size = 55
        self.selected_tool = tk.StringVar(value="mothership")
        
        self._setup_ui()
        self._set_default_map()

    def _setup_ui(self):
        control_frame = ttk.LabelFrame(self.root, text=" Configuración y Sensores (Agente Reactivo) ", padding=10)
        control_frame.pack(side=tk.TOP, fill=tk.X, padx=10, pady=10)

        ttk.Label(control_frame, text="Herramienta:").grid(row=0, column=0, padx=5, sticky="w")
        ttk.Radiobutton(control_frame, text="🏠 Nave Nodriza", variable=self.selected_tool, value="mothership").grid(row=0, column=1, padx=5)
        ttk.Radiobutton(control_frame, text="🤖 Robot", variable=self.selected_tool, value="agent").grid(row=0, column=2, padx=5)
        ttk.Radiobutton(control_frame, text="🧱 Obstáculo", variable=self.selected_tool, value="obstacle").grid(row=0, column=3, padx=5)
        ttk.Radiobutton(control_frame, text="💎 Muestra", variable=self.selected_tool, value="sample").grid(row=0, column=4, padx=5)
        ttk.Radiobutton(control_frame, text="🧹 Borrador", variable=self.selected_tool, value="eraser").grid(row=0, column=5, padx=5)

        btn_frame = ttk.Frame(control_frame)
        btn_frame.grid(row=1, column=0, columnspan=6, pady=10)

        ttk.Button(btn_frame, text="▶ Iniciar Ciclo Reactivo", command=self.start_simulation).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="⏹ Detener", command=self.stop_simulation).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="🔄 Reiniciar Mapa", command=self.reset_map).pack(side=tk.LEFT, padx=5)

        self.status_var = tk.StringVar(value="Estado: Esperando inicio... | Muestras recolectadas: 0 | Cargando muestra: No")
        status_bar = ttk.Label(self.root, textvariable=self.status_var, relief=tk.SUNKEN, anchor="w", padding=5)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)

        self.canvas = tk.Canvas(
            self.root,
            width=self.model.cols * self.cell_size,
            height=self.model.rows * self.cell_size,
            bg="#111827",
            highlightthickness=1,
            highlightbackground="#374151"
        )
        self.canvas.pack(pady=10)
        self.canvas.bind("<Button-1>", self.on_canvas_click)

    def _set_default_map(self):
        self.model.mothership_pos = [0, 0]
        self.model.agent_pos = [2, 2]
        self.model.grid[0][0] = 1
        self.model.grid[2][2] = 0
        for r, c in [[1, 2], [1, 3], [4, 4], [5, 4], [7, 7]]:
            self.model.grid[r][c] = 2
        for r, c in [[3, 3], [6, 2], [8, 8]]:
            self.model.grid[r][c] = 3
        self.draw_grid()

    def draw_grid(self):
        self.canvas.delete("all")
        for r in range(self.model.rows):
            for c in range(self.model.cols):
                x1 = c * self.cell_size
                y1 = r * self.cell_size
                x2 = x1 + self.cell_size
                y2 = y1 + self.cell_size

                fill_color = "#1f2937"
                text = ""

                val = self.model.grid[r][c]
                if [r, c] == self.model.mothership_pos:
                    fill_color = "#991b1b"
                    text = "🏠"
                elif [r, c] == self.model.agent_pos:
                    fill_color = "#1e40af"
                    text = "🤖"
                elif val == 2:
                    fill_color = "#4b5563"
                    text = "🧱"
                elif val == 3:
                    fill_color = "#d97706"
                    text = "💎"

                self.canvas.create_rectangle(x1, y1, x2, y2, outline="#374151", fill=fill_color, width=1)
                if text:
                    self.canvas.create_text(
                        x1 + self.cell_size / 2,
                        y1 + self.cell_size / 2,
                        text=text,
                        fill="white",
                        font=("Segoe UI Emoji", 20)
                    )

    def on_canvas_click(self, event):
        if self.controller.is_running:
            return
        c = event.x // self.cell_size
        r = event.y // self.cell_size

        if 0 <= r < self.model.rows and 0 <= c < self.model.cols:
            tool = self.selected_tool.get()
            if tool == "mothership":
                if self.model.mothership_pos:
                    self.model.grid[self.model.mothership_pos[0]][self.model.mothership_pos[1]] = 0
                self.model.mothership_pos = [r, c]
                self.model.grid[r][c] = 1
            elif tool == "agent":
                self.model.agent_pos = [r, c]
            elif tool == "obstacle":
                self.model.grid[r][c] = 2
            elif tool == "sample":
                self.model.grid[r][c] = 3
            elif tool == "eraser":
                if self.model.mothership_pos and self.model.mothership_pos == [r, c]:
                    self.model.mothership_pos = None
                self.model.grid[r][c] = 0
            self.draw_grid()

    def reset_map(self):
        self.controller.stop()
        self.model.reset()
        self.draw_grid()
        self.status_var.set("Estado: Mapa reiniciado.")

    def start_simulation(self):
        if not self.model.mothership_pos or not self.model.agent_pos:
            messagebox.showerror("Error", "Debe existir una Nave Nodriza y un Robot en el tablero.")
            return
        started = self.controller.start()
        if started:
            self.status_var.set("Estado: Simulación en ejecución (Ciclo Reactivo)...")

    def stop_simulation(self):
        self.controller.stop()
        self.status_var.set("Estado: Simulación detenida por el usuario.")

    def update_status_safe(self, text):
        self.root.after(0, lambda: self.status_var.set(text))

    def update_ui_safe(self):
        self.root.after(0, self.draw_grid)