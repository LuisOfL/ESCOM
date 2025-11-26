# Instalar si hace falta
# install.packages("leaps")

library(leaps)

# Suponiendo que tienes un data frame llamado 'datos'
# y que 'y' es el nombre de tu variable objetivo

modelo_forward <- regsubsets(
  y ~ .,               # todas las variables
  data = datos,        # tus datos
  method = "forward"   # selección hacia adelante
)

# Resumen del proceso de selección
resumen <- summary(modelo_forward)
print(resumen)
