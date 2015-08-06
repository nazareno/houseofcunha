
ler_votos_de_ativos <- function(filepath){
  votos <- read.csv(filepath, strip.white=TRUE, quote="")
  
  # ajustes nos valores e tipos das variáveis
  votos <- filter(votos, voto %in% c("sim", "não")) 
  votos$voto <- droplevels(votos$voto)
  votos$num_pro <- factor(votos$num_pro)
  votos$uf <- droplevels(votos$uf)
  
  # apenas quem votou em muitas proposições 
  # (espero que seja é deputado em 2015)
  ativos <- votos %>% 
    group_by(nome) %>% 
    summarise(c = n()) %>% 
    filter(c >= 31) %>% 
    select(nome)
  votos <- filter(votos, nome %in% ativos$nome) 

  # Cabo Daciolo aparece com duas afiliações. 
  # Usar apenas a última
  votos[votos$nome == "Cabo Daciolo", "partido"] <- "s.part."
  
  votos
}