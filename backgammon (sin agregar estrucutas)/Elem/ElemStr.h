typedef char *Elem;

void ImpElem(Elem e){puts(e);}
Elem LeeElem(int n){
   Elem t=(Elem)malloc(n);
   scanf("%s",t);
   return t;
}
int EsMoI(Elem e1, Elem e2){
    return strcmp(e1,e2)<=0;
}
int EsMayor(Elem e1, Elem e2){
    return strcmp(e1,e2)>0;
}
int SonIguales(Elem e1, Elem e2){
    return strcmp(e1,e2)==0;
}

