import tkinter as tk
from src.models import EnvironmentModel
from src.controller import AgentController
from src.view import AgentView

if __name__ == "__main__":
    root = tk.Tk()
    
    # Inicializar componentes de la arquitectura
    model = EnvironmentModel(rows=10, cols=10)
    controller = AgentController(model)
    view = AgentView(root, model, controller)
    
    controller.set_view(view)
    
    root.mainloop()