import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Sarang@123",
    database="practice_db"
)

print("Connected Successfully")

cursor=conn.cursor()

cursor.execute("SHOW TABLES")

for table in cursor:
    print(table)

cursor.close()
conn.close()