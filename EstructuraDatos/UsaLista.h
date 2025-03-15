#include".\Elem\ElemStr.h"
#include".\Lista\Lista.h"

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
Lista OrdenaLista(Lista l){
    if(esvacia(l))
        return l;
    else
        return InsOrd(cabeza(l),OrdenaLista(resto(l)));
};
