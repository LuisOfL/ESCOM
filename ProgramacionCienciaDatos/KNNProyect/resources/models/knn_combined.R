# Archivo: knn_combined.R
library(class)

# --- Dependencias de Funciones Auxiliares (Necesitan ser cargadas por app.R) ---

# Usaremos las funciones select_chi2_aux y select_forward_aux
# que obtendrían las listas de nombres de características de los archivos 2 y 3.

# Debido a la restricción de R de no tener funciones auxiliares globales,
# aquí redefiniremos las funciones de predicción para extraer solo las características
# para combinarlas. Es más limpio reusar la lógica de los archivos 2 y 3.

# Asumiremos que estas funciones existen y están disponibles globalmente en app.R
# después de hacer source.

#' KNN con selección de características combinando Chi2 y Forward.
predict_knn_combined <- function(train_data, new_id_row, target_col = "Clase", k = 5, n_chi2 = 3, n_forward = 3) {
  
  # **NOTA:** Este archivo necesita que knn_chi2.R y knn_forward.R hayan sido cargados
  # para que las funciones auxiliares (o la lógica de selección) estén disponibles.
  
  # 1. Obtener características seleccionadas por Chi2 (reusando la lógica)
  result_chi2 <- predict_knn_chi2(train_data, new_id_row, target_col, k, n_chi2)
  features_chi2 <- result_chi2$features
  
  # 2. Obtener características seleccionadas por Forward (reusando la lógica)
  result_forward <- predict_knn_forward(train_data, new_id_row, target_col, k, n_forward)
  features_forward <- result_forward$features
  
  # 3. Combinar (Unión) las características seleccionadas
  selected_features <- unique(c(features_chi2, features_forward))
  
  if (length(selected_features) == 0) {
    stop("No se seleccionó ninguna característica válida de los métodos combinados.")
  }
  
  # 4. Preparar matrices para knn()
  train_labels <- train_data[[target_col]]
  train_matrix <- as.matrix(train_data[, selected_features, drop = FALSE])
  test_matrix <- as.matrix(new_id_row[, selected_features, drop = FALSE])
  
  # 5. Realizar la predicción KNN
  prediction <- class::knn(
    train = train_matrix,
    test = test_matrix,
    cl = train_labels,
    k = k
  )
  
  return(list(prediction = as.character(prediction[1]), features = selected_features))
}