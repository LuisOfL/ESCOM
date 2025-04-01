#include<stdio.h>
#include<stdlib.h>
#include".\Elem\ElemInt.h"
#include".\AVL\AVL.h"

int main(){

  AVL a=vacioAB();

  while(1){
       printf("x?");
       a=InsOrd(LeeElem(),a);
       printf("\nAI=%d\tAD=%d\tFB=%d\n",Altura(izqAB(a)),Altura(derAB(a)),FactBal(a));
       if(FactBal(a)>1){
          puts("Rotacion derecha:");
          a=rotaIzqDer(a);
          printf("\n***AI=%d\tAD=%d\tFB=%d***\n",Altura(izqAB(a)),Altura(derAB(a)),FactBal(a));
          ImpNivelPorNivelAB(a);
       }
  }

   return 0;
}
