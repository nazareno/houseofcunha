#!/usr/bin/env bash
#### 1 - Put XML selecting votes to folder "votacoes_selecionadas"
#### 2 - Run parser scritps
python parser.py "votacoes_selecionadas/*.xml" "votacoes.csv"
python parser_parties.py "votacoes_selecionadas/*.xml" "parties_orientantion.csv"

#### 3 - Put the (description, short name) in "votacoes_selecionadas_resumo_nome.csv"

#### 4 - Parse data
#in votacoes.csv votacoes_selecionadas_resumo_nome.csv #out votacoes_selecionadas.csv votacoes_dados.csv
python parse_data.py

#### 5 - About external voting
##### 5.1 - Add congressman infos that are not in XML voting in "deputados_info_missing.csv"
##### 5.2 - Add the external file to "external_voting" variable in "deputados_votos.py" and "partidos_votos.py"
##### 5.3 - Add file with new party names

#### 6 - Run voting files:
python deputados_votos.py
python partidos_votos.py

#### 7 - Run script to generate json files that will be used in the website
#in deputados_votos.csv deputados_votos_nomes.csv #out deputados_votos.json
python parse_deputados_votos.py

cp data/deputados_votos_total.json ../../quemMeRepresenta/dados/deputados_votos.json
cp data/partidos_votos_total.json ../../quemMeRepresenta/dados/partidos_votos.json