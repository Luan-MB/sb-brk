all:
	as meuAlocador.s -o meuAlocador.o
	gcc -c main.c -o main.o
	gcc -static main.o meuAlocador.o -o meuAlocador

purge:
	rm -rd *.o
	rm -rf meuAlocador
