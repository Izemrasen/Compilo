%{
#include <stdio.h>
#include "symtable.h"
int yylex(void);
void yyerror(char*);
#define YYDEBUG 1

%}

%token tINTEGER tCONSTANT tCHAR tSTRING tNUMBER tID tVOID 
%token tIF tELSE tWHILE tFOR tMAIN tRETURN
%token tCOMMA tBEGIN_PARENTHESIS tEND_PARENTHESIS tBEGIN_BLOCK tEND_BLOCK 
%token tEND_OF_INSTRUCTION tPRINTF tQUOTE
%token tPLUS tMINUS tMULTIPLY tDIVIDE tASSIGN tGT tGTE tLT tLTE tEQUALITY

%left tPLUS tMINUS
%left tMULTIPLY tDIVIDE
%left tGT tGTE tLT tLTE tEQUALITY

%%


start: 
	tINTEGER tMAIN tBEGIN_PARENTHESIS tEND_PARENTHESIS Body { printf("Main\n"); };

Body: 
	tBEGIN_BLOCK Instrs tEND_BLOCK ;

Instrs: 
	Instr Instrs
	| Block Instrs
	| ;

Instr:
	Definition tEND_OF_INSTRUCTION
	| Assignment tEND_OF_INSTRUCTION
	| tEND_OF_INSTRUCTION ;

Block:
	If
	| While
	| For ;

Prefix: 
	Type { printf("Type\n"); }
	| tCONSTANT Type { printf("Constante\n"); } ;
	
Type: 
	tINTEGER { printf("Integer\n"); }
	| tCHAR { printf("Character\n"); }
	| tSTRING { printf("String\n"); };

Definition: 
	Prefix tID { printf("Definition\n"); }
	| Prefix Assignment { printf("Definition\n"); };

Assignment:
	tID tASSIGN Expr { printf("Assignment\n"); };
	

/*Assignment_sugar:
	tID tPLUS tPLUS
	| tID tMINUS tMINUS;
*/
// TODO : Printf Assembleur Ternaires Comments
//Printf:
	//tPRINTF tBEGIN_PARENTHESIS tQUOTE CoC tQUOTE tEND_PARENTHESIS;

For:
	tFOR tBEGIN_PARENTHESIS Assignment tEND_OF_INSTRUCTION Expr tEND_OF_INSTRUCTION Assignment tEND_PARENTHESIS Body;

If:
	tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body { printf("If\n"); }
	| tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body tELSE Body { printf("If Else\n"); };

While:
	tWHILE tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body { printf("While\n"); };

Expr:
	tNUMBER
	| tMINUS tNUMBER 
	| tID
	| Expr tPLUS Expr { printf("Addition\n"); }
	| Expr tMINUS Expr { printf("Soustraction\n"); }
	| Expr tMULTIPLY Expr { printf("Multiplication\n"); }
	| Expr tDIVIDE Expr { printf("Division\n"); }
	| Expr tGT Expr { printf("Condition 1\n"); }
	| Expr tGTE Expr { printf("Condition 2\n"); }
	| Expr tLT Expr { printf("Condition 3\n"); }
	| Expr tLTE Expr { printf("Condition 4\n"); }
	| Expr tEQUALITY Expr { printf("Egalité\n"); }

%%

extern int yydebug;

int main(){
	#if YYDEBUG
		yydebug = 1;
	#endif

	yyparse();
}

