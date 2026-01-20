# https://mlcryptopres-jpehjeqv.manus.space/

import os
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import json
from sklearn.metrics import ConfusionMatrixDisplay, classification_report, roc_auc_score
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
import joblib

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
    st.image("https://cryptologos.cc/logos/bitcoin-btc-logo.png", width=90)

    st.markdown("---")

    colA, colB = st.columns([1.2, 1])

    with colA:
        st.subheader("🎯 Objetivo")
        st.header("¿Sube o baja mañana?")

        st.markdown("")  # espacio

        st.subheader("🧭 Estructura")
        st.markdown(
            """
            <div style="display:flex; flex-wrap:wrap; gap:14px; align-items:center; margin-top:10px;">
              
              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                Problema
              </span>

              <span style="font-size:26px; opacity:0.9;">➜</span>

              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                Limpieza
              </span>

              <span style="font-size:26px; opacity:0.9;">➜</span>

              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                EDA
              </span>

              <span style="font-size:26px; opacity:0.9;">➜</span>

              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                Features
              </span>

              <span style="font-size:26px; opacity:0.9;">➜</span>

              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                Modelos
              </span>

              <span style="font-size:26px; opacity:0.9;">➜</span>

              <span style="padding:12px 18px; border-radius:999px;
                           background:rgba(255,255,255,0.10);
                           font-size:20px; font-weight:600;">
                Conclusión
              </span>

            </div>
            """,
            unsafe_allow_html=True
        )

    st.markdown("")  # espacio
    st.button("Siguiente ▶", on_click=next_page)

    with colB:

        st.markdown("")
        st.markdown(
            """
            <div style="
                width:100%;
                height:320px;
                overflow:hidden;
                border-radius:16px;
                box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            ">
                <img src="https://images.unsplash.com/photo-1621761191319-c6fb62004040?auto=format&fit=crop&w=1400&q=80"
                     style="width:100%; height:100%; object-fit:cover;">
            </div>
            """,
            unsafe_allow_html=True
        )

# ----------------------------
# Slide 1 - Datos y preparación (ARREGLADO)
# ----------------------------
elif st.session_state.page == 1:
    try:
        st.header("📂 Datos y preparación")

        def card(title, content):
            st.markdown(
                f"""
                <div style="
                    background: rgba(255,255,255,0.06);
                    border-radius:16px;
                    padding:22px;
                    height:140px;
                ">
                    <div style="font-size:22px; font-weight:600; margin-bottom:10px;">
                        {title}
                    </div>
                    <div style="font-size:20px; opacity:0.9;">
                        {content}
                    </div>
                </div>
                """,
                unsafe_allow_html=True
            )

        col1, col2, col3 = st.columns(3)
        with col1:
            card("❓ Problema", "Mercado volátil")
        with col2:
            card("🎯 Objetivo", "Predecir sube / baja")
        with col3:
            card("⏱️ Validación", "Split temporal")

        st.markdown("")

        col4, col5 = st.columns(2)
        with col4:
            card("📌 Dataset", "Históricos diarios")
        with col5:
            card("🎯 Target", "daily_return > 0")

        st.markdown("---")

        # BLOQUE INFERIOR
        st.header("🧼 Vista rápida")
        st.dataframe(df.head(), use_container_width=True)
        st.caption(f"Shape final: {df.shape}")

        colL, colR = st.columns(2)
        with colL:
            st.button("◀ Anterior", on_click=prev_page)
        with colR:
            st.button("Siguiente ▶", on_click=next_page)
    except Exception as e:
        st.error(f"Error en Slide 1: {e}")
        st.button("◀ Anterior", on_click=prev_page)

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

    with st.expander("4) Evolución temporal del Target" ):
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
# Slide X - Comparativa ROC AUC por modelo y cripto
# ----------------------------
elif st.session_state.page == 3:
    try:
        st.header("📊 Comparativa de modelos (ROC AUC)")

        # Ruta del JSON
        json_path = "/home/zhgx/Curso/3-Machine_Learning/ML_project/src/presentacion/data/modelos.json"

        # Cargar datos
        with open(json_path, "r") as f:
            data = json.load(f)

        # Convertir a DataFrame (modelos = filas, criptos = columnas)
        df_models = pd.DataFrame(data).T

        # Mostrar tabla
        st.dataframe(
            df_models,
            use_container_width=True
        )


        col1, col2 = st.columns(2)
        with col1:
            st.button("◀ Anterior", on_click=prev_page)
        with col2:
            st.button("Siguiente ▶", on_click=next_page)

    except Exception as e:
        st.error(f"Error en la diapositiva de modelos: {e}")
        st.button("◀ Anterior", on_click=prev_page)


# ----------------------------
# Slide 4 - Limitaciones + Next steps + Cierre
# ----------------------------
elif st.session_state.page == 4:
    try:
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
    except Exception as e:
        st.error(f"Error en Slide 4: {e}")
        st.button("◀ Anterior", on_click=prev_page)