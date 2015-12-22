require(FactoMineR)
library(plyr)
library(dplyr)

source("R/camara-lib.R")

caminho_base_resultados = "plot"
pasta_resultados = "analise_proposicoes"

ifelse(!dir.exists(file.path(caminho_base_resultados, pasta_resultados)), dir.create(file.path(caminho_base_resultados, pasta_resultados)), FALSE)

caminho_pasta_resultados = paste(caminho_base_resultados,pasta_resultados,sep="/")

votos_geral <- ler_votos_de_ativos(filepath = "votacoes.csv",corrigir_migracoes = TRUE)

votos_por_deputado <- recuperar_votos_por_deputado(arquivo.votos = "votacoes.csv",corrigir.migracoes = TRUE)

proposicao <- 171
id_votacao <- 4
posicionamento <- "não"

votos_prop <- recuperar_votos_proposicao(votos_df = votos_por_deputado, numero.prop = proposicao)

votos_geral_prop <- votos_geral[votos_geral$num_pro == proposicao & votos_geral$id_votacao == id_votacao,]

votacao <- paste(as.character(proposicao),as.character(id_votacao),sep="-")

summary(votos_prop[votos_prop[[votacao]] %in% c(posicionamento),])

########## Análise MCA ##########

#MCA
mca.res = MCA(votos_prop, 
              ncp = 2, # Default is 5 
              graph = TRUE,
              quali.sup = c(1:4),
              na.method = "Average") # NA or Average

summary(mca.res)

# Top contribuição das variaveis
top_contrib <- head(as.data.frame(mca.res$var$contrib))
top_contrib

# Top extremos
var_coord <- as.data.frame(mca.res$var$coord)

top_5_dim1 <- head(var_coord[order(var_coord$"Dim 1", decreasing=TRUE),], n=5)
top_5_dim1

bottom_5_dim1 <- tail(var_coord[order(var_coord$"Dim 1", decreasing=TRUE),], n=5)
bottom_5_dim1



########## Análise HCPC ##########

#HCPC
hcpc <- HCPC(mca.res, nb.clust = 2)
dev.off()
clusters <- obter_clusters(hcpc)

mca_pontos_df <- recuperar_df_pontos_mca(mca.res,votos_por_deputado)
mca_pontos_df <- add_col_partidos_iconicos(mca_pontos_df)
mca_pontos_df$clust <- as.factor(clusters$clust)

hist(clusters$clust)

partidos_por_cluster <- obter_partidos_por_cluster(clusters)
partidos_por_cluster

top10_cats <- obter_topN_cats_por_cluster(hcpc,10)
top10_cats

buildClustersPlots(hcpc,mca_pontos_df,caminho_pasta_resultados)

########## Análise Votações ##########
votos_geral_prop <- votos_geral[votos_geral$num_pro == proposicao,]
