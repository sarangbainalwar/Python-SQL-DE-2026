# Employee ETL Project

A beginner-friendly ETL (Extract, Transform, Load) project built using Python, PostgreSQL, SQLAlchemy, and Pandas.

---

## Technologies Used

- Python 3.x
- PostgreSQL
- SQLAlchemy
- Pandas

---

## Project Structure

employee_etl/

```
├── data/
│   └── cleaned_employees.csv
│
├── database/
│   ├── connection.py
│   ├── create_tables.py
│   └── seed_data.py
│
├── etl/
│   ├── extract.py
│   ├── transform.py
│   └── load.py
│
├── utils/
│   └── helpers.py
│
├── config.py
├── main.py
├── requirements.txt
└── README.md
```

---

## ETL Flow

```
PostgreSQL
        │
        ▼
Extract Data
        │
        ▼
Transform Data
        │
        ▼
Load Data
        │
        ▼
PostgreSQL + CSV
```

---

## Features

- Read data from PostgreSQL
- Handle missing values
- Create new columns
- Apply business logic
- Load cleaned data back into PostgreSQL
- Export cleaned data to CSV

---

## Database

Database Name

```
de_company_db
```

Source Table

```
employees
```

Target Table

```
employees_cleaned
```

---

## Setup

Install dependencies

```bash
pip install -r requirements.txt
```

Create database

```
de_company_db
```

Run

```bash
python database/create_tables.py
```

Insert sample data

```bash
python database/seed_data.py
```

Execute ETL

```bash
python main.py
```

---

## Learning Objectives

This project demonstrates:

- Modular Python Programming
- SQLAlchemy
- PostgreSQL Integration
- Pandas Data Processing
- ETL Pipeline Design
- Python Packages
- Project Organization

---

## Future Improvements

- Logging
- Exception Handling
- Environment Variables
- Unit Testing
- Docker
- Airflow Integration
- Apache Spark