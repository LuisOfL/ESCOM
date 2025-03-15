#include"..\Lista\Lista.h"
#include"..\Lista\UsaLista.h"
typedef Lista ColaP;

ColaP nuevaP(){return vacia();}

int esnuevaP(ColaP q){return esvacia(q);}

ColaP formarP(ColaP q, Elem e){
       if(esnuevaP(q))
           return cons(e,q);
       else if(EsMayor(e,cabeza(q)))
                return cons(e,q);
            else
                return cons(cabeza(q),formarP(resto(q),e));
}
Elem primeroP(ColaP q){return cabeza(q);}
ColaP desformarP(ColaP q){return resto(q);}
