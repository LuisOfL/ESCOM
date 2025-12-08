# Archivo: knn_chi2.R
library(class)
library(FSelector) # Necesario para chi.squared

#' KNN con selección de características por Chi2 (usando FSelector).
predict_knn_chi2 <- function(train_data, new_id_row, target_col = "Clase", k = 5, n_features = 3) {
  
  # 0. Preparar datos: Asegurar que la Clase sea un factor para FSelector
  data_chi2 <- train_data
  data_chi2[[target_col]] <- as.factor(data_chi2[[target_col]])
  
  # 1. Seleccionar las mejores características usando Chi-cuadrado
  formula_chi2 <- as.formula(paste(target_col, "~ ."))
  
  # FSelector::chi.squared excluye la columna ID automáticamente si no es numérica
  weights <- FSelector::chi.squared(formula_chi2, data_chi2[, !names(data_chi2) %in% c("ID")])
  
  # Ordenar por valor de Chi2 (mayor valor = mayor relevancia)
  weights <- weights[order(weights$attr_importance, decreasing = TRUE), , drop = FALSE]
  
  # Seleccionar las 'n_features' principales
  selected_features <- rownames(weights)[1:min(n_features, nrow(weights))]
  
  # 2. Preparar matrices para knn()
  train_labels <- train_data[[target_col]]
  train_matrix <- as.matrix(train_data[, selected_features, drop = FALSE])
  test_matrix <- as.matrix(new_id_row[, selected_features, drop = FALSE])
  
  # 3. Realizar la predicción KNN
  prediction <- class::knn(
    train = train_matrix,
    test = test_matrix,
    cl = train_labels,
    k = k
  )
  
  return(list(prediction = as.character(prediction[1]), features = selected_features))
}