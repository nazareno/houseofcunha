# coding: utf-8
import sys
from xml.dom import minidom

out = open('votacoes.csv', 'w')

print 'tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome,id_dep,partido,uf,voto,orientacao' 
xmldoc = minidom.parse(sys.argv[1])

to_print = []

sigla = xmldoc.getElementsByTagName('Sigla')[0].firstChild.nodeValue
n_prop = xmldoc.getElementsByTagName('Numero')[0].firstChild.nodeValue
ano = xmldoc.getElementsByTagName('Ano')[0].firstChild.nodeValue

to_print.append(sigla)
to_print.append(n_prop)
to_print.append(ano)

votacoes = xmldoc.getElementsByTagName('Votacao')

i = 0
for votacao in votacoes:
    i += 1
    resumo = votacao.attributes['Resumo'].value.strip()
    data_prop = votacao.attributes['Data'].value.strip()
    hora_prop = votacao.attributes['Hora'].value.strip()
    objetivo = votacao.attributes['ObjVotacao'].value.strip()
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
        map_bancada[b.attributes['Sigla'].value.lower()] = b.attributes['orientacao'].value.strip().lower()
    
    reg_votos = votacao.getElementsByTagName('votos')[0]
    
    for dep in reg_votos.getElementsByTagName('Deputado'):
        nome = dep.attributes['Nome'].value.strip()
        id_dep = dep.attributes['ideCadastro'].value.strip()
        partido = dep.attributes['Partido'].value.strip().lower()
        uf = dep.attributes['UF'].value.strip()
        voto = dep.attributes['Voto'].value.strip().lower()
        
        to_print.append(nome)
        to_print.append(id_dep)
        to_print.append(partido)
        to_print.append(uf)
        to_print.append(voto)

        orientacao = map_bancada.get(partido)
        if not orientacao:
            for key in map_bancada.keys():
                if len(key) > 8:
                    if partido in key:
                        orientacao = map_bancada.get(key)
        to_print.append(orientacao.lower())

        print ','.join(to_print)
