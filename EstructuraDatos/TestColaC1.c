#include<stdio.h>
#include<stdlib.h>
#include"Elem\ElemInt.h"
#include"ColaC\ColaC.h"
void ImpColaC(ColaC);
ColaC rotaC2(ColaC);

int main(){
   ColaC q=nuevaC();
   int i;
   for(i=1;i<=5;i++)
       q=formarC(q,i);

/*
   do{
       ImpElem(primeroC(q));
       q=desformarC(q);
   }while(!esnuevaC(q));
*/
   while(1){
       ImpColaC(q);
       puts("\n---------------");
       q=rotaC2(q);
       fflush(stdin);
       getchar();
   }

   return 0;
}

void ImpColaC(ColaC q){
   ColaC t;
   if(!esnuevaC(q)){
       t=q;
       do{
          ImpElem(primeroC(q));
          q=rotaC(q);
       }while(t!=q);
   }
};

ColaC rotaC2(ColaC q){return formarC(desformarC(q),primeroC(q));};


