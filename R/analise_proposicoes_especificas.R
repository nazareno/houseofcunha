require(FactoMineR)
library(plyr)
library(dplyr)

source("R/camara-lib.R")

caminho_base_resultados = "plot"
pasta_resultados = "analise_proposicoes"

ifelse(!dir.exists(file.path(caminho_base_resultados, pasta_resultados)), dir.create(file.path(caminho_base_resultados, pasta_resultados)), FALSE)

votos_por_deputado <- recuperar_votos_por_deputado(arquivo.votos = "votacoes.csv",corrigir.migracoes = TRUE)

hcpc <- clusterizar_deputados_por_proposicao(votos_por_deputado,182)
clusters <- obter_clusters(hcpc)

partidos_por_cluster <- obter_partidos_por_cluster(clusters)
partidos_por_cluster

# coords <- as.data.frame(mca1$ind$coord)
# 
# stripchart(mca1$ind$coord, method="jitter")
