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
  summarise(valor.total.doacoes = sum(valor.total.doacoes, na.rm=TRUE)) %>% 
  ungroup() %>% 
  arrange(-valor.total.doacoes)

top5.empresas <- doacoes.empresas.totais[1:5,]

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


###
# PCA!
### 

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

