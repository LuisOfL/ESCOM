typedef struct Nodo{
    Elem dato;
    struct Nodo *sig;
}*Lista;
Lista vacia(){return NULL;}
Lista cons(Elem e, Lista l){
    Lista t=(Lista)malloc(sizeof(struct Nodo));
    t->dato=e;
    t->sig=l;
    return t;
}
int esvacia(Lista l){return l==vacia();}
Elem cabeza(Lista l){return l->dato;}
Lista resto(Lista l){return l->sig;}

void ImpLista(Lista l){
    if(!esvacia(l)){
        ImpElem(cabeza(l));
        ImpLista(resto(l));
    }
}
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

Lista EliminaL(Elem e, Lista l){
	if(esvacia(l)){return vacia();}
	if(!EstaEn(e,l)){return l;}
	Lista temp = vacia();
	while(!esvacia(l)){
		Elem e1 = cabeza(l);
		if(e1 != e){
			temp = cons(e1,temp);
		}
		l = resto(l); 
	}
	temp = InvierteLista(temp);
	return temp;
}

Lista InterseccionL(Lista l1, Lista l2){
	if(esvacia(l1) || esvacia(l2)){return vacia();}
	Lista temp = vacia();
	while(!esvacia(l1)){
		Elem e = cabeza(l1);
		if(EstaEn(e,l2)){temp = cons(e,temp);}
		l1 = resto(l1);
	}
	return temp;
}

Lista DiferenciaL(Lista l1, Lista l2){
	if(esvacia(l1)){return l1;}
	if(esvacia(l2)){return l1;}
	Lista temp = vacia();
	while(!esvacia(l1)){
		Elem e = cabeza(l1);
		if(!EstaEn(e,l2)){temp = cons(e,temp);}
		l1 = resto(l1);
	}
	return temp;
}