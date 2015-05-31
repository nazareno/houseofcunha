
ler_votos_de_ativos <- function(filepath){
  votos <- read.csv(filepath, strip.white=TRUE)
  
  # ajustes nos valores e tipos das variáveis
  votos <- filter(votos, voto %in% c("sim", "não")) 
  votos$voto <- droplevels(votos$voto)
  votos$num_pro <- factor(votos$num_pro)
  #votos$nome <- paste0(votos$nome, " (", votos$partido, ")")
  
  # apenas quem votou em muitas proposições 
  # (espero que seja é deputado em 2015)
  ativos <- votos %>% 
    group_by(nome) %>% 
    summarise(c = n()) %>% 
    filter(c >= 31) %>% 
    select(nome)
  votos <- filter(votos, nome %in% ativos$nome) 
  
}