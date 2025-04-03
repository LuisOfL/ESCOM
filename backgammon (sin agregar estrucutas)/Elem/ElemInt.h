typedef int Elem;

Elem LeeElem(){Elem e; scanf("%d",&e); return e;}
void ImpElem(Elem e){printf("%d\t",e);}
int EsMenor(Elem e1, Elem e2){return e1<e2;}
int EsMoI(Elem e1, Elem e2){return e1<=e2;}
int SonIguales(Elem e1,Elem e2){return e1==e2;}

void Intercambia(Elem *a, Elem *b){
     Elem t;
     t=*a; *a=*b; *b=t;
};
