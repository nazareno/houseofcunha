#Clusteriza o resultado do MCA sobre os dados dos deputados federais considerando os votos em cada proposição. 

#Bibliotecas necessárias 
library(ggplot2)
library(plyr)
library(dplyr)
library(reshape2)
require(cluster)
require(ade4)
require(scales)
require(FactoMineR)
require(rCharts)
source("R/camara-lib.R")

caminho_pasta_resultados = "plot/clusters"

votos_por_deputado <- recuperar_votos_por_deputado(arquivo.votos = "votacoes.csv",corrigir.migracoes = TRUE)

mca <- MCA(votos_por_deputado, 
           ncp = 6, # Default is 5 
           graph = FALSE,
           quali.sup = c(1:4),
           na.method = "Average") # NA or Average

mca1_obs_df <-  data.frame(mca$ind$coord, 
                           nome = votos_por_deputado$nome,
                           partido = votos_por_deputado$partido, 
                           uf = votos_por_deputado$uf,
                           id_dep = votos_por_deputado$id_dep)

mca1_obs_df$id_dep <- as.integer(as.character(mca1_obs_df$id_dep))

#Partidos icônicos
mca1_obs_df$destaque_partido = factor(ifelse(mca1_obs_df$partido %in% 
                                               c("pmdb", "psdb", "pt", "psol"), 
                                             as.character(mca1_obs_df$partido), 
                                             "outros"))

hcpc <- clusterizar(mca, 2)
clusters <- obter_clusters(hcpc)

mca_clusters <- mca1_obs_df
mca_clusters <- cbind(mca_clusters, select(clusters,clust))
mca_clusters$clust <- as.factor(mca_clusters$clust)

buildClustersPlots(hcpc,mca_clusters,caminho_pasta_resultados, cores = c("#fdcdac", "#f4cae4", "#b3e2cd", "#cbd5e8"))

partidos_por_cluster <- obter_partidos_por_cluster(clusters)
posicao_deputados_em_destaque <- obter_cluster_de_deputados_em_destaque(clusters)
cabecas_por_cluster <- obter_num_cabecas_por_cluster(clusters)

top10_vars <- obter_topN_vars(hcpc,10)

top10_cats <- obter_topN_cats_por_cluster(hcpc,10)

#descrição do HCPC pelas dimensões do MCA
hcpc$desc.axes

#descriçao do HCPC utilizando os individuos que estao mais perto do centro e mais longe dos outros clusters para cada cluster
#interessante para ver os individuos que representam a media do cluster
hcpc$desc.ind