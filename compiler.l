%{
%}

SEPARATOR [\ \t\,]
END_OF_INSTRUCTION \;
BEGIN_BLOCK \{
END_BLOCK \}
BEGIN_PARENTHESIS \(
END_PARENTHESIS \)
CHARACTER [a-zA-Z_0-9]
NUMBER [0-9]
END_OF_LINE \n
ID [a-zA-Z][a-zA-Z0-9_]*


%%

{END_OF_LINE} { printf("END_OF_LINE\n"); }
{SEPARATOR}+	{ printf("SEPARATOR\n"); } 
{CHARACTER}+ { printf("STRING\n"); }
{NUMBER}+ { printf("NUMBER\n"); }
{BEGIN_BLOCK} { printf("BEGIN_BLOCK\n"); }
{END_BLOCK} { printf("END_BLOCK\n"); }
{BEGIN_PARENTHESIS} { printf("BEGIN_PARENTHESIS\n"); }
{END_PARENTHESIS} { printf("END_PARENTHESIS\n"); }
{ID} { printf("ID\n") ;}
"main" { printf("MAIN\n") ;}
"printf" { printf("PRINTF\n") ;}
"if" { printf("IF\n") ;}
"else" { printf("ELSE\n") ;}
"while" { printf("WHILE\n") ;}
"for" { printf("FOR\n") ;}
"const" { printf("CONSTANT\n") ;}
"void" { printf("VOID\n") ;}
"int" { printf("INTEGER\n") ;}
"char" { printf("CHAR\n") ;}
"+" { printf("PLUS\n") ;}
"-" { printf("MINUS\n") ;}
"*" { printf("\n") ;}
"/" { printf("DIVIDE\n") ;}
"=" { printf("EQUAL\n") ;}

%%

void main(void){
	yylex();
}
