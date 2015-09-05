echo "GETTING THE DATA"
sh get_data.sh
echo "DOWNLOAD FINISH. NOW WILL TRANSFORM THE DATA"
python ./python/parser.py "votacoes/*.xml" "votacoes.csv"
echo "THE END"
