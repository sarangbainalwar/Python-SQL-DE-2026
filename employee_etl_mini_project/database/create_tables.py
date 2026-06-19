from sqlalchemy import text
from database.connection import engine
from utils.logger import logger

create_table_query = """
CREATE TABLE IF NOT EXISTS employees(

employee_id INT PRIMARY KEY,
name VARCHAR(50),
department VARCHAR(30),
salary NUMERIC,
city VARCHAR(30)

);
"""

with engine.begin() as conn:
    conn.execute(text(create_table_query))

logger.info("Employee table created successfully")