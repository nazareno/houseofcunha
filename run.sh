echo "GETTING THE DATA"
sh get_data2.sh
echo "DOWNLOAD FINISH. NOW WILL TRANSFORM THE DATA"
python parser.py "votacoes2/*.xml" "votacoes2.csv"
echo "THE END"
