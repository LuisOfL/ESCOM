Minimum <- function(v){
  min_val <- v[1]
  for(x in 2:length(v)){
    if(v[x] < min_val) min_val <- v[x]
  }
  return(min_val)
}

Maximum <- function(v){
  max_val <- v[1]
  for(x in 2:length(v)){
    if(v[x] > max_val) max_val <- v[x]
  }
  return(max_val)
}

Sturges <- function(v){
  min_data <- Minimum(v)
  max_data <- Maximum(v)
  n <- length(v)
  k <- round(1 + log2(n))  
  range <- max_data - min_data
  width <- ceiling(range / k)
  
  
  limit <- numeric(2*k)
  aux <- min_data
  for(i in 1:k){
    limit[2*i-1] <- aux
    if(i < k){
      limit[2*i] <- aux + width - 1
      aux <- aux + width
    } else {
      limit[2*i] <- max_data
    }
  }
  
  frec <- numeric(k)
  for(x in v){
    for(y in 1:k){
      if(x >= limit[2*y-1] && x <= limit[2*y]){
        frec[y] <- frec[y] + 1
        break
      }
    }
  }
  cat("Ancho",width,"\n")
  cat("Sturges",k,"\n")
  cat("Frecuencias",frec,"\n")
  cat("Limites",limit,"\n")
}

v_test <- c(5, 7, 8, 10, 12, 14, 15, 16, 18, 19, 20, 22, 24, 25, 27)
Sturges(v_test)
