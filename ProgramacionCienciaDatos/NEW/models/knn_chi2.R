
source("models/knn_utils.R")

knn_chi2_simple <- function(id, k, data) {
  preparacion <- preparar_datos_knn(data_path = data, id_valor = id)
  
  features <- preparacion$features_chi2
  

  X_train <- preparacion$X_train_norm_full[, valid_features, drop = FALSE]
  X_test <- preparacion$X_test_norm_full[, valid_features, drop = FALSE]
  
  pred <- knn(
    train = X_train_final, 
    test = X_test_final, 
    cl = preparacion$y_train, 
    k = k
  )
  
  return(list(
    id = id,
    k_usado = k,
    prediccion_knn = as.character(pred),
    clase_real = preparacion$clase_real,
    features_usadas = valid_features
  ))
}