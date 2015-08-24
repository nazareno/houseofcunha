setwd("~/Projects/houseofcunha/votacoes_selecionadas")
votacoes = read.csv("votacoes.csv",stringsAsFactors=FALSE)
library(dplyr)
votacoes = 
  votacoes %>% 
  mutate(nome= ifelse(nome=="Evandro Rogerio Roman","Evandro Roman", nome))

votacoes = 
  votacoes %>% 
  mutate(nome= ifelse(nome=="Evandro Rogerio Roman","Evandro Roman", nome))

votacoes = 
  votacoes %>% 
  mutate(partido= ifelse(nome=="Cabo Daciolo","s.part.", partido))

write.csv(votacoes,"votacoes2.csv",row.names = FALSE, quote=FALSE)
