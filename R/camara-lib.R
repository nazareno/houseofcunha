# Responsável por gerar o gráfico
plotMCA <- function(dados){
  ggplot(data = dados, aes(x = Dim.1, y = Dim.2, label = nome,  colour = destaque_partido)) +
    geom_hline(yintercept = 0, colour = "gray70") +
    geom_vline(xintercept = 0, colour = "gray70") +
    geom_text(size = 3.) +
    scale_colour_manual(values = c(alpha("grey70", .6), 
                                   alpha("darkred", 1), 
                                   alpha("#0066CC", 1),
                                   alpha("#E69F00", 1),
                                   alpha("#FF3300", 1)
    ), 
    guide = guide_legend(title = "partido", 
                         override.aes = list(alpha = 1, size = 4))) + 
    ylab("") + xlab("")+ 
    theme_classic() + 
    theme(axis.ticks = element_blank(), 
          axis.text = element_blank(), 
          axis.line = element_blank())
}

# Ler os votos ativos dos deputados
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

  # Aparece com dois nomes
  votos[votos$nome == "Evandro Rogerio Roman", "nome"] <- "Evandro Roman"
  votos[votos$nome == "Eli Correa Filho", "nome"] <- "Eli Corrêa Filho"
  votos[votos$nome == "Mainha", "nome"] <- "José Maia Filho"
    
  # Aparece com duas afiliações.
  votos[votos$nome == "Cabo Daciolo", "partido"] <- "s.part."
  votos[votos$nome == "Glauber Braga", "partido"] <- "s.part."
  votos[votos$nome == "Silvio Costa", "partido"] <- "s.part."
  votos[votos$nome == "Elizeu Dionizio", "partido"] <- "s.part."
  votos[votos$nome == "Eliziane Gama", "partido"] <- "s.part."
  votos[votos$nome == "Fernando Francischini", "partido"] <- "s.part."
  votos[votos$nome == "João Derly", "partido"] <- "s.part."
  votos[votos$nome == "Marcelo Aguiar", "partido"] <- "s.part."
  votos[votos$nome == "Ronaldo Fonseca", "partido"] <- "s.part."
  votos[votos$nome == "Stefano Aguiar", "partido"] <- "s.part."
  votos[votos$nome == "Arthur Oliveira Maia", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Carvalho", "partido"] <- "s.part."
  votos[votos$nome == "Elizeu Dionizio", "partido"] <- "s.part."
  votos[votos$nome == "Genecias Noronha", "partido"] <- "s.part."
  votos[votos$nome == "Givaldo Carimbão", "partido"] <- "s.part."
  votos[votos$nome == "Izalci", "partido"] <- "s.part."
  votos[votos$nome == "Jaime Martins", "partido"] <- "s.part."
  votos[votos$nome == "Jorginho Mello", "partido"] <- "s.part."
  votos[votos$nome == "Luiz Nishimori", "partido"] <- "s.part."
  votos[votos$nome == "Valtenir Pereira", "partido"] <- "s.part."
  votos[votos$nome == "Zé Silva", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Carvalho", "partido"] <- "s.part."
  votos[votos$nome == "Paulo Pereira da Silva", "partido"] <- "s.part."
  votos[votos$nome == "Alessandro Molon", "partido"] <- "s.part."
  votos[votos$nome == "Aliel Machado", "partido"] <- "s.part."
  votos[votos$nome == "Ariosto Holanda", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Coutinho", "partido"] <- "s.part."
  votos[votos$nome == "Beto Mansur", "partido"] <- "s.part." 
  votos[votos$nome == "Ademir Camilo", "partido"] <- "s.part."
  votos[votos$nome == "Carlos Eduardo Cadoca", "partido"] <- "s.part."
  votos[votos$nome == "Cícero Almeida", "partido"] <- "s.part."
  votos[votos$nome == "Danilo Forte", "partido"] <- "s.part." 
  votos[votos$nome == "Deley", "partido"] <- "s.part."
  votos[votos$nome == "Dr. Jorge Silva", "partido"] <- "s.part."
  votos[votos$nome == "Hugo Leal", "partido"] <- "s.part."
  votos[votos$nome == "JHC", "partido"] <- "s.part."
  votos[votos$nome == "Jorge Boeira", "partido"] <- "s.part."
  votos[votos$nome == "Miro Teixeira", "partido"] <- "s.part."
  votos[votos$nome == "Vicente Arruda", "partido"] <- "s.part."
  
  votos
}

deputadosAtivos <- function(votacao.cast, porcentagemAtividadeMinima) {
  minNoVotacoes <- (ncol(votacao.cast) -4)*porcentagemAtividadeMinima
  ativos <- votacao.cast[rowSums(!is.na(votacao.cast[,5:ncol(votacao.cast)])) >= minNoVotacoes,]
  ativos
}

numero_de_votacoes <- function(votos){
  num_votacoes <- nrow(unique(votos[,c("num_pro","id_votacao")]))
  num_votacoes
}

deputadosAtivos2 <- function(votos, porcentagemAtividadeMinima) {
  num_votacoes <- numero_de_votacoes(votos)
  print(num_votacoes)
  min_num_votacoes <- num_votacoes*porcentagemAtividadeMinima
  print(min_num_votacoes)
  ativos <- votos %>% 
    group_by(nome) %>% 
    summarise(c = n()) %>% 
    filter(c >= min_num_votacoes) %>% 
    select(nome)
  
  ativos
}

# Ler os votos ativos dos deputados
ler_votos_de_ativos2 <- function(filepath){
  filepath <- "votacoes.csv"
  votos <- read.csv(filepath, strip.white=TRUE, quote="")
  
  # ajustes nos valores e tipos das variáveis
  votos <- filter(votos, voto %in% c("sim", "não")) 
  votos$voto <- droplevels(votos$voto)
  votos$num_pro <- factor(votos$num_pro)
  votos$uf <- droplevels(votos$uf)
  
  # apenas quem votou em muitas proposições 
  # (espero que seja quem é deputado em 2015)
  ativos <- deputadosAtivos2(votos,0.5)
  descartados <- unique(filter(votos, !(nome %in% ativos$nome)) %>% select(nome, uf, partido))
  descartados <- descartados[order(descartados$nome),]
  votos <- filter(votos, nome %in% ativos$nome) 
  print("Descartados por inatividade: ")
  print(descartados)
  
  # Aparece com dois nomes
  votos[votos$nome == "Evandro Rogerio Roman", "nome"] <- "Evandro Roman"
  votos[votos$nome == "Eli Correa Filho", "nome"] <- "Eli Corrêa Filho"
  votos[votos$nome == "Mainha", "nome"] <- "José Maia Filho"
  
  # Aparece com duas afiliações.
  votos[votos$nome == "Cabo Daciolo", "partido"] <- "s.part."
  votos[votos$nome == "Glauber Braga", "partido"] <- "s.part."
  votos[votos$nome == "Silvio Costa", "partido"] <- "s.part."
  votos[votos$nome == "Elizeu Dionizio", "partido"] <- "s.part."
  votos[votos$nome == "Eliziane Gama", "partido"] <- "s.part."
  votos[votos$nome == "Fernando Francischini", "partido"] <- "s.part."
  votos[votos$nome == "João Derly", "partido"] <- "s.part."
  votos[votos$nome == "Marcelo Aguiar", "partido"] <- "s.part."
  votos[votos$nome == "Ronaldo Fonseca", "partido"] <- "s.part."
  votos[votos$nome == "Stefano Aguiar", "partido"] <- "s.part."
  votos[votos$nome == "Arthur Oliveira Maia", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Carvalho", "partido"] <- "s.part."
  votos[votos$nome == "Elizeu Dionizio", "partido"] <- "s.part."
  votos[votos$nome == "Genecias Noronha", "partido"] <- "s.part."
  votos[votos$nome == "Givaldo Carimbão", "partido"] <- "s.part."
  votos[votos$nome == "Izalci", "partido"] <- "s.part."
  votos[votos$nome == "Jaime Martins", "partido"] <- "s.part."
  votos[votos$nome == "Jorginho Mello", "partido"] <- "s.part."
  votos[votos$nome == "Luiz Nishimori", "partido"] <- "s.part."
  votos[votos$nome == "Valtenir Pereira", "partido"] <- "s.part."
  votos[votos$nome == "Zé Silva", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Carvalho", "partido"] <- "s.part."
  votos[votos$nome == "Paulo Pereira da Silva", "partido"] <- "s.part."
  votos[votos$nome == "Alessandro Molon", "partido"] <- "s.part."
  votos[votos$nome == "Aliel Machado", "partido"] <- "s.part."
  votos[votos$nome == "Ariosto Holanda", "partido"] <- "s.part."
  votos[votos$nome == "Augusto Coutinho", "partido"] <- "s.part."
  votos[votos$nome == "Beto Mansur", "partido"] <- "s.part." 
  votos[votos$nome == "Ademir Camilo", "partido"] <- "s.part."
  votos[votos$nome == "Carlos Eduardo Cadoca", "partido"] <- "s.part."
  votos[votos$nome == "Cícero Almeida", "partido"] <- "s.part."
  votos[votos$nome == "Danilo Forte", "partido"] <- "s.part." 
  votos[votos$nome == "Deley", "partido"] <- "s.part."
  votos[votos$nome == "Dr. Jorge Silva", "partido"] <- "s.part."
  votos[votos$nome == "Hugo Leal", "partido"] <- "s.part."
  votos[votos$nome == "JHC", "partido"] <- "s.part."
  votos[votos$nome == "Jorge Boeira", "partido"] <- "s.part."
  votos[votos$nome == "Miro Teixeira", "partido"] <- "s.part."
  votos[votos$nome == "Vicente Arruda", "partido"] <- "s.part."
  
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

recuperar_votacoes <- function(votos) {
  votacao <- votos %>% 
    select(nome, partido, uf, num_pro, voto, id_dep)
  votacao
}

recuperar_votacoes_com_cunha <- function(votos) {
  votacao <- recuperar_votacoes(votos)
  
  # versão do dataframe com recomendações do PMDB sendo a
  # votação de Eduardo Cunha:
  ec.v <- votos %>% 
    select(num_pro, cunha) %>% 
    filter(cunha %in% c("sim", "não")) %>% 
    unique()
  
  ec <- cbind(data.frame(nome = "Eduardo Cunha", 
                         partido = "pmdb", 
                         uf = "RJ"), 
              ec.v)
  ec$id_dep <- "999999"
  
  names(ec) <- names(votacao)
  # esse é o df com cunha:
  votacao.cc <- rbind(votacao, ec)
  votacao.cc
}

deputados_ativos <- function(votacao.cc){
  dep_afastado <- filter(votacao.cc, id_dep %in% c("178864", 
                                                   "133439", 
                                                   "74213", 
                                                   "72912",  
                                                   "73720",     
                                                   "146829", 
                                                   "190149", 
                                                   "73481",  
                                                   "74460",  
                                                   "188097",
                                                   "180545", 
                                                   "80920",  
                                                   "88950",  
                                                   "160612", 
                                                   "141560", 
                                                   "167493"))
  
  votacao.cc <- setdiff(votacao.cc, dep_afastado)
  votacao.cc  
}

recuperar_num_votacoes <- function(votacao.cast) {
  num_votacoes <- as.data.frame(rowSums(!is.na(votacao.cast[,5:ncol(votacao.cast)])))
  names(num_votacoes) = c("num_votacoes")
  num_votacoes
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

# Mostra como é a votação dos extremos do gráfico
votos_deputados_extremo <- function(deputados, votacoes){
  df = data.frame()
  for (i in row.names(deputados)){
    df <- rbind(filter(votacao.cast[i,]), df)
  }
  
  df1 = df[c("nome","partido","uf")] 
  for (i in row.names(votacoes)){
    df1 <- cbind(df1, df[strsplit(i, "_")[[1]][1]])
  } 
  
  colnames(df1) <- c("nome","partido","uf", row.names(votacoes))
  df1
}

geraMCA <-  function(votos){
  votacao <- votos %>% 
    select(nome, partido, uf, num_pro, voto)
  
  # versão do dataframe com recomendações do PMDB sendo a
  # votação de Eduardo Cunha:
  ec.v <- votos %>% 
    select(num_pro, cunha) %>% 
    filter(cunha %in% c("sim", "não")) %>% 
    unique()
  
  ec <- cbind(data.frame(nome = "Eduardo Cunha", 
                         partido = "pmdb", 
                         uf = "rj"), 
              ec.v)
  names(ec) <- names(votacao)
  # esse é o df com cunha:
  votacao.cc <- rbind(votacao, ec)
  
  votacao.cast <- dcast(votacao.cc, 
                        nome + partido + uf ~ num_pro, 
                        value.var = "voto")
  
  votacao.cast <- as.data.frame(apply(votacao.cast, 2, as.factor))
  
  mca1 = MCA(votacao.cast, 
             ncp = 2, # Default is 5 
             graph = FALSE,
             quali.sup = c(1:3),
             na.method = "Average") # NA or Avarege
  
  # data frame with observation coordinates
  mca1_obs_df = data.frame(mca1$ind$coord, 
                           nome = votacao.cast$nome,
                           partido = votacao.cast$partido, 
                           uf = votacao.cast$uf)
  
  # Partidos icônicos
  mca1_obs_df$destaque_partido = factor(ifelse(mca1_obs_df$partido %in% 
                                                 c("pmdb", "psdb", "pt", "psol"), 
                                               as.character(mca1_obs_df$partido), 
                                               "outros"))
  
  mca1_obs_df
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

# Quantidade de votação mês a mês 
quantidade_votacao_mes <- function(votacoes){
  df <- data.frame()
  mes <- unique(votacoes$mes)
  
  for (m in mes){
    votacoes_mes <-  votacoes %>%
      filter(mes == m)
    
    df <- rbind(df, data.frame(n_votacoes = nrow(votacoes_mes), mes = m))
  }
  df
}


quantidade_votacao_mes_bbb <- function(votacoes){
  df <- data.frame()
  mes <- unique(votacoes$mes)
  
  for (m in mes){
    votacoes_mes <-  votacoes %>%
      filter(mes == m)
    
    votacao_bbb <- votacoes_mes %>%
      filter(bbb == TRUE)
    
    votacao_N_bbb <- votacoes_mes %>%
      filter(bbb == FALSE)
    
    df <- rbind(df, data.frame(bbb = nrow(votacao_bbb), nao_bbb = nrow(votacao_N_bbb),mes = m))
  }
  df
}

# Quantidade de votação dia a dia 
quantidade_votacao_dia <- function(votacoes){
  df <- data.frame()
  dia <- unique(votacoes$dia)
  
  for (d in dia){
    votacao_dia <-  votacoes %>%
      filter(dia == d)
    
    df <- rbind(df, data.frame(n_votacoes = nrow(votacao_dia), dia = d))
  }
  df
}

# Quantidade de votação dia a dia BBB/não BBB
quantidade_votacao_dia_bbb <- function(votacoes){
  df <- data.frame()
  dia <- unique(votacoes$dia)
  
  for (d in dia){
    votacao_dia <-  votacoes %>%
      filter(dia == d)
    
    votacao_bbb <- votacao_dia %>%
      filter(bbb == TRUE)
    
    votacao_N_bbb <- votacao_dia %>%
      filter(bbb == FALSE)
    
    df <- rbind(df, data.frame(bbb = nrow(votacao_bbb), nao_bbb = nrow(votacao_N_bbb), dia = d))
  }
  df
}

# Quantidade de votação semana a semana 
quantidade_votacao_semana <- function(votacoes){
  df <- data.frame()
  semana <- unique(votacoes$semana)
  
  for (s in semana){
    votacao_semana <-  votacoes %>%
      filter(semana == s) 
    
    df <- rbind(df, data.frame(n_votacoes = nrow(votacao_semana), semana = s))
  }
  df
}

# Quantidade de votação semana a semana BBB/não BBB
quantidade_votacao_semana_bbb <- function(votacoes){
  df <- data.frame()
  semana <- unique(votacoes$semana)
  
  for (s in semana){
    votacao_semana <-  votacoes %>%
      filter(semana == s) 
    
    votacao_bbb <- votacao_semana %>%
      filter(bbb == TRUE)
        
    votacao_N_bbb <- votacao_semana %>%
      filter(bbb == FALSE)
    
    df <- rbind(df, data.frame(bbb = nrow(votacao_bbb), nao_bbb = nrow(votacao_N_bbb),semana = s))
  }
  df
}
