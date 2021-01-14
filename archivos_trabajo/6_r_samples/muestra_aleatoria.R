#Este archivo toma la base final elaborada en STATA y crea una muestra aleatoria
#Este paso es necesario para disminuir el tiempo de computo en R.

data<-read.csv("final_oprobit.csv")
data<-expandRows(data,"factor")
data_complete<-data[complete.cases(data), ]
sample<-sample_n(data_complete, 10000)
