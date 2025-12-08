# Archivo: knn_forward.R
library(class)
library(leaps) # Necesario para regsubsets (Forward Selection)

#' KNN con selección de características Forward (usando leaps::regsubsets).
predict_knn_forward <- function(train_data, new_id_row, target_col = "Clase", k = 5, n_features = 3) {
  
  # 0. Preparar datos: Quitar ID y asegurar que la Clase es numérica para la regresión
  data_forward <- train_data[, !names(train_data) %in% c("ID")]
  
  # NOTA: Forward selection (regsubsets) funciona mejor si la variable Clase es numérica.
  # Si tu Clase es categórica (texto), esto generará un error o regresión incorrecta.
  # Intentaremos convertirla a numérica (aunque no es ideal para KNN).
  if (is.factor(data_forward[[target_col]])) {
    # Si es factor, usar niveles como 1, 2, 3...
    data_forward[[target_col]] <- as.numeric(data_forward[[target_col]])
  }
  
  # 1. Realizar Forward Selection
  formula_fs <- as.formula(paste(target_col, "~ ."))
  
  # Usar n_features + 1 porque regsubsets devuelve el modelo sin variables
  # y los modelos con 1, 2, 3... variables. Buscamos el modelo de tamaño n_features.
  max_vars <- min(n_features, ncol(data_forward) - 1)
  
  forward_model <- leaps::regsubsets(
    formula_fs, 
    data = data_forward, 
    nbest = 1, # El mejor modelo para cada tamaño
    nvmax = max_vars,
    method = "forward"
  )
  
  # 2. Extraer las características del mejor modelo (el de tamaño max_vars)
  summary_fs <- summary(forward_model)
  
  if (is.null(summary_fs$which) || nrow(summary_fs$which) == 0) {
    stop("Forward selection no encontró variables válidas.")
  }
  
  # Obtener las variables del mejor modelo de tamaño 'max_vars'
  vars_matrix <- summary_fs$which[max_vars, ]
  
  # La primera columna es el intercepto, las variables empiezan desde la segunda
  selected_features <- names(vars_matrix)[vars_matrix][2:length(vars_matrix)]
  
  # 3. Preparar matrices para knn()
  train_labels <- train_data[[target_col]]
  train_matrix <- as.matrix(train_data[, selected_features, drop = FALSE])
  test_matrix <- as.matrix(new_id_row[, selected_features, drop = FALSE])
  
  # 4. Realizar la predicción KNN
  prediction <- class::knn(
    train = train_matrix,
    test = test_matrix,
    cl = train_labels,
    k = k
  )
  
  return(list(prediction = as.character(prediction[1]), features = selected_features))
}