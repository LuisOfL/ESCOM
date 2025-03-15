#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include"UsaLista.h"

int main(){
    int i;
    Lista l=vacia(), l2=vacia();


    srand(time(NULL));

    for(i=1;i<=10;i++)
        l=cons(1+rand()%30,l);

    ImpLista(l);
    puts("\n---------");
    ImpLista(Ordena(l));
    return 0;
    ImpLista(InvierteLista(l));
    puts("\n---------");
    ImpLista(InsOrd(18,InvierteLista(l)));
    puts("\n---------");
    ImpLista(InvierteLista(l));


    return 0;
}

