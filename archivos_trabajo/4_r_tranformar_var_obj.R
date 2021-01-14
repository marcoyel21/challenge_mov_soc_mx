library(tidyverse)
out <- out%>% mutate(objetivo=per_ing_hoy)
write.csv(out,"final.csv")