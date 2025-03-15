#include<stdio.h>
#include<stdlib.h>
#include".\Elem\ElemInt.h"
#include".\BiCola\BiCola.h"

int main(){
    BiCola q=nuevaBi();
    q=formarIzq(3,formarDer(q,1));

    ImpElem(izquierdo(q));
    ImpElem(derecho(q));

    return 0;
}
