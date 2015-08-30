#
# Gera um mapa dos deputaods a partir das doações recebidas pelos deputados 
# 
require(dplyr)
require(reshape2)
require(ggplot2)
require(FactoMineR)
source("R/camara-lib.R")

doacoes.todas <- ler_doacoes_de_eleitos(arquivo.doacoes = "data//receitas_todos_deputados_federais.txt", 
                                  arquivo.eleitos = "deputados-detalhes.csv")



doacoes.empresas <- doacoes.todas %>%
  filter((! Nome.do.doador %in% c('Direção Nacional', 
                                  'Direção Estadual/Distrital', 
                                  'Direção Municipal', 
                                  'Comitê Financeiro Nacional para Presidente da República',
                                  'Comitê Financeiro Único')) &
           as.numeric(as.character(CPF.CNPJ.do.doador)) > 100000000000) %>% 
  group_by(Nome.candidato, Nome.do.doador, CPF.CNPJ.do.doador, Sigla..Partido, UF) %>% 
  summarise(
    valor.total.doacoes = sum(valor.doacoes, na.rm=TRUE)
  )

doacoes <- doacoes.empresas %>% 
  group_by(Nome.do.doador, CPF.CNPJ.do.doador) %>%
  summarise(
    valor.total.doacoes = sum(valor.total.doacoes, na.rm=TRUE)
  )

data.plot <- doacoes[order(desc(doacoes$valor.total.doacoes)),][1:10,]

png(file="top-doadores.png", height = 500, width = 650)
ggplot(data.plot, aes(x= reorder(Nome.do.doador,valor.total.doacoes), y=valor.total.doacoes)) + 
  geom_bar(stat='identity') + 
  theme_bw() +
  xlab("Empresa doadora") + 
  ylab("Total doado (R$)") + 
  coord_flip()
dev.off()

# PCA com os principais doadores 
top.empresas <- doacoes[order(desc(doacoes$valor.total.doacoes)), 'CPF.CNPJ.do.doador']
top.doacoes <- doacoes.empresas[doacoes.empresas$CPF.CNPJ.do.doador %in% 
                                  top.empresas$CPF.CNPJ.do.doador[1:20],] 
  
doacoes.cast <- dcast(top.doacoes, 
                      Nome.candidato + Sigla..Partido + UF ~ CPF.CNPJ.do.doador, 
                      value.var = "valor.total.doacoes")

doacoes.pca = PCA(doacoes.cast[,4:23], 
                  scale.unit=TRUE, 
                  ncp=2, 
                  graph=F, 
                  quali.sup = c(1:3))

pca_obs_df = data.frame(doacoes.pca$ind$coord, 
                         nome = doacoes.cast$Nome.candidato,
                         partido = doacoes.cast$Sigla..Partido, 
                         uf = doacoes.cast$UF)

ggplot(data = pca_obs_df, aes(x = Dim.1, y = Dim.2, label = nome)) +
  geom_hline(yintercept = 0, colour = "gray70") +
  geom_vline(xintercept = 0, colour = "gray70") +
  #geom_point(colour = "gray50", alpha = 0.7) +
  geom_text(colour = "gray50", alpha = 0.7, size =3) +
  #geom_density2d(colour = "gray75") +
  ylab("") + xlab("")+ 
  theme_classic() + 
  theme(axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        axis.line = element_blank())


dimdesc(doacoes.pca, axes = 1:2, proba  = 0.05)

