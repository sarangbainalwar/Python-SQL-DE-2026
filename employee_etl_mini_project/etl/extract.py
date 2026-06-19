import pandas as pd
from database.connection import engine

def extract_data():
    query="""
    select * from employees_mini_pj;    """

    df=pd.read_sql(query,engine)
    print("data extracted successfully")
    return df