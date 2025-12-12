source("models/knn_utils.R")

knn_forward_simple <- function(id, k, data) {
  preparacion <- preparar_datos_knn(data_path = data, id_valor = id)
  
  features <- preparacion$features_forward
  
  X_train <- preparacion$X_train_norm_full[, features, drop = FALSE]
  X_test <- preparacion$X_test_norm_full[, features, drop = FALSE]
  
  # Ejecutar KNN (usando la librería 'class')
  pred <- knn(
    train = X_train, 
    test = X_test, 
    cl = preparacion$y_train, 
    k = k
  )
  
  return(list(
    id = id,
    k_usado = k,
    prediccion_knn = as.character(pred),
    clase_real = preparacion$clase_real,
    features_usadas = features
  ))
}