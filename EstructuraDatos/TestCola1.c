#include<stdio.h>
#include<stdlib.h>
#include".\Elem\ElemInt.h"
#include".\Colas\Cola.h"

void ImpCola(Cola q){
    Cola t=nueva();
    while(!esnueva(q)){
        ImpElem(primero(q));
        t=formar(t,primero(q));
        desformar(q);
    }
    q=t;
}

int main(){
   Cola c1=nueva();

   c1=formar(formar(formar(formar(nueva(),1),2),3),4);


   while(!esnueva(c1)){
      ImpElem(primero(c1));
      desformar(c1);
   }

   return 0;
}
