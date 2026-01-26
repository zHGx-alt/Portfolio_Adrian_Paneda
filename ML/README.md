# Predicting Cryptocurrency Price Movements with Machine Learning

## Project Overview

This project analyzes historical cryptocurrency data and develops machine learning models to predict whether a cryptocurrency’s price will go up or down.  
It is a **classification problem** applied to **financial time series**.

---

## Contents

This project includes:

- A notebook containing the full end-to-end workflow  
- Data loading, cleaning, and preprocessing  
- Exploratory and statistical analysis  
- Training and evaluation of multiple classification models  
- Hyperparameter optimization  
- Saving the final trained model  

---

## Data

The dataset contains historical prices for multiple cryptocurrencies over a period of **365 days**.  
It includes numerical and categorical variables, as well as temporal information.

---

## Preprocessing

Before modeling, the following steps are performed:

- Handling temporal features  
- Encoding categorical variables  
- Scaling numerical features  
- Creating the target variable  
- Multicollinearity analysis using VIF  

---

## Models Used

Several classification models are trained and compared:

- Logistic Regression  
- Random Forest Classifier  
- XGBoost Classifier  

The models are integrated into pipelines to ensure a consistent preprocessing and training workflow.

---

## Validation and Evaluation

Due to the temporal nature of the data, **TimeSeriesSplit cross-validation** is used.

Models are evaluated using metrics such as:

- Classification report  
- ROC AUC  
- Confusion matrix  

---

## Optimization

Optuna is used for hyperparameter tuning, especially for the XGBoost model, with the goal of improving predictive performance.

---

## Results

Tree-based models perform better than linear models.  
Proper handling of temporal information is key to achieving stronger results.

---

## Model Saving

The best trained model is saved using `joblib`, allowing reuse without retraining.

---

## Conclusions

This project demonstrates the feasibility of applying machine learning techniques to predict cryptocurrency price movements.  
However, results should be interpreted with caution due to the high volatility of financial markets.

---

## Potential Improvements

- Add additional technical indicators  
- Incorporate external variables such as volume or market sentiment  
- Try deep learning models designed for time series  
- Extend the time horizon of the dataset  