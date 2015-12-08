# coding: utf-8
import sys
from xml.dom import minidom
import os
import csv

MIN_NUM_ARGS = 3
NUM_TABLE_COLS = 24

def printUsage():
    print "Usage: python prop_parser.py <inputPropXMLsFolder> <outputCSVFilePath>"

def getElementValueAsString(doc,elementTag):
    child = doc.getElementsByTagName(elementTag)[0].firstChild
    if (child != None):
        cleanValue = child.nodeValue.strip(' \t\n\r')
        if (cleanValue != ""):
            return cleanValue
    return "NA"

def getElementAttributeAsString(doc,elementTag,attributeTag):
    node = doc.getElementsByTagName(elementTag)[0]
    if (node != None):
        if (node.hasAttribute(attributeTag)):
            cleanValue = node.getAttribute(attributeTag).strip(' \t\n\r')
            if (cleanValue != ""):
                return cleanValue        
    return "NA"


reload(sys)
sys.setdefaultencoding('utf8')

if (len(sys.argv) < MIN_NUM_ARGS):
    print "Wrong Usage!"
    printUsage()
    exit(1)

props_folder_path = sys.argv[1]
fileToWrite = csv.writer(open(sys.argv[2], "wb"))

header =  'tipo,numero,ano,nome_proposicao,id_proposicao,id_proposicao_principal,nome_proposicao_origem,tipo_proposicao,tema,ementa,explicacao_ementa,autor,ide_cadastro,uf_autor,partido_autor,data_apresentacao,regime_tramitacao,data_ultimo_despacho,ultimo_despacho,apreciacao,indexacao,situacao,link_inteiro_teor,apensadas'
fileToWrite.writerow(header.split(","))

for file in os.listdir(props_folder_path):
    filePath = props_folder_path + "/" + file

    print "Parsing file:", filePath

    try:
        xmldoc = minidom.parse(filePath)
    except:
        txt = open(filePath)
        if ("xml") not in txt.readline():
            print "ERROR: NOT AN XML >>> " + filePath
            continue
        else:
            print "ERROR: >>>" + filePath
            continue

    prop_data = []

    proposicao = xmldoc.getElementsByTagName('proposicao')[0]
    tipo = getElementAttributeAsString(xmldoc,'proposicao','tipo')
    numero = getElementAttributeAsString(xmldoc,'proposicao','numero')
    ano = getElementAttributeAsString(xmldoc,'proposicao','ano')

    nome_proposicao = getElementValueAsString(xmldoc,'nomeProposicao')
    id_proposicao = getElementValueAsString(xmldoc,'idProposicao')
    id_proposicao_principal = getElementValueAsString(xmldoc,'idProposicaoPrincipal')
    nome_proposicao_origem = getElementValueAsString(xmldoc,'nomeProposicaoOrigem')
    tipo_proposicao = getElementValueAsString(xmldoc,'tipoProposicao')
    tema = getElementValueAsString(xmldoc,'tema')
    ementa = getElementValueAsString(xmldoc,'Ementa') 
    explicacao_ementa = getElementValueAsString(xmldoc,'ExplicacaoEmenta')
    autor = getElementValueAsString(xmldoc,'Autor')
    ide_cadastro = getElementValueAsString(xmldoc,'ideCadastro')
    uf_autor = getElementValueAsString(xmldoc,'ufAutor')
    partido_autor = getElementValueAsString(xmldoc,'partidoAutor')
    data_apresentacao = getElementValueAsString(xmldoc,'DataApresentacao')
    regime_tramitacao = getElementValueAsString(xmldoc,'RegimeTramitacao')
    ultimo_despacho = getElementValueAsString(xmldoc,'UltimoDespacho')
    data_ultimo_despacho = getElementAttributeAsString(xmldoc,'UltimoDespacho','Data')
    apreciacao = getElementValueAsString(xmldoc,'Apreciacao')
    indexacao = getElementValueAsString(xmldoc,'Indexacao')
    situacao = getElementValueAsString(xmldoc,'Situacao')
    link_inteiro_teor = getElementValueAsString(xmldoc,'LinkInteiroTeor')
    apensadas = getElementValueAsString(xmldoc,'apensadas')

    prop_data.append(tipo)
    prop_data.append(numero)
    prop_data.append(ano)
    prop_data.append(nome_proposicao)
    prop_data.append(id_proposicao)
    prop_data.append(id_proposicao_principal)
    prop_data.append(nome_proposicao_origem)
    prop_data.append(tipo_proposicao)
    prop_data.append(tema)
    prop_data.append(ementa)
    prop_data.append(explicacao_ementa)
    prop_data.append(autor)
    prop_data.append(ide_cadastro)
    prop_data.append(uf_autor)
    prop_data.append(partido_autor)
    prop_data.append(data_apresentacao)
    prop_data.append(regime_tramitacao)
    prop_data.append(data_ultimo_despacho)
    prop_data.append(ultimo_despacho)
    prop_data.append(apreciacao)
    prop_data.append(indexacao)
    prop_data.append(situacao)
    prop_data.append(link_inteiro_teor)
    prop_data.append(apensadas)

    if len(prop_data) == NUM_TABLE_COLS:
        #print prop_data
        prop_data_str =  ','.join(prop_data)
        fileToWrite.writerow(prop_data)

