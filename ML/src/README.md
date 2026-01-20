# Predicción del Movimiento de Precios de Criptomonedas con Machine Learning

## Descripción del Proyecto

Este proyecto tiene como objetivo analizar datos históricos de criptomonedas y desarrollar modelos de machine learning capaces de predecir si el precio de una criptomoneda subirá o bajará.  
Se trata de un problema de clasificación aplicado a series temporales financieras.

---

## Contenido

El proyecto incluye:

- Un notebook con todo el flujo de trabajo del análisis  
- Carga, limpieza y preprocesamiento de datos  
- Análisis exploratorio y estadístico  
- Entrenamiento y evaluación de distintos modelos de clasificación  
- Optimización de hiperparámetros  
- Guardado del modelo final entrenado  

---

## Datos

El conjunto de datos contiene precios históricos de distintas criptomonedas correspondientes a un periodo de 365 días.  
Incluye variables numéricas y categóricas, así como información temporal.

---

## Preprocesamiento

Antes del modelado se realizan las siguientes tareas:

- Tratamiento de variables temporales  
- Codificación de variables categóricas  
- Escalado de variables numéricas  
- Creación de la variable objetivo  
- Análisis de multicolinealidad mediante VIF  

---

## Modelos Utilizados

Se entrenan y comparan varios modelos de clasificación:

- Regresión Logística  
- Random Forest Classifier  
- XGBoost Classifier  

Los modelos se integran en pipelines para asegurar un flujo correcto de preprocesado y entrenamiento.

---

## Validación y Evaluación

Debido a la naturaleza temporal de los datos, se utiliza validación cruzada con TimeSeriesSplit.

Los modelos se evalúan utilizando métricas como:

- Classification report  
- ROC AUC  
- Matriz de confusión  

---

## Optimización

Se emplea Optuna para la búsqueda y optimización de hiperparámetros, especialmente en el modelo XGBoost, con el objetivo de mejorar el rendimiento predictivo.

---

## Resultados

Los modelos basados en árboles muestran un mejor rendimiento que los modelos lineales.  
La correcta gestión de la variable temporal resulta clave para obtener buenos resultados en la predicción.

---

## Guardado del Modelo

El mejor modelo entrenado se guarda utilizando joblib, permitiendo su reutilización sin necesidad de reentrenamiento.

---

## Conclusiones

Este proyecto demuestra la viabilidad de aplicar técnicas de machine learning para la predicción del movimiento del precio de criptomonedas.  
No obstante, los resultados deben interpretarse con cautela debido a la alta volatilidad de los mercados financieros.

---

## Posibles Mejoras

- Incluir indicadores técnicos adicionales  
- Incorporar variables externas como volumen o sentimiento de mercado  
- Probar modelos de deep learning orientados a series temporales  
- Ampliar el horizonte temporal de los datos  
