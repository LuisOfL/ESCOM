library(shiny)

#Fronted
ui <- fluidPage(
  tabsetPanel(
    id = "tabs",    
    
    
    # Inicio--------------------------------------------------------------------
    tabPanel(
      title = "Inicio",
      value = "1",
      
    ),
    
    
    #============================MODELOS========================================
    
    # Prediccion por ID (Originalmente 'Predecir Feature') ---------------------
    
    tabPanel(
      title = "KNN",
      value = "2",
    ),
    
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "Naive Bayes",
      value = "2_1",
    ),
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "CART",
      value = "2_2",
    ),
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "Regresion lineal",
      value = "2_3",
    ),
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "Redes neuronales",
      value = "2_3",
    ),
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "Random Forest",
      value = "2_3",
    ),
    # Prediccion por Features (Originalmente 'Predecir ID') --------------------
    tabPanel(
      title = "GBoost",
      value = "2_3",
    ),
    # Resultados  --------------------------------------------------------------
    tabPanel(
      title = "Resultados",
      value = "3",
    )
  )
  
)


#Backend
server <- function(input, output) {


}

shinyApp(ui = ui, server = server)
