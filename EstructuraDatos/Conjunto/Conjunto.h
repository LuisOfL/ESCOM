#include"ElemInt.h"
#include"lista.h"
//Estructura de datos
typedef Lista Conjunto;

void ImpConj(Conjunto s){return ImpLista(s);}

//Funciones
Conjunto Vacio(){return vacia();}

int Contiene(Elem e, Conjunto s){
	return EstaEn(e,s);
}

Conjunto Inserta(Elem e, Conjunto s){
    if(Contiene(e,s)){return s;}
    return cons(e,s);
}

int EsVacio(Conjunto s){return esvacia(s);}


Conjunto Elimina(Elem e, Conjunto s){
	return EliminaL(e,s);
}

Conjunto Union(Conjunto s1, Conjunto s2){
	return PegaListas(s1,s2);
}

Conjunto Interseccion(Conjunto s1, Conjunto s2){
	return InterseccionL(s1,s2);
}

Conjunto Diferencia(Conjunto s1, Conjunto s2){
	return DiferenciaL(s1,s2);
}

int Cardinalidad(Conjunto s1){
	return NumElems(s1);
}