library(shiny)

ui <- fluidPage(
  
  tags$style("body { background-color: #0d122b;
             background-image: radial-gradient( ellipse at center, #1a2550 0%, #0d122b 45% ),
             linear-gradient( 135deg,
                              #21287c 0%,
                              #0d122b 35%,
                              #0d122b 65%,
                              #16327c 100% );
             background-attachment: fixed;  
             background-size: cover;
             color: white; }"),
  
  
  
  # ---- Tabs ----
  tabsetPanel(
    id = "tabs",   
    
    tabPanel(
      title = "Menú",
      value = "main",   
      h2("Predice con KNN"),
      actionButton("Start", "Comenzar")
    ),
    
    tabPanel(
      title = "KNN",
      value = "knn",
      h2("Modelo KNN"),
      p("Aquí irá tu modelo KNN.")
    )
  )
  
)

server <- function(input, output, session){
  
  observeEvent(input$Start, {
    updateTabsetPanel(session, "tabs", selected = "knn")
  })
  
}

shinyApp(ui, server)
