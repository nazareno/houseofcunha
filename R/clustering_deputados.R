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
  
  # distinguir diferentes votações de uma mesma proposição
  votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)
  
  #Adicionando Cunha como votando nas orientações do PMDB
  votacao <- votos %>% 
    select(nome, partido, uf, num_pro, voto)
  
  ec.v <- votos %>% 
    select(num_pro, cunha) %>% 
    filter(cunha %in% c("sim", "não")) %>% 
    unique()
  
  ec <- cbind(data.frame(nome = "Eduardo Cunha", 
                         partido = "pmdb", 
                         uf = "rj"), 
              ec.v)
  names(ec) <- names(votacao)
  # esse é o df com cunha:
  votacao.cc <- rbind(votacao, ec)
  
  votacao.cast <- dcast(votacao.cc, 
                        nome + partido + uf ~ num_pro, 
                        value.var = "voto")
  
  votacao.cast <- as.data.frame(apply(votacao.cast, 2, as.factor))
  
  #MCA
  mca1 = MCA(votacao.cast, 
             ncp = 2, # Default is 5 
             graph = TRUE,
             quali.sup = c(1:3),
             na.method = "Average") # NA or Avarege
  
  summary(mca1)
  
  mca1.hcpc = HCPC(mca1,nb.clust = numClusters)
}

# clusterizar(caminhoPastaBaseHoC,numClusters)



