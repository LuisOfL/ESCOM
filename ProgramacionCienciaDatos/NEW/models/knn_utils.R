# Archivo: models/knn_utilidades.R
library(class)
library(leaps)
library(FSelector)
library(FSelectorRcpp)

preparar_datos_knn <- function(data_path, id_valor) {
  
  # 1. Leer datos
  datos <- read.csv(data_path)
  
  # 2. Buscar y Particionar (Test = 1 fila, Train = Resto)
  fila_id <- which(datos[, 1] == id_valor)
  
  if (length(fila_id) == 0) {
    stop(paste("El ID", id_valor, "NO existe en el dataset."))
  }
  
  # Separación
  datos_train <- datos[-fila_id, ]
  X_train_bruto <- datos_train[, 3:ncol(datos)]
  y_train_bruto <- datos_train[, 2]
  
  X_test_bruto <- datos[fila_id, 3:ncol(datos), drop = FALSE] 
  y_test <- datos[fila_id, 2]
  
  # Asegurar formatos
  X_train_num <- data.frame(lapply(X_train_bruto, as.numeric))
  X_test_num <- data.frame(lapply(X_test_bruto, as.numeric))
  y_train <- as.factor(y_train_bruto)
  clase_real <- as.character(y_test)
  
  
  # 3. Normalización Min-Max (basada en X_train_num)
  min_vals <- apply(X_train_num, 2, min)
  max_vals <- apply(X_train_num, 2, max)
  denominadores <- max_vals - min_vals
  cols_validas <- denominadores != 0 
  
  if (sum(cols_validas) == 0) {
    stop("No hay características variables para la predicción después de excluir el ID.")
  }
  
  # Aplicar escala solo a las columnas con varianza > 0
  X_train_norm_full <- X_train_num[, cols_validas, drop = FALSE]
  X_test_norm_full <- X_test_num[, cols_validas, drop = FALSE]
  
  X_train_norm_full <- as.data.frame(scale(
    X_train_norm_full, 
    center = min_vals[cols_validas], 
    scale = denominadores[cols_validas]
  ))
  
  X_test_norm_full <- as.data.frame(scale(
    X_test_norm_full, 
    center = min_vals[cols_validas], 
    scale = denominadores[cols_validas]
  ))
  
  # -------------------------------------------------------------------
  # 🛠️ FILTRO CRÍTICO: Eliminar filas que generaron NaN/Inf durante la normalización
  # -------------------------------------------------------------------
  
  # Comprobar filas finitas (no NA, no Inf, no NaN)
  filas_completas <- apply(X_train_norm_full, 1, function(x) all(is.finite(x) & !is.na(x)))
  
  if (sum(filas_completas) == 0) {
    stop("Todas las filas del conjunto de entrenamiento generaron valores no válidos (NaN/Inf) después de la normalización.")
  }
  
  # Aplicar el filtro a X_train y a y_train
  X_train_norm_full <- X_train_norm_full[filas_completas, , drop = FALSE]
  y_train <- y_train[filas_completas]
  
  # -------------------------------------------------------------------
  
  # 4. Cálculo de Selección de Features (Usando datos filtrados)
  
  # a) Forward Selection (nvmax=10)
  df_forward <- cbind(y = y_train, X_train_norm_full)
  modelo_forward <- regsubsets(y ~ ., data = df_forward, method = "forward", nvmax = 10)
  res_forward <- summary(modelo_forward)
  size_forward <- min(10, nrow(res_forward$which))
  best_vars_forward <- res_forward$which[size_forward, ]
  selected_vars_forward <- names(best_vars_forward)[best_vars_forward][-1]
  
  # b) Chi-Square (Discretización para Chi2)
  df_discrete <- data.frame(lapply(df_forward, function(col){
    if(is.numeric(col)){
      # Necesitamos asegurarse de que la discretización funciona, si la columna tiene pocos valores, puede fallar
      return(cut(col, breaks = min(10, length(unique(col))), labels = FALSE, include.lowest = TRUE)) 
    } else {
      return(as.factor(col))
    }
  }))
  
  chi_scores <- chi.squared(y ~ ., data = df_discrete)
  selected_vars_chi2 <- cutoff.k(chi_scores, 10) # Usar las 10 mejores
  
  return(list(
    X_train_norm_full = X_train_norm_full,
    X_test_norm_full = X_test_norm_full,
    y_train = y_train,
    clase_real = clase_real,
    features_forward = selected_vars_forward,
    features_chi2 = selected_vars_chi2
  ))
}