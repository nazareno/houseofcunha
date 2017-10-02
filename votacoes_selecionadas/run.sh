python parser.py "votacoes_selecionadas/*.xml" "votacoes.csv"
python parser_parties.py "votacoes_selecionadas/*.xml" "parties_orientantion.csv"

#in votacoes.csv votacoes_selecionadas_resumo_nome.csv #out votacoes_selecionadas.csv votacoes_dados.csv
python parse_data.py

python deputados_votos.py
python partidos_votos.py

#in deputados_votos.csv deputados_votos_nomes.csv #out deputados_votos.json
python parse_deputados_votos.py
