
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
  descartados <- filter(votos, !(nome %in% ativos$nome)) %>% select(nome, uf, partido)
  print("Descartados por inatividade: ")
  print(descartados)

  # Cabo Daciolo aparece com duas afiliações. 
  # Usar apenas a última
  votos[votos$nome == "Cabo Daciolo", "partido"] <- "s.part."
  # Evandro Roman aparece com dois nomes
  votos[votos$nome == "Evandro Rogerio Roman", "nome"] <- "Evandro Roman"
  
  votos
}


ler_doacoes_de_eleitos <- function(arquivo.doacoes, arquivo.eleitos){
  deputados <- read.csv(arquivo.eleitos, strip.white=TRUE) %>% select(nome, nomeParlamentar)
  deputados$nomeMaiusculo <- toupper(deputados$nome)
  doacoes <- read.csv(arquivo.doacoes, sep=";", strip.white=TRUE)
  doacoes$CPF.do.candidato <- as.factor(doacoes$CPF.do.candidato)
  doacoes$CPF.CNPJ.do.doador <- as.factor(doacoes$CPF.CNPJ.do.doador)
  doacoes %>% filter(Nome.candidato %in% deputados$nomeMaiusculo)
}