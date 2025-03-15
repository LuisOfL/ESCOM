#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include"ElemInt.h"
#include"Lista.h"

int NumElems(Lista);
int iNumElems(Lista);
void ImpLista(Lista);
int EstaEn(Elem, Lista);
Lista PegaListas(Lista, Lista);
Lista InvierteLista(Lista);
Lista InsOrd(Elem, Lista);
Lista Ordena(Lista);

int main(){
    int i;
    Lista l=vacia(), l2=vacia();

    printf("%ld\n",time(NULL));
    fflush(stdin);
    getchar();
    printf("%ld\n",time(NULL));
    return 0;

    srand(time(NULL));
    for(i=1;i<=5;i++)
        printf("%d\t",1+rand()%20);
    return 0;



    for(i=1;i<=5;i++)
        l=cons(i*5,l);

    ImpLista(l);
    puts("\n---------");
    ImpLista(InvierteLista(l));
    puts("\n---------");
    ImpLista(InsOrd(18,InvierteLista(l)));
    puts("\n---------");
    ImpLista(InvierteLista(l));


    return 0;
}


int NumElems(Lista x){
    if(esvacia(x))
          return 0;
    else
         return 1+NumElems(resto(x));

};
int iNumElems(Lista x){
    int n=0;
    while(!esvacia(x)){
        n++;
        x=resto(x);
    }
    return n;
};

void ImpLista(Lista l){
    if(!esvacia(l)){
        ImpElem(cabeza(l));
        ImpLista(resto(l));
    }
};
int EstaEn(Elem e, Lista l){
     if(esvacia(l))
        return 0;
     else if(SonIguales(e,cabeza(l)))
              return 1;
          else
              return EstaEn(e,resto(l));
};
Lista PegaListas(Lista l1, Lista l2){
     if(esvacia(l1))
        return l2;
     else
        return cons(cabeza(l1),PegaListas(resto(l1),l2));
};

Lista InvierteLista(Lista l){
    if(esvacia(l))
        return l;
    else
     return PegaListas(InvierteLista(resto(l)),cons(cabeza(l),vacia()));
};
Lista InsOrd(Elem e, Lista l){
    if(esvacia(l))
        return cons(e,l);
    else if(EsMoI(e,cabeza(l)))
            return cons(e,l);
         else
            return cons(cabeza(l),InsOrd(e,resto(l)));
};
Lista Ordena(Lista l){
    if(esvacia(l))
        return l;
    else
        return InsOrd(cabeza(l),Ordena(resto(l)));
};
