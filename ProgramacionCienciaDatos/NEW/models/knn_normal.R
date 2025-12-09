library(class)
library(caret)


knn_normal <- function(id,k,data){
  if(k %% 2 == 0 || k < 0){k = abs(k)+1}
  df <- read.csv(data)
  
  variable_clase <- df[,2] 
  
  set.seed(42)
  indices_entrenamiento <- createDataPartition(
    y = variable_clase, 
    p = 0.70,             
    list = FALSE          
  )
  
  X_train <- df[indices_entrenamiento, ]
  X_test <- df[-indices_entrenamiento, ]
  
}





df <- read.csv("C:/Users/luigu/OneDrive/Escritorio/NEW/breast-cancer.csv")

variable_clase <- df[,2] 

set.seed(42)
indices_entrenamiento <- createDataPartition(
  y = variable_clase, 
  p = 0.70,             
  list = FALSE          
)

X_train <- df[indices_entrenamiento, ]
X_test <- df[-indices_entrenamiento, ]
print(X_train)







