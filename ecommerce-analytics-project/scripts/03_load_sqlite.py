import pandas as pd
import sqlite3
import os

# Ruta al CSV
csv_path = "/home/zhgx/Portfolio_Adrian_Paneda/ecommerce-analytics-project/data_sample/clean_data.csv"

# Comprobación básica
if not os.path.exists(csv_path):
    raise FileNotFoundError(f"No existe el archivo: {csv_path}")

# Leer datos
df = pd.read_csv(csv_path)

# Crear / conectar a la base de datos
db_path = "/home/zhgx/Portfolio_Adrian_Paneda/ecommerce-analytics-project/sql/ecommerce.db"
conn = sqlite3.connect(db_path)

# Volcar a SQLite
df.to_sql(
    name="clean_data",
    con=conn,
    if_exists="replace",
    index=False
)

print("Datos cargados correctamente en SQLite.")
print(f"Base de datos creada en: {db_path}")

conn.close()