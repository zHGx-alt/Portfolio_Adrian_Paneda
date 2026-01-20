# https://mlcryptopres-jpehjeqv.manus.space/

import os
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

st.set_page_config(layout="wide")

if "page" not in st.session_state:
    st.session_state.page = 0

def next_page():
    st.session_state.page += 1

def prev_page():
    st.session_state.page -= 1


# ----------------------------
# Cargar y limpiar datos
# ----------------------------
@st.cache_data
def cargar_datos():
    csv_path = os.path.join(DATA_DIR, "crypto_historical_365days.csv")
    df = pd.read_csv(csv_path)

    df = df.dropna()

    # Ajusta aquí si luego cambias tu feature set
    df = df.drop(
        columns=[
            "coin_id",
            "symbol",
            "timestamp",
            "month",
            "cumulative_return",
        ],
        errors="ignore",
    )

    df["date"] = pd.to_datetime(df["date"])
    df = df.set_index("date").sort_index()

    # Target: retorno diario > 0 (1) / <= 0 (0)
    df["target"] = (df["daily_return"] > 0).astype(int)

    # Evitar duplicados (coin_name, date)
    df = (
        df.reset_index()
        .drop_duplicates(subset=["coin_name", "date"])
        .set_index("date")
        .sort_index()
    )

    return df


df = cargar_datos()


# ----------------------------
# Slide 0 - Intro + Contexto
# ----------------------------
if st.session_state.page == 0:
    st.title("📊 Predicción de movimientos diarios en criptomonedas con ML y Streamlit")
    st.write("Proyecto de Machine Learning aplicado a series temporales financieras.")
    st.image("https://cryptologos.cc/logos/bitcoin-btc-logo.png", width=90)

    st.markdown("---")

    colA, colB = st.columns([1.2, 1])

    with colA:
        st.subheader("🎯 Objetivo del proyecto")
        st.markdown(
            """
- **Clasificación binaria:** ¿el retorno diario será **positivo** o **negativo**?
- No buscamos predecir el **precio exacto**, sino la **dirección** (sube/baja).
- Presentación del flujo completo (datos → EDA → modelos → resultados) en **Streamlit**.
            """
        )

    with colB:
        st.subheader("🧭 Estructura")
        st.markdown(
            """
1. Problema y criterio (ML sí/no)
2. Datos y preparación
3. EDA (qué aprendemos)
4. Modelos + overfitting
5. Resultados + impacto
6. Limitaciones + próximos pasos
            """
        )

    st.button("Siguiente ▶", on_click=next_page)


# ----------------------------
# Slide 1 - Datos + Problema + ¿Tiene sentido ML? + Limpieza
# (Aquí hacemos coexistir “Slide 2” y “Slide 3” conceptuales)
# ----------------------------
elif st.session_state.page == 1:
    st.header("📂 Datos, problema y preparación")

    col1, col2 = st.columns([1.2, 1])

    with col1:
        st.subheader("❓ ¿Qué problema intentamos resolver?")
        st.markdown(
            """
- Los mercados cripto son **volátiles** y difíciles de interpretar día a día.
- Queremos anticipar la **dirección del retorno diario**.
- El objetivo es **tendencia (sube/baja)**, no precios exactos.
            """
        )

        st.subheader("🤔 ¿Tiene sentido usar Machine Learning aquí?")
        st.markdown(
            """
- Hay **datos históricos** y un **target definido** (supervisado).
- Puede haber relaciones **no lineales** (retorno, volatilidad, etc.).
- Riesgo clave en series temporales: **overfitting** y **data leakage**.
            """
        )

    with col2:
        st.subheader("📌 Dataset y target")
        st.markdown(
            """
- Dataset con históricos diarios de criptomonedas (Kaggle).
- Variables numéricas (retornos, volatilidad, métricas temporales).
- **Target:** `daily_return > 0` → 1, si no → 0.
- Split temporal: **sin shuffle** (respetamos el orden).
            """
        )

    st.markdown("---")
    st.subheader("🧼 Limpieza y feature engineering (vista rápida)")
    st.dataframe(df.head(), use_container_width=True)
    st.caption(f"Shape final: {df.shape}")

    st.markdown(
        """
**Qué se hace aquí (resumen):**
- Eliminación de columnas no informativas  
- Tratamiento de nulos  
- Conversión de fechas e indexado temporal  
- Construcción explícita del target  
        """
    )

    colL, colR = st.columns(2)
    with colL:
        st.button("◀ Anterior", on_click=prev_page)
    with colR:
        st.button("Siguiente ▶", on_click=next_page)


# ----------------------------
# Slide 2 - EDA + Visualización
# ----------------------------
elif st.session_state.page == 2:
    st.header("📈 EDA y visualización — Qué aprendemos antes de modelar")

    st.markdown(
        """
Antes de entrenar modelos, buscamos **estructura** en los datos:
- ¿Qué variables se relacionan entre sí?
- ¿Aparece alguna señal (aunque sea débil) que justifique el ML?
- ¿Cómo es la distribución del target (sube/baja)?
        """
    )

    with st.expander("1) Matriz de correlación"):
        fig, ax = plt.subplots(figsize=(10, 8))
        sns.heatmap(
            df.select_dtypes("number").corr(),
            cmap="coolwarm",
            center=0,
            annot=True,
            ax=ax,
        )
        st.pyplot(fig)

    with st.expander("2) Volatilidad vs Target (boxplot)"):
        fig, ax = plt.subplots(figsize=(6, 4))
        sns.boxplot(data=df, x="target", y="volatility_7d", ax=ax)
        ax.set_title("Volatilidad (7d) vs Target")
        st.pyplot(fig)

    with st.expander("3) Distribución del Target y Daily Return"):
        fig, ax = plt.subplots()
        df["target"].value_counts(normalize=True).plot(kind="bar", ax=ax)
        ax.set_title("Distribución del Target")
        st.pyplot(fig)

        fig, ax = plt.subplots()
        df[df["target"] == 1]["daily_return"].hist(alpha=0.6, label="Sube", ax=ax)
        df[df["target"] == 0]["daily_return"].hist(alpha=0.6, label="Baja", ax=ax)
        ax.legend()
        ax.set_title("Distribución Daily Return por Target")
        st.pyplot(fig)

    with st.expander("4) Evolución temporal del Target (media móvil 30 días)"):
        fig, ax = plt.subplots()
        df.groupby(df.index)["target"].mean().rolling(30).mean().plot(ax=ax)
        ax.set_title("Media móvil del Target (30 días)")
        st.pyplot(fig)

    with st.expander("5) Daily Return vs Volatility (scatter)"):
        fig, ax = plt.subplots(figsize=(6, 4))
        sns.scatterplot(
            data=df.sample(3000, random_state=42),
            x="volatility_7d",
            y="daily_return",
            hue="target",
            alpha=0.6,
            ax=ax,
        )
        ax.set_title("Daily Return vs Volatilidad (7d)")
        st.pyplot(fig)

    st.info(
        "Idea clave: aquí NO buscamos 'confirmar' que se puede predecir perfectamente, "
        "sino entender patrones y riesgos antes del modelado."
    )

    col1, col2 = st.columns(2)
    with col1:
        st.button("◀ Anterior", on_click=prev_page)
    with col2:
        st.button("Siguiente ▶", on_click=next_page)


# ----------------------------
# Slide 3 - Modelos + Overfitting + Resultados + Lectura
# ----------------------------
elif st.session_state.page == 3:
    import numpy as np
    import json
    from sklearn.metrics import ConfusionMatrixDisplay, classification_report, roc_auc_score
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split

    st.header("🤖 Modelos, overfitting y resultados")

    st.markdown(
        """
**Modelos probados (y por qué):**
- **Regresión Logística** → baseline simple y estable  
- **Random Forest** → capta relaciones no lineales  
- **XGBoost** → modelo potente, pero propenso a sobreajustar si no se controla  
**Métrica principal:** ROC AUC (más informativa que accuracy cuando hay ruido/umbral).
        """
    )

    st.caption("Baseline entrenado en vivo (rápido) · RF/XGB entrenados offline (solo resultados)")

    # Split temporal sin shuffle
    X = df.drop(columns=["target", "coin_name"], errors="ignore")
    y = df["target"]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)

    # Resultados offline (RF + XGB)
    rf_cm = np.load(os.path.join(DATA_DIR, "rf_confusion.npy"))
    xgb_cm = np.load(os.path.join(DATA_DIR, "xgb_confusion.npy"))
    with open(os.path.join(DATA_DIR, "metrics.json")) as f:
        metrics = json.load(f)

    tabs = st.tabs(["Baseline (LogReg)", "Random Forest (offline)", "XGBoost (offline)"])

    with tabs[0]:
        st.subheader("Baseline: Logistic Regression")
        baseline = LogisticRegression(max_iter=1000)
        baseline.fit(X_train, y_train)

        y_pred = baseline.predict(X_test)
        y_prob = baseline.predict_proba(X_test)[:, 1]

        st.text(classification_report(y_test, y_pred))
        st.write("ROC AUC:", roc_auc_score(y_test, y_prob))

        fig, ax = plt.subplots()
        ConfusionMatrixDisplay.from_predictions(
            y_test, y_pred, display_labels=[0, 1], ax=ax, values_format="d"
        )
        st.pyplot(fig)

        st.markdown(
            """
**Lectura correcta:** baseline = referencia.  
Si un modelo complejo “parece” muy bueno, pero no generaliza, suele ser **overfitting**.
            """
        )

    with tabs[1]:
        st.subheader("Random Forest Optimizado (Resultados finales)")
        st.write("Accuracy:", metrics["rf"]["accuracy"])
        st.write("ROC AUC:", metrics["rf"]["roc_auc"])
        st.write("F1-score:", metrics["rf"]["f1"])

        fig, ax = plt.subplots()
        ConfusionMatrixDisplay(rf_cm, display_labels=[0, 1]).plot(ax=ax, values_format="d")
        st.pyplot(fig)

        st.warning(
            "En series temporales financieras, es común que modelos potentes "
            "aprendan demasiado bien el training y pierdan generalización."
        )

    with tabs[2]:
        st.subheader("XGBoost (Optuna) (Resultados finales)")
        st.write("Accuracy:", metrics["xgb"]["accuracy"])
        st.write("ROC AUC:", metrics["xgb"]["roc_auc"])
        st.write("F1-score:", metrics["xgb"]["f1"])

        fig, ax = plt.subplots()
        ConfusionMatrixDisplay(xgb_cm, display_labels=[0, 1]).plot(ax=ax, values_format="d")
        st.pyplot(fig)

        st.warning(
            "Decisión técnica clave: limitar complejidad / regularizar / validar con rolling, "
            "porque el riesgo real aquí es el **overfitting**."
        )

    st.markdown("---")
    st.subheader("💡 Impacto: ¿para qué sirve esto?")
    st.markdown(
        """
- Generar **señales de tendencia diaria** como apoyo (no “oráculo”).
- Ayudar a priorizar análisis: **filtro previo** para decisiones humanas.
- Base para sistemas más complejos (validación rolling, features extra, datos en tiempo real).
        """
    )

    col1, col2 = st.columns(2)
    with col1:
        st.button("◀ Anterior", on_click=prev_page)
    with col2:
        st.button("Siguiente ▶", on_click=next_page)


# ----------------------------
# Slide 4 - Limitaciones + Next steps + Cierre
# ----------------------------
elif st.session_state.page == 4:
    st.header("✅ Conclusiones, limitaciones y próximos pasos")

    colA, colB = st.columns(2)

    with colA:
        st.subheader("✅ Conclusión")
        st.markdown(
            """
- Problema **realista**: dirección del retorno diario (sube/baja).
- Flujo completo: datos → EDA → modelos → resultados.
- Enfoque con criterio: **no** perseguimos “el mejor score” sin entenderlo.
- Streamlit aporta **orden, demo y reproducibilidad**.
            """
        )

    with colB:
        st.subheader("🚧 Limitaciones y futuro")
        st.markdown(
            """
- Overfitting en modelos complejos (especialmente en finanzas).
- No hay datos en tiempo real.
- Falta **validación rolling / walk-forward**.
- Próximos pasos: regularización, tuning con cuidado, más features, evaluación temporal estricta.
            """
        )

    st.success("Fin de la presentación.")
    st.button("◀ Anterior", on_click=prev_page)