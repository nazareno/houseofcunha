setwd("~/Projects/houseofcunha/backup")
library(reshape)

votacoes = read.csv("votacoes_selecionadas.csv",stringsAsFactors=FALSE)
votacoes_wide = votacoes[,c("id_dep","nome","voto","nome_votacao","partido","uf")]
votacoes_wide2 = votacoes_wide
votacoes_wide2$voto_long = votacoes_wide$voto

votacoes_wide[ is.na( votacoes_wide$voto ), ] = -1
votacoes_wide[votacoes_wide$voto == "sim",]$voto = 1
votacoes_wide[votacoes_wide$voto == "não",]$voto = 0
votacoes_wide[votacoes_wide$voto == "abstenção",]$voto = -2
votacoes_wide[votacoes_wide$voto == "obstrução",]$voto = -3
votacoes_wide[votacoes_wide$voto == "art. 17",]$voto = -4



votacoes_long = cast(votacoes_wide, id_dep + nome + partido + uf ~ nome_votacao,value="voto")
votacoes_long_sort <- votacoes_long[with(votacoes_long,order(partido,nome)),]



votacoes_long2 = cast(votacoes_wide2, id_dep + nome + partido + uf ~ nome_votacao,value="voto")
votacoes_long_sort2 <- votacoes_long2[with(votacoes_long2,order(partido,nome)),]

i <- sapply(votacoes_long_sort2, is.factor)
votacoes_long_sort2[i] <- lapply(votacoes_long_sort2[i], as.character)
votacoes_long_sort2[is.na(votacoes_long_sort2)] <- "não votou"



i <- sapply(votacoes_long_sort, is.factor)
votacoes_long_sort[i] <- lapply(votacoes_long_sort[i], as.character)

votacoes_long_sort[ is.na( votacoes_long_sort ) ] = -1
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "sim"] = 1
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "não"] = 0
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "abstenção"] = -2
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "obstrução"] = -3
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "art. 17  "] = -4

write.csv(votacoes_long_sort,"deputados_votos.csv",row.names = FALSE, quote=FALSE)
write.csv(votacoes_long_sort2,"deputados_votos2.csv",row.names = FALSE, quote=FALSE)
