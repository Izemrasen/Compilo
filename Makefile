all: compiler

lex.yy.c: compiler.l
	./flex compiler.l
compiler: lex.yy.c
	gcc -o compiler lex.yy.c libfl.a
