# Archivo: resources/models/knn_forward.R

# Asumimos que train_data es un data.frame limpio (sin NA, ID en col 1, Clase en col 2)
# new_id_row es la fila a predecir
# target_col es "Clase"
# k es el número de vecinos
# n_features es el número de features a seleccionar

predict_knn_forward <- function(train_data, new_id_row, target_col, k, n_features) {
  
  # --- 1. PREPARACIÓN DE DATOS (Partición y Normalización) ---
  
  # Separar la fila a predecir (X_test) del resto del entrenamiento (X_train)
  train_id <- train_data$ID
  new_id <- new_id_row$ID
  
  # X_train es todo el dataset menos la fila a predecir
  datos_train <- train_data[train_id != new_id, ] 
  
  # Separar X_train, y_train, X_test
  X_train <- datos_train[, !names(datos_train) %in% c("ID", target_col)]
  y_train <- datos_train[[target_col]]
  
  X_test_unnormalized <- new_id_row[, !names(new_id_row) %in% c("ID", target_col)]
  
  # Convertir a factor para asegurar el correcto etiquetado
  y_train <- as.factor(y_train)
  
  # Normalización Min-Max (solo en X_train y X_test)
  min_vals <- apply(X_train, 2, min)
  max_vals <- apply(X_train, 2, max)
  range_vals <- max_vals - min_vals
  
  # Manejar columnas con rango cero (evitar división por cero)
  range_vals[range_vals == 0] <- 1 
  
  X_train_norm <- as.data.frame(scale(X_train, center = min_vals, scale = range_vals))
  X_test_norm <- as.data.frame(scale(X_test_unnormalized, center = min_vals, scale = range_vals))
  
  # --- 2. SELECCIÓN DE CARACTERÍSTICAS (FORWARD) ---
  
  # CRÍTICO: regsubsets requiere un factor numérico y una fórmula y ~ .
  # Convertir la columna objetivo a un vector numérico (1, 2, 3...)
  y_numeric <- as.numeric(y_train)
  
  # Crear el data.frame para la regresión con la columna objetivo nombrada 'y'
  df_regress <- cbind(y = y_numeric, X_train_norm)
  
  # Ejecutar Forward Selection
  modelo_forward <- leaps::regsubsets(
    y ~ .,  
    data = df_regress,
    method = "forward",
    nvmax = 10 # Número máximo de features a seleccionar
  )
  
  res <- summary(modelo_forward)
  # Obtener las variables seleccionadas (n_features)
  best_vars_index <- res$which[n_features, ]
  selected_vars <- names(best_vars_index)[best_vars_index][-1] # Eliminar "(Intercept)"
  
  # Si el modelo no selecciona variables (puede pasar), usar todas
  if (length(selected_vars) == 0) {
    warning("Forward selection no eligió variables; usando todas.")
    selected_vars <- names(X_train_norm)
  }
  
  # --- 3. PREDICCIÓN KNN con Features Seleccionadas ---
  
  # Filtrar los datasets normalizados
  X_train_sel <- X_train_norm[, selected_vars, drop = FALSE]
  X_test_sel <- X_test_norm[, selected_vars, drop = FALSE]
  
  # Aplicar KNN
  pred <- class::knn(
    train = X_train_sel, 
    test = X_test_sel, 
    cl = y_train, 
    k = k
  )
  
  # Preparar resultado unificado
  return(list(
    prediction = as.character(pred[1]),
    features = selected_vars
  ))
}