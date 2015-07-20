library(reshape2)
votacoes = read.csv("votacoes_selecionadas.csv",stringsAsFactors=FALSE)
votacoes_wide = votacoes[,c("id_dep","nome","voto","nome_votacao","partido","uf")]
votacoes_long = cast(votacoes_wide, id_dep + nome + partido + uf ~ nome_votacao,value="voto")
votacoes_long_sort <- votacoes_long[with(votacoes_long,order(partido,nome)),]
votacoes_long_sort = as.character(votacoes_long_sort)

i <- sapply(votacoes_long_sort, is.factor)
votacoes_long_sort[i] <- lapply(votacoes_long_sort[i], as.character)


votacoes_long_sort[ is.na( votacoes_long_sort ) ] = -1
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "sim"] = 1
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "não"] = 0
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "abstenção"] = -2
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "obstrução"] = -3
votacoes_long_sort[,5:19][votacoes_long_sort[,5:19] == "art. 17  "] = -4

write.csv(votacoes_long_sort,"deputados_votos.csv",row.names = FALSE, quote=FALSE)
