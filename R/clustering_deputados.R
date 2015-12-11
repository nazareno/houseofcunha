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

# args <- commandArgs(trailingOnly = TRUE)
# 
# DEF_NUM_ARGS = 2
# 
# srcFilePath = ""
# experimentName = ""
# 
# if (length(args) < DEF_NUM_ARGS) {
#   print("Wrong number of arguments!")
#   print("Usage:")
#   print("RScript clustering_deputados.R <caminhoPastaBaseHoC> <numClusters>")
#   stop()
# } else {
#   caminhoPastaBaseHoC = args[1]
#   numClusters = as.numeric(args[2])
# }

caminho_pasta_resultados = "plot/clusters"

votos_por_deputado <- recuperar_votos_por_deputado(arquivo.votos = "votacoes.csv",corrigir.migracoes = TRUE)

mca <- MCA(votos_por_deputado, 
           ncp = 2, # Default is 5 
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

#   votos <- ler_votos_de_ativos("votacoes.csv")
#   
#   # Dep que pediram a cassação de Cunha 
#   cassacao.cunha <- read.table("data/cassacao-cunha.csv", header=TRUE, quote="\"")
#   
#   # Bancadas
#   bancada.bala <- read.table("data/bancada-bala.csv", header=TRUE, quote="\"")
#   bancada.humanista <- read.table("data/bancada-humanista.csv", header=TRUE, quote="\"")
#   bancada.sindical <- read.table("data/bancada-sindical.csv", header=TRUE, quote="\"")
#   bancada.evangelica <- read.table("data/bancada-evangelica.csv", header=TRUE, quote="\"")
#   bancada.ruralista <- read.table("data/bancada-ruralista.csv", header=TRUE, quote="\"")
#   cabecas <- read.table("data/cabecas.csv", header=TRUE, quote="\"")
#   deputados <- read.delim("deputados/deputados.csv")
#   
#   # distinguir diferentes votações de uma mesma proposição
#   votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)
#   
#   #Adicionando Cunha como votando nas orientações do PMDB
#   votacao <- recuperar_votacoes(votos)
#   
#   votacao.cast <- dcast(votacao, 
#                         nome + partido + uf + id_dep ~ num_pro, 
#                         value.var = "voto")
#   
#   votacao.cast <- as.data.frame(apply(votacao.cast, 2, as.factor))
#   
#   votacao.cast <- deputadosAtivos(votacao.cast,0.5)
#   
#   mca1_obs_df = votacao.cast
#   
#   # Alguns notáveis
#   mca1_obs_df$destaque <- mca1_obs_df$nome %in% c("Tiririca", 
#                                                   "Pr. Marco Feliciano", 
#                                                   "Jair Bolsonaro", 
#                                                   "Luiz Couto", 
#                                                   "Jandira Feghali",
#                                                   "Jean Wyllys", 
#                                                   "Veneziano Vital do Rêgo")
#   
#   # Destaque dos dep que se tornaram ministros
#   mca1_obs_df$destaque_ministros  <- mca1_obs_df$nome %in% c("Celso Pansera",
#                                                              "André Figueiredo",
#                                                              "Marcelo Castro"
#   )
#   
#   # Destaque dos deputados que participam da bancada bala
#   mca1_obs_df$destaque_bancada_bala <-  mca1_obs_df$nome %in% bancada.bala$Bala
#   
#   # Destaque dos deputados que estão na lista dos cabeças de 2015
# #   mca1_obs_df$destaque_cabeca <- mca1_obs_df$nome %in% cabecas$Cabeca
#   
#   # Destaque dos deputados que participam da bancada humanista
#   mca1_obs_df$destaque_bancada_humanista <-  mca1_obs_df$nome %in% bancada.humanista$Humanista
#   
#   # Bancada Evangelica 
#   mca1_obs_df$destaque_bancada_evangelica <- mca1_obs_df$nome %in% bancada.evangelica$Evangelica
#   
#   # Bancada Ruralista
#   mca1_obs_df$destaque_bancada_ruralista <- mca1_obs_df$nome %in% bancada.ruralista$Ruralista
#   
#   # Bancada Sindical
#   mca1_obs_df$destaque_bancada_sindical <- mca1_obs_df$nome %in% bancada.sindical$Sindical
#   
#   # Destaque dos dep que pediram a cassação de Cunha 
#   mca1_obs_df$destaque_cassacao  <- mca1_obs_df$nome %in% cassacao.cunha$Cassacao
#   
#   # Os da PB
#   mca1_obs_df$destaque_pb <- ifelse(mca1_obs_df$uf == "PB", "PB", "Demais estados")
#   
#   # Partidos icônicos
#   mca1_obs_df$destaque_partido = factor(ifelse(mca1_obs_df$partido %in% 
#                                                  c("pmdb", "psdb", "pt", "psol"), 
#                                                as.character(mca1_obs_df$partido), 
#                                                "outros"))
#   
#   
#   mca1_obs_df$destaque_cassacao_partido <-  ifelse(mca1_obs_df$destaque_cassacao == TRUE, as.character(mca1_obs_df$destaque_partido ), "não assinaram")
#   
#   mca1_obs_df$destaque_cassacao_pt <-  ifelse(as.character(mca1_obs_df$partido) == "pt", ifelse(mca1_obs_df$destaque_cassacao == TRUE, "assinaram", "não assinaram"), "outros partidos")

#MCA
#   mca1 = MCA(mca1_obs_df, 
#              ncp = 2, # Default is 5 
#              graph = FALSE,
#              quali.sup = c(1:4,261:274),
#              na.method = "Average") # NA or Average

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

buildClustersPlots <- function(hcpc, mca1_obs_df,pasta_resultados) {
  num_clusters <- length(levels(hcpc$data.clust$clust))
  print(num_clusters)
  p <- plotMCAstains(mca1_obs_df, alfa = 0.1)
  colors <- c("red","green","blue","orange")
  
  for (i in seq(1:num_clusters)) {
    c1 <- geom_point(data = filter(mca1_obs_df, clust == i), 
                     aes(x = Dim.1, y = Dim.2, label = nome), 
                     colour = "red", alpha = 0.5, size = 6)
    c1_ellipse <- stat_ellipse(data = filter(mca1_obs_df, clust == i),  
                               aes(x = Dim.1, y = Dim.2, label = nome), colour = "red",
                               type = "norm")
    plot_name = paste("c",num_clusters,"_",i,".png",sep="")
    plot_path = paste(pasta_resultados,plot_name,sep="/")
    print(plot_path)
    png(plot_path, width = 800, height = 600)
    p + c1 + c1_ellipse
    dev.off()
  }
}

recuperar_convex_hulls <- function(df) {
  find_hull <- function(df) df[chull(df$Dim.1, df$Dim.2), ]
  hulls <- ddply(df, "clust", find_hull)
  return(hulls)
}

hcpc <- clusterizar(mca,2)
clusters <- obter_clusters(hcpc)

mca1_obs_df <- cbind(mca1_obs_df, select(clusters,clust))
mca1_obs_df$clust <- as.factor(mca1_obs_df$clust)

buildClustersPlots(hcpc,mca1_obs_df,caminho_pasta_resultados)

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

#getting the convex hull of each unique point set
hulls <- recuperar_convex_hulls(mca1_obs_df)

p <- plotMCAstains(mca1_obs_df, alfa = 0.1)

paleta_partidos <- c("grey70", "darkred", "#56B4E9", "#F0E442", "#FF0000", "#0072B2", "#009E73", "#CC79A7")

paleta_partidos_small <- c("grey70", "darkred", "#FF0000", "#0072B2", "#009E73", "#CC79A7")

png(paste(caminho_pasta_resultados,"c2_1.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 1,], alpha = 0.05, color = "red") + 
  geom_point(data = filter(mca1_obs_df, clust == 1), aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos_small, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()


png(paste(caminho_pasta_resultados,"c2_2.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 2,], alpha = 0.05, color = "blue") + 
  geom_point(data = filter(mca1_obs_df, clust == 2), aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()


png(paste(caminho_pasta_resultados,"c2_all.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 1,], alpha = 0.05, color = "red") + 
  geom_polygon(data = hulls[hulls$clust == 2,], alpha = 0.05, color = "blue") +
  geom_point(data = mca1_obs_df, aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()

######################## cluster size = 3 #########################################

hcpc <- clusterizar(mca,3)
clusters <- obter_clusters(hcpc)

mca1_obs_df <- cbind(mca1_obs_df, select(clusters,clust))
mca1_obs_df$clust <- as.factor(mca1_obs_df$clust)

hulls <- recuperar_convex_hulls(mca1_obs_df)

png(paste(caminho_pasta_resultados,"c3_1.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 1,], alpha = 0.05, color = "red") + 
  geom_point(data = filter(mca1_obs_df, clust == 1), aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos_small, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()


png(paste(caminho_pasta_resultados,"c3_2.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 2,], alpha = 0.05, color = "orange") + 
  geom_point(data = filter(mca1_obs_df, clust == 2), aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()

png(paste(caminho_pasta_resultados,"c3_3.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 3,], alpha = 0.05, color = "blue") + 
  geom_point(data = filter(mca1_obs_df, clust == 3), aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()


png(paste(caminho_pasta_resultados,"c3_all.png",sep="/"), width = 800, height = 600)
p + geom_polygon(data = hulls[hulls$clust == 1,], alpha = 0.05, color = "red") + 
  geom_polygon(data = hulls[hulls$clust == 2,], alpha = 0.05, color = "orange") +
  geom_polygon(data = hulls[hulls$clust == 3,], alpha = 0.05, color = "blue") +
  geom_point(data = mca1_obs_df, aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = paleta_partidos, 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()
