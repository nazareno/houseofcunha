python parser.py "votacoes_selecionadas/*.xml" "votacoes.csv"
#in votacoes_selecionadas_resumo_nome.csv votacoes.csv #out votacoes_selecionadas.csv
python select_votacoes.py 
python correctFiles.py
python select_deputados.py
python select_nomes_votacoes.py
Rscript deputados_votos.R
Rscript partidos_votos.R
python parse_deputados_votos.py
