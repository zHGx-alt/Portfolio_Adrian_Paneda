# Análisis Exploratorio de Datos Musicales (Spotify Dataset)

## Descripción del proyecto

Este proyecto consiste en un análisis exploratorio (EDA) de un dataset musical.  
El objetivo es comprender mejor las características de las canciones, identificar patrones, relaciones entre variables y detectar posibles anomalías.

El análisis se ha realizado en un Jupyter Notebook siguiendo un flujo claro de limpieza, visualización y conclusiones.

---

## Hipótesis inicial

Al observar las columnas del dataset, planteé la siguiente hipótesis:

> "Seré capaz de identificar los artistas, canciones y álbumes más populares; encontrar las canciones más enérgicas, alegres, largas y cortas; ver posibles anomalías y analizar si algunas variables musicales están relacionadas entre sí."

---

## Preprocesado y limpieza

- Eliminación de duplicados  
- Eliminación de valores nulos  
- Conversión de tipos  
- Detección de outliers (solo significativos en `duration_ms`)  

El dataset venía bastante limpio, con pocas anomalías relevantes.

---

## Análisis Exploratorio (EDA)

Se realizaron:

- Histogramas por cada variable numérica  
- Boxplot general comparando todas las variables numéricas  
- Gráficos categóricos (variables booleanas)  
- Matriz de correlación  
- Scatterplots de las correlaciones más fuertes y más débiles  

---

## Principales conclusiones

### Correlaciones relevantes  
(> 0.5 o < -0.5 según criterio docente)

- Energy ↔ Loudness → correlación fuerte positiva (0.76)  
- Acousticness ↔ Energy → correlación fuerte negativa (-0.73)  
- Acousticness ↔ Loudness → correlación negativa (-0.58)  
- Danceability ↔ Valence → correlación positiva moderada (0.49)  

Estas relaciones encajan perfectamente con la lógica musical:

- Canciones energéticas tienden a sonar más fuerte.  
- Canciones acústicas suelen ser más suaves y menos energéticas.  

---

### Outliers

Solo aparecen outliers muy significativos en `duration`, probablemente debidos a podcasts o sesiones largas.

---

### Cumplimiento de la hipótesis

He podido confirmar todos mis objetivos iniciales:

- Identificación de canciones y artistas más populares  
- Análisis de emociones (valence), energía, tempo y duración  
- Detección de anomalías lógicas  
- Estudio profundo de correlaciones entre características musicales  

---

## Tecnologías utilizadas

- Python  
- Pandas  
- Matplotlib  
- Seaborn  
- Jupyter Notebook  