import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path

# =========================
# BASE PATH
# =========================
BASE_DIR = Path(__file__).resolve().parent.parent
CLEAN_DIR = BASE_DIR / "clean_csv"

# =========================
# DB CONNECTION
# =========================
engine = create_engine("postgresql+psycopg2://postgres:74627620adri@localhost:5432/postgres")

# =========================
# LOAD CSV (CLEAN)
# =========================
restaurants = pd.read_csv(CLEAN_DIR / "restaurants_clean.csv")
riders = pd.read_csv(CLEAN_DIR / "riders_clean.csv")
orders = pd.read_csv(CLEAN_DIR / "orders_clean.csv")
deliveries = pd.read_csv(CLEAN_DIR / "deliveries_clean.csv")
order_events = pd.read_csv(CLEAN_DIR / "order_events_clean.csv")

# =========================
# INSERT INTO DB
# =========================
restaurants.to_sql("restaurants", engine, if_exists="append", index=False)
riders.to_sql("riders", engine, if_exists="append", index=False)
orders.to_sql("orders", engine, if_exists="append", index=False)
deliveries.to_sql("deliveries", engine, if_exists="append", index=False)
order_events.to_sql("order_events", engine, if_exists="append", index=False)

print("✅ Data loaded successfully")