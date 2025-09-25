library(shiny)
library(ggplot2)
library(gganimate)
library(gifski)

# --- Función método de la falsa posición ---
false_position_method <- function(f, a, b, tol = 1e-5, max_iter = 20) {
  steps <- data.frame(iter = 0, a = a, b = b,
                      x_new = a - f(a)*(b-a)/(f(b)-f(a)), y_new = f(a - f(a)*(b-a)/(f(b)-f(a))))
  
  for(i in 1:max_iter) {
    fa <- f(a)
    fb <- f(b)
    x_new <- a - fa*(b-a)/(fb - fa)
    y_new <- f(x_new)
    
    steps <- rbind(steps, data.frame(iter = i, a = a, b = b, x_new = x_new, y_new = y_new))
    
    if(abs(y_new) < tol) break
    if(fa * y_new < 0) {
      b <- x_new
    } else {
      a <- x_new
    }
  }
  steps
}

# --- Función para crear líneas verticales en los extremos ---
false_position_lines <- function(steps) {
  lines <- data.frame()
  for(i in 1:nrow(steps)) {
    lines <- rbind(lines,
                   data.frame(iter = steps$iter[i], x = steps$a[i], y0 = 0, y1 = steps$y_new[i]),
                   data.frame(iter = steps$iter[i], x = steps$b[i], y0 = 0, y1 = steps$y_new[i])
    )
  }
  lines
}

# --- UI ---
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {background-color: #1e1e2f; color: #e0e0e0; font-family: 'Segoe UI', sans-serif;}
      
      /* Botón azul con degradado */
      .btn {
        background: linear-gradient(135deg, #1e90ff 0%, #00bfff 100%);
        color: white;
        border-radius: 12px;
        border: none;
        padding: 10px 20px;
        font-weight: bold;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        transition: 0.3s;
      }
      .btn:hover {
        background: linear-gradient(135deg, #1c86ee 0%, #00a5ee 100%);
        transform: translateY(-2px);
      }
      
      .form-control {
        background-color: #2c2c3e;
        color: #e0e0e0;
        border: 1px solid #555;
        border-radius: 8px;
        padding: 6px 12px;
      }
      
      h2 {color: #ffffff; text-align: center; font-size: 2em; margin-bottom: 20px;}
      .sidebar .well {background-color: #2c2c3e; border-radius: 12px; padding: 15px;}
    "))
  ),
  
  titlePanel(h2("False Position Method Visualizer")),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("a", "Límite inferior a:", 0, step = 0.1),
      numericInput("b", "Límite superior b:", 5, step = 0.1),
      numericInput("tol", "Tolerancia:", 0.01, step = 0.001),
      numericInput("n_iter", "Iteraciones:", 10, min = 1, max = 50),
      actionButton("go", "Ejecutar")
    ),
    mainPanel(
      imageOutput("anim")
    )
  )
)

# --- Server ---
server <- function(input, output) {
  observeEvent(input$go, {
    f <- function(x) x^2 - 4  # Ejemplo: raíz en x = 2
    
    steps <- false_position_method(f, input$a, input$b, tol = input$tol, max_iter = input$n_iter)
    lines_data <- false_position_lines(steps)
    
    x_range <- seq(min(steps$a)-1, max(steps$b)+1, length.out = 300)
    fun_data <- data.frame(x = x_range, y = f(x_range))
    
    p <- ggplot(fun_data, aes(x, y)) +
      geom_line(color = "cyan", size = 1.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "white") +
      # Líneas verticales de los extremos
      geom_segment(data = lines_data, aes(x = x, xend = x, y = y0, yend = y1, frame = iter),
                   color = "orange", linetype = "dotted", size = 1) +
      # Puntos en los extremos
      geom_point(data = steps, aes(x = a, y = f(a), frame = iter), color = "red", size = 4) +
      geom_point(data = steps, aes(x = b, y = f(b), frame = iter), color = "red", size = 4) +
      # Punto calculado por falsa posición
      geom_point(data = steps, aes(x = x_new, y = y_new, frame = iter), color = "purple", size = 4) +
      labs(title = "Método de Falsa Posición", x = "x", y = "f(x)") +
      theme_minimal(base_size = 14) +
      theme(
        plot.background = element_rect(fill = "#1e1e2f"),
        panel.background = element_rect(fill = "#1e1e2f"),
        panel.grid.major = element_line(color = "#444444"),
        panel.grid.minor = element_line(color = "#333333"),
        axis.text = element_text(color = "white"),
        axis.title = element_text(color = "white")
      ) +
      transition_states(iter, transition_length = 2, state_length = 1) +
      ease_aes('cubic-in-out')
    
    anim_file <- tempfile(fileext = ".gif")
    animate(p, nframes = 120, fps = 10, width = 750, height = 450,
            renderer = gifski_renderer(anim_file))
    
    output$anim <- renderImage({
      list(src = anim_file, contentType = "image/gif")
    }, deleteFile = TRUE)
  })
}

shinyApp(ui, server)
