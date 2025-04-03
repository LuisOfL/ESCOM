typedef struct Nodo{
         Elem dato;
         struct Nodo *izq;
         struct Nodo *der;
}*ApNodo;

typedef struct BiNodo{
      ApNodo izq;
      ApNodo der;
}*BiCola;
// BiCola q=nueva();
BiCola nuevaBi(){
    BiCola t =(BiCola)malloc(sizeof(struct BiNodo));
    t->izq=t->der=NULL;
    return t;
}
int esnueva(BiCola q){ return (q->izq==NULL)&&(q->der==NULL);}

BiCola formarIzq(Elem e, BiCola q) {
      ApNodo t = (ApNodo)malloc(sizeof(struct Nodo));
      t->dato = e;
      t->izq = NULL;  // CORRECCIÓN
      t->der = NULL;  // CORRECCIÓN
  
      if (esnueva(q))
          q->izq = q->der = t;
      else {
          t->der = q->izq;
          q->izq->izq = t;
          q->izq = t;
      }
      return q;
  }
  BiCola formarDer(BiCola q, Elem e) {
      ApNodo t = (ApNodo)malloc(sizeof(struct Nodo));
      t->dato = e;
      t->izq = NULL;  // CORRECCIÓN
      t->der = NULL;  // CORRECCIÓN
  
      if (esnueva(q))
          q->izq = q->der = t;
      else {
          t->izq = q->der;
          q->der->der = t;
          q->der = t;
      }
      return q;
  }

Elem izquierdo(BiCola q){ return q->izq->dato;}
Elem derecho(BiCola q){ return q->der->dato;}

BiCola desformarIzq(BiCola q){
      ApNodo t=q->izq;
      if(q->izq==q->der)
        q->izq=q->der=NULL;
      else{
         q->izq=q->izq->der;
         q->izq->izq = NULL;
      }
      free(t);
      return q;
}

BiCola desformarDer(BiCola q){
      ApNodo t=q->der;
      if(q->der==q->izq)
        q->der=q->izq=NULL;
      else{
         q->der=q->der->izq;
         q->der->der = NULL;
      }
      free(t);
      return q;
}
