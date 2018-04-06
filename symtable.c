#include "symtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

Symbol table[TABLE_SIZE];
int position = 0;

// TODO: upd initialized
// TODO: rm_symbol() (+ free(id))

void st_print_s(Symbol symbol)
{
	printf("%s\t%d\t%d\t%d\n", symbol.id, symbol.type, symbol.initialized,
		symbol.depth);
}

void st_print()
{
	int i;
	printf("Table: \n");
	for (i = 0; i < position; i++) {
		printf("%d\t", i);
		st_print_s(table[i]);
	}
}

void st_add(char *id, Type type, char depth)
{
	Symbol *s = malloc(sizeof(*s));
	s->id = id;
	s->type = type;
	s->initialized = 0;
	s->depth = depth;
	if (position >= TABLE_SIZE)
		return;
	table[position] = *s;
	position++;
}

int st_get(char *id)
{
	int i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0) {
			//Symbol *symbol = malloc(sizeof(Symbol));
			//*symbol = table[i];
			return i;
		}
	}
	return SYMBOL_NOT_FOUND;
}

void st_init(char *id)
{
	int i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0) {
			table[i].initialized = 1;
			return;
		}
	}
}

char st_is_init(char *id)
{
	int i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0)
			return table[i].initialized;
	}
}

int st_get_pos()
{
	return position;
}

void st_set_pos(int position_new)
{
	position = position_new;
}

/*
int main()
{
	print_table();
	add_symbol("michou", INTEGER, 0);
	print_table();
	Symbol *pe2 = get_symbol("michou");
}*/
