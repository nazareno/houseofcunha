# coding: utf-8
import numpy as np
import pandas as pd


def vote_to_int(vote):
    # 'sem orientação' and 'liberado' are used only at parties orientation
    vote_to_int_values = {"sim": 1, "não": 0, "liberado": -1, "abstenção": -2,
                          "obstrução": -3, "art. 17": -4, "sem orientação": -5, "não votou": None, "-": None}

    if vote is None or vote is np.nan:
        return -1
    if vote in vote_to_int_values:
        return vote_to_int_values[vote]
    raise Exception("Not found vote {}".format(vote))


def df_get_duplicated(df, column):
    return list(df[[column]][df[[column]].duplicated(keep=False)].drop_duplicates()[column])


def check_added_duplicated_row(df, column, external):
    if len(df_get_duplicated(df, column)) > 0:
        duplicated_ids = ','.join(map(str, df_get_duplicated(df, column)))
        raise Exception("Duplicated in voting {}: {}".format(external, duplicated_ids))

def change_parties_names(votes, column_party, new_name_parties):
    new_names_parties = {r['old_name']: r['new_name'] for i, r in new_name_parties.iterrows()}
    votes[column_party] = votes[column_party].apply(lambda x: new_names_parties[x] if x in new_names_parties else x)
    return votes

def change_parties_names_filename(votes_file, column_party, new_name_parties_file):
    votes = pd.read_csv(votes_file)
    new_name_parties = pd.read_csv(new_name_parties_file)
    votes = change_parties_names(votes, column_party, new_name_parties)
    votes.to_csv(votes_file, index=False)
