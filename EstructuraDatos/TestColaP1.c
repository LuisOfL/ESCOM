#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include".\Elem\ElemInt.h"
#include".\ColaP\ColaP.h"
void ImpColaP(ColaP);

int main(){
   int i;
   ColaP q=nuevaP();

   srand(time(NULL));
   for(i=1;i<=10;i++)
       q=formarP(q,1+rand()%30);

   ImpColaP(q);
   q=desformarP(q);
   puts("\n----------------");
   ImpColaP(q);
   puts("\n----------------");

   ImpColaP(q=formarP(q,LeeElem()));


   return 0;
}
void ImpColaP(ColaP q){ImpLista(q);};
