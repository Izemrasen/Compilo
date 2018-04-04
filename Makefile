all: compiler

lex.yy.c: compiler.l
	./flex compiler.l
rule.tab.c: rule.y
	~/bison/bin/bison -d -v rule.y
compiler: rule.tab.c lex.yy.c symtable.c
	gcc -o compiler lex.yy.c rule.tab.c symtable.c libfl.a ~/bison/lib/liby.a 

clean:
	rm -rf compiler lex.yy.c rule.tab.c
test: compiler ./test.txt
	./compiler < ./test.txt
test2: compiler ./test.txt
	./compiler < ./test.txt 2>&1 | grep -i token
