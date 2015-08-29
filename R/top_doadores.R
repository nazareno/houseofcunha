library(dplyr)
library(ggplot2)

args <- commandArgs(TRUE)

data <- read.table(args[1], sep=";", header = TRUE)

data.filtered <- data %>%
  filter(  Nome.do.doador != 'Diretório Nacional' & 
           Nome.do.doador != 'Diretório Estadual/Distrital' & 
           Nome.do.doador != 'Comitê Financeiro Único' &
             CPF.CNPJ.do.doador > 100000000000) %>%
  group_by(Nome.do.doador, CPF.CNPJ.do.doador) %>%
  summarise(
    valor.total.doacoes = sum(valor.doacoes, na.rm=TRUE),
    numero.total.doacoes = sum(numero.doacoes)
  )

data.plot <- data.filtered[order(desc(data.filtered$valor.total.doacoes)),][1:10,]
format(data.plot, scientific=F)

ggplot(data.plot, aes(x=Nome.do.doador, y=valor.total.doacoes)) + 
  geom_bar(stat='identity') + 
  theme_bw() +
  coord_flip()


write.table(file = args[2], data.filtered, quote = TRUE, sep=";", row.names = F)
