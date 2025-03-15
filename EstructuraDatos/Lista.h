typedef struct Nodo{
                 Elem dato;
                 struct Nodo *sig;
               }*Lista;

Lista vacia(){ return NULL; }  // vacia: -> Lista;
Lista cons(Elem e, Lista l){
       Lista t=(Lista)malloc(sizeof(struct Nodo));
       t->dato=e;
       t->sig=l;
       return t;
}
int esvacia(Lista l){return l==vacia();} // esvacia: Lista -> Bool;
Elem cabeza(Lista l){return l->dato;}   // cabeza: Lista -> Elem;
Lista resto(Lista l){return l->sig;}

