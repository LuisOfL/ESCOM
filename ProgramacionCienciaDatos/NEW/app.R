library(shiny)
library(class)
library(caret)
library(leaps)
library(FSelector)
library(FSelectorRcpp)
source("models/knn_utils.R") 
source("models/knn_normal.R")
source("models/knn_forward.R")
source("models/knn_chi2.R")
source("models/knn_interseccion.R")

ui <- fluidPage(
  includeCSS("www/styles2.css"), 
  tabsetPanel(
    id = "nav_panel",
    
    #----------------------------------------------------------------------------------------------------
    tabPanel("main", value = "page1", 
             div(
               h2("🔮 Predicciones con KNN", style = "color: white;"),
               actionButton("Start", "Comenzar")
             )
    ),
    #----------------------------------------------------------------------------------------------------
    tabPanel("knn", value = "page2", 
             div(
               actionButton("Back", "Regresar al Menú"),
               
               # Opciones
               selectInput( 
                 "select", 
                 "Select options below:", 
                 list("KNN (Todas las feactures)" = "1A", 
                      "KNN Chi2" = "1B",
                      "KNN Forward" = "1C",
                      "KNN Interseccion" = "1D") 
               ), 
               
               
               # Cargar archivos
               fileInput("data_file", 
                         "Selecciona un archivo CSV:",
                         multiple = FALSE, 
                         accept = c(".csv") # Solo CSV para simplicidad
               ),
               
               
               # Texto para ID
               textInput( 
                 "input_id", 
                 "Ingresa el ID del registro a predecir", 
                 placeholder = "Ingresa el ID..."
               ), 
               
               
               # Texto para K
               textInput( 
                 "input_k", 
                 "Ingresa el valor de K", 
                 placeholder = "Ingresa el valor de k (Impar preferiblemente)..."
               ), 
               
               
               # Boton para predecir
               actionButton("predecir", "Predecir")
             )
    )
  ),
  
  
  tags$style(HTML("
         .nav-tabs { display: none; }
     "))
)

## --------------------------------------------------
## DEFINICIÓN DEL SERVIDOR (SERVER)
## --------------------------------------------------

server <- function(input, output, session) {
  
  #  Lógica de Navegación 
  observeEvent(input$Start, {
    updateTabsetPanel(session, "nav_panel", selected = "page2")
  })
  
  observeEvent(input$Back, {
    updateTabsetPanel(session, "nav_panel", selected = "page1")
  })
  
  
  # ⚙️ Lógica de Predicción k-NN
  observeEvent(input$predecir, {
    
    # 1. Validaciones iniciales
    archivo_cargado <- input$data_file
    if (is.null(archivo_cargado)) {
      showNotification("Por favor, sube un archivo CSV.", type = "error")
      return()
    }
    
    data_path <- archivo_cargado$datapath
    id_val <- as.numeric(input$input_id)
    k_val <- as.integer(input$input_k)
    
    if (is.na(id_val)) {
      showNotification("Ingresa un valor de ID válido y numérico.", type = "error")
      return()
    }
    if (is.na(k_val) || k_val <= 0) {
      showNotification("Ingresa un valor de K válido y positivo.", type = "error")
      return()
    }
    
    # 2. Ejecución Condicional
    metodo_seleccionado <- input$select
    funcion_a_llamar <- NULL
    metodo_nombre <- ""
    
    if (metodo_seleccionado == "1A") {
      funcion_a_llamar <- knn_normal_simple
      metodo_nombre <- "KNN (Todas las features)"
    } else if (metodo_seleccionado == "1B") {
      funcion_a_llamar <- knn_chi2_simple
      metodo_nombre <- "KNN (Chi-cuadrado)"
    } else if (metodo_seleccionado == "1C") {
      funcion_a_llamar <- knn_forward_simple
      metodo_nombre <- "KNN (Forward Selection)"
    } else if (metodo_seleccionado == "1D") {
      funcion_a_llamar <- knn_interseccion_simple
      metodo_nombre <- "KNN (Intersección Chi2/Forward)"
    } else {
      showNotification("Método no implementado o no válido.", type = "warning")
      return()
    }
    
    # 3. Llamada a la función y manejo de errores
    tryCatch({
      resultado <- funcion_a_llamar(id = id_val, k = k_val, data = data_path)
      
      # 4. Mostrar el resultado (con texto negro)
      
      features_usadas_texto <- if (length(resultado$features_usadas) > 0) {
        paste(resultado$features_usadas, collapse = ", ")
      } else {
        "No hay características variables disponibles."
      }
      
      showModal(modalDialog(
        title = tags$span(paste("Resultado:", metodo_nombre), style = "color: black;"),
        
        tags$b(tags$span(paste("ID Predicho:", resultado$id), style = "color: black;")),
        tags$br(),
        tags$b(tags$span(paste("K Usado:", resultado$k_usado), style = "color: black;")),
        tags$hr(),
        tags$b(tags$span(paste("Predicción k-NN:", resultado$prediccion_knn), style = "color: black;")),
        tags$p(tags$span(paste("Clase Real (en el dataset):", resultado$clase_real), style = "color: black;")),
        tags$br(),
        tags$p(tags$span(paste("Características Usadas:", features_usadas_texto), style = "color: black;")),
        
        footer = modalButton("Cerrar")
      ))
      
    }, error = function(e) {
      showNotification(paste("Error en", metodo_nombre, ":", e$message), type = "error", duration = 8)
    })
  })
}

shinyApp(ui = ui, server = server)