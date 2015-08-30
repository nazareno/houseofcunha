#
# Gera um mapa dos deputaods a partir das doações recebidas pelos deputados 
# 
require(reshape2)
require(ggplot2)
require(FactoMineR)
require(dplyr)
source("R/camara-lib.R")

doacoes.todas <- ler_doacoes_de_eleitos(arquivo.doacoes = "data//receitas_todos_deputados_federais.txt", 
                                        arquivo.eleitos = "deputados-detalhes.csv")
# Mapeando CPF/CNPJ -> Nome único (o 1o que acontece)
doacoes.todas <- adiciona_nomes_corrigidos(doacoes.todas)

###############
# Descritivo
###############

# CNPJs das direções e comitês
cnpjs.comites <- doacoes.todas %>% 
  filter(Nome.do.doador %in% c('Direção Nacional', 
                               'Direção Estadual/Distrital', 
                               'Direção Municipal', 
                               'Comitê Financeiro Nacional para Presidente da República',
                               'Comitê Financeiro Único')) %>%
  select(CPF.CNPJ.do.doador) %>% 
  unique()

total <- doacoes.todas %>% summarise(doado  = sum(valor.doacoes))

doacoes.comites <- doacoes.todas %>% 
  filter(CPF.CNPJ.do.doador %in% cnpjs.comites$CPF.CNPJ.do.doador) %>% 
  group_by(CPF.CNPJ.do.doador, Nome.doador.corrigido) %>% 
  summarise(doado = sum(valor.doacoes))

print(paste0("Proporção das doações que vem de comitês e diretórios: ", sum(doacoes.comites$doado) / sum(total$doado)))

ggplot(doacoes.comites, aes(x = reorder(Nome.doador.corrigido, doado), y = doado / 1e6)) + 
  geom_bar(stat='identity') + 
  theme_bw() + 
  scale_y_continuous(labels=function(n){format(n, scientific = FALSE)}) + 
  ylab('Milhões doados') + 
  xlab('') + 
  coord_flip()

## Doações de empresas: 
doacoes.empresas <- doacoes.todas %>%
  filter(! (CPF.CNPJ.do.doador %in% cnpjs.comites$CPF.CNPJ.do.doador)) %>% 
  filter(as.numeric(as.character(CPF.CNPJ.do.doador)) > 100000000000) %>% 
  group_by(Nome.candidato, Nome.doador.corrigido, Sigla..Partido, UF, CPF.CNPJ.do.doador) %>% 
  summarise(
    valor.total.doacoes = sum(valor.doacoes, na.rm=TRUE)
  )

doacoes.empresas.totais <- doacoes.empresas %>% 
  group_by(Nome.doador.corrigido, CPF.CNPJ.do.doador) %>%
  summarise(valor.total.doacoes = sum(valor.total.doacoes, na.rm=TRUE), 
            numero.de.candidatos = n()) %>% 
  ungroup() %>% 
  arrange(-valor.total.doacoes)

top5.empresas <- doacoes.empresas.totais[1:5,]

# Doações PF
doacoes.pf.totais <- doacoes.todas %>%
  filter(! (CPF.CNPJ.do.doador %in% cnpjs.comites$CPF.CNPJ.do.doador)) %>% 
  filter(as.numeric(as.character(CPF.CNPJ.do.doador)) < 100000000000) %>% 
  group_by(Nome.doador.corrigido, CPF.CNPJ.do.doador) %>% 
  summarise( 
    valor.total.doacoes = sum(valor.doacoes, na.rm=TRUE)
  ) %>% ungroup() %>% arrange(-valor.total.doacoes)
write.csv2(doacoes.pf.totais, "data/doacoes-por-pf.csv", row.names=F)
require(rCharts)
write(toJSONArray(doacoes.pf.totais), "data/doacoes-pf-tentativa.json")

p <- ggplot(doacoes.empresas.totais, 
            aes(x = 1:NROW(doacoes.empresas.totais), 
                y = valor.total.doacoes / 1e6)) + 
  geom_point(size = 3, alpha = 0.8) +
  geom_text(data = top5.empresas, 
            aes(x = 1:NROW(top5.empresas), 
                y = valor.total.doacoes / 1e6, 
                label = Nome.doador.corrigido), 
            hjust = -.03, 
            size = 4, 
            colour = "grey20") + 
  ylab("Milhões de reais doados") + 
  xlab("Ranking do doador") + 
  theme_bw() + 
  scale_y_continuous(labels=function(n){format(n, scientific = FALSE)}) + 
  scale_x_log10()
p
png("top-empresas-doadoras.png", 600, 600)
p
dev.off()

# Ver empresas mais e menos doadoras em número de candidatos
top5.maiscandidatos <- arrange(doacoes.empresas.totais, -numero.de.candidatos)[1:5,]
p <- ggplot(arrange(doacoes.empresas.totais, -numero.de.candidatos), 
            aes(x = 1:NROW(doacoes.empresas.totais), 
                y = numero.de.candidatos)) + 
  geom_point(size = 3, alpha = 0.7) + 
  geom_text(data = top5.maiscandidatos, 
            aes(x = 1:NROW(top5.maiscandidatos), 
                y = numero.de.candidatos, 
                label = Nome.doador.corrigido), 
            hjust = -.03, 
            size = 4, 
            colour = "grey20") + 
  ylab("Candidatos financiados") + 
  xlab("Ranking do doador") + 
  theme_bw() + 
  scale_y_continuous(labels=function(n){format(n, scientific = FALSE)}) + 
  scale_x_log10()

p
png("top-empresas-numero-candidatos.png", 600, 600)
p
dev.off()

###
# PCA!
### 
doacoes.empresas.partido <- doacoes.empresas %>% 
  group_by(Nome.doador.corrigido, CPF.CNPJ.do.doador, Sigla..Partido) %>% 
  summarise(doado = sum(valor.total.doacoes))

top.empresas <- doacoes.empresas.totais[1:100, 'CPF.CNPJ.do.doador']

top.doacoes.candidato <- doacoes.empresas[doacoes.empresas$CPF.CNPJ.do.doador %in% 
                                   top.empresas$CPF.CNPJ.do.doador,] 

top.doacoes <- doacoes.empresas.partido[doacoes.empresas.partido$CPF.CNPJ.do.doador %in% 
                                  top.empresas$CPF.CNPJ.do.doador,] 

x <- top.doacoes.candidato
x$Candidato <- paste0(x$Nome.candidato, "(", x$Sigla..Partido, "-", x$UF, ")")
doacoes.cast.candidato <- dcast(x, 
                       Candidato ~ Nome.doador.corrigido, 
                       fun.aggregate = sum,
                       value.var = "valor.total.doacoes")

doacoes.cast <- dcast(top.doacoes, 
                      Sigla..Partido ~ Nome.doador.corrigido, 
                      fun.aggregate = sum,
                      value.var = "doado")

# PCA Por partido:

doacoes.pca = PCA(doacoes.cast[,2:100], 
                  scale.unit=T, 
                  ncp=2, 
                  graph=T, 
                  quali.sup = c(1:3))

pca_obs_df = data.frame(doacoes.pca$ind$coord, 
                         partido = doacoes.cast$Sigla..Partido)

dimexps <- data.frame(doacoes.pca$var$coord)
dimexps$empresas <- row.names(dimexps)
dimexps %>% filter(Dim.1 > 0.2)

p <- ggplot(data = pca_obs_df, aes(x = Dim.1, y = Dim.2, label = partido)) +
  geom_hline(yintercept = 0, colour = "gray70") +
  geom_vline(xintercept = 0, colour = "gray70") +
  #geom_point(colour = "gray50", alpha = 0.7) +
  geom_text(colour = "gray10", alpha = 0.7, size =4) +
  #geom_density2d(colour = "gray75") +
  ylab("") + xlab("")+ 
  theme_classic() + 
  ylim(-7, 18) + 
  xlim(-7, 16) + 
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.line = element_blank())
p
png("mapa-doacoes-partidos.png", width = 800, height = 600)
p
dev.off()

write.csv2(pca_obs_df, "pca-partidos.csv", row.names = F)
write(toJSONArray(pca_obs_df), "pca-partidos.json")
dimdesc(doacoes.pca, axes = 1:2, proba  = 0.01)

##################
# Agrupamento
##################
require(cluster)
pro.cluster <- doacoes.cast.candidato[,2:100]
row.names(pro.cluster) <- doacoes.cast.candidato[,1]
clustering <- agnes(pro.cluster, 
                    metric = "manhattan", 
                    method = "ward")

# cluster = hclust(doacoes.cast.candidato, method = "ward.D")
plot(clustering)

require(ggdendro)
png("dendrogram.png", height = 2000, width = 1200)
ggdendrogram(as.dendrogram(clustering), rotate = TRUE, size = 4, theme_dendro = T, color = "tomato")
dev.off()

library(dendextend)
library(circlize)

# create a dendrogram
dend <- as.dendrogram(clustering)

# modify the dendrogram to have some colors in the branches and labels
# dend <- dend %>% 
#   color_branches(k=4) %>% 
#   color_labels

# plot the radial plot
par(mar = rep(0,4))
# circlize_dendrogram(dend, dend_track_height = 0.8) 
png("circular.png", h = 1500, w = 1500)
circlize_dendrogram(dend, labels_track_height = 0.05, dend_track_height = .8) 
dev.off()
