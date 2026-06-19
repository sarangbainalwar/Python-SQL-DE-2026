from utils.helpers import print_title
from etl.extract import extract_data
from etl.transform import transform_data
from etl.load import load_data

def main():
    print_title("EMPLOYEE ETL PROJECT")
    
    df = extract_data()
    
    print("\nOriginal Data\n")
    print(df)
    df=transform_data(df)
    
    print("\nCleaned Data\n")
    print(df)
    
    load_data(df)
    
if __name__ == "__main__":
    main()