# coding: utf-8
import csv


votacoes_file = open('votacoes_selecionadas.csv', 'rb')
votacoesReader = csv.reader(votacoes_file, delimiter=',')
paraSalvar_file = open("deputados.csv","w")

deputados = {}
for votacao in votacoesReader:
    nome = votacao[9].strip()
    if not (nome in deputados.keys()):
        dados = [nome,votacao[10].strip(),votacao[11].strip(),votacao[12].strip()]
        deputados[nome] = dados
        paraSalvar_file.write(','.join(dados) + "\n")
print deputados