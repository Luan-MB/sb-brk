#include <unistd.h>
#include <stdio.h>

unsigned long incremento = 4096;
unsigned long inicioHeap;
unsigned long atualHeap;
unsigned long fimHeap;

// Salva o falor inicial de brk 
void iniciaAlocador() {

    inicioHeap = (unsigned long) sbrk(0);
    atualHeap = inicioHeap;
    fimHeap = inicioHeap;
}

// Restaura o valor inicial de brk
void finalizaAlocador() {

    brk((void *) inicioHeap);
}

// "Aloca" numbytes de memoria na heap, colocando o status como 1
void *alocaMem(unsigned long numBytes) {

    unsigned long *aux = (unsigned long *) inicioHeap;
    unsigned long bestfit = 0;
    unsigned long i = inicioHeap;

    // Checa se existem espacos disponiveis
    // Selecionando com menor valor maior que numBytes
    while (i < atualHeap) {
        if (*(aux) == 0) {
            if (*(aux+1) >= numBytes) {
                if (bestfit == 0)
                    bestfit = (unsigned long) aux;
                else {
                    if (*(((unsigned long *) (bestfit)) + 1) > *(aux+1))
                        bestfit = (unsigned long) aux;
                }
            }
        }
        
        i += (*(aux+1) + 16);
        aux = (unsigned long *) i;
    }

    if (bestfit != 0) {
        *((unsigned long *) bestfit) = 1;
        return (((unsigned long *) bestfit) + 2);
    }

    // Se necessario aumenta o brk em 4096 bytes
    while ((fimHeap - atualHeap) < (numBytes + 16))
        fimHeap = (unsigned long) sbrk(incremento);
    
    *(aux) = 1;
    *(aux+1) = numBytes;
    atualHeap = atualHeap + (numBytes + 16);
    return (aux+2);
}

// Libera um espaco, trocando o status para 0
void liberaMem(void *bloco) {

    *(((unsigned long *)bloco)-2) = 0;
}

// Imprime o mapa da memoria
void imprimeMapa() {

    unsigned long *aux = (unsigned long *) inicioHeap;
    unsigned long i = inicioHeap;
    
    while (i < atualHeap) {
        printf("################");
        if (*(aux) == 0) {
            for (unsigned long k=0; k<*(aux+1); ++k)
                printf("-");
        } else {
            for (unsigned long k=0; k<*(aux+1); ++k)
                printf("+");
        }
        i += (*(aux+1) + 16);
        aux = (unsigned long *) i;
    }
    printf("\n");
}

int main () {

    unsigned long *x, *y, *z, *a, *b, *c;
    
    printf("\n");
    iniciaAlocador();
    
    printf("Inicio heap: %lx\n",inicioHeap);
    
    x = alocaMem(50);
    a = alocaMem(44);
    y = alocaMem(47);
    b = alocaMem(48);
    
    imprimeMapa();
    
    liberaMem(x);
    liberaMem(a);
    liberaMem(y);
    liberaMem(b);

    imprimeMapa();
    
    z = alocaMem(45);

    imprimeMapa();
    
    printf("Fim heap antes final: %lx\n",fimHeap);
    finalizaAlocador();
    printf("Fim heap final: %lx\n",fimHeap);
    return 0;
}