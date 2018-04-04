%{
#include <stdio.h>
#include <string.h>
#include "symtable.h"
int yylex(void);
void yyerror(char*);
#define YYDEBUG 0

// TODO: handle depth
char depth = 0;
Type type;

%}

%union{
	char *str;
	int nb;
}

%token tINTEGER tCONSTANT tCHAR tSTRING tNUMBER tID tVOID 
%token tIF tELSE tWHILE tFOR tMAIN tRETURN
%token tCOMMA tBEGIN_PARENTHESIS tEND_PARENTHESIS tBEGIN_BLOCK tEND_BLOCK 
%token tEND_OF_INSTRUCTION tPRINTF tQUOTE
%token tPLUS tMINUS tMULTIPLY tDIVIDE tASSIGN tGT tGTE tLT tLTE tEQUALITY

// TODO: rm tInteger etc.
%type <str> tID tINTEGER tCONSTANT tCHAR tSTRING 
%type <nb> tNUMBER Expr

%left tPLUS tMINUS
%left tMULTIPLY tDIVIDE
%left tGT tGTE tLT tLTE tEQUALITY

%nonassoc tTRUC
%nonassoc tELSE

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
	Type { printf("Type\n");}
	| tCONSTANT Type { printf("Constante\n"); } ;
	
Type: 
	tINTEGER { printf("Integer\n"); type = INTEGER;}
	| tCHAR { printf("Character\n"); type = CHAR;}
	| tSTRING { printf("String\n"); type = CHAR;}; // TODO: rm tSTRING

Definition: 
	Prefix tID
	{
		//printf("<<<<<<<<<<\n");
		st_add($2, type, depth);
		printf("Definition\n");
	}
	| Prefix Assignment { printf("Definition\n"); }; // TODO: st_init()

Assignment:
	tID tASSIGN Expr
	{
		printf("AFC R0,%d\n", $3);
		printf("STORE %d,R0\n", st_get($1));
		//st_add($1, type, depth);
		st_init($1);
		printf("Assignment\n");
	} ;

Assignment_sugar:
	tID tPLUS tPLUS
	| tID tMINUS tMINUS;

// TODO : Printf Assembleur Ternaires Comments
//Printf:
	//tPRINTF tBEGIN_PARENTHESIS tQUOTE CoC tQUOTE tEND_PARENTHESIS;

For:
	tFOR tBEGIN_PARENTHESIS Assignment tEND_OF_INSTRUCTION Expr tEND_OF_INSTRUCTION Assignment tEND_PARENTHESIS Body;
	| tFOR tBEGIN_PARENTHESIS Assignment Expr tEND_OF_INSTRUCTION Assignment_sugar tEND_PARENTHESIS Body;

If:
	tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body { printf("If\n"); } //%prec tTRUC 
	| tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body tELSE Body /* Body_if */ { printf("If Else\n"); };

While:
	tWHILE tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS Body { printf("While\n"); };

Expr:
	tNUMBER
	{
		printf("<<<AFC R0,%d\n", $1);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		printf("STORE %d, R0\n", $$);
		st_print();
	}
	| tMINUS tNUMBER
	{
		printf("AFC R0,%d\n", $2);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		printf("AFC R1,%d\n", 0);
		printf("SOU R0,R1,R0\n");
		printf("STORE %d, R0\n", $$);
	}
	| tID
	{
		printf("LOAD R0,%d\n", st_get($1));
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		printf("STORE %d, R0\n", $$);
	}
	| Expr tPLUS Expr
	{
		printf("LOAD R0,%d\n", $1);
		printf("LOAD R1,%d\n", $3);
		printf("ADD R0,R0,R1\n");
		printf("STORE %d, R0\n", $1);
		// liberer une variable tmp (decrementer l'indice dans table des symboles)
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tMINUS Expr
	{
		printf("LOAD R0,%d\n", $1);
		printf("LOAD R1,%d\n", $3);
		printf("SOU R0,R0,R1\n");
		printf("STORE %d, R0\n", $1);
		// liberer une variable tmp (decrementer l'indice dans table des symboles)
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
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

