typedef struct Nodo{
         Elem dato;
         struct Nodo *sig;
}*ApNodo;

typedef struct CNodo{
      ApNodo prim;
      ApNodo ult;
}*Cola;
// Cola q=nueva();
Cola nueva(){
    Cola t =(Cola)malloc(sizeof(struct CNodo));
    t->prim=t->ult=NULL;
    return t;
}
int esnueva(Cola q){ return q->prim==NULL;}

Cola formar(Cola q, Elem e){
    ApNodo t = (ApNodo)malloc(sizeof(struct Nodo));
    t->dato = e;
    if(esnueva(q))
        q->prim=q->ult=t;
    else
        q->ult=q->ult->sig=t;
    return q;
}

Elem primero(Cola q){ return q->prim->dato;}

Cola desformar(Cola q){
      if(q->prim==q->ult)
        q->prim=q->ult=NULL;
      else
         q->prim=q->prim->sig;
      return q;
}
