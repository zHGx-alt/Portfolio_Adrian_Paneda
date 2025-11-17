# main.py

from variables import barcos
import funciones

print("¡Comienza la batalla naval!\n")

funciones.todos(barcos)
funciones.todos_machine(barcos)

while funciones.barcos_restantes1() > 0 and funciones.barcos_restantes2() > 0:
    while funciones.player1():
        print("¡Has acertado, dispara de nuevo!\n")
    while funciones.machine():
        print("¡La máquina acierta y vuelve a disparar!\n")

print("\nFin del juego")
if funciones.barcos_restantes2() == 0:
    print("¡Ganaste! Hundiste todos los barcos enemigos.")
else:
    print("Perdiste. La máquina hundió todos tus barcos.")