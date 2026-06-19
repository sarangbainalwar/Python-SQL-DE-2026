import pandas as pd
from utils.logger import logger
from database.connection import engine

def extract_data():
    query="""
    select * from employees_mini_pj;    """

    df=pd.read_sql(query,engine)
    logger.info("data extracted successfully")
    return df