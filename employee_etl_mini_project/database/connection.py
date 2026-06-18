from sqlalchemy import create_engine

URL="postgresql://postgres:Sarang%40123@localhost:5432/de_company_db"

engine=create_engine(URL)

print("success")