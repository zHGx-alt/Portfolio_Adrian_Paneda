# funciones.py

import random
from variables import tablero, tablero2, disparos

def barcos_restantes1():
    return sum(row.count("B") for row in tablero)

def barcos_restantes2():
    return sum(row.count("B") for row in tablero2)

def disparar(x, y):
    try:
        if tablero[y][x] == "B":
            tablero[y][x] = "X"
            print("¡Has acertado!")
        else:
            tablero[y][x] = "O"
            print("¡Agua!")
        mostrar_tablero(tablero)  
        return tablero[y][x] == "X"
    except (ValueError, IndexError):
        print("Coordenada inválida.")
        return False

def disparar_maquina(x, y):
     try:
          if tablero2[y][x] == "B":
               tablero2[y][x] = "X"
               for fila in tablero2:
                    print(' '.join(fila))
               print("Has acertado!!")
               return True
          else:
               tablero2[y][x] = "O"
               for fila in tablero2:
                    print(' '.join(fila))
               print("Agua!!")
               return False 
     except (ValueError, IndexError): # Value para cosas que no sean numeros  
          print("Coordenada no valida, prueba de nuevo") # Index para coordenadas fuera del tablero
          return False


def player1():
    try:
        x = input("Introduce x (0-9) o 'salir' para terminar: ")
        if x.lower() == "salir":
            print("Has salido del juego.")
            exit()  

        x = int(x)
        y = int(input("Introduce y (0-9): "))
        return disparar(x, y)
    except ValueError:
        print("Introduce números válidos.")
        return False

def machine():
    x = random.randint(0, 9)
    y = random.randint(0, 9)

    while [x, y] in disparos:
        x = random.randint(0, 9)
        y = random.randint(0, 9)

    resultado = disparar_maquina(x, y)
    disparos.append([x, y])

    if not resultado:
        print("La máquina ha fallado.")

    return resultado

def mostrar_tablero(tab):
    for fila in tab:
        print(" ".join(fila))
    print()


def V_H():
    orientacion = random.randint(0,1)
    if orientacion == 0:
        orientacion = "V"
    else:
        orientacion = "H"
    return orientacion

def poner_barcos_largo(longitud):
    colocado = False                              # valor por defecto, para comprobar si ha colocado barco o no
    while not colocado:
        x, y = random.randint(0,9), random.randint(0,9)  # escoge coordenadas y orientacion 
        orientacion = V_H()  

        if orientacion == "V" and y + longitud <= 10:     # mira si es V o H y si cabe dentro del tablero
            libre = True
            for i in range(longitud):               # por defecto true, para comprobar si esta libre la casilla 
                if tablero[y + i][x] == "B":        # si no esta libre hace break 
                    libre = False                   # vuelve arriba hasta que colocado sea true  
                    break
            if libre:
                for i in range(longitud):           # si pasa del for pone una "B" y pasa a true
                    tablero[y + i][x] = "B"
                colocado = True

        elif orientacion == "H" and x + longitud <= 10:
            libre = True
            for i in range(longitud):
                if tablero[y][x + i] == "B":
                    libre = False
                    break
            if libre:
                for i in range(longitud):
                    tablero[y][x + i] = "B"
                colocado = True
    return tablero


def poner_barcos_largo_machine(longitud):
    colocado = False
    while not colocado:
        x, y = random.randint(0,9), random.randint(0,9)
        orientacion = V_H()

        if orientacion == "V" and y + longitud <= 10:
            libre = True
            for i in range(longitud):
                if tablero2[y + i][x] == "B":
                    libre = False
                    break
            if libre:
                for i in range(longitud):
                    tablero2[y + i][x] = "B"
                colocado = True

        elif orientacion == "H" and x + longitud <= 10:
            libre = True
            for i in range(longitud):
                if tablero2[y][x + i] == "B":
                    libre = False
                    break
            if libre:
                for i in range(longitud):
                    tablero2[y][x + i] = "B"
                colocado = True
    return tablero2


def todos(barcos):
    for longitud in barcos:
        poner_barcos_largo(longitud)
    return tablero


def todos_machine(barcos):
    for longitud in barcos:
        poner_barcos_largo_machine(longitud)
    return tablero2