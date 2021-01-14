library(readstata13)
library(tidyverse)

#Este paso solo se realizo para trannsformar los datos en formato dta a csv

mydata<-read.dta13("datos_movilidad_2.dta")
write.csv(mydata,"datos_movilidad_2.csv")