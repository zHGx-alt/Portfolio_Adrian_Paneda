# Exploratory Data Analysis (EDA) — Spotify Tracks Dataset

## Introduction

This document summarizes the process, development, and conclusions of an Exploratory Data Analysis performed on a musical dataset from Spotify.

The main objective of this analysis is to understand the characteristics of the songs, detect patterns, study relationships between variables, and identify potential anomalies.

The analysis was conducted in a Jupyter Notebook using Python, Pandas, Matplotlib, and Seaborn.

---

## Initial Hypothesis

"I will be able to identify relevant artists, songs, and albums; find extreme songs (most energetic, acoustic, long, short, happy, or sad); detect anomalies; and analyze relationships between musical variables."

---

## Data Cleaning Process

The following preprocessing steps were performed:

- Removal of irrelevant columns: `Unnamed: 0` and `track_id`.
- Only 3 missing values were found and removed, as they were negligible.
- Duplicates were identified using `track_name`, `artists`, and `duration_ms` and removed using `drop_duplicates(keep="first")`.
- Data types were already correct and did not require conversion.
- The only variable with significant outliers was `duration_ms`, mainly due to podcasts or long audio sessions.

---

## Exploratory Data Analysis

### Univariate Distributions

Histograms were generated for all numerical variables.  
Most of them show approximately normal distributions, except for `duration_ms`, which presents a long right tail.

### Global Boxplot

A global boxplot clearly shows that `duration_ms` is the only variable with strong outlier behavior.

### Categorical Variables

The most frequent genres and boolean variables were analyzed.

### Correlations and Relationships Between Variables

A correlation matrix and several scatter plots were created.  
The most relevant relationships (≥ 0.5 or ≤ –0.5) are:

- Energy ↔ Loudness: +0.76  
- Acousticness ↔ Energy: –0.73  
- Acousticness ↔ Loudness: –0.58  
- Danceability ↔ Valence: +0.49  

These correlations are fully consistent with musical logic.

### Identification of Extreme Values

The analysis identified the fastest, slowest, most energetic, most acoustic, and most popular songs in the dataset.

---

## Conclusions

- The dataset was already relatively clean.
- The detected correlations are strong and consistent.
- Only one variable presents significant outliers.
- The initial hypothesis is fully confirmed: clear patterns, musical extremes, and meaningful relationships between features were identified.

---

## Technologies Used

- Python  
- Pandas  
- NumPy  
- Matplotlib  
- Seaborn  
- Jupyter Notebook  

---

## Recommended Project Structure

```text
project/
│── data/
│── notebook/
│   └── EDA.ipynb
│── outputs/
│   ├── figures/
│   └── tables/
└── README.md