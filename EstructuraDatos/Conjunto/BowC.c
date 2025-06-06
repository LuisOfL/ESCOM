#include<stdio.h>
#include<stdlib.h>
#include"Conjunto.h"

int main(){
	Conjunto s1 = Vacio();
	Conjunto s2 = Vacio();
	s1 = Inserta(3,Inserta(5,Inserta(7,Inserta(11,s1))));
	s2 = Inserta(3,Inserta(2,Inserta(8,Inserta(11,s2))));
	printf("Es vacio el vacio?: %d \n",EsVacio(Vacio()));
	printf("Es vacio el Insertar algun elemento a un conjunto?: %d \n",EsVacio(Inserta(3,Vacio())));
	printf("Hay algun elemento en el vacio el vacio?: %d \n",EstaEn(3,Vacio()));
	ImpConj(s1);
	puts(" ");
	ImpConj(s2);
	puts(" ");
	Conjunto s3 = Interseccion(s1,s2);
	ImpConj(s3);
	puts(" ");
	Conjunto s4 = Diferencia(s1,s2);
	ImpConj(s4);
	puts(" ");
	printf("Cardinalidad de la diferencia: %d",Cardinalidad(s4));
	return 0;
}
