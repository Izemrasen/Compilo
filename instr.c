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
	printf("Instrs: \n");
	for (i = 0; i < instr_position; i++)
		printf("%s\t%s\t%s\t%s\n", instrs[i].op, instrs[i].a, instrs[i].b,
			instrs[i].c);
}

void instr_add(Instruction instr)
{
	instrs[instr_position] = instr;
	instr_position++;
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
