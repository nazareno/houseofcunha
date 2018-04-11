# coding: utf-8
import pandas as pd
import copy
from utils import vote_to_int, check_added_duplicated_row, change_parties_names


def parse_orientation(orientation_filename, parties_already_know_filename, orientantion_parsed_filename):
    orient = pd.read_csv(orientation_filename)
    orient = orient[["partido", "nome_votacao", "orientacao_partido"]]
    coaliations = {
        "PpPtbPscPhs": ["Pp", "Ptb", "Psc", "Phs"],
        "PmdbPen": ["Pmdb", "Pen"],
        "PrbPtnPmnPrpPsdcPtcPslPtdoB": ["Prb", "Ptn", "Pmn", "Prp", "Psdc", "Ptc", "Psl", "PtdoB"],
        "Solidaried": ["Solidaried"],
        "PCdoB": ["PCdoB"],
        "PmdbPpPtbPscPhsPen": ["Pmdb", "Pp", "Ptb", "Psc", "Phs", "Pen"],
        "PrbPtnPmnPrpPsdcPrtbPtcPslPtdoB": ["Prb", "Ptn", "Pmn", "Prp", "Psdc", "Prtb", "Ptc", "Psl", "PtdoB"],
        "PtbProsPsl": ["Ptb", "Pros", "Psl"],
        "PpPtnPhs...": ["Pp", "Ptn", "Phs", "Prp", "Ptdob"],
        "PpPtnPTdoB": ["Pp", "Ptn", "PTdoB"]
    }

    exclude = {"Maioria", "Minoria", "GOV."}

    parties_already_know = pd.read_csv(parties_already_know_filename)
    parties_already_know = set(parties_already_know["partido"])

    parties_already_know = map(lambda x: x.lower(), parties_already_know)
    rows = []
    for index, row in orient.iterrows():
        party = row["partido"]
        party = party.replace("Repr.", "")
        row["partido"] = party
        if party in exclude:
            continue
        if party in coaliations:
            parties_splited = coaliations[party]
            for party_splited in parties_splited:
                row_ = copy.deepcopy(row)
                row_["partido"] = party_splited
                rows.append(row_)
        elif party.lower() in parties_already_know:
            rows.append(row)
        else:
            raise Exception("Party not found: {}".format(party))
    df = pd.DataFrame.from_records(rows)
    df["partido"] = df["partido"].apply(lambda x: x.lower())
    df.to_csv(orientantion_parsed_filename, index=False)


def parse_parties_data(parties_orientation_filename, parties_voting_filename, parties_voting_name_filename):
    voting = pd.read_csv(parties_orientation_filename)
    voting.rename(columns={"partido": "nome"}, inplace=True)
    voting.orientacao_partido = voting.orientacao_partido.fillna("sem orientação")
    voting["orientacao_partido_int"] = voting["orientacao_partido"].apply(vote_to_int)

    voting_int_long = voting.pivot(index="nome", columns="nome_votacao",
                                   values="orientacao_partido_int").reset_index()
    voting_int_long = voting_int_long.fillna(-10)  # the party didn't exist at the time of voting

    voting_name_long = voting.pivot(index="nome", columns="nome_votacao",
                                    values="orientacao_partido").reset_index()
    voting_name_long = voting_name_long.fillna("não votou")  # the party didn't exist at the time of voting

    voting_int_long.to_csv(parties_voting_filename, index=False)
    voting_name_long.to_csv(parties_voting_name_filename, index=False)


def add_external_voting_parties(external_voting, parties_voting_filename, parties_voting_name_filename,
                                out_parties_voting_filename, out_parties_voting_name_filename, change_party_name):
    parties_voting_int = pd.read_csv(parties_voting_filename)
    parties_voting_names = pd.read_csv(parties_voting_name_filename)
    new_name_parties = pd.read_csv(NEW_NAMES_PARTIES)
    for info in external_voting:
        external_vote = pd.read_csv(info[0])
        if change_party_name:
            external_vote = change_parties_names(external_vote, "nome", new_name_parties)

        external_vote["voto_int"] = external_vote["voto"].apply(vote_to_int)

        parties_voting_names = pd.merge(parties_voting_names,
                                        external_vote[["nome", "voto"]], on="nome", how="outer")
        parties_voting_names = parties_voting_names.rename(columns={"voto": info[1]})
        parties_voting_names = parties_voting_names.fillna("não votou")

        parties_voting_int = pd.merge(parties_voting_int,
                                      external_vote[["nome", "voto_int"]], on="nome", how="outer")
        parties_voting_int = parties_voting_int.rename(columns={"voto_int": info[1]})

        check_added_duplicated_row(parties_voting_int, "nome", info[1])
        check_added_duplicated_row(parties_voting_names, "nome", info[1])

    parties_voting_int = parties_voting_int.fillna(-10)
    parties_voting_int.iloc[:, 1:] = parties_voting_int.iloc[:, 1:].astype(int)

    parties_voting_int.to_csv(out_parties_voting_filename, index=False)
    parties_voting_names.to_csv(out_parties_voting_name_filename, index=False)


NEW_NAMES_PARTIES = "data/parties_new_names.csv"

parse_orientation("data/parties_orientation_selected.csv", "data/parties_already_know.csv",
                  "data/parties_orientation_selected_parsed.csv")

parse_parties_data("data/parties_orientation_selected_parsed.csv", "data/partidos_votos.csv",
                   "data/partidos_votos_nomes.csv")

external_voting = [("votacoes_selecionadas/impeachmeant_partidos.csv", "Impeachment"),
                   ("votacoes_selecionadas/temer_partidos.csv", "Prosseguimento da denúncia contra Temer"),
                   ("votacoes_selecionadas/temer_2_partidos.csv", "Prosseguimento da 2ª denúncia contra Temer")]

add_external_voting_parties(external_voting,
                            "data/partidos_votos.csv", "data/partidos_votos_nomes.csv",
                            "data/partidos_votos_total.csv", "data/partidos_votos_nomes_total.csv", change_party_name=True)

