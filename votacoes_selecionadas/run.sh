python parser.py "votacoes_selecionadas/*.xml" "votacoes.csv"

#in votacoes_selecionadas_resumo_nome.csv votacoes.csv #out votacoes_selecionadas.csv
python select_votacoes.py 

#in votacoes_selecionadas.csv votacoes.csv #out votacoes_selecionadas.csv
python correctFiles.py

#in votacoes_selecionadas.csv votacoes.csv #out deputados.csv
python select_deputados.py

#in votacoes_selecionadas.csv votacoes.csv #out votacoes_dados.csv
python select_nomes_votacoes.py

#in votacoes_selecionadas.csv votacoes.csv #out deputados_votos.csv deputados_votos_nomes.csv
Rscript deputados_votos.R

Rscript partidos_votos.R

#in deputados_votos.csv deputados_votos_nomes.csv #out deputados_votos.json
python parse_deputados_votos.py
