all: compiler

lex.yy.c: compiler.l
	./flex compiler.l
rule.tab.c: rule.y
	~/bison/bin/bison -d rule.y
compiler: rule.tab.c lex.yy.c
	gcc -o compiler lex.yy.c rule.tab.c libfl.a ~/bison/lib/liby.a 

clean:
	rm -rf compiler lex.yy.c rule.tab.c
test: compiler
	./compiler < test.c
