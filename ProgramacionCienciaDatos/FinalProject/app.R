library(shiny)

#Fronted
ui <- fluidPage(
  
  tabsetPanel(
    id = "tabs",    
    
    
    # Inicio--------------------------------------------------------------------
    
    tabPanel(
      title = "Inicio",
      value = "1",
      p(" 🔮 Sube el csv"),
      fileInput("file1", "Choose a File"),
      verbatimTextOutput("file1_contents"),
      p("Nota: La primer columna debe ser ID y la segunda la variable a predecir"),
      actionButton("Start", "Comenzar")
    ),
    
    
    #============================MODELOS========================================
    
    # KNN ----------------------------------------------------------------------
    
    tabPanel(
      title = "KNN",
      value = "2",
    ),
    
    # Naive Bayes --------------------------------------------------------------
    tabPanel(
      title = "Naive Bayes",
      value = "2_1",
    ),
    # CART ---------------------------------------------------------------------
    tabPanel(
      title = "CART",
      value = "2_2",
    ),
    # Regresion lineal  --------------------------------------------------------
    tabPanel(
      title = "Regresion lineal",
      value = "2_3",
    ),
    # Redes neuronales ---------------------------------------------------------
    tabPanel(
      title = "Redes neuronales",
      value = "2_3",
    ),
    # Random Forest ------------------------------------------------------------
    tabPanel(
      title = "Random Forest",
      value = "2_3",
    ),
    # GBoost -------------------------------------------------------------------
    tabPanel(
      title = "GBoost",
      value = "2_3",
    ),
    # Resultados  --------------------------------------------------------------
    tabPanel(
      title = "Resultados",
      value = "3",
      p('Resumen de resultados')
      
      
      
      
    )
  )
  
)


#Backend
server <- function(input, output, session) {
  #Logica de navegacion --------------------------------------------------------
  observeEvent(input$Start, {
    updateTabsetPanel(session, "tabs", selected = "3")
  })
  #-----------------------------------------------------------------------------
}

shinyApp(ui = ui, server = server)