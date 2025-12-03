library(leaps)      # Forward selection
library(FSelector)  # Chi2
library(FSelectorRcpp)#Chi2

# Leer datos
datos <- read.csv("C:/Users/luigu/OneDrive/Escritorio/Tareas/PCD/2/breast-cancer.csv")

# KNN sin librerías ------------------------------------------------------------

knn_sin_lib <- function(X_train, X_test, y_train, ks) {
  
  X_train <- as.matrix(X_train)
  X_test  <- as.matrix(X_test)
  
  resultados <- list()
  
  for (k in ks) {
    
    pred <- c()
    
    for (i in 1:nrow(X_test)) {
      
      distancias <- sqrt( rowSums((X_train - X_test[i, ])^2) )
      
      vecinos_idx <- order(distancias)[1:k]
      
      clases_vecinos <- y_train[vecinos_idx]
      
      pred[i] <- names(sort(table(clases_vecinos), decreasing = TRUE))[1]
    }
    
    resultados[[paste0("k_", k)]] <- pred
  }
  
  return(resultados)
}

# Mezclar datos ---------------------------------------------------------------

datos <- datos[sample(nrow(datos)), ]

# Partición 80/20 -------------------------------------------------------------

X_train <- data.frame()
X_test  <- data.frame()
y_train <- c()
y_test  <- c()

for(x in 1:nrow(datos)){
  data <- datos[x, 3:ncol(datos)]
  label <- datos[x, 2]
  
  if(x <= nrow(datos)*0.8){
    X_train <- rbind(X_train, data)
    y_train <- c(y_train, label)
  } else {
    X_test <- rbind(X_test, data)
    y_test <- c(y_test, label)
  }
}

# Convertir formatos
X_train <- data.frame(lapply(X_train, as.numeric))
X_test  <- data.frame(lapply(X_test, as.numeric))

y_train <- as.factor(y_train)
y_test  <- as.factor(y_test)

# Normalización Min-Max
min_vals <- apply(X_train, 2, min)
max_vals <- apply(X_train, 2, max)

X_train <- as.data.frame(scale(X_train, center = min_vals, scale = max_vals - min_vals))
X_test  <- as.data.frame(scale(X_test,  center = min_vals, scale = max_vals - min_vals))

# KNN con todas las features --------------------------------------------------

pred_all <- knn_sin_lib(X_train, X_test, y_train, ks = 5)$k_5

acc1 <- mean(pred_all == y_test)
cat("\nAccuracy KNN con TODAS las features:", acc1, "\n")

# WRAPPER - Forward Selection -------------------------------------------------

df <- cbind(y = y_train, X_train)

modelo_forward <- regsubsets(
  y ~ ., 
  data = df,
  method = "forward",
  nvmax = 10
)

res <- summary(modelo_forward)

size <- 10
best_vars <- res$which[size, ]
selected_vars1 <- names(best_vars)[best_vars][-1]

cat("\nVariables seleccionadas con FORWARD:\n")
print(selected_vars1)

X_train_forward <- X_train[, selected_vars1]
X_test_forward  <- X_test[, selected_vars1]

pred_forward <- knn_sin_lib(
  X_train_forward,
  X_test_forward,
  y_train,
  ks = 5
)$k_5

acc2 <- mean(pred_forward == y_test)
cat("\nAccuracy Forward Selection:", acc2, "\n")





# MÉTODO FILTER - Chi-cuadrada ------------------------------------------------

df_discrete <- data.frame(lapply(df, function(col){
  if(is.numeric(col)){
    return(cut(col, breaks = 10, labels = FALSE))
  } else {
    return(as.factor(col))
  }
}))

chi_scores <- chi.squared(y ~ ., data = df_discrete)
print(chi_scores)

best_features2 <- cutoff.k(chi_scores, 10)
print(best_features2)

X_train_chi <- X_train[, best_features2]
X_test_chi  <- X_test[, best_features2]

predicciones_chi <- knn_sin_lib(
  X_train_chi,
  X_test_chi,
  y_train,
  ks = 5
)$k_5

acc3 <- mean(predicciones_chi == y_test)
cat("Accuracy Chi2:", acc3, "\n")






   
# ----------------------------------------------------------------------
predecir_por_id <- function(datos, id_valor, k = 5) {
  
  # Buscar fila con ese ID en la PRIMERA columna
  fila_id <- which(datos[, 1] == id_valor)
  
  if (length(fila_id) == 0) {
    stop(paste("El ID", id_valor, "NO existe en la columna 1 del dataset."))
  }
  
  # Separar test
  X_test  <- datos[fila_id, 3:ncol(datos)]
  y_test  <- datos[fila_id, 2]
  
  # Training = todos menos esa fila
  datos_train <- datos[-fila_id, ]
  X_train <- datos_train[, 3:ncol(datos)]
  y_train <- datos_train[, 2]
  
  # Asegurar numéricos
  X_train <- data.frame(lapply(X_train, as.numeric))
  X_test  <- data.frame(lapply(X_test,  as.numeric))
  
  y_train <- as.factor(y_train)
  y_test  <- as.factor(y_test)
  
  # Normalización Min-Max
  min_vals <- apply(X_train, 2, min)
  max_vals <- apply(X_train, 2, max)
  
  X_train <- as.data.frame(scale(X_train, center = min_vals, scale = max_vals - min_vals))
  X_test  <- as.data.frame(scale(X_test,  center = min_vals, scale = max_vals - min_vals))
  
  # Ejecutar KNN
  pred <- knn_sin_lib(X_train, X_test, y_train, ks = k)[[paste0("k_", k)]]
  
  # Imprimir resultado
  cat("=====================================\n")
  cat("ID:", id_valor, "\n")
  cat("Clase real:       ", as.character(y_test), "\n")
  cat("Predicción KNN:   ", as.character(pred), "\n")
  cat("=====================================\n")
  
  return(pred)
}


a = predecir_por_id(datos, 842302, k = 5)
print(a)





842302 %in% datos[,1]




# Funciones extras ------------------------------------------------------------

Iguales <- function(l1,l2){
  res <- c()
  for(x in 1:length(l1)){
    if(l1[x] %in% l2){
      res <- append(res,l1[x])
    }      
  }  
  return(res)
}

juntos <- function(l1, l2) {
  lista <- list(l1, l2)
  return(lista)
}

iguales <- Iguales(selected_vars1, best_features2)
tot <- juntos(selected_vars1, best_features2)

print(tot[1])
print(tot[2])
print(iguales)

#_----------------------------------------------MENU------------------------------#
# ----------------------------------------------------------------------
# ------------------------- MENÚ DE PREDICCIÓN --------------------------
# ----------------------------------------------------------------------

menu_prediccion <- function() {
  
  repeat {
    cat("\n===============================\n")
    cat("      SISTEMA DE PREDICCIÓN     \n")
    cat("===============================\n")
    cat("1) KNN con TODAS las features\n")
    cat("2) KNN con Forward Selection\n")
    cat("3) KNN con Chi-Square\n")
    cat("===============================\n")
    
    opcion_raw <- readline("Seleccione una opción (1-3): ")
    
    # Forzar conversión segura
    opcion <- suppressWarnings(as.integer(opcion_raw))
    
    if (!is.na(opcion) && opcion %in% 1:3) {
      break
    }
    
    cat("\n Entrada inválida. Intente de nuevo.\n")
  }
  
  # PEDIR ID (también robusto)
  repeat {
    id_raw <- readline("Ingrese el ID a predecir: ")
    id_valor <- suppressWarnings(as.numeric(id_raw))
    
    if (!is.na(id_valor)) break
    
    cat("\n ID inválido. Debe ser numérico.\n")
  }
  
  # Buscar el ID en el dataset
  fila_id <- which(datos[, 1] == id_valor)
  
  if (length(fila_id) == 0) {
    stop("Ese ID NO existe en la columna 1 del dataset.")
  }
  
  # Separar test
  X_test  <- datos[fila_id, 3:ncol(datos)]
  y_test  <- datos[fila_id, 2]
  
  # Training = todos menos esa fila
  datos_train <- datos[-fila_id, ]
  X_train <- datos_train[, 3:ncol(datos)]
  y_train <- datos_train[, 2]
  
  # Asegurar numéricos
  X_train <- data.frame(lapply(X_train, as.numeric))
  X_test  <- data.frame(lapply(X_test,  as.numeric))
  y_train <- as.factor(y_train)
  y_test  <- as.factor(y_test)
  
  # Normalizar
  min_vals <- apply(X_train, 2, min)
  max_vals <- apply(X_train, 2, max)
  X_train <- as.data.frame(scale(X_train, center = min_vals, scale = max_vals - min_vals))
  X_test  <- as.data.frame(scale(X_test,  center = min_vals, scale = max_vals - min_vals))
  
  # SELECCIÓN DE FEATURES SEGÚN MÉTODO
  if (opcion == 1) {
    cat("\nMétodo seleccionado: TODAS LAS FEATURES\n")
    X_train_sel <- X_train
    X_test_sel  <- X_test
  }
  
  if (opcion == 2) {
    cat("\nMétodo seleccionado: FORWARD SELECTION\n")
    X_train_sel <- X_train[, selected_vars1]
    X_test_sel  <- X_test[, selected_vars1]
  }
  
  if (opcion == 3) {
    cat("\nMétodo seleccionado: CHI-SQUARE\n")
    X_train_sel <- X_train[, best_features2]
    X_test_sel  <- X_test[, best_features2]
  }
  
  # Ejecutar KNN
  pred <- knn_sin_lib(X_train_sel, X_test_sel, y_train, ks = 5)$k_5
  
  cat("\n=====================================\n")
  cat("ID:", id_valor, "\n")
  cat("Clase real:        ", as.character(y_test), "\n")
  cat("Predicción KNN:    ", as.character(pred), "\n")
  cat("=====================================\n\n")
  
  return(pred)
}


# -------------------------
# LLAMAR MENÚ
# -------------------------

resultado <- menu_prediccion()
print(resultado)






