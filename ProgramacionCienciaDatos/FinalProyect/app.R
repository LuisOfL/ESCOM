library(shiny)
library(shinythemes)
source("utils.R")
lapply(list.files("models", full.names = TRUE), source)




# UI ---------------------------------------------------------------------------
ui <- fluidPage(
  theme = shinytheme("darkly"),
  titlePanel("🔮 Predictor por: ID & Machine Learning"),
  
  sidebarLayout(
    sidebarPanel(
      p("1. Configuración de Datos"),
      fileInput("file1", "Subir archivo CSV", accept = ".csv"),
      helpText("La col 1 debe ser ID y la col 2 el Target."),
      hr(),
      
      p("2. Parámetros del Modelo"),
      selectInput("alg", "Seleccionar Algoritmo", 
                  choices = c("KNN", "Naive Bayes", "CART", "Regresión Lineal", "Redes Neuronales")),
      
      # Controles dinámicos según el modelo
      conditionalPanel(
        condition = "input.alg == 'KNN'",
        numericInput("k_val", "Vecinos (k)", value = 5, min = 1)
      ),
      conditionalPanel(
        condition = "input.alg == 'CART'",
        numericInput("cp_val", "Complejidad (CP)", value = 0.01, step = 0.01)
      ),
      conditionalPanel(
        condition = "input.alg == 'Redes Neuronales'",
        numericInput("size_val", "Nodos Capa Oculta", value = 5, min = 1),
        p(strong("Nota:"), " Se aplicará normalización automática para evitar errores numéricos.")
      ),
      
      hr(),
      p("3. Búsqueda Específica"),
      textInput("search_id", "Ingresar ID para predecir", placeholder = "Ej: 84458202"),
      
      actionButton("run_all", "Ejecutar Predicción", class = "btn-primary", width = "100%")
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel("Resultados", value = "res_tab",
                 br(),
                 h4("Predicción Individual por ID"),
                 wellPanel(
                   tableOutput("single_prediction")
                 ),
                 hr(),
                 h4("📊 Métricas Globales (Set de Prueba)"),
                 h3(textOutput("accuracy_text")),
                 tableOutput("full_results_table")
        ),
        tabPanel("Ayuda", 
                 p(),
                 p("Sube tu archivo y asegúrate de que el ID que buscas esté en la primera columna y la variable que 
                   quieres predecir este en la segunda."))
      )
    )
  )
)

# SERVER -----------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Procesamiento de datos y modelos
  results <- eventReactive(input$run_all, {
    req(input$file1)
    
    # Leer datos
    raw_df <- read.csv(input$file1$datapath)
    data_split <- split_ml(raw_df) 
    
    # Definir fórmula: Columna 2 es la variable a predecir, ignorando Columna 1 (ID)
    target_name <- colnames(raw_df)[2]
    id_name <- colnames(raw_df)[1]
    formula_ml <- as.formula(paste(target_name, "~ . -", id_name))
    
    
    output_model <- switch(input$alg,
                           "KNN"              = run_knn(data_split$train, data_split$test, input$k_val),
                           "Naive Bayes"      = run_bayes(data_split$train, data_split$test, formula_ml),
                           "CART"             = run_cart(data_split$train, data_split$test, formula_ml, input$cp_val),
                           "Regresión Lineal" = run_linear(data_split$train, data_split$test, formula_ml),
                           "Redes Neuronales" = run_nnet(data_split$train, data_split$test, formula_ml, input$size_val)
    )
    
    output_model$full_data <- data_split$full
    return(output_model)
  })
  
  # 1. Mostrar Accuracy
  output$accuracy_text <- renderText({
    req(results())
    paste("Precisión del Modelo:", round(results()$acc * 100, 2), "%")
  })
  
  # 2. Tabla de búsqueda por ID
  output$single_prediction <- renderTable({
    req(results(), input$search_id)
    
    full_df <- results()$full_data
    id_buscado <- as.character(input$search_id)
    
    # Filtrar la fila exacta por ID
    fila_id <- full_df[as.character(full_df[[1]]) == id_buscado, ]
    
    if (nrow(fila_id) == 0) {
      return(data.frame(Status = "ID no encontrado en el dataset cargado."))
    }
    
    # Predecir para esa fila específica
    target_col <- colnames(full_df)[2]
    formula_id <- as.formula(paste(target_col, "~ . -", colnames(full_df)[1]))
    
    # Re-ejecutamos la predicción solo para esta fila
    pred_val <- switch(input$alg,
                       "KNN"              = run_knn(results()$full_data, fila_id, input$k_val)$pred,
                       "Naive Bayes"      = run_bayes(results()$full_data, fila_id, formula_id)$pred,
                       "CART"             = run_cart(results()$full_data, fila_id, formula_id, input$cp_val)$pred,
                       "Regresión Lineal" = run_linear(results()$full_data, fila_id, formula_id)$pred,
                       "Redes Neuronales" = run_nnet(results()$full_data, fila_id, formula_id, input$size_val)$pred
    )
    
    data.frame(
      ID = id_buscado,
      Valor_Real = as.character(fila_id[[2]]),
      Prediccion = as.character(pred_val)
    )
  })
  
  # 3. Tabla de resultados generales (Set de prueba)
  output$full_results_table <- renderTable({
    req(results())
    data.frame(
      ID = results()$ids,
      Real = results()$real,
      Predicho = results()$pred
    )
  })
}

shinyApp(ui, server)