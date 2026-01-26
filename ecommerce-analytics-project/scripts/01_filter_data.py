import pandas as pd

# Paths (relativos a la raíz del proyecto)
input_file = "data/2019-Oct.csv"
output_file = "data/events_sample.csv"

chunks = pd.read_csv(
    input_file,
    parse_dates=["event_time"],
    chunksize=1_000_000
)

filtered_chunks = []

for i, chunk in enumerate(chunks, 1):
    print(f"Processing chunk {i}...")

    mask = (
        (chunk["event_time"] >= "2019-10-01") &
        (chunk["event_time"] <  "2019-10-04")
    )

    filtered = chunk[mask]
    filtered_chunks.append(filtered)

df_sample = pd.concat(filtered_chunks)

print("Final sample shape:", df_sample.shape)

df_sample.to_csv(output_file, index=False)

print(f"Saved reduced file to {output_file}")