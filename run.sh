echo "GETTING THE DATA"
sh get_data.sh
echo "DOWNLOAD FINISH. NOW WILL TRANSFORM THE DATA"
python parser.py "votacoes/*.xml" "votacoes2.csv"
echo "THE END"
