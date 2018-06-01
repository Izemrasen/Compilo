#include "symtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

Symbol table[TABLE_SIZE];
int position = 0;

// TODO: handle flag "initialized"
// error msg if whaaaat???

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
	printf("Adding symbol '%s' @%d...\n", id, position);
	
	// Make sure symbol doesn't exist in an upper block (smaller depth)
	// If a symbol exists in a lower block, overwrite it
	int i = st_get(id);
	if (i != SYMBOL_NOT_FOUND && table[i].depth <= depth) {
		printf("Error: symbol '%s' already exists!\n", id);
		return;
	}
	
	// TODO: useless memory leak (malloc for symbols) => no allocation: directly write to table[]
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

// Return symbol index
int st_get(char *id)
{
	if (strcmp(id, EMPTY_SYMBOL) != 0) {
		int i;
		for (i = 0; i < position; i++) {
			if (strcmp(id, table[i].id) == 0)
				return i;
		}
	}
	return SYMBOL_NOT_FOUND;
}

void st_init(char *id)
{
	int i = st_get(id);
	table[i].initialized = 1;
}

char st_is_init(char *id)
{
	int i = st_get(id);
	return table[i].initialized;
}

int st_get_pos()
{
	return position;
}

void st_set_pos(int position_new)
{
	position = position_new;
}

void st_rm(char *id)
{
	int i = st_get(id);
	//free(table[i]);
	if (i == position - 1)
		position--;
	else
		table[i].id = EMPTY_SYMBOL;
}

void st_rm_block(int depth)
{
	printf("Removing symbols @depth=%d...\n", depth);
	int i;
	for (i = 0; i < position; i++) {
		if (table[i].depth == depth)
			st_rm(table[i].id);
	}
}
/*
int main()
{
	st_print();
	st_add("michou", INTEGER, 0);
	st_add("michou1", CHAR, 1);
	st_print();
	st_add("michou1", INTEGER, 0);
	st_print();
/*	int index = st_get("michou");
	printf("michou=%d\n", table[index].depth);
	st_rm("michou");
	st_print();
	printf("%d\n", st_get("michou"));
}
*/