#Clusteriza o resultado do MCA sobre os dados dos deputados federais considerando os votos em cada proposição. 

#Bibliotecas necessárias 
library(ggplot2)
library(dplyr)
library(reshape2)
require(cluster)
require(ade4)
require(scales)
require(FactoMineR)
require(rCharts)

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

clusterizar <- function(caminhoPastaBaseHoC,numClusters) {
  setwd(caminhoPastaBaseHoC)
  
  source("R/camara-lib.R")
  votos <- ler_votos_de_ativos("votacoes.csv")
  
  # Dep que pediram a cassação de Cunha 
  cassacao.cunha <- read.table("data/cassacao-cunha.csv", header=TRUE, quote="\"")
  
  # Bancadas
  bancada.bala <- read.table("data/bancada-bala.csv", header=TRUE, quote="\"")
  bancada.humanista <- read.table("data/bancada-humanista.csv", header=TRUE, quote="\"")
  bancada.sindical <- read.table("data/bancada-sindical.csv", header=TRUE, quote="\"")
  bancada.evangelica <- read.table("data/bancada-evangelica.csv", header=TRUE, quote="\"")
  bancada.ruralista <- read.table("data/bancada-ruralista.csv", header=TRUE, quote="\"")
  deputados <- read.delim("deputados/deputados.csv")
  
  # distinguir diferentes votações de uma mesma proposição
  votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)
  
  #Adicionando Cunha como votando nas orientações do PMDB
  votacao <- recuperar_votacoes(votos)
  
  votacao.cast <- dcast(votacao, 
                        nome + partido + uf + id_dep ~ num_pro, 
                        value.var = "voto")
  
  votacao.cast <- as.data.frame(apply(votacao.cast, 2, as.factor))
  
  mca1_obs_df = votacao.cast
  
  deputados <- select(deputados, ideCadastro, condicao, sexo)
  
  
  # To plot
  mca1_obs_df$id_dep <- as.integer(as.character(mca1_obs_df$id_dep))
  mca1_obs_df <- left_join(mca1_obs_df, deputados, by = c("id_dep" = "ideCadastro"))
  #write.csv2(mca1_obs_df, "mapas_votacoes.csv", row.names = FALSE)
  
  # Alguns notáveis
  mca1_obs_df$destaque <- mca1_obs_df$nome %in% c("Tiririca", 
                                                  "Pr. Marco Feliciano", 
                                                  "Jair Bolsonaro", 
                                                  "Luiz Couto", 
                                                  "Jandira Feghali",
                                                  "Jean Wyllys", 
                                                  "Veneziano Vital do Rêgo")
  
  # Destaque dos dep que se tornaram ministros
  mca1_obs_df$destaque_ministros  <- mca1_obs_df$nome %in% c("Celso Pansera",
                                                             "André Figueiredo",
                                                             "Marcelo Castro"
  )
  
  # Destaque dos deputados que participam da bancada bala
  mca1_obs_df$destaque_bancada_bala <-  mca1_obs_df$nome %in% bancada.bala$Bala
  
  # Destaque dos deputados que estão na lista dos cabeças de 2015
#   mca1_obs_df$destaque_cabeca <- mca1_obs_df$nome %in% cabecas$Cabeca
  
  # Destaque dos deputados que participam da bancada humanista
  mca1_obs_df$destaque_bancada_humanista <-  mca1_obs_df$nome %in% bancada.humanista$Humanista
  
  # Bancada Evangelica 
  mca1_obs_df$destaque_bancada_evangelica <- mca1_obs_df$nome %in% bancada.evangelica$Evangelica
  
  # Bancada Ruralista
  mca1_obs_df$destaque_bancada_ruralista <- mca1_obs_df$nome %in% bancada.ruralista$Ruralista
  
  # Bancada Sindical
  mca1_obs_df$destaque_bancada_sindical <- mca1_obs_df$nome %in% bancada.sindical$Sindical
  
  # Destaque dos dep que pediram a cassação de Cunha 
  mca1_obs_df$destaque_cassacao  <- mca1_obs_df$nome %in% cassacao.cunha$Cassacao
  
  # Os da PB
  mca1_obs_df$destaque_pb <- ifelse(mca1_obs_df$uf == "PB", "PB", "Demais estados")
  
  # Partidos icônicos
  mca1_obs_df$destaque_partido = factor(ifelse(mca1_obs_df$partido %in% 
                                                 c("pmdb", "psdb", "pt", "psol"), 
                                               as.character(mca1_obs_df$partido), 
                                               "outros"))
  
  
  mca1_obs_df$destaque_cassacao_partido <-  ifelse(mca1_obs_df$destaque_cassacao == TRUE, as.character(mca1_obs_df$destaque_partido ), "não assinaram")
  
  mca1_obs_df$destaque_cassacao_pt <-  ifelse(as.character(mca1_obs_df$partido) == "pt", ifelse(mca1_obs_df$destaque_cassacao == TRUE, "assinaram", "não assinaram"), "outros partidos")
  
  #MCA
#   mca1 = MCA(mca1_obs_df, 
#              ncp = 2, # Default is 5 
#              graph = FALSE,
#              quali.sup = c(1:4,261:274),
#              na.method = "Average") # NA or Average

  mca1 = MCA(votacao.cast, 
           ncp = 2, # Default is 5 
           graph = FALSE,
           quali.sup = c(1:4),
           na.method = "Average") # NA or Average
    
  mca1.hcpc = HCPC(mca1,nb.clust = numClusters)
  mca1.hcpc
}

obter_clusters <- function(res.hcpc) {
  clusters <- res.hcpc$data.clust
  clusters <- select(clusters, nome, partido, uf, clust)
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

# clusterizar(caminhoPastaBaseHoC,numClusters)
hcpc <- clusterizar("./",3)
clusters <- obter_clusters(hcpc)

top10_vars <- obter_topN_vars(hcpc,10)

top10_cats <- obter_topN_cats_por_cluster(hcpc,10)

#descrição do HCPC pelas dimensões do MCA
hcpc$desc.axes

#descriçao do HCPC utilizando os individuos que estao mais perto do centro e mais longe dos outros clusters para cada cluster
#interessante para ver os individuos que representam a media do cluster
hcpc$desc.ind
