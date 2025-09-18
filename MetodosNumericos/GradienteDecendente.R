library(shiny)
library(ggplot2)
library(gganimate)
library(gifski)

gradient_descent_parabola <- function(a, b, c, x0, lr = 0.1, n_iter = 10) {
  f <- function(x) a*x^2 + b*x + c
  df <- function(x) 2*a*x + b
  
  steps <- data.frame(iter = 0, x = x0, y = f(x0), slope = df(x0))
  x_curr <- x0
  
  for(i in 1:n_iter) {
    grad <- df(x_curr)
    x_new <- x_curr - lr * grad
    y_new <- f(x_new)
    
    steps <- rbind(steps, data.frame(iter = i, x = x_new, y = y_new, slope = df(x_new)))
    x_curr <- x_new
  }
  steps
}

tangent_lines <- function(steps) {
  lines <- data.frame()
  for(i in 1:nrow(steps)) {
    xi <- steps$x[i]
    yi <- steps$y[i]
    slope <- steps$slope[i]
    
    x_seq <- seq(xi-2, xi+2, length.out = 50)
    y_seq <- yi + slope*(x_seq - xi)
    
    lines <- rbind(lines, data.frame(iter = steps$iter[i], x = x_seq, y = y_seq))
  }
  lines
}

# --- UI ---
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {background-color: #121212; color: #e0e0e0; font-family: 'Segoe UI', sans-serif;}
      .btn {
        background-color: #1e90ff;
        color: white;
        border-radius: 12px;
        border: none;
        padding: 12px 24px;
        font-weight: bold;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        transition: 0.3s;
      }
      .btn:hover {background-color: #1c86ee; transform: translateY(-2px);}
      .form-control {
        background-color: #1e1e1e;
        color: #e0e0e0;
        border: 1px solid #444;
        border-radius: 8px;
        padding: 6px 12px;
      }
      h2 {color: #ffffff; text-align: center; font-size: 2em; margin-bottom: 20px;}
      .well, .panel {background-color: #1e1e1e; border: none; box-shadow: 0 2px 6px rgba(0,0,0,0.5);}
    "))
  ),
  
  titlePanel(h2("Gradient Descent Visualizer")),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("x0", "Valor inicial x0:", 8, step = 0.1),
      numericInput("lr", "Learning rate:", 0.2, step = 0.01),
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
    a <- 1
    b <- -10
    c <- 20
    
    steps <- gradient_descent_parabola(a, b, c, input$x0, lr = input$lr, n_iter = input$n_iter)
    tangents <- tangent_lines(steps)
    
    x_range <- seq(min(steps$x)-2, max(steps$x)+2, length.out = 300)
    fun_data <- data.frame(x = x_range, y = a*x_range^2 + b*x_range + c)
    
    verticals <- data.frame()
    for(i in 1:nrow(steps)) {
      verticals <- rbind(verticals, data.frame(iter = steps$iter[i],
                                               x = steps$x[i],
                                               y0 = 0, y1 = steps$y[i]))
    }
    
    p <- ggplot(fun_data, aes(x, y)) +
      geom_line(color = "cyan", size = 1.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "white") +
      geom_point(data = steps, aes(x, y, frame = iter), color = "orange", size = 4) +
      geom_segment(data = verticals, aes(x = x, xend = x, y = y0, yend = y1, frame = iter),
                   color = "orange", linetype = "dotted", size = 0.8) +
      geom_line(data = tangents, aes(x, y, group = iter, frame = iter), color = "purple", size = 1) +
      labs(title = "", x = "x", y = "f(x)") +
      theme_minimal(base_size = 14) +
      theme(
        plot.background = element_rect(fill = "#121212"),
        panel.background = element_rect(fill = "#121212"),
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
