#data <- matrix(c(1:80), nrow = 10, byrow = TRUE)

norm.euclidiana <- function(a , b){
  result <- sqrt( sum( ( a - b )^2 ))
  return(result)
}

Entorno.generaMatrizC <- function(dimensiones , nclusters){
  return(matrix(0, nclusters, dimensiones[2] ))
}

Entorno.generaMatrizU <- function(dimensiones , nclusters){
  mat = matrix( rexp(dimensiones[1]*nclusters, rate=.1), ncol = nclusters )
  for(j in 1:dimensiones[1]){
    suma = sum(mat[j,])
    mat[j,] = mat[j,]/suma
  }
  return(mat)
}

Entorno.cargaMatrix <- function(nombre){
  #"data.rds"
  data <- readRDS(nombre)
  return(data)
}


clustering.calculaMatrisDistancia <- function(data , matrixC, norm){
  filas = dim(data)[1]
  columnas = dim(matrixC)[1]
  mat = matrix(0, filas, columnas)
  for (j in 1:filas) {
    for (i in 1:columnas ){
      mat[j,i] <- norm.euclidiana(data[j,], matrixC[i,])
    }
  }
  return(mat)
}

clustering.fcmcalculaC <- function( data , matrixC, matrixU, nclusters ){
  matC = matrix(0, nclusters, (dim(data)[2]) )
  for(i in 1:nclusters ){
    for(k in 1:(dim(data)[1])){
      matC[i,] = matC[i,] + data[k,] * matrixU[k,i]
    }
    matC[i,] = matC[i,] / sum(matrixU[,i]) 
  }
  return(matC)
}

clustering.fcmcalculaU <- function( data , matrixC, matrixU, nclusters, norm , Entorno){
  mat = clustering.calculaMatrisDistancia(data, matrixC, norm)
  for (j in 1:dim(data)[1]) {
    for (i in 1:nclusters ){
      suma <- 0
      for (k in 1:nclusters ){
        suma <- suma + (mat[j,i]/mat[j,k])
      }
      matrixU[j,i] <- 1/suma
    }
  }
  return(matrixU)
}

clustering.feccalculaU <- function( data , matrixC, matrixU, nclusters, norm , Entorno){
  mat = clustering.calculaMatrisDistancia(data, matrixC, norm)
  for (j in 1:dim(data)[1]) {
    for (i in 1:nclusters ){
      suma = 0
      for (r in 1:nclusters ){
        suma = suma +(2.71828182^(mat[j,i]-mat[j,r]))^(1/(dim(data)[1]))
      }
      matrixU[j,i] = 1/suma
    }
  }
  return(matrixU)
}

clustering.asignaCluster <- function(algName, indice, matrixU){
  vector = matrix( 0, nrow = dim(matrixU)[1] )
  for (j in (1:dim(matrixU)[1])) {
    vector[j,1] = which(matrixU[j,] == max(matrixU[j,]))[1]
  }
  img = matrix(vector, nrow = 500)
  png(paste(algName,indice,".png",sep = ""))
  par(mar=c(0, 0, 0, 0))
  image(img)
  dev.off()
  return(img)
}


Algorithm.FCM <- function(data, nclusters, matrixC , matrixU, error, iteraciones, norm, Entorno){
  aux <- matrixU
  for (i in 1:iteraciones) {
    #print(paste("iteraciones",i))
    matrixC = clustering.fcmcalculaC( data , matrixC, matrixU, nclusters )
    #print(paste("centroides",i))
    matrixU = clustering.fcmcalculaU( data , matrixC, matrixU, nclusters, norm , Entorno)
    var = max(abs(matrixU-aux))
    print(var)
    aux <- matrixU
    if ( var < error && i > 10 ) {
      break
    }
  }
  return(matrixU)
}

Algorithm.FEC <- function(data, nclusters, matrixC , matrixU, error, iteraciones, norm, Entorno){
  aux <- matrixU
  for (i in 1:iteraciones) {
    print(paste("iteraciones",i))
    matrixC = clustering.fcmcalculaC( data , matrixC, matrixU, nclusters )
    matrixU = clustering.feccalculaU( data , matrixC, matrixU, nclusters, norm , Entorno)
    var = max(abs(matrixU-aux))
    print(var)
    aux <- matrixU
    if ( var < error ) {
      break
    }
  }
  return(matrixU)
}

#Algorithm.FCM(data , matrixC , matrixU, error, iteraciones, norm, Entorno)
#Algorithm.FEC(data , matrixC , matrixU, error, iteraciones, norm, Entorno)

main <- function(cls, norm, Entorno, clustering, Algorithm){
  data <- Entorno.cargaMatrix("data.rds")
  dimensiones = dim(data)
  print(dimensiones)
  iteraciones = 12
  error = 0.001
  
  for (i in (2:cls) ) {
    nclusters = i
    matrixU = Entorno.generaMatrizU(dimensiones , nclusters)
    matrixC = Entorno.generaMatrizC(dimensiones , nclusters)
    
    resfcm = Algorithm.FCM(data, nclusters, matrixC , matrixU, error, iteraciones, norm, Entorno)
    aux =clustering.asignaCluster("FCM clusters =",i, resfcm)
    #saveRDS(resfcm, paste("out/fcm",i,".rds",sep = ""))
    
    #resfec = Algorithm.FEC(data, nclusters, matrixC , matrixU, error, iteraciones, norm, Entorno)
    #aux =clustering.asignaCluster("FEC clusters =",i, resfec)
    #saveRDS(resfcm, paste("out/fec",i,".rds",sep = ""))
  }
}

# Save a single object to a filed
#saveRDS(mtcars, "mtcars.rds")
# Restore it under a different name
#data <- readRDS("mtcars.rds")
