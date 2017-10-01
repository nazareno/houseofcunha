# coding: utf-8

import csv
import json
import sys
from operator import itemgetter
reload(sys)
sys.setdefaultencoding('utf8')


def parse(fileValue,fileName,fileJSON,indexCut):
    deputados_votos_file = open(fileValue, 'rb')
    deputados_reader = csv.reader(deputados_votos_file, delimiter=',')
    deputados_votos_file2 = open(fileName, 'rb')
    deputados_reader2 = csv.reader(deputados_votos_file2, delimiter=',')
    deputados_json = open(fileJSON,"w")
    deputadoslista2 = []
    for deputado in deputados_reader2:
        deputadoslista2.append(deputado)

    deputados = []

    for index,deputado in enumerate(deputados_reader, start=0):
        deputado2 = deputadoslista2[index]
        if (index == 0):
            header = deputado
            for value in header:
                print value
            continue
        dict_dept =  dict(zip( header[0:indexCut], deputado[0:indexCut]))
        dict_dept["temas"] = [{"tema":voto[0].strip().replace("."," "),"value":voto[1],"value_name":voto[2]} for voto in zip( header[indexCut:], deputado[indexCut:], deputado2[indexCut:])]
        dict_dept["temas"] = sorted(dict_dept["temas"], key=itemgetter('tema')) 
        # dict_dept["temas_nomes"] = [{"tema":voto[0],"value":voto[1]} for voto in zip( header[4:], deputado2[4:])]
        deputados.append(dict_dept)

    json.dump(deputados, deputados_json, ensure_ascii=False)

    deputados_json.close()

parse("partidos_votos_total.csv","partidos_votos_nomes_total.csv","partidos_votos_total.json",1)
parse("deputados_votos_total.csv","deputados_votos_nomes_total.csv","deputados_votos_total.json",4)
