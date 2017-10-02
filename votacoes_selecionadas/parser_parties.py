# coding: utf-8
import sys
from xml.dom import minidom
import glob

###################################
#
#To run:
#python parser.py folder/*.xml file_to_write.csv
#
###################################

reload(sys)
sys.setdefaultencoding('utf8')

files = glob.glob(sys.argv[1])
fileToWrite = open(sys.argv[2],'w')

header =  'tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,partido,orientacao_partido'
fileToWrite.write(header + '\n')

for file in files:
    try:
        xmldoc = minidom.parse(file)
    except:
        txt = open(file)
        if ("xml") not in txt.readline():
            print "ERROR: NOT A XML >>> " + file
            continue
        else:
            print "ERROR: >>>" + file
            continue

    sigla = xmldoc.getElementsByTagName('Sigla')[0].firstChild.nodeValue
    n_prop = xmldoc.getElementsByTagName('Numero')[0].firstChild.nodeValue
    ano = xmldoc.getElementsByTagName('Ano')[0].firstChild.nodeValue

    votacoes = xmldoc.getElementsByTagName('Votacao')

    i = 0
    for votacao in votacoes:
        to_print = []
        to_print.append(sigla)
        to_print.append(n_prop)
        to_print.append(ano)

        i += 1
        resumo = votacao.attributes['Resumo'].value.strip().replace(',','.')
        data_prop = votacao.attributes['Data'].value.strip()
        hora_prop = votacao.attributes['Hora'].value.strip()
        objetivo = votacao.attributes['ObjVotacao'].value.strip().replace(',','.')
        sessao = votacao.attributes['codSessao'].value.strip()

        to_print.append(str(i))
        to_print.append(resumo)
        to_print.append(data_prop)
        to_print.append(hora_prop)
        to_print.append(objetivo)
        to_print.append(sessao)

        bancada = votacao.getElementsByTagName('bancada')
        for b in bancada:
            content = b.attributes.get('orientacao','NA')
            if content != 'NA':
                content = content.value.strip().lower()

            # map_bancada[b.attributes['Sigla'].value] = content
            to_print_dep = []
            to_print_dep.append(b.attributes['Sigla'].value)
            to_print_dep.append(content)
            # print(len(to_print + to_print_dep))
            if len(to_print + to_print_dep) == 11:
                to_print_final =  ','.join(to_print + to_print_dep)
                fileToWrite.write(to_print_final + "\n")
            else:
                print(to_print)


fileToWrite.flush()
fileToWrite.close()