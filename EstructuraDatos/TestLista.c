#include<stdio.h>
#include<stdlib.h>
#include"ElemInt.h"
#include"Lista.h"
int NumElems(Lista);
void ImpLista(Lista);

int main(){
    int i;
    Lista l;

    l=vacia();

    for(i=1;i<=5;i++)
        l=cons(5*i,l);

    esvacia(l)?puts("Si esta vacia.\n"):puts("No esta vacia.\n");

    ImpElem(cabeza(l));
    ImpElem(cabeza(resto(l)));

    printf("La lista tiene %d elementos.\n",NumElems(l));

    puts("\n----------------");
    ImpLista(l);

    return 0;
}

int NumElems(Lista x){
     if(esvacia(x))
        return 0;
     else
        return 1+NumElems(resto(x));

};
void ImpLista(Lista l){
     if(!esvacia(l)){
        ImpElem(cabeza(l));
        ImpLista(resto(l));
     }
};
