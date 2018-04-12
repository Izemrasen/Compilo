%{
#include <stdio.h>
#include <string.h>
#include "symtable.h"
#include "instr.h"

int yylex(void);
void yyerror(char*);
#define YYDEBUG 0

// TODO: handle depth
char depth = 0;
Type type;
char buffer[32];

// TODO: $1 returns bullshit
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
		st_add($2, type, depth);
		printf("Definition\n");
		st_print();
	}
	| Prefix Assignment { printf("Definition2\n");};

Assignment:
	tID tASSIGN Expr
	{
		printf("Assignment\n");
		int position = st_get($1);
		if (position == SYMBOL_NOT_FOUND) {
			st_add($1, type, depth);
			position = st_get($1);
		}
		sprintf(buffer, "%d", $3);
		printf("<<<<<id: %s  %s  \n", $1, buffer);
		instr_add("AFC", "RO", buffer, "");
		sprintf(buffer, "%d", position);
		instr_add("STORE", buffer, "R0", "");
		st_init($1);
		st_print();
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
		sprintf(buffer, "%d", $1);
		instr_add("AFC", "R0", buffer, "");
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		printf("$$: %d\n", $$);
		instr_add("STORE", buffer, "R0", "");
		st_print();
	}
	| tMINUS tNUMBER
	{
		sprintf(buffer, "%d", $2);
		instr_add("AFC", "R0", buffer, "");
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		instr_add("AFC", "R1", "0", "");
		instr_add("SOU", "R0", "R1", "R0");
		sprintf(buffer, "%d", $$);
		instr_add("STORE", buffer, "R0", "");
	}
	| tID
	{
		sprintf(buffer, "%d", st_get($1));
		instr_add("LOAD", "R0", buffer, "");
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		instr_add("STORE", buffer, "R0", "");
	}
	| Expr tPLUS Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "");
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "");
		instr_add("ADD", "R0", "R0", "R1");
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "");
		// liberer une variable tmp (decrementer l'indice dans table des symboles)
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tMINUS Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "");
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "");
		instr_add("SOU", "R0", "R0", "R1");
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "");
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tMULTIPLY Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "");
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "");
		instr_add("MUL", "R0", "R0", "R1");
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "");
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tDIVIDE Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "");
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "");
		instr_add("DIV", "R0", "R0", "R1");
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "");
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
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

	instr_print();
}

