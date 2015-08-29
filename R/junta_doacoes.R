library(dplyr)
library(ggplot2)

args <- commandArgs(TRUE)

data <- read.table(args[1], sep=";", header = TRUE)

data.filtered <- data %>%
  filter(Cargo == 'Deputado Federal') %>%
  mutate(
    Valor.receita = as.integer(gsub(",", "\\.", Valor.receita))
  ) %>%
  group_by(UF, Sigla.Partido, Nome.candidato, CPF.do.candidato, Nome.do.doador, CPF.CNPJ.do.doador,  Tipo.receita, Fonte.recurso, Descrição.da.receita) %>%
  summarise(
    valor.doacoes = sum(Valor.receita, na.rm=TRUE),
    numero.doacoes = length(Valor.receita)
  )

write.table(file = args[2], data.filtered, quote = TRUE, sep=";")
