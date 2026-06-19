# ==============================
# PostgreSQL Database Configuration
# ==============================

DB_USERNAME = "postgres"
DB_PASSWORD = "your_password"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "de_company_db"

DATABASE_URL = (
    f"postgresql://{DB_USERNAME}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ==============================
# Table Names
# ==============================

SOURCE_TABLE = "employees"
TARGET_TABLE = "employees_cleaned"

# ==============================
# File Paths
# ==============================

OUTPUT_CSV = "data/cleaned_employees.csv"