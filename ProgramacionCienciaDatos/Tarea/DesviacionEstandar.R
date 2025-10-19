datos <- read.csv("C:/Users/luigu/OneDrive/Escritorio/Tarea/ciencia_datos/dataset1.csv")
print(datos)
print(typeof(datos))
print(class(datos))
getwd()


#Obtengo todas las clases posibles, cancer, no cancer, etc.
l <- c()
for(x in 1:nrow(datos)){
  if(!(datos[x,1] %in% l)){
    l <- append(datos[x,1],l)
  }
  
}
n = length(l)
#Pongo cada clase en un dataframe diferente, obteniendo una vector de dataframes
tipos = list()
for(x in 1:length(l)){
  tipos[[x]] <- datos[datos[,1] == l[x], ]
}

# Creo una lista con los vectores de cada clase
tot <- list()
for(x in 1:length(tipos)){
  df <- tipos[[x]]        
  vectores <- list()          
  
  for(y in colnames(df)){
    if(is.numeric(df[[y]])){        
      vectores[[y]] <- df[[y]]      
    }
  }
  tot[[l[x]]] <- vectores
}
#Saco el promedio de cada clase

promedios <- list()

for(clase in l){
  df_class <- as.data.frame(tot[[clase]])
  promedios[[clase]] <- rowMeans(df_class)
}

#desviacion estandar    #124.444
DesEs <- function(v){
  suma <- sum((v-mean(v))^2)
  return( sqrt(suma / (length(v) - 1)) )
}

##Vectores de la desviacion
d1 = DesEs(promedios[[1]])
d2 = DesEs(promedios[[2]])

v1_cancer = promedios[[1]]+d1*2
v2_cancer = promedios[[1]]-d1*2

v1_no_cancer = promedios[[2]]+d2*2
v2_no_cancer = promedios[[2]]-d2*2


##Graficacion
plot(promedios[[1]], type = "l", col = "red",main = "Personas con y sin cancer",
     ylim = range(unlist(promedios)))  

lines(promedios[[2]], type="l", col = "blue")

lines(v1_cancer, type="l", col = "#F79365",lty=2)
lines(v2_cancer, type="l", col = "#F79365",lty=2)

lines(v1_no_cancer, type="l", col = "#65D3F7",lty=2)
lines(v2_no_cancer, type="l", col = "#65D3F7",lty=2)


print(d1)
print(d2)
