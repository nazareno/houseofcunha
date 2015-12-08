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

header =  'ideCadastro\tcondicao\tmatricula\tidParlamentar\tnome\tnomeParlamentar\turlFoto\tsexo\tuf\tpartido\tgabinete\tfone\temail\tnone'
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

    deputados = xmldoc.getElementsByTagName('deputado')

    for deputado in deputados:
       ideCadastro = deputado.getElementsByTagName('ideCadastro')[0].firstChild.nodeValue
       condicao = deputado.getElementsByTagName('condicao')[0].firstChild.nodeValue
       matricula = deputado.getElementsByTagName('matricula')[0].firstChild.nodeValue
       idParlamentar = deputado.getElementsByTagName('idParlamentar')[0].firstChild.nodeValue
       nome = deputado.getElementsByTagName('nome')[0].firstChild.nodeValue
       nomeParlamentar = deputado.getElementsByTagName('nomeParlamentar')[0].firstChild.nodeValue
       urlFoto = deputado.getElementsByTagName('urlFoto')[0].firstChild.nodeValue
       sexo = deputado.getElementsByTagName('sexo')[0].firstChild.nodeValue
       uf = deputado.getElementsByTagName('uf')[0].firstChild.nodeValue
       partido = deputado.getElementsByTagName('partido')[0].firstChild.nodeValue
       gabinete = deputado.getElementsByTagName('gabinete')[0].firstChild.nodeValue
       fone = deputado.getElementsByTagName('fone')[0].firstChild.nodeValue
       email = deputado.getElementsByTagName('email')[0].firstChild.nodeValue

       to_print = []
       to_print.append(ideCadastro)
       to_print.append(condicao)
       to_print.append(matricula)
       to_print.append(idParlamentar)
       to_print.append(nome)
       to_print.append(nomeParlamentar)
       to_print.append(urlFoto)
       to_print.append(sexo)
       to_print.append(uf)
       to_print.append(partido)
       to_print.append(gabinete)
       to_print.append(fone)
       to_print.append(email)

       for _print in to_print:
            fileToWrite.write(_print + "\t")
       
       fileToWrite.write("\n")


fileToWrite.close()