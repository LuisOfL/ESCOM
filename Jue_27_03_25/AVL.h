#include"..\DicBin\DicBin.h"
typedef DicBin AVL;

int ABS(int n){
    if(n<0)
        return -n;
    else
        return n;
}

int FactBal(DicBin a){return Altura(izqAB(a))-Altura(derAB(a));}
int esAVL(DicBin a){
    return (esvacioAB(a))||((ABS(Altura(izqAB(a))-Altura(derAB(a)))<=1) &&
            esAVL(izqAB(a)) && esAVL(derAB(a)));
}
AVL rotaDer(DicBin a){
   return consAB(raiz(izqAB(a)),izqAB(izqAB(a)),
                 consAB(raiz(a),derAB(izqAB(a)),derAB(a)));
}

AVL rotaIzq(DicBin a){
   return consAB(raiz(derAB(a)),
                 consAB(raiz(a),izqAB(a),izqAB(derAB(a))),derAB(derAB(a)));
}

AVL rotaIzqDer(DicBin a){rotaDer(consAB(raiz(a),rotaIzq(izqAB(a)),derAB(a)));}

AVL rotaDerIzq(DicBin a){rotaIzq(consAB(raiz(a),izqAB(a),rotaDer(derAB(a))));}

AVL HazAVL(DicBin a){
    if(FactBal(a)>0)
        if(esAVL(izqAB(a)))
            if(FactBal(izqAB(a))>0)
                return rotaDer(a);
            else
                return rotaIzqDer(a);
        else
            return consAB(raiz(a),HazAVL(izqAB(a)),derAB(a));
    else if(esAVL(derAB(a)))
             if(FactBal(derAB(a))<0)
                 return rotaIzq(a);
             else
                 return rotaDerIzq(a);
         else
            return consAB(raiz(a),izqAB(a),HazAVL(derAB(a)));
}

AVL consAVL(Elem e, AVL a){
  a=InsOrd(e,a);
  if(esAVL(a))
    return a;
  else
    return HazAVL(a);
}

