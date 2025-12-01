🎵 ANÁLISIS EXPLORATORIO DE DATOS (EDA) – Spotify Tracks Dataset

🔹 Introducción

Este documento resume el proceso, desarrollo y conclusiones del análisis exploratorio realizado sobre un dataset musical de Spotify.
El objetivo ha sido entender las características de las canciones, detectar patrones, estudiar relaciones entre variables y localizar posibles anomalías.
El análisis se ha llevado a cabo en Jupyter Notebook usando Pandas, Matplotlib, Seaborn y Python.

🎯 Hipótesis inicial

“Seré capaz de identificar artistas, canciones y álbumes destacados; encontrar canciones extremas (más enérgicas, acústicas, largas, cortas, alegres o tristes); detectar anomalías y analizar relaciones entre variables musicales.”

🧹 Proceso de limpieza del dataset

Se eliminaron columnas irrelevantes: Unnamed: 0 y track_id.

Se hallaron solo 3 nulos, eliminados por ser insignificantes.

Se identificaron duplicados usando track_name, artists y duration_ms.
Se eliminaron con drop_duplicates(keep="first").

Los tipos de datos eran correctos y no necesitaron cambios.

La única variable con outliers significativos fue duration_ms, debido a podcasts o sesiones largas.

📊 Análisis Exploratorio

• Distribuciones univariantes
Se generaron histogramas para todas las variables numéricas.
La mayoría presentan distribuciones normales, excepto duración, con una cola muy larga.

• Boxplot general
Permitió ver claramente que duration_ms es la única variable realmente atípica.

• Variables categóricas
Se analizaron los géneros más frecuentes y las variables booleanas.

• Correlaciones y relaciones entre variables
Se creó una matriz de correlaciones y varios scatterplots.
Relaciones más relevantes (≥0.5 o ≤–0.5):

Energy ↔ Loudness: +0.76

Acousticness ↔ Energy: –0.73

Acousticness ↔ Loudness: –0.58

Danceability ↔ Valence: +0.49

Estas correlaciones son coherentes con la lógica musical.

• Identificación de extremos
Se buscaron canciones más rápidas, lentas, enérgicas, acústicas, populares, etc.

📈 Conclusiones

El dataset venía bastante limpio.

Las correlaciones encontradas son fuertes y consistentes.

Solo una variable presenta outliers importantes.

La hipótesis inicial se cumple totalmente: se han identificado patrones, extremos musicales y relaciones significativas entre características de las canciones.

🛠 Tecnologías utilizadas

Python · Pandas · NumPy · Matplotlib · Seaborn · Jupyter Notebook

📦 Estructura recomendada del proyecto

project/
│── data/
│── notebook/
│   └── EDA.ipynb
│── outputs/
│   ├── figures/
│   └── tablas/
└── README.md


📚 Posibles extensiones futuras

Modelos predictivos (popularidad, valencia, energía…).

Recomendador musical.

Análisis segmentado por géneros o artistas.

Clustering para agrupar canciones similares.

🏁 Cierre

El EDA ofrece una visión completa del dataset musical y sienta las bases para análisis avanzados o futuros proyectos de machine learning.