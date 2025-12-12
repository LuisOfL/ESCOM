# utils.R

leer_datos <- function(file_info) {
  if (is.null(file_info))
    return(NULL)
  
  ext <- tools::file_ext(file_info$datapath)
  
  if (ext == "csv") {
    df <- read.csv(file_info$datapath, stringsAsFactors = TRUE)
  } else if (ext == "xml") {
    # Aquí iría el código para leer XML si fuera necesario
    stop("La lectura de archivos XML no está implementada en este ejemplo.")
  } else {
    stop("Tipo de archivo no soportado. Por favor use .csv.")
  }
  
  # Asegurar que la primera columna sea ID y la segunda sea la variable objetivo (Y)
  if(ncol(df) < 3) stop("El dataset debe tener al menos ID, Y, y una caracteristica.")
  
  return(df)
}