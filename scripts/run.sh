#!/usr/bin/env bash

set -u
set -e

echo "GETTING THE DATA"
sh get_data.sh
python ../python/parser_deputados.py "../dados/deputados/deputados.xml" "../dados/deputados/deputados.csv"
echo "DOWNLOAD FINISH. NOW WILL TRANSFORM THE DATA"
python ../python/parser.py "../dados/votacoes/*.xml" "../dados/votacoes.csv"
python ../python/prop_parser.py "../dados/proposicoes/" "../dados/proposicoes.csv"
echo "THE END"