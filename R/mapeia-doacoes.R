#
# Gera um mapa dos deputaods a partir das doações recebidas pelos deputados 
# 
require(dplyr)
source("R/camara-lib.R")

doacoes <- ler_doacoes_de_eleitos(arquivo.doacoes = "data//receitas_todos_deputados_federais.txt", 
                                  arquivo.eleitos = "deputados-detalhes.csv")

