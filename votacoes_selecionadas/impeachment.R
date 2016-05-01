setwd("~/Projects/houseofcunha/votacoes_selecionadas")
library(reshape)
library(dplyr)
impeachment = read.csv("deputados_temas_e_impeachment.csv",stringsAsFactors=FALSE,sep = ';')
impeachment = impeachment[,c("id_dep","deputado","partido","UF","IMPEACHMENT")]
impeachment = impeachment[with(impeachment, order(UF)), ]
#by_state = group_by(impeachment,UF) %>% summarise(count = n())
#by_vote = group_by(impeachment,IMPEACHMENT) %>% summarise(count = n())

impeachment_nomes = impeachment


impeachment[ is.na( impeachment$IMPEACHMENT ), ]$IMPEACHMENT = -1
impeachment[impeachment$IMPEACHMENT == "AUSEN",]$IMPEACHMENT = -1
impeachment[impeachment$IMPEACHMENT == "SIM",]$IMPEACHMENT = 1
impeachment[impeachment$IMPEACHMENT == "NAO",]$IMPEACHMENT = 0
impeachment[impeachment$IMPEACHMENT == "ABST",]$IMPEACHMENT = -2
#by_vote = group_by(impeachment_nomes,IMPEACHMENT) %>% summarise(count = n())
#by_vote2 = group_by(impeachment,IMPEACHMENT) %>% summarise(count = n())


outros_votos = read.csv("deputados_votos.csv",stringsAsFactors=FALSE,sep = ',')
outros_votos_nomes = read.csv("deputados_votos_nomes.csv",stringsAsFactors=FALSE,sep = ',')

votos = merge(outros_votos,impeachment,by="id_dep",all = TRUE)
votos[is.na(votos$nome),]$nome = votos[is.na(votos$nome),]$deputado
votos[is.na(votos$partido.x),]$partido.x = votos[is.na(votos$partido.x),]$partido.y
votos[is.na(votos$uf),]$uf = votos[is.na(votos$uf),]$UF
votos = votos[, !(colnames(votos) %in% c("deputado","partido.y","UF"))]
votos[ is.na( votos ) ] = -1


votos_nomes = merge(outros_votos_nomes,impeachment_nomes,by="id_dep",all = TRUE)
votos_nomes[is.na(votos_nomes$nome),]$nome = votos_nomes[is.na(votos_nomes$nome),]$deputado
votos_nomes[is.na(votos_nomes$partido.x),]$partido.x = votos_nomes[is.na(votos_nomes$partido.x),]$partido.y
votos_nomes[is.na(votos_nomes$uf),]$uf = votos_nomes[is.na(votos_nomes$uf),]$UF
votos_nomes = votos_nomes[, !(colnames(votos_nomes) %in% c("deputado","partido.y","UF"))]
votos_nomes[ is.na( votos_nomes ) ] = "não votou"
votos_nomes[ votos_nomes$IMPEACHMENT == "SIM", ]$IMPEACHMENT = "sim"
votos_nomes[ votos_nomes$IMPEACHMENT == "NAO", ]$IMPEACHMENT = "não"
votos_nomes[ votos_nomes$IMPEACHMENT == "AUSEN", ]$IMPEACHMENT = "ausente"
votos_nomes[ votos_nomes$IMPEACHMENT == "ABST", ]$IMPEACHMENT = "abstenção"
names(votos_nomes)[names(votos_nomes)=="partido.x"] <- "partido"
names(votos)[names(votos)=="partido.x"] <- "partido"
names(votos_nomes)[names(votos_nomes)=="IMPEACHMENT"] <- "Impeachment"
names(votos)[names(votos)=="IMPEACHMENT"] <- "Impeachment"

write.csv(votos,"deputados_votos_total.csv",row.names = FALSE, quote=FALSE)
write.csv(votos_nomes,"deputados_votos_nomes_total.csv",row.names = FALSE, quote=FALSE)


partidos_impeachment_nomes = read.csv("partidos_votos_nomes_impeachment.csv",stringsAsFactors=FALSE,sep = ',')
partidos_impeachment = partidos_impeachment_nomes

partidos_impeachment[ is.na( impeachment$Impeachment ), ]$Impeachment = -10
partidos_impeachment[partidos_impeachment$Impeachment == "não votou",]$Impeachment = -10
partidos_impeachment[partidos_impeachment$Impeachment == "liberado",]$Impeachment = -1
partidos_impeachment[partidos_impeachment$Impeachment == "sim",]$Impeachment = 1
partidos_impeachment[partidos_impeachment$Impeachment == "não",]$Impeachment = 0
partidos_impeachment[partidos_impeachment$Impeachment == "sem orientação",]$Impeachment = -5

partidos_votos = read.csv("partidos_votos.csv",stringsAsFactors=FALSE,sep = ',')
partidos_votos_nomes = read.csv("partidos_votos_nomes.csv",stringsAsFactors=FALSE,sep = ',')

votos_p = merge(partidos_votos,partidos_impeachment,by="nome",all = TRUE)
votos_p[ is.na( votos_p)  ] = -10

votos_nomes_p = merge(partidos_votos_nomes,partidos_impeachment_nomes,by="nome",all = TRUE)
votos_nomes_p[ is.na( votos_nomes_p)  ] = "nao votou"

write.csv(votos,"partidos_votos_total.csv",row.names = FALSE, quote=FALSE)
write.csv(votos_nomes,"partidos_votos_nomes_total.csv",row.names = FALSE, quote=FALSE)