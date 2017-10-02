import pandas as pd
from datetime import datetime

ALL_VOTING_FILENAME = "votacoes.csv"
SELECTED_VOTING_NAMES_FILENAME = "votacoes_selecionadas_resumo_nome.csv"
SELECTED_VOTING_FILENAME = "votacoes_selecionadas.csv"
SELECTED_VOTING_DATA = "votacoes_dados.csv"
PARTIES_ORIENATATION_FILENAME = "orientacao_partido.csv"

def filter_selected_voting(all_voting_filename, selected_voting_names_filename, selected_voting_filename):
    all_voting = pd.read_csv(all_voting_filename, delimiter=',', doublequote=True)
    selected_voting_names = pd.read_csv(selected_voting_names_filename, delimiter=',',
                                        names=["resumo", "nome_votacao"])
    selected_voting = pd.merge(all_voting, selected_voting_names, on="resumo")

    missing_votings = set(selected_voting_names.nome_votacao) - set(
        selected_voting.drop_duplicates("nome_votacao").nome_votacao)
    if len(missing_votings) > 0:
        raise Exception("ERROR, missing {} votings: {}".format(len(missing_votings), missing_votings))
    else:
        selected_voting.to_csv(selected_voting_filename, index=False)

def unify_congressman_data(selected_voting_filename):
    selected_voting = pd.read_csv(selected_voting_filename)

    selected_voting["data_date"] = selected_voting["data"].apply(lambda x: datetime.strptime(x, "%d/%m/%Y"))
    congressman = selected_voting.sort_values(by="data_date", ascending=False).drop_duplicates(
        "id_dep")[["nome", "id_dep", "partido"]]

    corrected_selected_voting = pd.merge(selected_voting.drop(["nome", "partido"], axis=1),
                                         congressman, on="id_dep", how="left")
    if len(corrected_selected_voting) != len(selected_voting):
        raise Exception("Some congressman were not found")
    else:
        corrected_selected_voting[selected_voting.columns].to_csv(selected_voting_filename, index=False)

def select_voting_data(selected_voting_filename, selected_voting_names_filename, selected_voting_data_filename):
    selected_voting = pd.read_csv(selected_voting_filename)
    selected_voting_names = pd.read_csv(selected_voting_names_filename,
                                        delimiter=',', names=["resumo", "nome_votacao"])

    columns = ["tipo", "num_pro", "ano", "id_votacao", "resumo", "data", "hora", "objetivo", "sessao", "nome_votacao"]
    selected_voting_data = selected_voting.drop_duplicates("nome_votacao")[columns]
    missing_votings = set(selected_voting_names.nome_votacao) - set(selected_voting_data.nome_votacao)

    if len(missing_votings) > 0:
        raise Exception("{} voting names are missing: {}".format(len(missing_votings), missing_votings  ))
    else:
        selected_voting_data.to_csv(selected_voting_data_filename, index=False)


filter_selected_voting(ALL_VOTING_FILENAME, SELECTED_VOTING_NAMES_FILENAME, SELECTED_VOTING_FILENAME)
filter_selected_voting("parties_orientation.csv", SELECTED_VOTING_NAMES_FILENAME, "parties_orientation_selected.csv")
unify_congressman_data(SELECTED_VOTING_FILENAME)
select_voting_data(SELECTED_VOTING_FILENAME, SELECTED_VOTING_NAMES_FILENAME, SELECTED_VOTING_DATA)