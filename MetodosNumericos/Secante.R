library(shiny)
library(ggplot2)
library(gganimate)
library(gifski)

secant_geom <- function(f, x0, x1, n_iter) {
  steps <- data.frame(iter = 0, x = x0, y = f(x0))
  steps <- rbind(steps, data.frame(iter = 1, x = x1, y = f(x1)))
  
  for (i in 2:n_iter) {
    x_prev <- steps$x[i-1]
    x_curr <- steps$x[i]
    y_prev <- steps$y[i-1]
    y_curr <- steps$y[i]
    
    x_new <- x_curr - y_curr * (x_curr - x_prev) / (y_curr - y_prev)
    y_new <- f(x_new)
    
    steps <- rbind(steps, data.frame(iter = i, x = x_new, y = y_new))
  }
  steps
}


secant_lines <- function(steps) {
  lines <- data.frame()
  for (i in 2:nrow(steps)) {
    x_seq <- seq(min(steps$x)-1, max(steps$x)+1, length.out = 50)
    slope <- (steps$y[i] - steps$y[i-1]) / (steps$x[i] - steps$x[i-1])
    intercept <- steps$y[i] - slope * steps$x[i]
    y_seq <- slope * x_seq + intercept
    tmp <- data.frame(iter = i, x = x_seq, y = y_seq)
    lines <- rbind(lines, tmp)
  }
  lines
}


secant_intersections <- function(steps) {
  inter <- data.frame()
  for (i in 2:nrow(steps)) {
    x_prev <- steps$x[i-1]
    x_curr <- steps$x[i]
    y_prev <- steps$y[i-1]
    y_curr <- steps$y[i]
    x_int <- x_curr - y_curr*(x_curr - x_prev)/(y_curr - y_prev)
    y_int <- 0
    inter <- rbind(inter, data.frame(iter = i, x = x_int, y = y_int))
  }
  inter
}

# --- UI ---
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {background-color: #121212; color: #e0e0e0;}
      .btn {background-color: #1e90ff; color: white; border-radius: 12px; border: none; padding: 10px 20px;}
      .btn:hover {background-color: #1c86ee;}
      .form-control {background-color: #1e1e1e; color: #e0e0e0; border: 1px solid #444; border-radius: 6px;}
      .well {background-color: #1e1e1e;}
      h2 {color: #ffffff;}
    "))
  ),
  titlePanel("Método de la Secante"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("x0", "Valor inicial x0:", 50, step = 1),
      numericInput("x1", "Valor inicial x1:", 70, step = 1),
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
    f <- function(x) (6/233)*x^2 - 56
    
    steps <- secant_geom(f, input$x0, input$x1, input$n_iter)
    sec_lines <- secant_lines(steps)
    intersections <- secant_intersections(steps)
    
    x_range <- seq(min(c(steps$x, intersections$x))-5, max(c(steps$x, intersections$x))+5, length.out = 300)
    fun_data <- data.frame(x = x_range, y = f(x_range))
    
    verticals <- data.frame()
    for(i in 1:nrow(intersections)) {
      verticals <- rbind(verticals, data.frame(iter = intersections$iter[i],
                                               x = intersections$x[i],
                                               y0 = 0, y1 = f(intersections$x[i])))
    }
    
    p <- ggplot(fun_data, aes(x, y)) +
      geom_line(color = "cyan", linewidth = 1) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "white") +
      geom_point(data = steps, aes(x, y, frame = iter), color = "orange", size = 3) +
      geom_line(data = sec_lines, aes(x, y, group = iter, frame = iter), color = "magenta") +
      geom_segment(data = verticals, aes(x = x, xend = x, y = y0, yend = y1, frame = iter),
                   color = "orange", linetype = "dotted") +
      labs(title = "Método de la Secante", x = "x", y = "y") +
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
    animate(p, nframes = 120, fps = 10, width = 700, height = 450,
            renderer = gifski_renderer(anim_file))
    
    output$anim <- renderImage({
      list(src = anim_file, contentType = "image/gif")
    }, deleteFile = TRUE)
  })
}

shinyApp(ui, server)
