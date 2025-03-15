#include<stdio.h>
#include<stdlib.h>
#include".\Elem\ElemInt.h"
#include".\Lista\Lista.h"

Lista ElimRep(Elem e, Lista l){
    if(esvacia(l))
        return l;
    else if(SonIguales(e,cabeza(l)))
             return ElimRep(e,resto(l));
         else
             return cons(cabeza(l),ElimRep(e,resto(l)));
}
void ImpLista(Lista l){
    if(!esvacia(l)){
        ImpElem(cabeza(l));
        ImpLista(resto(l));
    }
};
int main(){

   Lista l=cons(1,cons(2,cons(1,cons(3,cons(2,cons(1,vacia()))))));

   ImpLista(ElimRep(3,l));

   return 0;
}
