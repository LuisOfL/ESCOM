typedef struct Nodo{
      Elem dato;
      struct Nodo *sig;
} *Pila;

Pila empty(){return NULL;}
Pila push(Elem e, Pila s){
   Pila t=(Pila)malloc(sizeof(struct Nodo));
   t->dato=e;
   t->sig=s;
   return t;
}
int isempty(Pila s){return s==empty();}
Elem top(Pila s){return s->dato;}
Pila pop(Pila s){return s->sig;}

