# coding: utf-8
import csv


votacoes_file = open('votacoes_selecionadas.csv', 'rb')
votacoesReader = csv.reader(votacoes_file, delimiter=',')
paraSalvar_file = open("votacoes_dados.csv","w")
header="tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome_votacao"
paraSalvar_file.write(header)
votacoes = {}
for votacao in votacoesReader:
    nome = votacao[-1]
    if not (nome in votacoes.keys()):

        dados = votacao[1:9] + [votacao[-1]]
        votacoes[nome] = dados
        paraSalvar_file.write(','.join(dados) + "\n")
print votacoes