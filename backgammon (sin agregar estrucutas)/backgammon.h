#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "./Elem/ElemInt.h"
#include"./BiCola/BiCola.h"

void ImpTablero(BiCola b, BiCola b2, BiCola *Bar);
void ImpBiCola(BiCola b);
int EleccionTurnos();
void Turno(BiCola *b, int jugador, BiCola b2, BiCola *Bar);
int ganar(BiCola b);
int MoverFicha(int jugador, int origen, int dado, BiCola *b, BiCola *Bar);
int PuedeMover(int jugador, int destino, BiCola b);
int PuedeMover2(int jugador, int origen, BiCola b);
int PuedeMover3(int jugador, int origen, BiCola b);
void AplicarMovimiento(int jugador, int destino, BiCola *b);
void QuitarFicha(int jugador, int origen, BiCola *b);
void ComerFichas(int jugador, int destino, BiCola *b, BiCola *Bar);
void Movimiento(int jugador, int destino, BiCola *b, BiCola *Bar);
void BarBloqueo(int jugador, int destino, BiCola *Bar);
int TieneFichasEnBar(int jugador, BiCola Bar);
int HayFichasDisponibles(int jugador,BiCola b,int dado);
void SacarFichaBar(int jugador, BiCola *b, int dado, BiCola *Bar);
Elem ObtenerElem(BiCola *b,int posicion);

Elem ObtenerElem(BiCola *b, int posicion) {
    BiCola temp = nuevaBi();
    Elem resultado;
    for (int i = 0; i <= posicion; i++) {
        Elem e = izquierdo(*b);
        temp = formarDer(temp, e);
        if (i == posicion) resultado = e;
        *b = desformarIzq(*b);
    }
    while (!esnueva(temp)) {
        Elem e = derecho(temp);
        *b = formarIzq(e, *b);
        temp = desformarDer(temp);
    }
    return resultado;
}

int ganar(BiCola b) {
    Elem n = 15;
    if (!esnueva(b)) {
        if (EsMoI(n, izquierdo(b))) return 1;
        if (EsMoI(n, derecho(b))) return 2;
    }
    return 0;
}
int HayFichasDisponibles(int jugador, BiCola b, int dado) {
    Elem val = ObtenerElem(&b, dado);
    if (jugador == 1) return val <= 1;
    if (jugador == 2) return val >= -1;
    return 0;
}
void SacarFichaBar(int jugador, BiCola *b, int dado, BiCola *Bar) {
    if (jugador == 1) {
        Elem e = izquierdo(*Bar) - 1;
        *Bar = desformarIzq(*Bar);
        *Bar = formarIzq(e, *Bar);
    } else {
        Elem e = derecho(*Bar) - 1;
        *Bar = desformarDer(*Bar);
        *Bar = formarDer(*Bar, e);
    }


    int destino = (jugador == 1) ? dado : 25 - dado;

    Movimiento(jugador, destino, b, Bar);
}

void Turno(BiCola *b, int jugador, BiCola b2,BiCola *Bar) {
    ImpTablero(*b, b2,Bar);
    printf("Jugador %d:\nPresiona Enter para tirar los dados\n", jugador);
    getchar();

    int dado1 = rand() % 6 + 1;
    int dado2 = rand() % 6 + 1;
    printf("Dado 1: %d\nDado 2: %d\n", dado1, dado2);
    

    if (TieneFichasEnBar(jugador, *Bar)) {
        printf("Tienes fichas en la base. Debes intentar sacarlas antes de mover otras.\n");

        if(HayFichasDisponibles(jugador,*b,dado1)){SacarFichaBar(jugador, b, dado1, Bar);  
            printf("Presiona Enter para continuar...\n");
            getchar();
            if(!TieneFichasEnBar(jugador, *Bar)){return;}
        }
        if(HayFichasDisponibles(jugador,*b,dado2)){SacarFichaBar(jugador, b, dado2, Bar); 
            printf("Presiona Enter para continuar...\n");
            getchar();
            if(!TieneFichasEnBar(jugador, *Bar)){return;}
        }
    }


    else{
    int o1, o2, o3, o4;

    if (dado1 == dado2) {
        printf("Dados dobles (tiras doble)\n");
        
        do {
            printf("Casilla a mover %d: ", dado1); scanf("%d", &o1);
        } while (!MoverFicha(jugador, o1, dado1, b, Bar));

        do {
            printf("Casilla a mover %d: ", dado2); scanf("%d", &o2);
        } while (!MoverFicha(jugador, o2, dado2, b, Bar));

        do {
            printf("Casilla a mover %d: ", dado1); scanf("%d", &o3);
        } while (!MoverFicha(jugador, o3, dado1, b, Bar));

        do {
            printf("Casilla a mover %d: ", dado2); scanf("%d", &o4);
        } while (!MoverFicha(jugador, o4, dado2, b, Bar));
    } else {
        do {
            printf("Casilla a mover %d: ", dado1); scanf("%d", &o1);
        } while (!MoverFicha(jugador, o1, dado1, b, Bar));

        do {
            printf("Casilla a mover %d: ", dado2); scanf("%d", &o2);
        } while (!MoverFicha(jugador, o2, dado2, b, Bar));
    }
  }
}



int MoverFicha(int jugador, int origen, int dado, BiCola *b,BiCola *Bar) {
    int destino = (jugador == 1) ? origen + dado : origen - dado;
    if (destino < 0) destino = 0;
    if (destino > 25) destino = 25;

    if (!PuedeMover(jugador, destino, *b)) {
        printf("Movimiento inválido. Casilla bloqueada o fichas del oponente.\n");
        return 0;
    }
    if (!PuedeMover2(jugador, origen, *b)) {
        char *frase = (jugador == 1)? "No hay fichas blancas en esa casilla\n"  : "No hay fichas negras en esa casilla\n";
        printf("%s",frase);
        return 0;
    }
    
    if(destino >= 25 && jugador == 1){
    if(!PuedeMover3(jugador,origen,*b)){
       printf("Aun no puedes sacar fichas de la base\n");
       return 0;
    }
   }
   if(destino <= 0 && jugador == 2){
    if(!PuedeMover3(jugador,origen,*b)){
       printf("Aun no puedes sacar fichas de la base\n");
       return 0;
    }
   }

    QuitarFicha(jugador, origen, b);
    Movimiento(jugador, destino, b,Bar);
    return 1;
    
}

int PuedeMover3(int jugador, int origen, BiCola b) {
    int limite = 18;
    int i;
    for (i = 0; i <= limite; i++) {
        Elem val = ObtenerElem(&b, i);
        if ((jugador == 1 && val < 0) || (jugador == 2 && val > 0)) {
            return 0; 
        }
    }
    return 1; 
}

int PuedeSalirDelBar(int jugador, int dado, BiCola b) {
    int destino = (jugador == 1) ? dado : 25 - dado;
    return PuedeMover(jugador, destino, b);
}
int TieneFichasEnBar(int jugador, BiCola Bar) {
    if (jugador == 1) return izquierdo(Bar) > 0;
    if (jugador == 2) return derecho(Bar) > 0;
    return 0;
}

void Movimiento(int jugador, int destino, BiCola *b,BiCola *Bar){
    BiCola temp = nuevaBi();

    for(int i = 0; i < destino; i++){
        Elem e = izquierdo(*b);
        temp = formarDer(temp,e);
        *b = desformarIzq(*b);
      }
      Elem e = izquierdo(*b);

      while(!esnueva(temp)){
        Elem e = derecho(temp);
        *b = formarIzq(e, *b);
        temp = desformarDer(temp);
       }
      if(jugador == 1 && e == 1){ComerFichas(jugador,destino,b,Bar); return;}
      if(jugador == 2 && e == -1){ComerFichas(jugador,destino,b,Bar); return;} 
      else AplicarMovimiento(jugador, destino, b);
       

}

void BarBloqueo(int jugador, int destino,BiCola *Bar){
     if(jugador == 1){Elem e = derecho(*Bar)+1; *Bar = desformarDer(*Bar); formarDer(*Bar,e); }
     if(jugador == 2){Elem e = izquierdo(*Bar)+1; *Bar = desformarIzq(*Bar); formarIzq(e,*Bar);}
}

void ComerFichas(int jugador, int destino, BiCola *b,BiCola *Bar){
   BiCola temp = nuevaBi();
   for(int i = 0; i < destino; i++){
     Elem e = izquierdo(*b);
     temp = formarDer(temp,e);
     *b = desformarIzq(*b);
   }
   Elem e = (jugador == 1) ? -1 : 1;
   *b = desformarIzq(*b);
   *b = formarIzq(e,*b);
   
   BarBloqueo(jugador,destino,Bar);

   while(!esnueva(temp)){
    Elem e = derecho(temp);
    *b = formarIzq(e, *b);
    temp = desformarDer(temp);
   }

}

int PuedeMover2(int jugador, int origen, BiCola b) {
    Elem val = ObtenerElem(&b, origen);
    return (jugador == 1) ? (val < 0) : (val > 0);
}

int PuedeMover(int jugador, int destino, BiCola b) {
    Elem val = ObtenerElem(&b, destino);

    if (jugador == 1) {
        return (val <= 0 || val == 1);
    } else {
        return (val >= 0 || val == -1);
    }
}


void AplicarMovimiento(int jugador, int destino, BiCola *b) {
    Elem val = ObtenerElem(b, destino);
    val += (jugador == 1) ? -1 : 1;

    BiCola temp = nuevaBi();
    for (int i = 0; i < destino; i++) {
        temp = formarDer(temp, izquierdo(*b));
        *b = desformarIzq(*b);
    }
    *b = desformarIzq(*b); 
    *b = formarIzq(val, *b); 

    while (!esnueva(temp)) {
        Elem e = derecho(temp);
        *b = formarIzq(e, *b);
        temp = desformarDer(temp);
    }
}


void QuitarFicha(int jugador, int origen, BiCola *b) {
    Elem val = ObtenerElem(b, origen);
    val += (jugador == 1) ? 1 : -1;

    BiCola temp = nuevaBi();
    for (int i = 0; i < origen; i++) {
        temp = formarDer(temp, izquierdo(*b));
        *b = desformarIzq(*b);
    }
    *b = desformarIzq(*b); 
    *b = formarIzq(val, *b); 

    while (!esnueva(temp)) {
        Elem e = derecho(temp);
        *b = formarIzq(e, *b);
        temp = desformarDer(temp);
    }
}


int EleccionTurnos() {
    int suma1 = 0, suma2 = 0;
    do {
        printf("Jugador 1 (blancas): presiona enter para tirar dados\n"); getchar();
        suma1 = rand() % 6 + 1 + rand() % 6 + 1;
        printf("Suma: %d\n", suma1);
        printf("Jugador 2 (negras): presiona enter para tirar dados\n"); getchar();
        suma2 = rand() % 6 + 1 + rand() % 6 + 1;
        printf("Suma: %d\n", suma2);
        if (suma1 == suma2) printf("Empate. Vuelvan a tirar.\n");
    } while (suma1 == suma2);
    return suma1 > suma2 ? 1 : 2;
}

void ImpBiCola(BiCola b) {
    BiCola temp = nuevaBi();
    while (!esnueva(b)) {
        Elem e = izquierdo(b);
        temp = formarDer(temp,e);
        ImpElem(e);
        b = desformarIzq(b);
    }
    while (!esnueva(temp)) {
        b = formarDer(b,izquierdo(temp));
        temp = desformarIzq(temp);
    }
    printf("\n");
}
void ImpTablero(BiCola b,BiCola b2,BiCola *Bar){
    if(!esnueva(b)){
        int vals[13], vals2[13], vals3[13], vals4[13];
        puts("\n-----------------------------------BACKGAMOO-----------------------------------\n");
        for(int i = 0; i < 13; i++){
            Elem e = izquierdo(b2);
            vals3[i] = e;
            b2 = desformarIzq(b2);
        }
        for(int i= 12; i >=1; i--){
            printf("%3d    ", abs(vals3[i]));
        }
        for(int i= 12; i >=0; i--){
            b2 = formarIzq(vals3[i],b2);
        }
        puts("\n----------------------------------------------------------------------------------");
        for(int i = 0; i < 13; i++){
            Elem e = izquierdo(b);
            vals[i] = e;
            b = desformarIzq(b);
        }
        for(int i= 12; i >=0; i--){
            b = formarIzq(vals[i],b);
        }
        for(int i= 12; i >=1; i--){
            if(vals[i]>0){printf("%3dN   ",vals[i]);}
            else if(vals[i]==0){printf("%3d    ",vals[i]);}
            else{printf("%3dB   ",-vals[i]);}
        }
        printf("     Jugador 2: %d",izquierdo(b));
        printf("\n\n\n\n\n");

        printf("Jugador 1 (Fichas en la base):"); ImpElem(izquierdo(*Bar));
        printf("             Jugador 2 (Fichas en la base):"); ImpElem(derecho(*Bar));

        printf("\n\n\n\n\n");

        for(int i = 0; i < 13; i++){
            Elem e = derecho(b);
            vals2[i] = e;
            b = desformarDer(b);
        }
        for(int i= 12; i >=0; i--){
            b = formarDer(b,vals2[i]);
        }
        for(int i= 12; i >=1; i--){
            if(vals2[i]>0){printf("%3dN   ",vals2[i]);}
            else if(vals2[i]==0){printf("%3d    ",vals2[i]);}
            else{printf("%3dB   ",-vals2[i]);}
        }
        printf("     Jugador 1: %d",-derecho(b));
        puts("\n----------------------------------------------------------------------------------");
        for(int i = 0; i < 13; i++){
            Elem e = derecho(b2);
            vals4[i] = e;
            b2 = desformarDer(b2);
        }
        for(int i= 12; i >=1; i--){
            printf("%3d    ",vals4[i]);
        }
        for(int i= 12; i >=0; i--){
            b2 = formarDer(b2,vals4[i]);
        }
        puts("\n----------------------------------------------------------------------------------");
        printf("\n\n");
    }
}
