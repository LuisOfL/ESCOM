# CART_functions.R (CÓDIGO MEJORADO)

library(rpart)
library(rpart.plot)
library(FSelector)
library(MASS)


seleccionar_top_features <- function(df_noID, ycol, es_regresion) {
  predictores <- colnames(df_noID)[-1] # quitar Y
  
  if (!es_regresion) {
    # CLASIFICACIÓN (Chi-square)
    df_noID[[ycol]] <- as.factor(df_noID[[ycol]])
    scores <- chi.squared(as.formula(paste(ycol, "~ .")), df_noID)
    top2 <- rownames(scores)[order(scores$attr_importance, decreasing = TRUE)][1:2]
  } else {
    # REGRESIÓN (Forward - AIC)
    f <- as.formula(paste(ycol, "~ 1"))
    full <- as.formula(paste(ycol, "~", paste(predictores, collapse = "+")))
    modelo_forward <- stepAIC(lm(f, df_noID), scope = full, direction = "forward", trace = FALSE)
    top2 <- names(modelo_forward$coefficients)[-1][1:2]
  }
  return(top2)
}
 
predecir_por_id <- function(df, id) {
  ids <- df[,1]
  ycol <- colnames(df)[2]
  target <- df[[ycol]]
  
  index <- which(ids == id)
  if (length(index) == 0) return(NULL)
  
  es_regresion <- is.numeric(target)
  metodo <- if(es_regresion) "anova" else "class"
  df_noID <- df[, -1]
  
  # Seleccionar features
  top2 <- seleccionar_top_features(df_noID, ycol, es_regresion)
  x1 <- top2[1]
  x2 <- top2[2]
  
  # Preparar la variable objetivo como factor si es clasificación
  if (!es_regresion) {
    df_noID[[ycol]] <- as.factor(df_noID[[ycol]])
    # **NUEVO:** Almacenar los niveles del factor para la traducción
    class_levels <- levels(df_noID[[ycol]])
  }
  
  # Entrenar modelo
  formula <- as.formula(paste(ycol, "~", x1, "+", x2))
  modelo <- rpart(formula, data = df_noID, method = metodo)
  
  # Predicción
  tipo_pred <- if(es_regresion) "vector" else "class"
  pred <- predict(modelo, newdata = df_noID[index,], type = tipo_pred)
  
  # **NUEVO:** Mapear la predicción a la etiqueta de clase (M/B)
  if (!es_regresion) {
    pred_etiqueta <- as.character(pred) # Convertir el factor predicho a caracter
    clase_real_etiqueta <- as.character(target[index]) # Clase real como caracter
  } else {
    pred_etiqueta <- pred
    clase_real_etiqueta <- target[index]
  }
  
  # Preparar gráficos
  par(mfrow = c(1, 2))
  
  # Gráfico 1: Árbol
  # Se añade 'extra=101' para mostrar la etiqueta de la clase y la probabilidad
  rpart.plot(modelo, main = "Árbol CART", extra = 101) 
  
  # Gráfico 2: Particiones 2D
  x1_seq <- seq(min(df_noID[[x1]]), max(df_noID[[x1]]), length.out = 200)
  x2_seq <- seq(min(df_noID[[x2]]), max(df_noID[[x2]]), length.out = 200)
  grid <- expand.grid(x1_seq, x2_seq)
  colnames(grid) <- c(x1, x2)
  pred_grid <- predict(modelo, newdata = grid, type = tipo_pred)
  
  # Si es clasificación, usamos los niveles para colorear
  if (!es_regresion) {
    pred_colores <- as.numeric(pred_grid) # Obtiene 1, 2, etc.
    puntos_colores <- as.numeric(df_noID[[ycol]]) + 1 # +1 para evitar el color 1 (negro)
  } else {
    pred_colores <- as.numeric(cut(pred_grid, breaks = 20)) # Para regresión
    puntos_colores <- "black"
  }
  
  plot(grid[[x1]], grid[[x2]], 
       col = pred_colores,
       pch = 15, cex = 0.6,
       xlab = x1, ylab = x2,
       main = "Particiones CART en plano 2D")
  
  points(df_noID[[x1]], df_noID[[x2]], 
         col = puntos_colores,
         pch = 19)
  
  par(mfrow = c(1, 1)) # Resetear layout
  
  return(list(
    clase_real = clase_real_etiqueta,
    clase_predicha = pred_etiqueta,
    variables_usadas = top2,
    modelo = modelo
  ))
}




predecir_por_features <- function(df, val1, val2) {
  ycol <- colnames(df)[2]
  target <- df[[ycol]]
  es_regresion <- is.numeric(target)
  metodo <- if(es_regresion) "anova" else "class"
  df_noID <- df[, -1]
  
  # Seleccionar features
  top2 <- seleccionar_top_features(df_noID, ycol, es_regresion)
  x1 <- top2[1]
  x2 <- top2[2]
  
  # Preparar la variable objetivo como factor si es clasificación
  if (!es_regresion) {
    df_noID[[ycol]] <- as.factor(df_noID[[ycol]])
    # **NUEVO:** Almacenar los niveles del factor para la traducción
    class_levels <- levels(df_noID[[ycol]])
  }
  
  # Entrenar modelo
  formula <- as.formula(paste(ycol, "~", x1, "+", x2))
  modelo <- rpart(formula, data = df_noID, method = metodo)
  
  # Crear nuevo dataframe de predicción
  val1_num <- as.numeric(val1)
  val2_num <- as.numeric(val2)
  if (is.na(val1_num) || is.na(val2_num)) {
    return(list(error = "Los valores de las características deben ser numéricos."))
  }
  
  nueva_data <- data.frame(val1_num, val2_num)
  colnames(nueva_data) <- c(x1, x2)
  
  # Predicción
  tipo_pred <- if(es_regresion) "vector" else "class"
  pred <- predict(modelo, newdata = nueva_data, type = tipo_pred)
  
  # **NUEVO:** Mapear la predicción a la etiqueta de clase (M/B)
  if (!es_regresion) {
    # Convertir el factor predicho a caracter (ej. 'M' o 'B')
    pred_etiqueta <- as.character(pred) 
  } else {
    pred_etiqueta <- pred
  }
  
  return(list(
    clase_predicha = pred_etiqueta,
    variables_usadas = top2,
    modelo = modelo
  ))
}
