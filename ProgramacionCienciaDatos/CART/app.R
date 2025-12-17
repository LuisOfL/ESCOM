library(shiny)
library(tools) 
source("models/utils.R")
source("models/CART_functions.R")



ui <- fluidPage(
  includeCSS("www/style.css"), 
  # ---- Tabs ----
  tabsetPanel(
    id = "tabs",    
    
    # Inicio--------------------------------------------------------------------
    tabPanel(
      title = "Main",
      value = "1",
      fileInput("file1", "Carga el archivo .csv"),
      tableOutput("file1_head"), # Mostrar las primeras filas
      actionButton("btnPredecirID", "Predecir por ID", class = "btn-primary"),
      actionButton("btnPredecirFe", "Predecir por Características", class = "btn-primary")
    ),
    
    # Prediccion por ID (Originalmente 'Predecir Feature') ---------------------
    tabPanel(
      title = "Predecir por ID",
      value = "2",
      actionButton("btnReturn1_id", "Regresar"),
      h2("Predicción CART por ID"),
      
      textInput( 
        "id_input", 
        "Ingrese el ID a predecir", 
        placeholder = "Ejemplo: 844981"
      ), 
      
      actionButton("btnPredictID", "Predecir", class = "btn-success")
    ),
    
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "Predecir por Features",
      value = "2_1",
      actionButton("btnReturn1_fe", "Regresar"),
      h2("Predicción CART por Características"),
      
      # Los nombres de las características se actualizarán dinámicamente
      uiOutput("feature1_ui"), 
      uiOutput("feature2_ui"), 
      
      actionButton("btnPredictFe", "Predecir", class = "btn-success")
    ),
    
    # Resultados  --------------------------------------------------------------
    tabPanel(
      title = "Resultados",
      value = "3",
      actionButton("btnReturn2", "Regresar"),
      h2("Resultados de Predicción CART"),
      verbatimTextOutput("prediction_output"),
      plotOutput("model_plots") # Donde se mostrarán el árbol y el plano 2D
    )
  )
)




server <- function(input, output, session){
  
  # Variable reactiva para almacenar el dataframe cargado
  data_df <- reactiveVal(NULL)
  # Variable reactiva para almacenar las Top 2 features seleccionadas
  top_features <- reactiveVal(NULL)
  
  
  observeEvent(input$file1, {
    tryCatch({
      df <- leer_datos(input$file1)
      data_df(df)
      output$file1_head <- renderTable(head(df))
      
      # Ejecutar la selección de features una vez cargado el archivo
      ycol <- colnames(df)[2]
      df_noID <- df[, -1]
      es_regresion <- is.numeric(df[[ycol]])
      features <- seleccionar_top_features(df_noID, ycol, es_regresion)
      top_features(features)
      
    }, error = function(e) {
      showNotification(paste("Error al cargar o procesar el archivo:", e$message), type = "error")
      data_df(NULL)
      output$file1_head <- renderTable(NULL)
    })
  })
  
  
  output$feature1_ui <- renderUI({
    req(top_features()) 
    feature_name <- top_features()[1]
    textInput( 
      "feature1_val", 
      paste("Ingresa el valor para la característica:", feature_name), 
      placeholder = paste("Valor para", feature_name, "...")
    )
  })
  
  output$feature2_ui <- renderUI({
    req(top_features())
    feature_name <- top_features()[2]
    textInput( 
      "feature2_val", 
      paste("Ingresa el valor para la característica:", feature_name), 
      placeholder = paste("Valor para", feature_name, "...")
    )
  })
  
 
  observeEvent(input$btnPredecirID, {
    req(data_df()) # Solo si se han cargado datos
    updateTabsetPanel(session, "tabs", selected = "2")
  })
  
  observeEvent(input$btnPredecirFe, {
    req(data_df()) # Solo si se han cargado datos
    updateTabsetPanel(session, "tabs", selected = "2_1")
  })
  
  # Botones de Regreso (Corregidos)
  observeEvent(input$btnReturn1_id, {
    updateTabsetPanel(session, "tabs", selected = "1")
  })
  
  observeEvent(input$btnReturn1_fe, {
    updateTabsetPanel(session, "tabs", selected = "1")
  })
  
  observeEvent(input$btnReturn2, {
    updateTabsetPanel(session, "tabs", selected = "1") 
  })
  
  
  # Predicción por ID
  observeEvent(input$btnPredictID, {
    req(data_df())
    id_val <- as.character(input$id_input) 
    
    results <- predecir_por_id(data_df(), id_val)
    
    if (is.null(results)) {
      output$prediction_output <- renderPrint("Error: ID no encontrado en el dataset.")
      output$model_plots <- renderPlot(NULL)
      return()
    }
    
    # Mostrar resultados
    output$prediction_output <- renderPrint({
      cat("Variables usadas:", results$variables_usadas, "\n")
      cat("Clase Real:", results$clase_real, "\n")
      cat("Clase Predicha:", results$clase_predicha, "\n")
    })
    
    # La función 'predecir_por_id' ya genera el gráfico (par(mfrow))
    output$model_plots <- renderPlot({
      # Solo necesitamos que la función sea llamada aquí para que genere el gráfico
      predecir_por_id(data_df(), id_val) 
    }, res = 96) # res=96 para buena resolución en web
    
    updateTabsetPanel(session, "tabs", selected = "3")
  })
  
  # Predicción por Características
  observeEvent(input$btnPredictFe, {
    req(data_df(), top_features())
    
    val1 <- input$feature1_val
    val2 <- input$feature2_val
    
    results <- predecir_por_features(data_df(), val1, val2)
    
    if ("error" %in% names(results)) {
      output$prediction_output <- renderPrint(results$error)
      output$model_plots <- renderPlot(NULL)
      return()
    }
    
    # Mostrar resultados
    output$prediction_output <- renderPrint({
      cat("Variables usadas:", results$variables_usadas, "\n")
      cat("Valores ingresados:", results$variables_usadas[1], "=", val1, ";", results$variables_usadas[2], "=", val2, "\n")
      cat("Clase Predicha:", results$clase_predicha, "\n")
    })
    
    # Para este modo, solo se requiere el texto de predicción.
    # Si se quisiera generar el gráfico 2D, se necesitaría adaptar la función.
    output$model_plots <- renderPlot(NULL) 
    
    updateTabsetPanel(session, "tabs", selected = "3")
  })
  
}

shinyApp(ui, server)
