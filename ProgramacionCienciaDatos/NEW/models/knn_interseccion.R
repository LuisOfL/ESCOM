source("models/knn_utils.R")

knn_interseccion_simple <- function(id, k, data) {
  
  preparacion <- preparar_datos_knn(data_path = data, id_valor = id)
  
  features_forward <- preparacion$features_forward
  features_chi2 <- preparacion$features_chi2
  
  features_interseccion <- intersect(features_forward, features_chi2)
  
  if(length(features_interseccion) == 0) {
    stop("La intersección de Chi2 y Forward no produjo características comunes. Intenta con otro método.")
  }
  

  features <- features_interseccion
  
  
  X_train <- preparacion$X_train_norm_full[, features, drop = FALSE]
  X_test <- preparacion$X_test_norm_full[, features, drop = FALSE]
  

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