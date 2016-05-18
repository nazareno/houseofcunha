library(ggplot2)
library(reshape2)
library(dplyr)

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
                                   alpha("#FF3300", 1)), 
                        guide = guide_legend(title = "Partido", 
                                             override.aes = list(alpha = 1, size = 4))) + 
    ylab("") + xlab("")+ 
    theme_classic() + 
    theme(axis.ticks = element_blank(), 
          axis.text = element_blank(), 
          axis.line = element_blank())
}


plotMCABasico <- function(dados){
  ggplot(data = dados, aes(x = Dim.1, y = Dim.2, label = nome)) +
    geom_hline(yintercept = 0, colour = "gray70") +
    geom_vline(xintercept = 0, colour = "gray70") +
    geom_text(size = 3.,  colour = "gray70") +
    ylab("") + xlab("")+ 
    theme_classic() + 
    theme(axis.ticks = element_blank(), 
          axis.text = element_blank(), 
          axis.line = element_blank())
}

plotMCAstains <- function(dados, alfa = 0.2){
  ggplot(data = dados, aes(x = Dim.1, y = Dim.2)) +
    geom_hline(yintercept = 0, colour = "gray70") +
    geom_vline(xintercept = 0, colour = "gray70") +
    geom_point(size = 9, alpha = alfa, colour = "grey") + 
    # stat_density2d(aes(fill = ..level..), geom="polygon") + 
    ylab("") + xlab("")+ 
    theme_classic() + 
    theme(axis.ticks = element_blank(), 
          axis.text = element_blank(), 
          axis.line = element_blank())
}

plotBancadas <- function(dados){
  aux <- as.data.frame(table(dados$clust))
  colnames(aux) <- c("clust", "freq") 
  aux$porcentagem <- (aux$freq / sum(aux$freq)) * 100
  
  ggplot(data = aux, aes(x=reorder(clust, -porcentagem), y = porcentagem)) + 
    geom_bar(stat="identity") + 
    theme_classic() + 
    theme(axis.ticks = element_blank())
}

plotCluster <- function(mca1_obs_df, cores = c("#fdcdac", "#f4cae4", "#b3e2cd", "#cbd5e8")) {
  num_clusters <- length(levels(mca1_obs_df$clust))
  p <- plotMCAstains(mca1_obs_df, alfa = 0.3)
  hulls <- recuperar_convex_hulls(mca1_obs_df, delta = .04)
  
  p <- p + geom_polygon(data = hulls, 
                        aes(x = x_aum, y = y_aum, fill = clust), 
                        alpha = 0.5) + 
    geom_point(size = 9, alpha = .3, aes(colour = clust)) + 
    scale_fill_manual(values = cores) +
    scale_colour_manual(values = cores) +
    theme(legend.position="none")
  p
}

deputadosAtivos <- function(votacao, porcentagemAtividadeMinima) {
  minNoVotacoes <- (ncol(votacao) -4)*porcentagemAtividadeMinima
  ativos <- votacao[rowSums(!is.na(votacao[,5:ncol(votacao)])) >= minNoVotacoes,]
  ativos
}

numero_de_votacoes <- function(votos){
  num_votacoes <- nrow(unique(votos[,c("num_pro","id_votacao")]))
  num_votacoes
}

deputadosAtivos2 <- function(votos, porcentagemAtividadeMinima) {
  num_votacoes <- numero_de_votacoes(votos)
  min_num_votacoes <- num_votacoes*porcentagemAtividadeMinima
  ativos <- votos %>% 
    group_by(id_dep) %>% 
    dplyr::summarise(c = n()) %>% 
    filter(c >= min_num_votacoes) %>% 
    select(id_dep)
  
  ativos
}

deputados_que_mudaram_de_partido <- function(votos) {
  deputados <- select(votos, id_dep, partido, uf)
  deputados <- deputados[!duplicated(deputados),]
  deputados_agrupados_por_id <- aggregate(partido ~ id_dep, deputados, length)
  
  deputados_infieis <- filter(deputados_agrupados_por_id, partido > 1)
  deputados_infieis
}

partido_atual <- function(id_deputado,votos) {
  votos_deputado <- votos[votos$id_dep == id_deputado,]
  votos_deputado <- votos_deputado[complete.cases(votos_deputado[, 12]),]
  partidos_por_data <- votos_deputado[order(as.Date(votos_deputado$data, format="%d/%m/%Y")),]
  partido <- tail(partidos_por_data,1)$partido
  
  return(partido)
}

definir_partido <- function(deputados_infieis, votos) {
  for (i in seq(1:nrow(deputados_infieis))) {
    id_deputado <- deputados_infieis[i,]$id_dep
    partido <- partido_atual(id_deputado,votos) 
    votos$partido[votos$id_dep == id_deputado] <- partido
  }
  
  return(votos)
}

deputados_com_multiplos_nomes <- function(votos) {
  deputados <- select(votos,nome,id_dep,uf)
  deputados <- deputados[!duplicated(deputados),]
  deputados_agrupados_por_id <- aggregate(nome ~ id_dep, deputados, length)
  
  deputados_repetidos <- filter(deputados_agrupados_por_id, nome > 1)
  deputados_repetidos
}

nome_atual <- function(id_deputado,votos) {
  nomes_deputado <- votos[votos$id_dep == id_deputado,]
  nomes_por_data <- nomes_deputado[order(as.Date(nomes_deputado$data, format="%d/%m/%Y")),]
  nome <- tail(nomes_por_data,1)$nome
  
  return(nome)
}

definir_nome <- function(deputados_repetidos, votos) {
  for (i in seq(1:nrow(deputados_repetidos))) {
    id_deputado <- deputados_repetidos[i,]$id_dep
    nome <- nome_atual(id_deputado,votos) 
    votos$nome[votos$id_dep == id_deputado] <- nome
  }
  
  return(votos)
}

# Ler os votos ativos dos deputados
ler_votos_de_ativos <- function(filepath, corrigir_migracoes, min.porc.votacoes = 0.15, limpar.votos=TRUE){
  votos <- read.csv(filepath, strip.white=TRUE, quote="")
  
  # Considera todos os deputados com id_dep
  votos <- votos[complete.cases(votos[,11]),]
  
  # ajustes nos valores e tipos das variáveis
  if (limpar.votos) {
    votos <- filter(votos, voto %in% c("sim", "não")) 
    votos$voto <- droplevels(votos$voto)
  }    
  votos$num_pro <- factor(votos$num_pro) 
  votos$uf <- droplevels(votos$uf)
  
  deputados_antes <- votos[!duplicated(votos$id_dep),]
    
  # Apenas quem votou em pelo menos x% das proposições
  ativos <- deputadosAtivos2(votos, min.porc.votacoes)
  
#   descartados <- filter(votos, !(id_dep %in% ativos$id_dep)) %>% select(nome, id_dep, uf, partido)
#   descartados <- descartados[!duplicated(descartados$id_dep),]
#   print("Descartados por inatividade: ")
#   print(descartados)

  votos <- filter(votos, id_dep %in% ativos$id_dep) 

  # Correção de deputados com múltiplos nomes
  deputados_repetidos <- deputados_com_multiplos_nomes(votos)
  votos <- definir_nome(deputados_repetidos,votos)

  if (corrigir_migracoes) {
    # Correção de deputados que aparecem com mais de uma afiliação.
    deputados_infieis <- deputados_que_mudaram_de_partido(votos)
    votos <- definir_partido(deputados_infieis, votos)
  }

  deputados_depois <- votos[!duplicated(votos$id_dep),]
  
  return(votos)
}

ler_doacoes_de_eleitos <- function(arquivo.doacoes, arquivo.eleitos){
  deputados <- read.csv(arquivo.eleitos, strip.white=TRUE) %>% select(nome, nomeParlamentar)
  doacoes.f <- read.csv(arquivo.doacoes, sep=";", strip.white=TRUE)
  doacoes <- doacoes.f %>% filter(Nome.candidato %in% deputados$nome)
  doacoes$CPF.do.candidato <- droplevels(as.factor(doacoes$CPF.do.candidato))
  doacoes$CPF.CNPJ.do.doador <- droplevels(as.factor(doacoes$CPF.CNPJ.do.doador))
  doacoes
}

recuperar_votos_por_deputado <- function(arquivo.votos, corrigir.migracoes) {
  votos <- ler_votos_de_ativos(arquivo.votos, corrigir.migracoes)
  
  # distinguir diferentes votações de uma mesma proposição
  votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)
  
  votacao <- recuperar_votacoes(votos)
  
  votos_por_deputado <- dcast(votacao, 
                        nome + partido + uf + id_dep ~ num_pro, 
                        value.var = "voto")
  
  votos_por_deputado <- as.data.frame(apply(votos_por_deputado, 2, as.factor))
  
  return(votos_por_deputado)
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

recuperar_num_votacoes <- function(votacao) {
  num_votacoes <- as.data.frame(rowSums(!is.na(votacao[,5:ncol(votacao)])))
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
  discordancia <- ifelse(length(partidoA) > length(partidoB), 
                         length(partidoA) - concordancia,  
                         length(partidoB) - concordancia)
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

###### FUNÇÕES DE CLUSTERIZAÇÂO ######
clusterizar <- function(mca,numClusters) {    
  mca.hcpc = HCPC(mca,nb.clust = numClusters)
  mca.hcpc
}

obter_clusters <- function(res.hcpc) {
  clusters <- res.hcpc$data.clust
  clusters <- select(clusters, nome, id_dep, partido, uf, clust)
  clusters$clust <- as.integer(as.character(clusters$clust))
  clusters
}

obter_topN_vars <- function(res.hcpc, n) {
  #variaveis que melhor diferenciam/caracterizam os clusters
  topN_vars <- as.data.frame(res.hcpc$desc.var$test.chi2)[1:n,]
  topN_vars
}

obter_topN_cats_por_cluster <- function(res.hcpc, n) {
  #categorias das variaveis que melhor diferenciam/caracterizam os clusters
  topN_cats <- list()
  categories <- res.hcpc$desc.var$category
  
  for (i in 1:length(categories)) {
    category <- as.data.frame(categories[i])[1:n,]
    topN_cats[[i]] <- category
  }
  topN_cats
}

obter_partidos_por_cluster <- function(clusters) {
  partidos_por_cluster <- list()
  num_clusters = length(unique(clusters$clust))
  for (i in seq(1:num_clusters)) {
    cluster <- filter(clusters,clust == i)
    partidos_por_cluster[[i]] <- aggregate(clust ~ partido, cluster, length)
    partidos_por_cluster[[i]] <- partidos_por_cluster[[i]][order(-partidos_por_cluster[[i]]$clust),]
  }
  partidos_por_cluster
}

obter_cluster_de_deputados_em_destaque <- function(clusters) {
  deputados_em_destaque <-  c("Tiririca", 
                              "Pr. Marco Feliciano", 
                              "Jair Bolsonaro", 
                              "Luiz Couto", 
                              "Jandira Feghali",
                              "Jean Wyllys", 
                              "Veneziano Vital do Rêgo")
  
  posicao_deputados_em_destaque <- filter(clusters, nome %in% deputados_em_destaque)
  posicao_deputados_em_destaque
}

obter_num_cabecas_por_cluster <- function(clusters) {
  cabecas <- read.table("data/cabecas.csv", header=TRUE, quote="\"")
  
  clusters$cabeca <- clusters$nome %in% cabecas$Cabeca
  
  cabecas_por_cluster <- list()
  num_clusters = length(unique(clusters$clust))
  for (i in seq(1:num_clusters)) {
    cluster <- filter(clusters,clust == i)
    cabecas_por_cluster[[i]] <- aggregate(clust ~ cabeca, cluster, length)
  }
  cabecas_por_cluster
}

criar_df_aumentado <- function(df, delta = 0.4) { 
  require(tidyr)
  
  df_aux <- df
  
  df_aux$x1 <- df$Dim.1 + delta
  df_aux$x2 <- df$Dim.1 - delta
  
  df_aux$y1 <- df$Dim.2 + delta
  df_aux$y2 <- df$Dim.2 - delta  
  df_aum <- cbind(gather(select(df_aux, x1, x2), key = nome_x, value = x_aum), gather(select(df_aux, y1, y2), nome_y, y_aum))

  df_aum <- rbind(df_aum, cbind(gather(select(df_aux, x2, x1), nome_x, x_aum), gather(select(df_aux, y1, y2), nome_y, y_aum)))
  df_aum <- select(df_aum, -nome_x, -nome_y)   
  df_aum <- cbind(df_aum, clust = rep(df_aux$clust, 4))
  df_aum
}

recuperar_convex_hulls <- function(df, delta = .4) {
  require(plyr)
  df.i <- criar_df_aumentado(df, delta)
  find_hull <- function(df) df[chull(df$x_aum, df$y_aum), ]
  hulls <- ddply(df.i, "clust", find_hull)
  detach("package:plyr")
  return(hulls)
}

buildClustersPlots <- function(mca1_obs_df, pasta_resultados, cores = c("#fdcdac", "#f4cae4", "#b3e2cd", "#cbd5e8") ) {
  num_clusters <- length(levels(mca1_obs_df$clust))
  p <- plotMCAstains(mca1_obs_df, alfa = 0.1)
  colors <- c("outros" = "grey70","pmdb" = "darkred","psdb" = "#56B4E9", "psol" = "#F0E442","pt" = "#FF0000")
  hulls <- recuperar_convex_hulls(mca1_obs_df, delta = .04)
  
  for (i in seq(1:num_clusters)) {
    file_name = paste("c", num_clusters, "_", i, ".png", sep="")
    file_path = paste(caminho_pasta_resultados,file_name,sep="/")
    print(file_path)
    png(file_path, width = 800, height = 600)
    plot <- p + geom_polygon(data = hulls[hulls$clust == i,], aes(x = x_aum, y = y_aum), alpha = 0.05, color = colors[1]) + 
      geom_point(data = filter(mca1_obs_df, clust == i), aes(colour = destaque_partido), size = 7)  +  
      scale_colour_manual(values = colors, 
                          guide = guide_legend(title = "partido", 
                                               override.aes = list(alpha = 1, size = 7))) 
    print(plot)
    dev.off()
  }
  
  file_name = paste("c",num_clusters,"_all.png",sep="")
  file_path = paste(caminho_pasta_resultados,file_name,sep="/")
  print(file_path)
  png(file_path, width = 800, height = 600)
  plot <- p
  plot <- plot + geom_polygon(data = hulls, 
                      aes(x = x_aum, y = y_aum, fill = clust), 
                      alpha = 0.5) + 
    geom_point(size = 9, alpha = .4, aes(colour = clust)) + 
    scale_fill_manual(values = cores) +
    scale_colour_manual(values = cores) +
    theme(legend.position="none")

  # temporariamente não destacamos mais partidos
#   plot <- plot + geom_point(data = mca1_obs_df, aes(colour = destaque_partido), size = 7)  +  
#     scale_colour_manual(values = colors, 
#                         guide = guide_legend(title = "partido", override.aes = list(alpha = 1, size = 7))) 
  print(plot)
  dev.off()
}

recuperar_votos_proposicao <- function(votos_df, numero.prop, remover.nas = FALSE) {
  proposicao = as.character(numero.prop)
  colunas_props <- grepl(paste("^",proposicao,"\\b", sep=""),names(votos_por_deputado))
  votos_proposicao <- as.data.frame(votos_por_deputado[,colunas_props])
  names(votos_proposicao) <- names(votos_por_deputado)[colunas_props]
  votos_proposicao <- cbind(votos_por_deputado[,1:4],votos_proposicao)
  
  if (remover.nas) {
    votos_proposicao <- votos_proposicao[complete.cases(votos_proposicao),]
  }
  
  return(votos_proposicao)
}

recuperar_df_pontos_mca <- function(mca.res, votos_df) {
  mca_obs_df <-  data.frame(mca.res$ind$coord, 
                            nome = votos_df$nome,
                            partido = votos_df$partido, 
                            uf = votos_df$uf,
                            id_dep = votos_df$id_dep)
  
  mca_obs_df$id_dep <- as.integer(as.character(mca_obs_df$id_dep))
  
  return(mca_obs_df)
}

add_col_partidos_iconicos <- function(df_pontos_mca) {
  df_pontos_mca$destaque_partido = factor(ifelse(df_pontos_mca$partido %in% 
                                                 c("pmdb", "psdb", "pt", "psol"), 
                                               as.character(df_pontos_mca$partido), 
                                               "outros"))
  
  return(df_pontos_mca)
}

# Lista o deputado que não tem afinidade 
list_not_afinidade <- function(data_frame, top_n = 1){
  top_not_afinidade <- as.data.frame(cbind(row.names(data_frame), 
                                           apply(data_frame, 1, function(x) names(data_frame)[which(x == sort(x, decreasing = TRUE)[top_n])])))
  
  l1 <- sapply(top_not_afinidade$V2, length)
  unlist.col1 <- rep(top_not_afinidade$V1, l1)
  id_dep <- unlist(unlist.col1)
  
  not_afinidade <- unnest(top_not_afinidade, V2)
  
  df <- cbind(id_dep, not_afinidade)
  df$id_dep <- as.integer(as.character(df$id_dep))
  
  df$V1 <- NULL
  
  df
}

# Lista o deputado que tem afinidade
list_afinidade <- function(data_frame, top_n = 1){
  top_afinidade <-  as.data.frame(cbind(row.names(data_frame), 
                                        apply(data_frame, 1, function(x) names(data_frame)[which(x == sort(x, decreasing = FALSE)[top_n])])))
  
  l1 <- sapply(top_afinidade$V2, length)
  unlist.col1 <- rep(top_afinidade$V1, l1)
  id_dep <- unlist(unlist.col1)
  
  afinidade <- unnest(top_afinidade, V2)
  
  df <- cbind(id_dep, afinidade)
  df$id_dep <- as.integer(as.character(df$id_dep))
  
  df$V1 <- NULL
  
  df
}

# Cria data frame com o top not afinidade
top_not_afinidade <- function(data_frame){
  df_5 <- list_not_afinidade(data_frame, 5)
  colnames(df_5) <- c("id_dep", "5")
  
  df_4 <- list_not_afinidade(data_frame, 4)
  colnames(df_4) <- c("id_dep", "4")
  
  df_3 <- list_not_afinidade(data_frame, 3)
  colnames(df_3) <- c("id_dep", "3")
  
  df_2 <- list_not_afinidade(data_frame, 2)
  colnames(df_2) <- c("id_dep", "2")
  
  df_1 <- list_not_afinidade(data_frame, 1)
  colnames(df_1) <- c("id_dep", "1")
  
  join <- left_join(df_1, df_2, by = "id_dep") %>%
    left_join(df_3, by = "id_dep") %>%
    left_join(df_4, by = "id_dep") %>%
    left_join(df_5, by = "id_dep")
  
  temp <- apply(join, 1, duplicated) %>% apply(2, sum)
  join$del <- temp
  
  join <- filter(join, del < 1)
  temp <- apply(join, 2, duplicated) 
  
  if (length(temp) != 0){
    join$del <- temp[,1]
    join <- filter(join, del == 0)
  }
  
  join
}

# Cria data frame com o top afinidade
#top_afinidade <- function(data_frame){
#  df_5 <- list_afinidade(data_frame, 5)
#  colnames(df_5) <- c("id_dep", "5")
  
#  df_4 <- list_afinidade(data_frame, 4)
#  colnames(df_4) <- c("id_dep", "4")
  
#  df_3 <- list_afinidade(data_frame, 3)
#  colnames(df_3) <- c("id_dep", "3")
  
#  df_2 <- list_afinidade(data_frame, 2)
#  colnames(df_2) <- c("id_dep", "2")
  
#  df_1 <- list_afinidade(data_frame, 1)
#  colnames(df_1) <- c("id_dep", "1")
  
#  join <- left_join(df_1, df_2, by = "id_dep") %>%
#    left_join(df_3, by = "id_dep") %>%
#    left_join(df_4, by = "id_dep") %>%
#    left_join(df_5, by = "id_dep")
  
#  temp <- apply(join, 1, duplicated) %>% apply(2, sum)
#  join$del <- temp
  
#  join <- filter(join, del == 1)
#  temp <- apply(join, 2, duplicated) 
  
#  if (length(temp) != 0){
#    join$del <- temp[,1]
#    join <- filter(join, del == 0)
#  }
  
#  join
#}


##### FUNÇÕES PROCESSAMENTO DISCURSOS ####

frequencia_palavra_discursos <- function (discursos, n_grams = 1, stopWords = FALSE){
  frequency <- frequencia_palavras(discursos, n_grams, stopWords)
  
  frequency <- as.data.frame(frequency)
  frequency <- cbind(Palavra = rownames(frequency), frequency)
  rownames(frequency) <- NULL
  
  frequency$top <- 1:nrow(frequency)
  
  frequency
}


frequencia_palavras <- function (discursos, n_grams = 1, stopWords = FALSE){
  review_text <- paste(discursos$Fala, collapse=" ")
  review_source <- VectorSource(review_text)
  corpus <- Corpus(review_source)
  
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  
  if (stopWords){
    corpus <- tm_map(corpus, removeWords, stopwords("portuguese"))
  }
  
  
  ngramTokenizer <- function(x) unlist(lapply(ngrams(words(x), n_grams), paste, collapse = " "), use.names = FALSE)
  
  dtm <- DocumentTermMatrix(corpus, control = list(tokenize = ngramTokenizer))
  dtm2 <- as.matrix(dtm)
  frequency <- colSums(dtm2)
  frequency <- sort(frequency, decreasing = TRUE)
  frequency
}



processamento_palavras_frequentes <- function(discursos.sim, discursos.nao, n_palavras = 100){
  #frequencia.discursos.sim$zipf <- frequencia.discursos.sim$frequency * frequencia.discursos.sim$top
  #hist(frequencia.discursos.sim$zipf)
  
  colnames(discursos.nao) <- c("Palavra", "frequency", "top_nao")
  
  discursos.sim.nao <- left_join(discursos.sim, discursos.nao, by = "Palavra")
  
  discursos.nao.sim <- left_join(discursos.nao, discursos.sim, by = "Palavra")
  
  palavras_frequentes <- discursos.sim.nao[1:100,]$Palavra
  palavras_frequentes <- append(palavras_frequentes, discursos.nao.sim[1:100,]$Palavra)
  palavras_frequentes <- unique(palavras_frequentes)
  
  discursos.total <- full_join(discursos.sim.nao, discursos.nao.sim, by = "Palavra")
  
  discursos.total$destaque_top <- discursos.total$Palavra %in% palavras_frequentes
  discursos.total <- select(discursos.total, Palavra, frequency.x.x, top.x, frequency.x.y, top_nao.y, destaque_top)
  
  discursos.total <- filter(discursos.total, destaque_top == TRUE)
  
  discursos.total <- discursos.total[complete.cases(discursos.total),]
  
  colnames(discursos.total) <- c("Palavra", "frequency.sim", "top", "frequency.nao", "top_nao", "destaque_top")
  
  discursos.total
}

create_destaque_columns <- function(df, n_palavras = 15) {
  df$diff <- df$top - df$top_nao
  top_sim <- head(df[with(df, order(diff)), ]$Palavra, n_palavras)
  
  df$diff <-  df$top_nao - df$top
  top_nao <- head(df[with(df, order(diff)), ]$Palavra, n_palavras)
  
  palavras_destaque <- append(top_sim, top_nao)
  df$destaque <- df$Palavra %in% palavras_destaque
  
  df
}