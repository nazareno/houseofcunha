
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
  doacoes.f <- read.csv(arquivo.doacoes, sep=";", strip.white=TRUE)
  doacoes <- doacoes.f %>% filter(Nome.candidato %in% deputados$nome)
  doacoes$CPF.do.candidato <- droplevels(as.factor(doacoes$CPF.do.candidato))
  doacoes$CPF.CNPJ.do.doador <- droplevels(as.factor(doacoes$CPF.CNPJ.do.doador))
  doacoes
}

adiciona_nomes_corrigidos <- function(data){
  cpfs.cnpjs <- data %>% 
    select(CPF.CNPJ.do.doador) %>% 
    unique()
  
  cpfs.cnpjs.nomes <- left_join(cpfs.cnpjs, 
                                data[, c('CPF.CNPJ.do.doador', 'Nome.do.doador')], 
                                by = c('CPF.CNPJ.do.doador')) %>% 
    group_by(CPF.CNPJ.do.doador) %>% 
    do(.[1,])
  
  names(cpfs.cnpjs.nomes) <- c("CPF.CNPJ.do.doador", "Nome.doador.corrigido")
  cpfs.cnpjs.nomes$Nome.doador.corrigido <- droplevels(cpfs.cnpjs.nomes$Nome.doador.corrigido)
  data <- left_join(data, cpfs.cnpjs.nomes)
  data 
}

# Comparação da orientação entre dois partidos partidos. 
concordancia <- function(partidoA, partidoB){
  concordancia <- length(intersect(partidoA , partidoB))
  discordancia <- length(partidoA) - concordancia
  indice <- concordancia / (concordancia + discordancia)
  indice
}


# Comparação da orientação entre dois partidos mês a mês 
concordancia_mes <- function(partidoA, partidoB){
  df <- data.frame()
  mes <- unique(partidoA$mes)
  
  for (m in mes){
    partidoA_mes <-  partidoA %>%
      filter(mes == m)
    
    partidoB_mes <-  partidoB %>%
      filter(mes == m)
    
    
    df <- rbind(df, data.frame(Concordancia = concordancia(partidoA_mes$pro_orientacao, partidoB_mes$pro_orientacao), Mes = m))
  }
  df
}

# Quantidade de votação mês a mês 
quantidade_votacao_mes <- function(partidoA){
  df <- data.frame()
  mes <- unique(partidoA$mes)
  
  for (m in mes){
    partidoA_mes <-  partidoA %>%
      filter(mes == m)
        
    df <- rbind(df, data.frame(N_votacoes = nrow(partidoA_mes), Mes = m))
  }
  df
}

