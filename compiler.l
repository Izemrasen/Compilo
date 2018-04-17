%{
#include "rule.tab.h"
%}

COMMA \,
END_OF_INSTRUCTION \;
BEGIN_BLOCK \{
END_BLOCK \}
BEGIN_PARENTHESIS \(
END_PARENTHESIS \)
NUMBER [0-9]
CHARACTER [a-zA-Z_0-9]


%%
"main" { return tMAIN;}
"return" { return tRETURN;}
"if" { return tIF;}
"else" { return tELSE;}
"while" { return tWHILE;}
"for" { return tFOR;}
"const" { return tCONSTANT;}
"void" { return tVOID;}
"int" { return tINTEGER;}
"char" { return tCHAR;}
"+" { return tPLUS;}
"-" { return tMINUS;}
"*" { return tMULTIPLY;}
"/" { return tDIVIDE;}
"=" { return tASSIGN;}
">" { return tGT;}
">=" { return tGTE;}
"<" { return tLT;}
"<=" { return tLTE;}
"==" { return tEQUALITY;}
"\"" { return tQUOTE;}
"printf" { return tPRINTF; }
[a-zA-Z]{CHARACTER}* { yylval.str = strdup(yytext); return tID; }
{NUMBER}+ { yylval.nb = atoi(yytext); return tNUMBER; }
{CHARACTER}+ { return tSTRING; }
{BEGIN_BLOCK} { return tBEGIN_BLOCK; }
{END_BLOCK} { return tEND_BLOCK; }
{END_OF_INSTRUCTION} {return tEND_OF_INSTRUCTION; }
{BEGIN_PARENTHESIS} { return tBEGIN_PARENTHESIS; }
{END_PARENTHESIS} { return tEND_PARENTHESIS; }
[\t \n] ;

%%

