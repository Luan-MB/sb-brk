#include "meuAlocador.h"

int main () {
    long *a, *b, *c;

    iniciaAlocador();
    a = alocaMem(200);
    imprimeMapa();
    b = alocaMem(300);
    imprimeMapa();
    liberaMem(a);
    imprimeMapa();
    c = alocaMem(250);
    imprimeMapa();
    finalizaAlocador();
    return 0;
}