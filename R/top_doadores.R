library(dplyr)
library(ggplot2)

args <- commandArgs(TRUE)

data <- read.table(args[1], sep=";", header = TRUE)

data.filtered <- data %>%
  group_by(CPF.CNPJ.do.doador) %>%
  summarise(
    valor.doacoes = sum(valor.doacoes, na.rm=TRUE),
    numero.doacoes = sum(numero.doacoes)
  ) %>%
  arrange(desc(valor.doacoes))

write.table(file = args[2], data.filtered, quote = TRUE, sep=";", row.names = F)
