# Instalar librerías (solo la primera vez)
install.packages("rpart")
install.packages("rpart.plot")

# Cargar librerías
library(rpart)
library(rpart.plot)


datos <- read.csv("C:/Users/luigu/OneDrive/Escritorio/Tarea/ciencia_datos/dataset_punto_cruz.csv")

str(datos)
head(datos)


modelo <- rpart(
  formula = Clase ~ .,      # La variable objetivo es "Clase", el resto son predictores
  data = datos,
  method = "class",         # Clasificación
  control = rpart.control(
    minsplit = 10,          # Mínimo de datos por nodo para dividir
    cp = 0.01,              # Parámetro de complejidad (evita sobreajuste)
    maxdepth = 5            # Profundidad máxima
  )
)


rpart.plot(modelo, type = 2, extra = 104, under = TRUE,
           main = "Árbol de Clasificación - CART (rpart)")



predicciones <- predict(modelo, newdata = datos, type = "class")


matriz <- table(Real = datos$Clase, Predicho = predicciones)
print(matriz)


accuracy <- sum(diag(matriz)) / sum(matriz)
cat("Precisión del modelo:", accuracy, "\n")



printcp(modelo)    
plotcp(modelo)    


modelo_podado <- prune(modelo, cp = 0.02)
rpart.plot(modelo_podado, type = 2, extra = 104, under = TRUE,
           main = "Árbol Podado")
