# coding: utf-8
import pandas as pd
import numpy as np
import copy


def vote_to_int(vote):
    vote_to_int_values = {"sim": 1, "não": 0, "liberado": -1, "abstenção":-2,
                          "obstrução":-3, "art. 17":-4, "sem orientação": -5, "não votou":None, "-":None}

    if vote is None or vote is np.nan:
        return -1
    if vote in vote_to_int_values:
        return vote_to_int_values[vote]
    raise Exception("Not found vote {}".format(vote))

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

def add_external_voting_parties(external_voting, parties_voting_filename, parties_voting_name_filename,
                                out_parties_voting_filename, out_parties_voting_name_filename):
    parties_voting_int = pd.read_csv(parties_voting_filename)
    parties_voting_names = pd.read_csv(parties_voting_name_filename)
    for info in external_voting:
        external_vote = pd.read_csv(info[0])
        external_vote["voto_int"] = external_vote["voto"].apply(vote_to_int)


        parties_voting_names = pd.merge(parties_voting_names,
                                        external_vote[["partido", "voto"]], on="partido", how="left")
        parties_voting_names = parties_voting_names.rename(columns={"voto": info[1]})
        parties_voting_names = parties_voting_names.fillna("não votou")

        parties_voting_int = pd.merge(parties_voting_int,
                                      external_vote[["partido", "voto_int"]], on="partido", how="left")
        parties_voting_int = parties_voting_int.rename(columns={"voto_int": info[1]})
        parties_voting_int = parties_voting_int.fillna(-10)
        parties_voting_int.iloc[:, 1:] = parties_voting_int.iloc[:, 1:].astype(int)

        parties_voting_int.to_csv(out_parties_voting_filename, index=False)
        parties_voting_names.to_csv(out_parties_voting_name_filename, index=False)

def add_missing_infos(infos_filename, df):
    dep_missing = pd.read_csv(infos_filename)
    df["id_dep"] = df.id_dep.astype(int)
    df = pd.merge(df, dep_missing,on="id_dep", how="left")
    columns = ["nome","partido", "uf"]
    for c in columns:
        df[c+"_x"] = df[c+"_x"].fillna(df[c+"_y"])
        df.drop(c+"_y", axis=1, inplace=True)
        df.rename(columns={c+"_x":c}, inplace=True)
    return df

def add_external_voting_congressman(external_voting, congressman_voting_filename,
                                    congressman_voting_name_filename, out_congressman_voting_filename,
                                    out_congressman_voting_name_filename):
    voting_int = pd.read_csv(congressman_voting_filename)
    voting_names = pd.read_csv(congressman_voting_name_filename)

    for info in external_voting:
        external_vote = pd.read_csv(info[0])
        external_vote["voto_int"] = external_vote["voto"].apply(vote_to_int)

        voting_names = pd.merge(voting_names,
                                external_vote[["id_dep", "voto"]], on="id_dep", how="outer")
        voting_names = voting_names.rename(columns={"voto": info[1]})

        voting_int = pd.merge(voting_int, external_vote[["id_dep", "voto_int"]], on="id_dep", how="outer")
        voting_int = voting_int.rename(columns={"voto_int": info[1]})
    voting_names = add_missing_infos("deputados_info_missing.csv", voting_names)
    voting_int = add_missing_infos("deputados_info_missing.csv", voting_int)

    voting_names = voting_names.fillna("não votou")
    voting_int = voting_int.fillna(-1)
    voting_int.iloc[:, 4:] = voting_int.iloc[:, 4:].astype(int)

    voting_int.to_csv(out_congressman_voting_filename, index=False)
    voting_names.to_csv(out_congressman_voting_name_filename, index=False)


def extract_congressman(voting_filename, congressman_filename):
    voting = pd.read_csv(voting_filename)
    voting[["nome","id_dep","partido"]].to_csv(congressman_filename, index=False)


parse_orientation("parties_orientation_selected.csv", "parties_already_know.csv", "parties_orientation_selected_parsed.csv")

parse_parties_data("parties_orientation_selected_parsed.csv", "partidos_votos.csv", "partidos_votos_nomes.csv")

external_voting = [("votacoes_selecionadas/impeachmeant_partidos.csv", "Impeachment"),
                   ("votacoes_selecionadas/temer_partidos.csv", "Prosseguimento da denúncia contra Temer")]

add_external_voting_parties(external_voting,
                            "partidos_votos.csv", "partidos_votos_nomes.csv",
                            "partidos_votos_total.csv", "partidos_votos_nomes_total.csv")

