def transform_data(df):
    df["salary"]=df["salary"].fillna(
        df["salary"].mean()
    )
    
    df["city"]=df["city"].fillna("Unknown")
    
    df["bonus"] = df["salary"]*0.1
    
    def salary_band(salary):
        if salary >= 70000:
            return "High"
        
        elif salary >= 55000:
            return "medium"
        
        else:
            return "low"
        
    df["salary_band"] = df["salary"].apply(salary_band)
    
    print("transformation completed")
    
    return df