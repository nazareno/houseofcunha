    Arquivos

Pasta - votacoes_selecionadas
Pasta contendo os xmls das votações selecionadas

votacoes_selecionadas_resumo_nome.csv
Arquivo com as votações mais importantes, contendo o RESUMO e o NOME conhecido delas.

select_votacoes.py
Extrai do arquivo votacoes.csv, que contém os dados de todos os atos de votação, os atos das votações selecionadas, gerando o arquivo votacoes_selecionadas.csv

votacoes_selecionadas.csv
Arquivo com todos os dados dos atos de votação das votações mais importantes

select_deputados.py
Do arquivo votacoes_selecionadas.csv seleciona as informações dos deputados e salva em deputados.csv

deputados.csv
Arquivo com as informações dos deputados: nome,id_dep,partido,uf

select_nomes_votacoes.py
Do arquivo votacoes_selecionadas.csv seleciona as informações de cada votação (e não do ato de votação). Salva em votacoes_dados.csv

votacoes_dados.csv
Arquivo com os dados da votações (e não do ato de votação):
tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome_votacaonum_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome_votacao

deputados_votos.R
Filtra o arquivo votacoes_dados e deixa no formato long, gerando o arquivo deputados_votos.csv

deputados_votos.csv
Arquivo filtrado e no formato long das votações dos deputados
id_dep,nome,partido,uf,Coincidência reeleição,Cota para mulheres legislativo,Distritao,Financiamento privado para partidos,Financiamento privado para partidos e candidatos,Maioridade 1,Maioridade 2,Pensão, Reeleição,Seguro Desemprego,Tempo Mandato,Terceirização,Transgênico,Voto Facultativo,Voto impresso

parse_deputados_votos.py
Transforma o deputados_votos.csv em um json, onde os temas são agrupados em um elemento.

deputados_votos.json
Json criado a partir do parse_deputados_votos.py


