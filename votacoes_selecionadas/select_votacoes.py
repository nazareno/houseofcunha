import csv

selecionadas_file = open('votacoes_selecionadas_resumo_nome.csv', 'rb')
votacoes_file = open('../votacoes.csv', 'rb')
votacoesReader = csv.reader(votacoes_file, delimiter=',')
selecionadasReader = csv.reader(selecionadas_file, delimiter=',')
listaVotaca = []
listaSele = []

paraSalvar_file = open("votacoes_selecionadas.csv","w")
header = "tipo,num_pro,ano,id_votacao,resumo,data,hora,objetivo,sessao,nome,id_dep,partido,uf,voto,orientacao_partido,orientacao_gov,cunha"
paraSalvar_file.write(header+"\n")

for votacao in votacoesReader:
    listaVotaca.append(votacao)
for selecionada in selecionadasReader:
    listaSele.append(selecionada)

for selecionada in listaSele:
    encontrou = False
    for votacao in listaVotaca:
        if (selecionada[0] in votacao[4]):
            encontrou = True
            paraSalvar_file.write(', '.join(votacao) + "\n")
    if (not encontrou):
        print "DIDN'T FIND " + selecionada


paraSalvar_file.close()
votacoes_file.close()
selecionadas_file.close()