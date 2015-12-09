# Comparação das chapas do governo e 
# oposição para formar a chapa especial de 
# análise do impeachment.

library(ggplot2)
library(reshape2)
require(cluster)
require(ade4)
require(scales)
require(FactoMineR)
library(dplyr)

source("R/camara-lib.R")

caminho_pasta_resultados = "plot/impeachment_vs_cons_etica"

votos_por_deputado <- recuperar_votos_por_deputado(arquivo.votos = "votacoes.csv",corrigir.migracoes = TRUE)

conselho.etica <- read.table("data/conselho-de-etica.csv", header=TRUE, quote="\"")
chapas <- read.csv("data/chapas-impeachment.csv", header=TRUE)
deputados <- read.delim("deputados/deputados.csv")

chapas$chapa <- chapas$comissão
chapas$comissão <- NULL
indicados <- filter(chapas, chapa != "")
indicados$chapa <- droplevels(indicados$chapa)

indicados <- within(indicados, 
                    partido <- factor(partido, 
                                      levels = names(sort(table(partido), decreasing = F)), 
                                      ordered = TRUE))

# # Barplot das composições do conselho de ética vs. a comissão de impeachment.
# p <- ggplot() + 
#   geom_bar(data = indicados,
#            aes(x = partido, y = ..count.. * 0)) +
#   geom_bar(data = filter(indicados, chapa == "oposição"),
#            aes(x = partido, fill = chapa)) + 
#   geom_bar(data = filter(indicados, chapa == "governista"),
#            aes(x = partido, fill = chapa, y = ..count..*(-1))) + 
#   scale_y_continuous(breaks=seq(-10,10,5),labels=abs(seq(-10,10,5))) + 
#   ylab("Quantos deputados") + scale_fill_brewer(palette = "Set2") +  
#   coord_flip() + theme_bw() + theme(panel.border = element_blank())
# p
# png("plot/impeachment/chapas-impeachment.png", 
#     width = 800, height = 550)
# p
# dev.off()

# No mapa:
mca1 = MCA(votos_por_deputado, 
           ncp = 2, # Default is 5 
           graph = FALSE,
           quali.sup = c(1:4),
           na.method = "Average") # NA or Average

# data frame with observation coordinates
mca1_obs_df = data.frame(mca1$ind$coord, 
                         nome = votos_por_deputado$nome,
                         partido = votos_por_deputado$partido, 
                         uf = votos_por_deputado$uf,
                         id_dep = votos_por_deputado$id_dep)

# To plot
mca1_obs_df$id_dep <- as.integer(as.character(mca1_obs_df$id_dep))
mca1_obs_df$destaque_partido = factor(ifelse(mca1_obs_df$partido %in% 
                                               c("pmdb", "psdb", "pt", "psol"), 
                                             as.character(mca1_obs_df$partido), 
                                             "outros"))
mca1_obs_df <- left_join(mca1_obs_df, select(indicados, ideCadastro, chapa), by = c("id_dep" = "ideCadastro"))

# Destaque dos deputados que participam do conselho de ética
mca1_obs_df$conselho_etica <- mca1_obs_df$nome %in% conselho.etica$Deputados

p <- plotMCAstains(mca1_obs_df, alfa = 0.1)

# Referência geral
png("plot/visao-geral-pontos.png", width = 800, height = 600)
p + geom_point(aes(colour = destaque_partido), size = 7)  +  
  scale_colour_manual(values = c(alpha("grey70", .05), 
                                 alpha("darkred", .6), 
                                 alpha("#0066CC", .6),
                                 alpha("#E69F00", .6),
                                 alpha("#FF3300", .6)), 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 7))) 
dev.off()

# Conselho de ética, sem nomes
c1 <- geom_point(data = filter(mca1_obs_df, conselho_etica == TRUE), 
                 aes(x = Dim.1, y = Dim.2, label = nome), 
                 colour = "blue", alpha = 0.5, size = 6) 
png(paste(caminho_pasta_resultados,"conselho-etica-pontos.png",sep="/"), width = 800, height = 600)
p + c1 
dev.off()

png(paste(caminho_pasta_resultados,"conselho-etica-pontos-e-nomes.png",sep="/"), width = 800, height = 600)
p + c1 + geom_text(data = filter(mca1_obs_df, conselho_etica == TRUE), 
                   aes(x = Dim.1, y = Dim.2, label = paste(nome, "-", toupper(partido))),
                   check_overlap = TRUE,
                   colour = "blue", alpha = 0.5, size = 3.5, hjust = 0.5, vjust = 1.9)
dev.off()

# Chapa eleita (oposição), sem nomes
c2 <- geom_point(data = filter(mca1_obs_df, chapa == "oposição"), 
                 aes(x = Dim.1, y = Dim.2, label = nome), 
                 colour = "darkcyan", alpha = 0.5, size = 6)
png(paste(caminho_pasta_resultados,"chapa-oposicao-pontos.png",sep="/"), width = 800, height = 600)
p + c2 
dev.off()

png(paste(caminho_pasta_resultados,"conselho-etica-vs-chapa-oposicao-pontos.png",sep="/"), width = 800, height = 600)
p + c1 + c2
dev.off()

# png("plot/impeachment/chapas-as-duas-pontos-e-manchas.png", width = 800, height = 600)
# p + c1 + c2 + stat_density2d(aes(fill = chapa, #colour = chapa,
#                                  alpha = ..level..),
#                              geom = "polygon") +  
#   scale_alpha(range = c(0, 1/3), guide = "none") 
# dev.off()

png(paste(caminho_pasta_resultados,"chapa-oposicao-pontos-e-nomes.png",sep="/"), width = 800, height = 600)
p + c2 + geom_text(data = filter(mca1_obs_df, chapa == "oposição"), 
                   aes(x = Dim.1, y = Dim.2, label = paste(nome, "-", toupper(partido))),
                   check_overlap = TRUE,
                   colour = "darkcyan", alpha = 0.5, size = 3.5, hjust = 0.5, vjust = 1.9)
dev.off()

# p + stat_density2d(aes(fill = destaque_partido, colour = destaque_partido,
#                        alpha = ..level.., 
#                        size = ..level..),
#                    geom = "polygon") +  
#   scale_alpha(range = c(0, 1/2), guide = "none") + 
#   scale_size(range = c(0, 6/2), guide = "none")
# 
# p + stat_density2d(aes(fill = chapa, #colour = chapa,
#                        alpha = ..level.., 
#                        size = ..level..),
#                    geom = "polygon") +  
#   scale_alpha(range = c(0, 1/2), guide = "none") 