echo "GETTING THE DATA"
sh get_data.sh
python ./python/parser_deputados.py "deputados/deputados.xml" "deputados/deputados.csv"
echo "DOWNLOAD FINISH. NOW WILL TRANSFORM THE DATA"
python ./python/parser.py "votacoes/*.xml" "votacoes.csv"
python ./python/prop_parser.py "proposicoes/" "proposicoes.csv"
echo "THE END"
