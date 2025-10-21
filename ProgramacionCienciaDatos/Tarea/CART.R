library(rpart)
library(rpart.plot)


datos <- read.csv("C:/Users/luigu/OneDrive/Escritorio/Tarea/ciencia_datos/dataset_punto_cruz.csv")

datos$Clase <- as.factor(datos$Clase)


# Entrenar modelo
modelo <- rpart(
  formula = Clase ~ .,      
  data = datos,
  method = "class",
  control = rpart.control(minsplit = 10, cp = 0.01, maxdepth = 5)
)


# Graficar árbol
rpart.plot(modelo, type = 2, extra = 104, under = TRUE,
           main = "Árbol de Clasificación - CART (rpart)")


# Nueva observación
nueva_observacion <- data.frame(
  x = 13,
  y = 4
)
# Predicción
clase_predicha <- predict(modelo, newdata = nueva_observacion, type = "class")
cat("La clase predicha es:", clase_predicha, "\n")
l = rpart.rules(modelo)
print(l)
