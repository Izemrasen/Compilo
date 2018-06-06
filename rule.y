%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symtable.h"
#include "instr.h"

int yylex(void);
void yyerror(char*);
#define YYDEBUG 0

// TODO: handle depth
char depth = 0;
Type type;
char prefix = 0;
char string_defined = 0;
char constant = 0;
char buffer[64];
int instr_count = 0;
int instr_count2 = 0;


%}

%union{
	char *str;
	int nb;
}

%token tINTEGER_TYPE tSTRING_TYPE tCONSTANT tNUMBER tSTRING tID tVOID 
%token tIF tELSE tWHILE tFOR tMAIN tRETURN
%token tCOMMA tBEGIN_PARENTHESIS tEND_PARENTHESIS tBEGIN_BLOCK tEND_BLOCK 
%token tEND_OF_INSTRUCTION tPRINT_FUNC tQUOTE
%token tPLUS tMINUS tMULTIPLY tDIVIDE tADDRESS tASSIGN tGT tGTE tLT tLTE tEQUALITY

// TODO: rm tInteger etc.
%type <str> tID tINTEGER_TYPE tSTRING_TYPE tCONSTANT tSTRING
%type <nb> tNUMBER Expr


%left tPLUS tMINUS
%left tMULTIPLY tDIVIDE
%left tNEG
%left tGT tGTE tLT tLTE tEQUALITY


%nonassoc tTRUC
%nonassoc tELSE

%%


start:
	tINTEGER_TYPE tMAIN tBEGIN_PARENTHESIS tEND_PARENTHESIS Body { printf("Main\n"); };

Body:
	{ depth++; } tBEGIN_BLOCK Instrs tEND_BLOCK { st_rm_block(depth--); } ;

Body_if: 
	Instr
	| Body ; 

Instrs:
	Instr Instrs
	| Block Instrs
	| ;

Instr:
	Definition tEND_OF_INSTRUCTION
	| Dereference tEND_OF_INSTRUCTION
	| Assignment tEND_OF_INSTRUCTION
	| Print tEND_OF_INSTRUCTION
	| tEND_OF_INSTRUCTION;

Block:
	If
	| While
	| For ;

Prefix: 
	Type { printf("Type\n"); prefix = 1; }
	| tCONSTANT Type { printf("Constante\n"); prefix = 1; constant = 1; } ;
	
Type: 
	tINTEGER_TYPE { printf("Integer\n"); type = INTEGER; }
	| tSTRING_TYPE { printf("String\n"); type = STRING; string_defined = 1; } ;

Definition: 
	Prefix tID
	{
		st_add($2, type, depth);
		printf("Definition\n");
		st_print();
	}
	| Prefix Assignment
	{
		printf("Definition2\n");
		st_print();
	};

Dereference:
	tMULTIPLY Expr tASSIGN Expr
	{
		printf("Dereference left!!!!\n");
		// Load target address
		sprintf(buffer, "%d", $2);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		
		// Load value to assign to target
		sprintf(buffer, "%d", $4);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		
		// Store value to target
		instr_add("STOREI", "R0", "R1", "", &instr_count);
	};

Assignment:
	tID tASSIGN Expr
	{
		printf("Assignment\n");
		int pos = st_get($1);
		if (pos == SYMBOL_NOT_FOUND) {
			if (prefix) {
				st_add($1, type, depth);
				pos = st_get($1);
				prefix = 0;
			} else {
				sprintf(buffer, "Symbol '%s' not found\n", $1);
				yyerror(buffer);
			}
		}
		printf("<<<<<id: %s  @%s  \n", $1, buffer);
		
		if (constant && st_is_init($1)) {
			sprintf(buffer, "Constant '%s' is already initialized", $1);
			yyerror(buffer);
		}
		
		sprintf(buffer, "%d", $3);		
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", pos);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_init($1);
	};

// TODO: test 
Assignment_sugar:
	tID tPLUS tPLUS
	| tID tMINUS tMINUS;

// XXX
Print:
/*	tPRINT_FUNC tBEGIN_PARENTHESIS tSTRING tEND_PARENTHESIS{} | */
	tPRINT_FUNC tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS
	{
		printf("Printf\n");
		/*int pos = st_get($3);
		if (pos == SYMBOL_NOT_FOUND) {
			sprintf(buffer, "Symbol '%s' not found\n", $3);
			yyerror(buffer);
		}*/
		
		//sprintf(buffer, "%d", pos);
		sprintf(buffer, "%d", $3);
		instr_add("AFC", "R0", buffer, "", &instr_count);
		instr_add("LOADI", "R1", "R0", "", &instr_count);
		instr_add("PRINT", "R1", "", "", &instr_count);
	};

For:
	tFOR tBEGIN_PARENTHESIS Assignment tEND_OF_INSTRUCTION Expr tEND_OF_INSTRUCTION Assignment tEND_PARENTHESIS Body;
	| tFOR tBEGIN_PARENTHESIS Assignment tEND_OF_INSTRUCTION Expr tEND_OF_INSTRUCTION Assignment_sugar tEND_PARENTHESIS Body;

If:
	tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS If_act Body_if %prec tTRUC 
	{
		// Patch jump instr
		int pos = instr_count + 1;
		Instruction jump = instr_get(pos);
		sprintf(buffer, "%d", pos);
		jump.a = buffer;
		instr_set(pos, jump);
	}
	| tIF tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS If_act Body_if If_else_act tELSE else_act Body_if
	{
		int pos = instr_count + 1;
		Instruction jump = instr_get(pos);
		sprintf(buffer, "%d", pos);
		jump.a = strdup(buffer);
		instr_set(pos, jump);
	}
	;

If_act:
	{
		sprintf(buffer, "%d", st_get_pos() - 1);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		instr_add("JMPC", "-1", "R0", "", &instr_count);
		instr_count = 0;
	}

If_else_act:
	{
		// Patch jump instr
		int pos = instr_count + 1;
		Instruction jumpc = instr_get(pos);
		sprintf(buffer, "%d", pos);
		jumpc.a = strdup(buffer);
		instr_set(pos, jumpc);
	}
else_act:
	{	
		sprintf(buffer, "%d", st_get_pos() - 1);
		instr_add("JMP", "-1", "R0", "", &instr_count);
		instr_count = 0;
	}

While:
	tWHILE tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS While_act Body 
	{
		// Patch jump instr
		int pos = instr_count + 1;
		sprintf(buffer, "%d", -pos - 10); // TODO: WARNING: this is a silly workaround
		instr_add("JMP", buffer, "R0", "", &instr_count);
		pos = instr_count + 1;
		Instruction jumpc = instr_get(pos);
		sprintf(buffer, "%d", pos - 1);
		jumpc.a = strdup(buffer);
		instr_set(pos, jumpc);
	}
	;

While_act:
	{
		sprintf(buffer, "%d", st_get_pos());
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		instr_add("JMPC", "-1", "R0", "", &instr_count);
		instr_count = 0;
	}

Expr:
	tBEGIN_PARENTHESIS Expr tEND_PARENTHESIS
	{
		printf("Expr w/ parentheses!!!\n");
		$$ = $2;
	}
	|
	tNUMBER
	{
		sprintf(buffer, "%d", $1);
		instr_add("AFC", "R0", buffer, "", &instr_count);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		printf("$$: %d\n", $$);
		instr_add("STORE", buffer, "R0", "", &instr_count);
	}
	| tSTRING
	{
		// XXX: disabled string checking
		/*if (!string_defined) {
			sprintf(buffer, "Strings must be assigned through definition\n");
			yyerror(buffer);
		}*/
		
		// Store pointer
		st_add("", STRING, depth);
		sprintf(buffer, "%d", st_get_pos());
		instr_add("AFC", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", st_get_pos() - 1);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		$$ = st_get_pos() - 1;
		
		char str[64];
		sprintf(str, "%s", $1);
		printf("<<<<string: %s len=%d\n", str, strlen(str));
		
		// Store string char by char into memory and into symbol table
		int i;
		char c[1];
		printf("Saving string...\n");
		for (i = 1; i < strlen(str); i++) {
			printf("i=%d\n", i);
			if (i == strlen(str) - 1)
				c[0] = '\0';
			else
				c[0] = str[i];
			
			sprintf(buffer, "%d", c[0]);
			instr_add("AFC", "R0", buffer, "", &instr_count);
			
			// Add byte to symbol table
			st_add("", INTEGER, depth);
			int pos = st_get_pos() - 1;
			sprintf(buffer, "%d", pos);
			instr_add("STORE", buffer, "R0", "", &instr_count);
		}
	}
	| tMINUS tNUMBER %prec tNEG
	{
		sprintf(buffer, "%d", $2);
		instr_add("AFC", "R0", buffer, "", &instr_count);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		instr_add("AFC", "R1", "0", "", &instr_count);
		instr_add("SOU", "R0", "R1", "R0", &instr_count);
		sprintf(buffer, "%d", $$);
		instr_add("STORE", buffer, "R0", "", &instr_count);
	}
	| tADDRESS tID
	{
		sprintf(buffer, "%d", st_get($2));
		instr_add("AFC", "R0", buffer, "", &instr_count);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		printf("$$: %d\n", $$);
		instr_add("STORE", buffer, "R0", "", &instr_count);
	}
	| tID
	{
		sprintf(buffer, "%d", st_get($1));
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		instr_add("STORE", buffer, "R0", "", &instr_count);
	}
	| Expr tPLUS Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		instr_add("ADD", "R0", "R0", "R1", &instr_count);
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		// liberer une variable tmp (decrementer l'indice dans table des symboles)
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tMINUS Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		instr_add("SOU", "R0", "R0", "R1", &instr_count);
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tMULTIPLY Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		instr_add("MUL", "R0", "R0", "R1", &instr_count);
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tDIVIDE Expr
	{
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		instr_add("DIV", "R0", "R0", "R1", &instr_count);
		sprintf(buffer, "%d", $1);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $1;
	}
	| Expr tGT Expr
	{
		printf("Condition GT\n");
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R2", buffer, "", &instr_count);
		instr_add("SUP", "R0", "R1", "R2", &instr_count);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $3;
	}
	| Expr tGTE Expr
	{
		printf("Condition GTE\n");
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R2", buffer, "", &instr_count);
		instr_add("SUPE", "R0", "R1", "R2", &instr_count);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $3;
	}
	| Expr tLT Expr
	{
		printf("Condition LT\n");
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R2", buffer, "", &instr_count);
		instr_add("INF", "R0", "R1", "R2", &instr_count);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $3;
	}
	| Expr tLTE Expr
	{
		printf("Condition LTE\n");
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R2", buffer, "", &instr_count);
		instr_add("INFE", "R0", "R1", "R2", &instr_count);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $3;
	}
	| Expr tEQUALITY Expr
	{
		printf("Condition EQU\n");
		sprintf(buffer, "%d", $1);
		instr_add("LOAD", "R1", buffer, "", &instr_count);
		sprintf(buffer, "%d", $3);
		instr_add("LOAD", "R2", buffer, "", &instr_count);
		instr_add("EQU", "R0", "R1", "R2", &instr_count);
		instr_add("STORE", buffer, "R0", "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		$$ = $3;
	}
	| tMULTIPLY Expr
	{
		printf("Dereference right!!!!\n");
		// Load result of expression
		sprintf(buffer, "%d", $2);
		instr_add("LOAD", "R0", buffer, "", &instr_count);
		st_set_pos(st_get_pos() - 1);
		
		// Get targeted value
		instr_add("LOADI", "R0", "R0", "", &instr_count);
		
		// Save to stack
		st_add("", INTEGER, depth);
		$$ = st_get_pos() - 1;
		sprintf(buffer, "%d", $$);
		instr_add("STORE", buffer, "R0", "", &instr_count);
	};

%%

extern int yydebug;

int main()
{
	#if YYDEBUG
		yydebug = 1;
	#endif
	

	yyparse();
	
	printf("\n");
	instr_print();
	instr_to_file("./instr_sample.txt");
}

void yyerror(char *msg)
{
	printf("Error: %s\n", msg);
	exit(-1);
}
