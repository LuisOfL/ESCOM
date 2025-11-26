# Instalar si hace falta
# install.packages("infotheo")

library(infotheo)

# Cargar datos de ejemplo
data(iris)

# 1. Discretizar TODAS las variables predictoras
X <- discretize(iris[, 1:4])

# 2. La variable objetivo (clase)
Y <- iris$Species

# 3. Calcular la información mutua entre cada variable y la clase
MI <- sapply(X, function(col) mutinformation(col, Y))

# 4. Mostrar resultados
print(MI)

# (Opcional) Ordenar de mayor a menor
MI_ordenado <- sort(MI, decreasing = TRUE)
print(MI_ordenado)
