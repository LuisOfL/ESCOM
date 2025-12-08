library(shiny)
library(shinyjs)
library(class)    
library(FSelector) 
library(leaps)

# Cargar las funciones de cada archivo de algoritmo
source("resources/models/knn_normal.R") 
source("resources/models/knn_chi2.R") 
source("resources/models/knn_forward.R")
source("resources/models/knn_combined.R") 

# --------------------------------------------------------------------------
# --- UI para las Tarjetas de Carga y Búsqueda ---
# --------------------------------------------------------------------------

dataset_tools_ui <- div(
  fluidRow(
    style = "margin-top: 20px;",
    column(6,
           div(class = "dark-card",
               h4(icon("cloud-upload-alt"), " Cargar Dataset", style = "color: #a8b3e2;"),
               p(HTML("La **primera** columna será el ID, la **segunda** la Clase. (CSV/Excel)"), style = "color: #b3b3b3; font-size: 0.9em; margin-bottom: 20px;"),
               div(id = "upload_file_group",
                   fileInput(
                     inputId = "upload_file", label = div(
                       class = "upload-icon", icon("upload"), p("Arrastra o haz clic para subir", style = "font-size: 0.9em; margin: 5px 0 0 0;"),
                       p("csv, xlsx", style = "font-size: 0.8em; color: #4a5c8e;")),
                     multiple = FALSE, accept = c(".csv", ".xlsx")
                   )
               )
           )
    ),
    column(6,
           div(id = "search_by_id_card", class = "dark-card",
               h4(icon("search"), " Buscar por ID", style = "color: #a8b3e2;"),
               p("Ingresa el ID del registro a predecir", style = "color: #b3b3b3; font-size: 0.9em; margin-bottom: 20px;"),
               textInput(
                 inputId = "search_id_input", label = NULL, placeholder = "ID del registro (e.g., 42, 101, etc.)..."
               ),
               actionButton(
                 inputId = "search_button", label = " Buscar registro", icon = icon("search"),
                 style = "background-color: #6a5acd; border: none; color: white; border-radius: 8px;"
               )
           )
    )
  ),
  div(style = "text-align: center; margin-top: 30px;",
      h4(icon("magic"), " Realizar Predicción", style = "color: #b3b3e2;"),
      p(id = "status_message", "Carga un archivo para comenzar la predicción.", style = "color: #7b8dc6;"),
      h3(textOutput("prediction_output"), style = "color: #00c6ff; margin-top: 15px;")
  )
)

ui <- fluidPage(
  useShinyjs(), 
  includeCSS("www/styles.css"), # Asume que tienes un archivo de estilos
  
  div(style = "max-width: 1000px; margin: auto; padding: 20px;",
      tabsetPanel(
        id = "tabs",  
        tabPanel(
          title = "Main", value = "main",  h2("Predice con KNN"),
          div(style = "margin-top: 30px;", actionButton("Start", HTML("Comenzar &rsaquo;"), style = "background: linear-gradient(90deg, #00c6ff, #0072ff); border: none; color: white; font-size: 1.2em; padding: 10px 40px; border-radius: 8px;"))
        ),
        tabPanel(
          title = "KNN", value = "knn",
          selectInput("select", "Selecciona el algoritmo:", 
                      list("KNN normal" = "1", "KNN chi2" = "2", "KNN Fordward" = "3", "KNN Ponderado" = "4")), 
          dataset_tools_ui,
          div(style = "margin-top: 40px; text-align: center;", actionButton("Then", HTML("Predecir &rsaquo;"), style = "background: linear-gradient(90deg, #00c6ff, #0072ff); border: none; color: white; font-size: 1.2em; padding: 10px 40px; border-radius: 8px;"))
        )
      )
  )
)

# --------------------------------------------------------------------------
# --- Servidor (Lógica) ---
# --------------------------------------------------------------------------

server <- function(input, output, session){
  
  rv <- reactiveValues(data = NULL)
  
  observeEvent(input$Start, { updateTabsetPanel(session, "tabs", selected = "knn") })
  
  # 2. LÓGICA DE CARGA DE ARCHIVO (CON LIMPIEZA)
  observeEvent(input$upload_file, {
    file <- input$upload_file
    if (is.null(file)) {
      # Código para limpiar interfaz si no hay archivo
      # ...
      return()
    }
    
    tryCatch({
      # 1. Cargar datos
      data <- read.csv(file$datapath, header = TRUE, stringsAsFactors = FALSE)
      if (ncol(data) < 2) { stop("El CSV debe tener al menos dos columnas (ID y Clase).") }
      
      # 2. Renombrar las primeras dos columnas
      names(data)[1:2] <- c("ID", "Clase")
      
      required_cols <- c("ID", "Clase") 
      feature_cols <- names(data)[!names(data) %in% required_cols]
      
      # 3. Forzar conversión de características a numérico (Genera NAs en datos no numéricos)
      data[, feature_cols] <- lapply(data[, feature_cols], as.numeric)
      
      # 4. LIMPIEZA CRÍTICA: Eliminar filas con cualquier NA (Clave para Forward Selection)
      data_cleaned <- na.omit(data)
      
      # 5. Verificación después de la limpieza
      if (nrow(data_cleaned) < nrow(data)) {
        showNotification(paste0("Se eliminaron ", nrow(data) - nrow(data_cleaned), " filas con valores faltantes (NA)."), type = "warning")
      }
      
      if (nrow(data_cleaned) < 10) { # Condición de seguridad
        stop("Quedaron muy pocas filas después de la limpieza. Verifique sus datos.")
      }
      
      rv$data <- data_cleaned # Almacenar datos limpios
      
      shinyjs::enable("search_by_id_card")
      shinyjs::html(id = "status_message", html = paste0("Dataset '", file$name, "' cargado. Filas: ", nrow(rv$data)))
      shinyjs::runjs('document.getElementById("status_message").style.color = "#00c6ff";') 
      
    }, error = function(e) {
      rv$data <- NULL
      shinyjs::disable("search_by_id_card")
      shinyjs::html(id = "status_message", html = paste("ERROR:", e$message))
      shinyjs::runjs('document.getElementById("status_message").style.color = "red";') 
      output$prediction_output <- renderText("ERROR")
    })
  })
  
  # 3. LÓGICA DE PREDICCIÓN 
  observeEvent(input$Then | input$search_button, {
    
    req(rv$data, input$search_id_input)
    
    input_id <- as.numeric(input$search_id_input)
    
    # ... (validación de ID sin cambios) ...
    if (is.na(input_id)) {
      showNotification("El ID ingresado no es válido.", type = "error")
      output$prediction_output <- renderText("ID Inválido")
      return()
    }
    
    new_row <- rv$data[rv$data$ID == input_id, , drop = FALSE]
    
    if (nrow(new_row) == 0) {
      showNotification(paste("No se encontró el ID:", input_id), type = "warning")
      output$prediction_output <- renderText("ID NO ENCONTRADO")
      return()
    }
    
    prediction_result <- NULL
    
    tryCatch({
      # Usaremos una partición (train/test) similar a su script de consola
      # Se asume que k=5 y n_features=3 son parámetros correctos para su aplicación.
      
      if (input$select == "1") {
        prediction_result <- predict_knn_normal(rv$data, new_row, target_col = "Clase", k = 5)
        
      } else if (input$select == "2") {
        prediction_result <- predict_knn_chi2(rv$data, new_row, target_col = "Clase", k = 5, n_features = 10)
        
      } else if (input$select == "3") {
        prediction_result <- predict_knn_forward(rv$data, new_row, target_col = "Clase", k = 5, n_features = 10)
        
      } else if (input$select == "4") {
        prediction_result <- predict_knn_combined(rv$data, new_row, target_col = "Clase", k = 5, n_chi2 = 10, n_forward = 10)
        
      } else {
        output$prediction_output <- renderText("Selecciona un algoritmo.")
        return()
      }
      
      # Mostrar el resultado unificado
      feature_list <- paste(prediction_result$features, collapse = ", ")
      
      output$prediction_output <- renderText({
        paste0("Predicción (K=5): ", prediction_result$prediction, "\n",
               "Características usadas (", length(prediction_result$features), "): ", feature_list)
      })
      
      shinyjs::html(id = "status_message", html = paste("Predicción realizada para el ID:", input_id))
      shinyjs::runjs('document.getElementById("status_message").style.color = "#00c6ff";') 
      
    }, error = function(e) {
      # Muestra el error anterior de 'NA/NaN/Inf' o el que sea
      showNotification(paste("Error en el modelo:", e$message), type = "error")
      output$prediction_output <- renderText("ERROR DE MODELO")
      shinyjs::runjs('document.getElementById("status_message").style.color = "red";') 
    })
    
  })
  
  # Deshabilitar la búsqueda al inicio
  shinyjs::disable("search_by_id_card")
}

shinyApp(ui, server)