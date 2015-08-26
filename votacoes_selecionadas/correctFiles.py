# coding: utf-8

import csv
import json
import sys
reload(sys)
sys.setdefaultencoding('utf8')
deputados_votos_file = open("votacoes_selecionadas.csv", 'rb')
deputados_reader = csv.reader(deputados_votos_file, delimiter=',')
deputadoslista2 = []
for deputado in deputados_reader:
    deputadoslista2.append(deputado)

for deputado in deputadoslista2:
    if (deputado[9] == "Evandro Rogerio Roman"):
        deputado[9] = "Evandro Roman"
    if (deputado[9] == "Eli Côrrea Filho"):
        deputado[9] = "Eli Corrêa Filho"
    if (deputado[9] == "Cabo Daciolo"):
        deputado[11] = "s.part."

for deputado in deputadoslista2:
    if (deputado[9] == "Evandro Rogerio Roman"):
        print deputado
    if (deputado[9] == "Eli Côrrea Filho"):
        print deputado




myfile = open("votacoes_selecionadas.csv", 'wb')
wr = csv.writer(myfile, quoting=csv.QUOTE_NONE)
wr.writerows(deputadoslista2)
