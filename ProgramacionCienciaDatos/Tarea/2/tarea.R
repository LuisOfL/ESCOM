library(class)      # KNN
library(leaps)      # Forward selection
library(FSelector)  # Chi2
library(FSelectorRcpp)#Chi2

# Leer datos
datos <- read.csv("C:/Users/luigu/OneDrive/Escritorio/Tareas/PCD/2/breast-cancer.csv")


#Mezclar datos por si el dataset esta ordenado
set.seed(123)
datos <- datos[sample(nrow(datos)), ]


# Variables
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


# KNN con todas las features --------------------------------------------------
pred_all <- knn(
  train = X_train,
  test  = X_test,
  cl    = y_train,
  k     = 5
)

acc1 <- mean(pred_all == y_test)
cat("\nAccuracy KNN con TODAS las features:", acc1, "\n")






# MÉTODO WRAPPER - Forward Selection -------------------------------------------
df <- cbind(y = y_train, X_train) 

modelo_forward <- regsubsets(
  y ~ ., 
  data = df,
  method = "forward",
  nvmax = ncol(X_train)
)

res <- summary(modelo_forward)
size <- which.max(res$adjr2)
best_vars <- res$which[size, ]
selected_vars <- names(best_vars)[best_vars][-1]

cat("\nVariables seleccionadas con FORWARD:\n")
print(selected_vars)


X_train_forward <- X_train[, selected_vars]
X_test_forward  <- X_test[, selected_vars]

pred_forward <- knn(
  train = X_train_forward,
  test  = X_test_forward,
  cl    = y_train,
  k     = 5
)

acc2 <- mean(pred_forward == y_test)
cat("\nAccuracy Forward Selection:", acc2, "\n")





# MÉTODO FILTER - Chi-cuadrada-----------------------------------------------------


# Discretización usando CUT()
df_discrete <- data.frame(lapply(df, function(col){
  if(is.numeric(col)){
    return(cut(col, breaks = 5, labels = FALSE))
  } else {
    return(as.factor(col))
  }
}))

# Chi2
chi_scores <- chi.squared(y ~ ., data = df_discrete)
print(chi_scores)

# Seleccionar las mejores 5
best_features <- cutoff.k(chi_scores, 5)
print(best_features)

X_train_chi <- X_train[, best_features]
X_test_chi  <- X_test[, best_features]

predicciones_chi <- knn(
  train = X_train_chi,
  test  = X_test_chi,
  cl    = y_train,
  k     = 5
)

acc3 <- mean(predicciones_chi == y_test)
cat("Accuracy Chi2:", acc3, "\n")
