import seaborn as sns
import matplotlib.pyplot as plt

def set_dark_theme():
    """
    Activa el estilo oscuro elegante para todos los gráficos.
    """
    
    sns.set_theme(
        style="darkgrid",
        rc={
            "figure.facecolor": "#1B1F30",   # fondo figura
            "axes.facecolor": "#1B1F30",     # fondo ejes
            "axes.edgecolor": "#1B1F30",
            "savefig.facecolor": "#1B1F30",
            "grid.color": "#2B314A",         # grid suave
            "axes.labelcolor": "white",
            "xtick.color": "white",
            "ytick.color": "white",
            "text.color": "white",
            "legend.facecolor": "#1B1F30",
            "legend.edgecolor": "#1B1F30",
        }
    )

COLOR_VERDE = "#32E875"  # verde moderno