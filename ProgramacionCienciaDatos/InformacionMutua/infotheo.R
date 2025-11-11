Salud <- c(rep("SI", 26), rep("NO", 24))
Dieta <- c(rep("SI", 23), rep("NO", 3), rep("SI", 4), rep("NO", 20))
Color <- c(rep("SI", 12), rep("NO", 14), rep("SI", 14), rep("NO", 10))

datos <- data.frame(Salud, Dieta, Color)


library(infotheo)
IM_1 <- mutinformation(datos$Salud, datos$Dieta)
IM_2 <- mutinformation(datos$Salud, datos$Color)
print(IM_1)
print(IM_2)
