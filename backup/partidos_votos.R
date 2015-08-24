setwd("~/Projects/houseofcunha/votacoes_selecionadas")
library(reshape)
library(dplyr)
votacoes = read.csv("votacoes_selecionadas.csv",stringsAsFactors=FALSE)
votacoes_wide = votacoes %>%
        select(orientacao_partido,nome_votacao,partido) %>%
          distinct(orientacao_partido,nome_votacao,partido)

distinct(votacoes_wide,orientacao_partido)

votacoes_wide = rename(votacoes_wide, nome = partido)


votacoes_wide_name = votacoes_wide


votacoes_wide = 
  votacoes_wide %>% 
    mutate(orientacao_partido= ifelse(is.na(orientacao_partido),-5, orientacao_partido))


votacoes_wide = 
  votacoes_wide %>%
  mutate(voto = ifelse(orientacao_partido == "sim", 1,
                                ifelse(orientacao_partido == "não", 0,
                                  ifelse(orientacao_partido == "liberado", -1,
                                    ifelse(orientacao_partido == "abstenção", -2,
                                      ifelse(orientacao_partido == "obstrução", -3,
                                        ifelse(is.na(orientacao_partido),-5,orientacao_partido
                                     )))))))

votacoes_long = cast(votacoes_wide, nome ~ nome_votacao,value="voto")
votacoes_long <-
  votacoes_long%>%
    arrange(nome)

i <- sapply(votacoes_long, is.factor)
votacoes_long[i] <- lapply(votacoes_long[i], as.character)
votacoes_long[is.na(votacoes_long)] <- -10






votacoes_wide_name = 
  votacoes_wide_name %>% 
  mutate(orientacao_partido= ifelse(is.na(orientacao_partido),"sem orientação", orientacao_partido))


votacoes_long_name = cast(votacoes_wide_name, nome ~ nome_votacao,value="orientacao_partido")
votacoes_long_name <-
  votacoes_long_name%>%
    arrange(nome)

i <- sapply(votacoes_long_name, is.factor)
votacoes_long_name[i] <- lapply(votacoes_long_name[i], as.character)
votacoes_long_name[is.na(votacoes_long_name)] <- "não votou"



write.csv(votacoes_long,"partidos_votos.csv",row.names = FALSE, quote=FALSE)
write.csv(votacoes_long_name,"partidos_votos_nomes.csv",row.names = FALSE, quote=FALSE)
