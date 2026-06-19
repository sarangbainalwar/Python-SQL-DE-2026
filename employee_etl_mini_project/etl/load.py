from database.connection import engine

def load_data(df):
    df.to_sql(
        "employees_cleaned",
        engine,
        if_exists="replace",
        index=False
    )
    
    df.to_csv(
        "data/cleaned_employees.csv",
        index=False
    )
    print("Data exported into CSV")
    
    print("Cleaned data loaded into postgresql")