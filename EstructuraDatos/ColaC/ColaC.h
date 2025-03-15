typedef struct Nodo{
      Elem dato;
      struct Nodo *sig;
}*ColaC;

ColaC nuevaC(){return NULL;}
int esnuevaC(ColaC q){return q==nuevaC();}
ColaC formarC(ColaC q, Elem e){
     ColaC t=(ColaC)malloc(sizeof(struct Nodo));
     t->dato=e;
     if(esnuevaC(q))
         t->sig=t;
     else{
        t->sig=q->sig;
        q->sig=t;
     }
     return t;
}
Elem primeroC(ColaC q){return q->sig->dato;}
ColaC desformarC(ColaC q){
      ColaC t;
      if(q==q->sig){
          free(q);
          return nuevaC();
      }
      else {
         t=q->sig;
         q->sig=q->sig->sig;
         free(t);
      }
      return q;
}
ColaC rotaC(ColaC q){
     return q=q->sig;
}
