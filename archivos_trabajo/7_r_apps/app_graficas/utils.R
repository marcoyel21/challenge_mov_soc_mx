
load <- function(){
  if(!file.exists('parcial.rds')){
    parcial_url <- 'https://raw.githubusercontent.com/marcoyel21/intro-to-data-science-2020/master/primer_parcial/data/imports-85.csv?token=ANVOYCVSMJEXLPUXPYIRMOC7ZPQLO'
    
    parcial_data <- read_csv(parcial_url, 
                      col_names = colnames,
                      na = 'XXXXXXX')
    saveRDS(parcial_data, "parcial.rds")
    print('parcial.rds se bajó y guardó\n')
  }
  else{
    warning('parcial.rds ya existe\n')
    parcial_data <- readRDS("parcial.rds")
  }
  
  return(parcial_data)
}



parcial_clean_colnames <- function(x){
  str_replace_all(tolower(x),"/| |-",'_')
}

parcial_clean_data <- function(x){
  str_replace_all(tolower(x),"_",'')
}


#Graficas

general <- function(a,b) {  #agrega el dataframe, y b en forma a$b
  if (is.factor(b)){
    p <- ggplot(a, aes(factor(b),fill=factor(b)))
    return(p + geom_bar()+ geom_text(
      aes(label='stat(count)'),
      stat='count',
      nudge_y=0.125,
      va='bottom'
    )) }
  else{
    p <- ggplot(a, aes(x=b))
    return(p+geom_histogram()+ theme(axis.text.x = element_text(angle = 90)))}
}

bigeneral <- function(a,b,c)  { #agrega el dataframe, y b y c entre comillas
  p <- ggpairs(a, columns = c(b,c), cardinality_threshold = 30)
  return(p + theme(axis.text.x = element_text(angle = 90)))}

multigeneral <- function(a,b,c,d)  { #dataframe, dataframe$variablecategórica, variable categorica con comillas, variable no categórcia
  p <- ggpairs(a, columns = c(c,d), legend=1, cardinality_threshold = 30,aes(colour = b, alpha = 0.4))
  return(p + theme(axis.text.x = element_text(angle = 90)))}

# Imputacion

mode <- function(v) {
  #Esta función calcula la moda de un vector dado
  #Recibe como argumento un vector v
  #Regresa un valor númerico (moda)
  unique(v)[which.max(tabulate(match(v, unique(v))))]
}

imputar_valor_central_0 <- function(df,x){
  #Esta funcion imputa la moda en variables categóricas y la mediana en variables numéricas
  #Recibe como argumento a un dataframe y el nombre de la columna
  #La función regresa el dataframe con los valores imputados
  
  if(typeof(unlist(df[x]))== "character"){
    df[is.na(df[x]), x] <- mode(df[x])
  }
  if(typeof(unlist(df[x]))== "double"){
    df[is.na(df[x]), x] <- median(unlist(df[x]), na.rm=TRUE)
    
  }
  
  return(df)
}

imputar_valor_central <- function(df, v_cols){
  #Esta función imputa los valores faltantes
  #Recibe como argumento un dataframe y un vector con las columans a imputar
  #Regresa un dataframe con las columnas imputadas
  for( i in v_cols){
    df <- imputar_valor_central_0(df,i)
  }
  return(df)
  
}


imputar_valor_lm <- function(df, var_independiente, modelo) {
  #La función imputa los valores continuos de una variable numérica utilizando un modelo de regresión lineal
  #La función recibe como argumento un dataframe, la variable independiente y el modelo
  #Regresa el dataframe con los valores imputados
  df[is.na(df[var_independiente]), var_independiente] <- predict(modelo, df[is.na(df[var_independiente]), ])
  return(df)
  
}