#include"backgammon.h"

int main() {
    BiCola newGame = nuevaBi();
    BiCola Posiciones = nuevaBi();
    BiCola Bar = nuevaBi();

    Bar = formarDer(Bar, 0);
    Bar = formarIzq(0, Bar);

    int valoresIzq[] = {-5, 0, 0, 0, 3, 0, 5, 0, 0, 0, 0, -2, 0};
    int valoresDer[] = {5, 0, 0, 0, -3, 0, -5, 0, 0, 0, 0, 2, 0};
    int valoresIzq2[] = {12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    int valoresDer2[] = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24};

    for (int i = 0; i < 13; i++) newGame = formarIzq(valoresIzq[i], newGame);
    for (int i = 0; i < 13; i++) newGame = formarDer(newGame, valoresDer[i]);
    for (int i = 0; i < 13; i++) Posiciones = formarIzq(valoresIzq2[i], Posiciones);
    for (int i = 0; i < 13; i++) Posiciones = formarDer(Posiciones, valoresDer2[i]);

    ImpTablero(newGame, Posiciones, &Bar);
    int priTurn = EleccionTurnos();
    int segTurn = (priTurn == 1) ? 2 : 1;

    srand(time(NULL));
    int g = 0;
    while ((g = ganar(newGame)) == 0) {
        Turno(&newGame, priTurn, Posiciones, &Bar);
        Turno(&newGame, segTurn, Posiciones, &Bar);
    }
    printf("GANO EL JUGADOR %d",g);
    return 0;
}

