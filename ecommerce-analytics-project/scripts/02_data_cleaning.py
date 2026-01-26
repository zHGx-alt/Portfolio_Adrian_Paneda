import pandas as pd

df = pd.read_csv("data_sample/events_tiny.csv", nrows=200_000)

# 1. Parse datetime
df["event_time"] = pd.to_datetime(df["event_time"], errors="coerce")

# 2. Drop rows with invalid datetime
df = df.dropna(subset=["event_time"])

# 3. Fix user_id
df = df.dropna(subset=["user_id"])
df["user_id"] = df["user_id"].astype("int64")

# 4. Keep only useful events
df = df[df["event_type"].isin(["view", "cart", "purchase"])]

# 5. Fill missing category_code and brand
df["category_code"] = df["category_code"].fillna("unknown")
df["brand"] = df["brand"].fillna("unknown")

# 6. Remove invalid prices
df = df[df["price"] > 0]

df.info()