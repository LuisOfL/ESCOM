
ElemHT getKeyBoardElem(){
	ElemHT e = nuevoElemento();

	printf("Numero atomico: ");
		scanf("%d",&e.numAtomico);
			limpiaBuffer();
	printf("Nombre: ");
		scanf("%s",e.nombre);
			limpiaBuffer();
	printf("simbolo: ");
		scanf("%s",e.simbolo);
	printf("Periodo: ");
		scanf("%d",&e.periodo);
	printf("Grupo: ");
		scanf("%s",e.grupo);
			limpiaBuffer();
	printf("Masa atomica: ");
		scanf("%f",&e.masaAtomica);
			limpiaBuffer();
	printf("Fecha: ");
		scanf("%s",e.fecha);
			limpiaBuffer();
	printf("Inventor: ");
		scanf("%s",e.inventor);

	return e;
}

void Menu(FILE * in, Hash h, int n){
	String id;
	int selection;
	ElemHT e = nuevoElemento();

	printf("\tTabla periodica de los elementos quimicos\n");
	printf("1. Buscar\n");
	printf("2. Borrar\n");
	printf("3. Insertar\n");
	printf("4. Salir\n");
	printf("   Seleccione una opcion: ");
	scanf("%d",&selection);

	switch(selection){
		case 1: 
			limpiaPantalla();
			printf("\n\tSelection : (Buscar)\n");
			printf("   Teclee el nombre a buscar: ");
			scanf("%s",id);
			if(estaEnHT(h,n,valorString(id))){
				impElemHT(htRecupera(h,n,valorString(id)));
			}
			else
				printf("Elemento no encontrado\n");
			break;
		case 2: 
			limpiaPantalla();
			printf("\n\tSelection : (Eliminar)\n");
			printf("Teclee el nombre a Borrar: ");
			scanf("%s",id);
			if(estaEnHT(h,n,valorString(id))){
				h = deleteToHash(h,n,valorString(id));
				printf("completed removal\n");
			}
			else
				printf("Elemento inexistente\n");
			break;
		case 3: 
			limpiaPantalla();
			printf("\n\tSelection : (Insertar)\n");
			e = getKeyBoardElem();
			if(estaEnHT(h,n,valorString(getNombre(e))))
				printf("\nElemento existente\n");
			else
				h = htInsertar(h,n,e);
			break;
		case 4:
			printf("Ending ...\n");
			exit(0);
		default:
			printf("Opcion no valida!\n");
			exit(0);
	}
}