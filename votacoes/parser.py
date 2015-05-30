# coding: utf-8
import sys
from xml.dom import minidom
reload(sys)
sys.setdefaultencoding('utf8')

print 'tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome,id_dep,partido,uf,voto,orientacao' 
xmldoc = minidom.parse(sys.argv[1])


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
    map_bancada = {}
    
    for b in bancada:
    
        value = b.attributes['orientacao'].value
        
        if not value:
            o = 'NA'
        else:
            o = b.attributes['orientacao'].value.strip().lower()

        map_bancada[b.attributes['Sigla'].value.lower()] = o
    
    reg_votos = votacao.getElementsByTagName('votos')[0]
    
    for dep in reg_votos.getElementsByTagName('Deputado'):
        to_print_dep = []
        nome = dep.attributes['Nome'].value.strip()
        id_dep = dep.attributes['ideCadastro'].value.strip()
        partido = dep.attributes['Partido'].value.strip().lower()
        uf = dep.attributes['UF'].value.strip()
        voto = dep.attributes['Voto'].value.strip().lower()
        
        to_print_dep.append(nome)
        to_print_dep.append(id_dep)
        to_print_dep.append(partido)
        to_print_dep.append(uf)
        to_print_dep.append(voto)

        orientacao = map_bancada.get(partido)
        if not orientacao:
            for key in map_bancada.keys():
                if len(key) > 8:
                    if partido in key:
                        orientacao = map_bancada.get(key)
        if not orientacao:
            to_print_dep.append('NA')
        else:
            to_print_dep.append(orientacao)

        if len(to_print + to_print_dep) == 15:
            print ','.join(to_print + to_print_dep)
        else:
            print '#########'
