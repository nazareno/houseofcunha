# coding: utf-8
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

def df_get_duplicated(df, column):
    return list(df[[column]][df[[column]].duplicated(keep=False)].drop_duplicates()[column])


def check_added_duplicated_row(df, column, external):
    if len(df_get_duplicated(df, column)) > 0:
        duplicated_ids = ','.join(map(str, df_get_duplicated(df, column)))
        raise Exception("Duplicated in voting {}: {}".format(external, duplicated_ids))