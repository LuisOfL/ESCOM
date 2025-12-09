library(shiny)

ui <- fluidPage(
  includeCSS("www/styles.css"),
  tabsetPanel(
    id = "nav_panel",
    
#----------------------------------------------------------------------------------------------------
    tabPanel("main", value = "page1", 
             div(
               h2("Menú principal", style = "color: white;"),
               actionButton("Start", "Comenzar")
             )
    ),
#----------------------------------------------------------------------------------------------------
    tabPanel("knn", value = "page2", 
             div(
               actionButton("Back_to_Main", "Regresar al Menú"),
               
               #Opciones
               selectInput( 
                 "select", 
                 "Select options below:", 
                 list("KNN (Todas las feactures)" = "1A", "KNN Chi2" = "1B",
                      "KNN Forward" = "1C","KNN Interseccion" = "1D") 
               ), 
               
               
               # Cargar archivos
               fileInput("data_file", 
                         "Selecciona un archivo CSV o Excel:",
                         multiple = FALSE, 
                         accept = c(".csv", ".xlsx", ".xls") 
               ),
               
               
               #Texto para ID
               textInput( 
                 "text", 
                 "Ingresa el ID", 
                 placeholder = "Ingresa el ID..."
               ), 
               
               
               #Texto para K
               textInput( 
                 "text", 
                 "Ingresa el valor de K", 
                 placeholder = "Ingresa el valor de k (Impar preferiblemente)..."
               ), 
               
               
               #Boton para predecir
               actionButton("predecir", "Predecir"), 
               
               
             )
    )
  ),
  

  tags$style(HTML("
        .nav-tabs { display: none; }
    "))
)


server <- function(input, output, session) {
  
  # 1. Observa el botón "Comenzar" y cambia a la página KNN (page2)
  observeEvent(input$Start, {
    updateTabsetPanel(session, "nav_panel", selected = "page2")
  })
  
  # 2. 💡 NUEVO OBSERVER para el botón de regreso
  observeEvent(input$Back_to_Main, {
    # Cambia la pestaña activa al valor 'page1' (Menú principal)
    updateTabsetPanel(session, "nav_panel", selected = "page1")
  })
  
}

shinyApp(ui = ui, server = server)
