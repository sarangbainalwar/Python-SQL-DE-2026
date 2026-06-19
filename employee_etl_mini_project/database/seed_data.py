import pandas as pd 
from database.connection import engine

employees = pd.DataFrame({
    "employee_id":[101,102,103,104,105,106],
    
    "name":[
        "rahul",
        "priya",
        "amit",
        "sneha",
        "neha",
        "arjun"
    ],
    
    "department":[
        "IT",
        "HR",
        "Finance",
        "IT",
        "HR",
        "Finance"
    ],
    
    "salary":[
        60000,
        55000,
        None,
        80000,
        52000,
        70000
    ],

    "city":[
        "Mumbai",
        "Pune",
        "Delhi",
        "Nagpur",
        None,
        "Mumbai"
    ]
})

employees.to_sql(
    "employees_mini_pj",
    engine,
    if_exists="append",
    index=False
)

print("sample data inserted")