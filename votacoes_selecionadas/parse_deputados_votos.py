# coding: utf-8

import csv
import json
import sys
reload(sys)
sys.setdefaultencoding('utf8')


deputados_votos_file = open('deputados_votos.csv', 'rb')
deputados_reader = csv.reader(deputados_votos_file, delimiter=',')
deputados_json = open("deputados_votos.json","w")


deputados = []
i = 0
for deputado in deputados_reader:
    if (i == 0):
        header = deputado
        for value in header:
            print value
        i = i+1
        continue
    dict_dept =  dict(zip( header[0:4], deputado[0:4]))
    dict_dept["temas"] = [{"tema":voto[0],"value":voto[1]} for voto in zip( header[4:], deputado[4:])]
    deputados.append(dict_dept)

json.dump(deputados, deputados_json, ensure_ascii=False)

deputados_json.close()