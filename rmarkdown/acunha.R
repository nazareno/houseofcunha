library(ggplot2)
library(dplyr)

votos <- read.csv("votacoes//votacao.csv", strip.white=TRUE)

votos <- filter(votos, voto %in% c("sim", "não")) 
votos$voto <- droplevels(votos$voto)
votos$num_pro <- factor(votos$num_pro)
votos$num_pro <- paste0(votos$num_pro, "-", votos$id_votacao)

votos$nome <- paste0(votos$nome, " (", votos$partido, ")")

ativos <- votos %>% 
  group_by(nome) %>% 
  summarise(c = n()) %>% 
  filter(c >= 31) %>% 
  select(nome)

votos <- filter(votos, nome %in% ativos$nome) 
votos = mutate(votos, concorda = ifelse(as.character(voto) == as.character(cunha), 1, 0) )

acunhamento = votos %>%
  group_by(nome, partido) %>%
  summarise(prop = sum(concorda) / n())

ac = acunhamento %>%
  mutate(nivel = ifelse(prop >= 0.70,'Cunha', ifelse(prop <= 0.6, 'Acunha','Muro'))) %>%
  ungroup() %>%
  arrange(desc(prop))


### PLOTS ###

png(file="tops-cunhas.png", height = 850, width = 650)
tops = filter(ac, prop >= 0.9 , prop != 'NA')

ggplot(tops, aes(reorder(nome,prop), prop*100)) + 
  geom_point(alpha = 0.9, size = 4, colour = "darkred") +
  theme_bw() + 
  theme(axis.title = element_text(color="#666666", face="bold", size=16), 
        axis.text = element_text(size=14), 
        axis.line = element_blank()) + 
  xlab("") + ylab("Concordância com Cunha (%)") + 
  coord_flip()
dev.off()
  

to_plot = mutate(ac, cat_partido = ifelse(partido == 'pt' | partido == 'pmdb' | partido == 'psol' 
                                | partido == 'psdb' , as.character(partido), 'outros'))
to_plot$cat_partido <- factor(to_plot$cat_partido, 
                              levels = c("psol", "psdb", "pt", "pmdb", "outros"),
                              ordered = T)
                              
require(scales)
png(file="cunhometro-por-partido.png", height = 450, width = 600)
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

# top do bem
png(file="tops-acunhas.png", height = 850, width = 650)
tops = filter(ac, prop < 0.4 , prop != 'NA')

ggplot(tops, aes(reorder(nome,prop), prop*100)) + 
  geom_point(alpha = 0.9, size = 4, colour = "darkgreen") +
  theme_bw() + 
  theme(axis.title = element_text(color="#666666", face="bold", size=16), 
        axis.text = element_text(size=14), 
        axis.line = element_blank()) + 
  xlab("") + ylab("Concordância com Cunha (%)") + 
  coord_flip()
dev.off()

