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

clusterizar <- function(mca,numClusters) {    
  mca.hcpc = HCPC(mca,nb.clust = numClusters)
  mca.hcpc
}

obter_clusters <- function(res.hcpc) {
  clusters <- res.hcpc$data.clust
  clusters <- select(clusters, nome, id_dep, partido, uf, clust)
  clusters$clust <- as.integer(as.character(clusters$clust))
  clusters
}

obter_topN_vars <- function(res.hcpc, n) {
  #variaveis que melhor diferenciam/caracterizam os clusters
  topN_vars <- as.data.frame(res.hcpc$desc.var$test.chi2)[1:n,]
  topN_vars
}

obter_topN_cats_por_cluster <- function(res.hcpc, n) {
  #categorias das variaveis que melhor diferenciam/caracterizam os clusters
  topN_cats <- list()
  categories <- res.hcpc$desc.var$category
  
  for (i in 1:length(categories)) {
    category <- as.data.frame(categories[i])[1:n,]
    topN_cats[[i]] <- category
  }
  topN_cats
}

obter_partidos_por_cluster <- function(clusters) {
  partidos_por_cluster <- list()
  num_clusters = length(unique(clusters$clust))
  for (i in seq(1:num_clusters)) {
    cluster <- filter(clusters,clust == i)
    partidos_por_cluster[[i]] <- aggregate(clust ~ partido, cluster, length)
    partidos_por_cluster[[i]] <- partidos_por_cluster[[i]][order(-partidos_por_cluster[[i]]$clust),]
  }
  partidos_por_cluster
}

obter_cluster_de_deputados_em_destaque <- function(clusters) {
  deputados_em_destaque <-  c("Tiririca", 
                                   "Pr. Marco Feliciano", 
                                   "Jair Bolsonaro", 
                                   "Luiz Couto", 
                                   "Jandira Feghali",
                                   "Jean Wyllys", 
                                   "Veneziano Vital do Rêgo")
  
  posicao_deputados_em_destaque <- filter(clusters, nome %in% deputados_em_destaque)
  posicao_deputados_em_destaque
}

obter_num_cabecas_por_cluster <- function(clusters) {
  cabecas <- read.table("data/cabecas.csv", header=TRUE, quote="\"")
  
  clusters$cabeca <- clusters$nome %in% cabecas$Cabeca
  
  cabecas_por_cluster <- list()
  num_clusters = length(unique(clusters$clust))
  for (i in seq(1:num_clusters)) {
    cluster <- filter(clusters,clust == i)
    cabecas_por_cluster[[i]] <- aggregate(clust ~ cabeca, cluster, length)
  }
  cabecas_por_cluster
}

recuperar_convex_hulls <- function(df) {
  find_hull <- function(df) df[chull(df$Dim.1, df$Dim.2), ]
  hulls <- ddply(df, "clust", find_hull)
  return(hulls)
}

buildClustersPlots <- function(hcpc, mca1_obs_df,pasta_resultados) {
  num_clusters <- length(levels(hcpc$data.clust$clust))
  p <- plotMCAstains(mca1_obs_df, alfa = 0.1)
  colors <- c("outros" = "grey70","pmdb" = "darkred","psdb" = "#56B4E9", "psol" = "#F0E442","pt" = "#FF0000")
  hulls <- recuperar_convex_hulls(mca1_obs_df)
  
  for (i in seq(1:num_clusters)) {
    file_name = paste("c",num_clusters,"_",i,".png",sep="")
    file_path = paste(caminho_pasta_resultados,file_name,sep="/")
    print(file_path)
    png(file_path, width = 800, height = 600)
    plot <- p + geom_polygon(data = hulls[hulls$clust == i,], alpha = 0.05, color = colors[1]) + 
      geom_point(data = filter(mca1_obs_df, clust == i), aes(colour = destaque_partido), size = 7)  +  
      scale_colour_manual(values = colors, 
                          guide = guide_legend(title = "partido", 
                                               override.aes = list(alpha = 1, size = 7))) 
    print(plot)
    dev.off()
  }
  
  file_name = paste("c",num_clusters,"_all.png",sep="")
  file_path = paste(caminho_pasta_resultados,file_name,sep="/")
  print(file_path)
  png(file_path, width = 800, height = 600)
  plot <- p
  for (i in seq(1:num_clusters)) {
    color_index <- as.integer(i%%length(colors))
    plot <- plot + geom_polygon(data = hulls[hulls$clust == i,], alpha = 0.05, color = colors[1])
  }
  plot <- plot + geom_point(data = mca1_obs_df, aes(colour = destaque_partido), size = 7)  +  
    scale_colour_manual(values = colors, 
                        guide = guide_legend(title = "partido", override.aes = list(alpha = 1, size = 7))) 
  print(plot)
  dev.off()
}

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

hcpc <- clusterizar(mca,3)
clusters <- obter_clusters(hcpc)

mca_clusters <- mca1_obs_df
mca_clusters <- cbind(mca_clusters, select(clusters,clust))
mca_clusters$clust <- as.factor(mca_clusters$clust)

buildClustersPlots(hcpc,mca_clusters,caminho_pasta_resultados)

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