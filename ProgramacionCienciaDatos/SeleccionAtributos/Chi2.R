install.packages("FSelector")
library(FSelector)

# dataset ejemplo
data(iris)

# aplicar chi-cuadrado
result <- chi.squared(Species ~ ., data = iris)

# ver importancia de atributos
print(result)

# elegir los mejores atributos (por ejemplo, los 2 más fuertes)
best_attributes <- cutoff.k(result, 2)
best_attributes
