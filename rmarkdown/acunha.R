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
  

ac$nivel = factor(ac$nivel, levels = c('Cunha', 'Muro', 'Acunha'), ordered = T)
to_plot = mutate(ac, cat_partido = ifelse(partido == 'pt' | partido == 'pmdb' | partido == 'psol' 
                                | partido == 'psdb' , as.character(partido), 'outros'))

ggplot(to_plot, aes(cat_partido, prop, colour = cat_partido) ) + 
  geom_point( position = position_jitter(), alpha = 0.5, size = 4 ) +
  coord_flip() + 
  theme_bw()

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

