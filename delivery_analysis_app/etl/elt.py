import pandas as pd 
from pathlib import Path

BASE_DIR = Path.cwd().parent
CSV_DIR = BASE_DIR / "csv"

deliveries = pd.read_csv(CSV_DIR / "deliveries.csv")
orders = pd.read_csv(CSV_DIR / "orders.csv")
restaurants = pd.read_csv(CSV_DIR / "restaurants.csv")
riders = pd.read_csv(CSV_DIR / "riders.csv")
order_events = pd.read_csv(CSV_DIR / "order_events.csv")

date_cols = [
    "assigned_at",
    "picked_up_at",
    "delivered_at"
]

for col in date_cols:
    deliveries[col] = pd.to_datetime(deliveries[col])

deliveries["hour"] = deliveries["assigned_at"].dt.hour
deliveries["day"] = deliveries["assigned_at"].dt.day_name()
deliveries["month"] = deliveries["assigned_at"].dt.month

deliveries["prep_minutes"] = (
    deliveries["picked_up_at"] - deliveries["assigned_at"]
).dt.total_seconds() / 60

deliveries["delivery_minutes"] = (
    deliveries["delivered_at"] - deliveries["picked_up_at"]
).dt.total_seconds() / 60

deliveries["total_minutes"] = (
    deliveries["delivered_at"] - deliveries["assigned_at"]
).dt.total_seconds() / 60

order_date = ['event_timestamp']
for col in order_date:
    order_events[col] = pd.to_datetime(order_events[col])

orders_date = ['created_at']
for col in orders_date:
    orders[col] = pd.to_datetime(orders[col])


# ---- Guardar CSV limpios ----

CLEAN_DIR = BASE_DIR / "clean_csv"
CLEAN_DIR.mkdir(exist_ok=True)

deliveries.to_csv(CLEAN_DIR / "deliveries_clean.csv", index=False)
orders.to_csv(CLEAN_DIR / "orders_clean.csv", index=False)
restaurants.to_csv(CLEAN_DIR / "restaurants_clean.csv", index=False)
riders.to_csv(CLEAN_DIR / "riders_clean.csv", index=False)
order_events.to_csv(CLEAN_DIR / "order_events_clean.csv", index=False)