# Exploratory Data Analysis of Musical Data (Spotify Dataset)

## Project Description

This project consists of an **Exploratory Data Analysis (EDA)** of a musical dataset obtained from Spotify.  
The main objective is to better understand the characteristics of the songs, identify patterns, relationships between variables, and detect potential anomalies.

The analysis was performed in a Jupyter Notebook following a clear workflow of data cleaning, visualization, and final conclusions.

---

## Initial Hypothesis

After inspecting the dataset columns, I formulated the following hypothesis:

> "I will be able to identify the most popular artists, songs, and albums; find the most energetic, happy, longest and shortest songs; detect possible anomalies; and analyze whether some musical variables are related to each other."

---

## Preprocessing and Data Cleaning

- Removal of duplicate records  
- Removal of missing values  
- Data type conversion  
- Outlier detection (only significant in `duration_ms`)  

The dataset was already quite clean, with very few relevant anomalies.

---

## Exploratory Data Analysis (EDA)

The following analyses were performed:

- Histograms for each numerical variable  
- Global boxplot comparing all numerical variables  
- Categorical plots (boolean variables)  
- Correlation matrix  
- Scatter plots for the strongest and weakest correlations  

---

## Main Conclusions

### Relevant Correlations  
(Threshold > 0.5 or < -0.5 according to academic criteria)

- Energy ↔ Loudness → strong positive correlation (0.76)  
- Acousticness ↔ Energy → strong negative correlation (-0.73)  
- Acousticness ↔ Loudness → negative correlation (-0.58)  
- Danceability ↔ Valence → moderate positive correlation (0.49)  

These relationships are fully consistent with musical logic:

- Energetic songs tend to sound louder.  
- Acoustic songs are usually softer and less energetic.  

---

### Outliers

Only very significant outliers appear in `duration`, most likely due to podcasts or long audio sessions.

---

### Hypothesis Validation

All the initial objectives were successfully confirmed:

- Identification of the most popular songs and artists  
- Analysis of emotions (valence), energy, tempo, and duration  
- Detection of logical anomalies  
- In-depth study of correlations between musical features  

---

## Technologies Used

- Python  
- Pandas  
- Matplotlib  
- Seaborn  
- Jupyter Notebook  
