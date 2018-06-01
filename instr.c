#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "instr.h"

Instruction instrs[NO_INSTR];
int instr_position = 0;

void instr_print()
{
	int i;
	printf("Instrs (%d): \n", instr_position);
	for (i = 0; i < instr_position; i++) {
		printf("%s\t%s\t%s\t%s", instrs[i].op, instrs[i].a, instrs[i].b,
			instrs[i].c);
		if (i < instr_position - 1)
			printf("\n");
	}
}

void instr_to_file(char *filename)
{
	FILE *f = fopen(filename, "w");
	if (f == NULL)
		return;
	
	int i;
	for (i = 0; i < instr_position; i++) {
		fprintf(f, "%s\t%s\t%s\t%s", instrs[i].op, instrs[i].a, instrs[i].b,
			instrs[i].c);
		if (i < instr_position - 1)
			fprintf(f, "\n");
	}
}


void instr_add(char *op, char *a, char *b, char *c, int *counter)
{
	Instruction i = {strdup(op), strdup(a), strdup(b), strdup(c)};
	//printf("ARTHOOOUUUUUUUR!!! (%d) '%s  '%s  '%s  '%s\n", instr_position, i.op, i.a, i.b, i.c);
	instrs[instr_position] = i;
	instr_position++;
	(*counter)++;
}

Instruction instr_get(int offset) // Stack-like
{
	Instruction i;
	if (instr_position - offset >= 0)
		i = instrs[instr_position - offset];
	return i;
}

void instr_set(int offset, Instruction instr)
{
	if (instr_position - offset >= 0)
		instrs[instr_position - offset] = instr;
}
