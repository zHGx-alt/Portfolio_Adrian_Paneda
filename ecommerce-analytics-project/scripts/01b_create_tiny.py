import pandas as pd

df = pd.read_csv("/home/zhgx/Portfolio_Adrian_Paneda/ecommerce-analytics-project/data/events_sample.csv")
df_tiny = df.sample(n=100_000, random_state=42)
df_tiny.to_csv("/home/zhgx/Portfolio_Adrian_Paneda/ecommerce-analytics-project/data_sample/events_tiny.csv", index=False)