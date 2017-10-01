# coding: utf-8
import pandas as pd
import numpy as np

def vote_to_int(vote):
    #'sem orientação' and 'liberado' are used only at parties orientation
    vote_to_int_values = {"sim": 1, "não": 0, "liberado": -1, "abstenção":-2,
                          "obstrução":-3, "art. 17":-4, "sem orientação": -5, "não votou":None, "-":None}

    if vote is None or vote is np.nan:
        return -1
    if vote in vote_to_int_values:
        return vote_to_int_values[vote]
    raise Exception("Not found vote {}".format(vote))


def parse_congressman_data(selected_voting_filename, congressman_voting_filename, congressman_voting_name_filename):
    voting = pd.read_csv(selected_voting_filename)
    voting = voting[["id_dep", "nome", "voto", "nome_votacao", "partido", "uf"]]
    voting["voto_int"] = voting["voto"].apply(vote_to_int)

    congressman_infos = voting.drop_duplicates("id_dep")[["id_dep", "nome", "partido", "uf"]]

    voting_name_long = voting.pivot(index="id_dep", columns="nome_votacao", values="voto").reset_index()
    voting_name_long = voting_name_long.fillna("não votou")
    voting_name_long = pd.merge(congressman_infos, voting_name_long, on='id_dep')
    voting_name_long = voting_name_long.sort_values(by=["partido", "nome"])

    voting_int_long = voting.pivot(index="id_dep", columns="nome_votacao", values="voto_int").reset_index()
    voting_int_long = voting_int_long.fillna(-1)
    voting_int_long.iloc[:, 1:-1] = voting_int_long.iloc[:, 1:-1].astype(int)
    voting_int_long = pd.merge(congressman_infos, voting_int_long, on='id_dep')
    voting_int_long = voting_int_long.sort_values(by=["partido", "nome"])

    voting_int_long.to_csv(congressman_voting_filename, index=False)
    voting_name_long.to_csv(congressman_voting_name_filename, index=False)

def parse_parties_data(parties_orientation_filename, parties_voting_filename, parties_voting_name_filename):
    voting = pd.read_csv(parties_orientation_filename)
    voting.rename(columns={"partido": "nome"})
    voting.orientacao_partido = voting.orientacao_partido.fillna("sem orientação")
    voting["orientacao_partido_int"] = voting["orientacao_partido"].apply(vote_to_int)

    voting_int_long = voting.pivot(index="partido", columns="nome_votacao",
                                   values="orientacao_partido_int").reset_index()
    voting_int_long = voting_int_long.fillna(-10)  # the party didn't exist at the time of voting

    voting_name_long = voting.pivot(index="partido", columns="nome_votacao",
                                    values="orientacao_partido").reset_index()
    voting_name_long = voting_name_long.fillna("não votou")  # the party didn't exist at the time of voting

    voting_int_long.to_csv(parties_voting_filename, index=False)
    voting_name_long.to_csv(parties_voting_name_filename, index=False)

def add_external_voting_parties(impeachment_parties_filename, parties_voting_filename, parties_voting_name_filename,
                                out_parties_voting_filename, out_parties_voting_name_filename):
    parties_impeachment = pd.read_csv(impeachment_parties_filename)
    parties_impeachment["Impeachment_int"] = parties_impeachment.Impeachment.apply(vote_to_int)

    parties_voting_names = pd.read_csv(parties_voting_name_filename)
    parties_voting_names = pd.merge(parties_voting_names,
                                    parties_impeachment[["partido", "Impeachment"]], on="partido", how="left")
    parties_voting_names = parties_voting_names.fillna("não votou")

    parties_voting_int = pd.read_csv(parties_voting_filename)
    parties_voting_int = pd.merge(parties_voting_int,
                                  parties_impeachment[["partido", "Impeachment_int"]], on="partido", how="left")
    parties_voting_int = parties_voting_int.fillna(-10)
    parties_voting_int.iloc[:, 1:-1] = parties_voting_int.iloc[:, 1:-1].astype(int)

    parties_voting_int.to_csv(out_parties_voting_filename, index=False)
    parties_voting_names.to_csv(out_parties_voting_name_filename, index=False)

def add_external_voting_congressman(impeachment_deputies_filename, congressman_voting_filename,
                                    congressman_voting_name_filename, out_congressman_voting_filename,
                                    out_congressman_voting_name_filename):
    impeachment = pd.read_csv(impeachment_deputies_filename)
    impeachment["Impeachment_int"] = impeachment.Impeachment.apply(vote_to_int)

    voting_names = pd.read_csv(congressman_voting_name_filename)
    voting_names = pd.merge(voting_names,
                            impeachment[["id_dep", "Impeachment"]], on="id_dep", how="left")
    voting_names = voting_names.fillna("não votou")

    voting_int = pd.read_csv(congressman_voting_filename)
    voting_int = pd.merge(voting_int,
                          impeachment[["id_dep", "Impeachment_int"]], on="id_dep", how="left")
    voting_int = voting_int.fillna(-10)
    voting_int.iloc[:, 4:-1] = voting_int.iloc[:, 4:-1].astype(int)

    voting_int.to_csv(out_congressman_voting_filename, index=False)
    voting_names.to_csv(out_congressman_voting_name_filename, index=False)


parse_congressman_data("votacoes_selecionadas.csv", "deputados_votos.csv", "deputados_votos_nomes.csv")

parse_parties_data("orientacao_partido.csv", "partidos_votos.csv", "partidos_votos_nomes.csv")

add_external_voting_congressman("votacoes_selecionadas/impeachmeant_deputados.csv",
                                "deputados_votos.csv", "deputados_votos_nomes.csv",
                                "deputados_votos_total.csv", "deputados_votos_nomes_total.csv")

add_external_voting_parties("votacoes_selecionadas/impeachmeant_partidos.csv",
                            "partidos_votos.csv", "partidos_votos_nomes.csv",
                            "partidos_votos_total.csv", "partidos_votos_nomes_total.csv")

