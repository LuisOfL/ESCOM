library(shiny)
library(ggplot2)
library(gganimate)
library(gifski)

newton_geom <- function(f, df, x0, n_iter) {
  steps <- data.frame(iter = 0, x = x0, y = f(x0))
  for (i in 1:n_iter) {
    xi <- steps$x[i]
    yi <- steps$y[i]
    slope <- df(xi)
    x_new <- xi - yi/slope
    y_new <- f(x_new)
    steps <- rbind(
      steps,
      data.frame(iter = i, x = x_new, y = y_new)
    )
  }
  steps
}

tangent_data <- function(f, df, steps) {
  out <- data.frame()
  for (i in 1:(nrow(steps)-1)) {
    xi <- steps$x[i]
    yi <- steps$y[i]
    slope <- df(xi)
    x_seq <- seq(min(steps$x)-1, max(steps$x)+1, length.out = 50)
    y_seq <- yi + slope*(x_seq - xi)
    tmp <- data.frame(iter = i, x = x_seq, y = y_seq)
    out <- rbind(out, tmp)
  }
  out
}

# --- UI ---
ui <- fluidPage(
  # CSS para tema oscuro y botones azules redondeados
  tags$head(
    tags$style(HTML("
      body {background-color: #121212; color: #e0e0e0;}
      .well {background-color: #1e1e1e; border: none;}
      .btn {
        background-color: #1e90ff;  /* azul */
        color: white;
        border-radius: 12px;        /* bordes suavizados */
        border: none;
        padding: 8px 16px;
      }
      .btn:hover {
        background-color: #1c86ee;
      }
      .form-control {
        background-color: #1e1e1e; 
        color: #e0e0e0; 
        border: 1px solid #444;
        border-radius: 6px;
      }
    "))
  ),
  
  titlePanel("Visualización geométrica del método de Newton-Raphson"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("x0", "Valor inicial x0:", 1, step = 0.1),
      numericInput("n_iter", "Iteraciones:", 5, min = 1, max = 15),
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
    f <- function(x) x^2 - 2
    df <- function(x) 2*x
    
    steps <- newton_geom(f, df, input$x0, input$n_iter)
    tangs <- tangent_data(f, df, steps)
    
    x_range <- seq(min(steps$x)-1, max(steps$x)+1, length.out = 300)
    fun_data <- data.frame(x = x_range, y = f(x_range))
    
    p <- ggplot(fun_data, aes(x, y)) +
      geom_line(color = "cyan", linewidth = 1) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "white") +
      geom_segment(data = steps, aes(x = x, xend = x, y = 0, yend = y, frame = iter),
                   color = "orange", linetype = "dotted") +
      geom_point(data = steps, aes(x, y, frame = iter), color = "orange", size = 3) +
      geom_line(data = tangs, aes(x, y, group = iter, frame = iter), color = "magenta") +
      labs(title = "Método de Newton-Raphson", x = "x", y = "f(x)") +
      theme_minimal(base_size = 14) +
      theme(
        plot.background = element_rect(fill = "#121212"),
        panel.background = element_rect(fill = "#121212"),
        panel.grid.major = element_line(color = "#444444"),
        panel.grid.minor = element_line(color = "#333333"),
        axis.text = element_text(color = "white"),
        axis.title = element_text(color = "white"),
        plot.title = element_text(color = "white", hjust = 0.5)
      ) +
      transition_states(iter, transition_length = 2, state_length = 1) +
      ease_aes('cubic-in-out')
    
    anim_file <- tempfile(fileext = ".gif")
    animate(p, nframes = 100, fps = 10, width = 650, height = 450,
            renderer = gifski_renderer(anim_file))
    
    output$anim <- renderImage({
      list(src = anim_file, contentType = "image/gif")
    }, deleteFile = TRUE)
  })
}

shinyApp(ui, server)

