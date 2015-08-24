python parser.py "votacoes_selecionadas/*.xml" "votacoes.csv"
python select_votacoes.py
python select_deputados.py
python select_nomes_votacoes.py
Rscript deputados_votos.R
Rscript partidos_votos.R
