library(ggplot2)
library(dplyr)
source("R/camara-lib.R")

votos <- ler_votos_de_ativos("dados/votacoes.csv")
# separar sessões de uma mesma proposição
votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)
votos$nome <- paste0(votos$nome, " (", toupper(votos$partido), " ", votos$uf, ")")

ativos <- votos %>% 
  group_by(nome) %>% 
  summarise(c = n()) %>% 
  filter(c >= 31) %>% 
  select(nome)

votos <- filter(votos, nome %in% ativos$nome, cunha %in% c("sim", "não")) 
votos$cunha <- droplevels(votos$cunha)
votos = mutate(votos, concorda = ifelse(voto == cunha, 1, 0)) 

ac = votos %>%
  group_by(nome, partido, uf) %>%
  summarise(prop = sum(concorda) / n(), concordancias = sum(concorda), votos = n()) %>% 
  ungroup() %>% 
  arrange(desc(prop)) %>% 
  mutate(rank = rank(-prop, ties.method = "min"))

# ac <- ac %>% filter (uf == "PE")

### PLOTS ###

png(file="tops-cunhas.png", height = 500, width = 650)
# top 12
tops = ac[1:12,] # filter(ac, prop >= 0.95 , prop != 'NA')

ggplot(tops, aes(reorder(nome,prop), prop*100)) + 
  geom_bar(stat="identity", width=.07, fill = "darkred") + 
  geom_point(alpha = 0.9, size = 5, colour = "darkred") +
  theme_bw() + 
  theme(axis.title = element_text(color="#666666", face="bold", size=16), 
        axis.text = element_text(size=14), 
        axis.line = element_blank()) + 
  xlab("") + ylab("Concordância com Cunha (%)") + 
  ylim(0, 100) + 
  coord_flip()
dev.off()

# top do bem
png(file="tops-acunhas.png", height = 500, width = 650)
tops = ac[(NROW(ac) - 12):NROW(ac),]

ggplot(tops, aes(reorder(nome,prop), prop*100)) + 
  geom_bar(stat="identity", width=.05, fill = "darkgreen") + 
  geom_point(alpha = 0.9, size = 4, colour = "darkgreen") +
  theme_bw() + 
  theme(axis.title = element_text(color="#666666", face="bold", size=16), 
        axis.text = element_text(size=14), 
        axis.line = element_blank()) + 
  xlab("") + ylab("Concordância com Cunha (%)") + 
  ylim(0, 100) + 
  coord_flip()
dev.off()

# Por partido
to_plot = mutate(ac, cat_partido = ifelse(partido == 'pt' | partido == 'pmdb' | partido == 'psol' 
                                | partido == 'psdb' , as.character(partido), 'outros'))
to_plot$cat_partido <- factor(to_plot$cat_partido, 
                              levels = c("psol", "psdb", "pt", "pmdb", "outros"),
                              ordered = T)
                              
require(scales)
png(file="cunhometro-por-partido.png", height = 400, width = 500)
ggplot(to_plot, aes(cat_partido, prop * 100, colour = cat_partido) ) + 
  geom_point( position = position_jitter(width = 0.2), size = 5 ) +
  scale_colour_manual(values = c(alpha("#E69F00", 0.6),
                                 alpha("#0066CC", 0.6),
                                 alpha("#FF3300", 0.6),
                                 alpha("darkred", 0.6),
                                 alpha("grey70", .3)), 
                      guide = guide_legend(title = "partido", 
                                           override.aes = list(alpha = 1, size = 4))) + 
  theme(axis.title = element_text(color="#666666", face="bold", size=18), 
        axis.text.y = element_text(size=18), 
        axis.line = element_blank()) + 
  xlab("Partido") + ylab("Concordância com Cunha (%)") + 
  coord_flip() + 
  theme_bw()
dev.off()

r1 <- nPlot(cat_partido ~ prop, data = to_plot, type = 'point')
r1
