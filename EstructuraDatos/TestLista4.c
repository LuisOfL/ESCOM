#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include"UsaLista.h"

int main(){
    int i;
    Lista l1=vacia(), l2=vacia();
    Elem t;

    for(i=1;i<=5;i++){
        printf("Dame la cadena %d: ",i);
        t=LeeElem(30);
        l1=cons(t,l1);
    }
    puts("Elementos en la lista:");
    ImpLista(l1);
    puts("Elementos invertidos de la lista:");
    ImpLista(OrdenaLista(l1));
    return 0;
}

