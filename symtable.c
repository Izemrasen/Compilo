#include "symtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

Symbol table[TABLE_SIZE];
int position = 0;

// TODO: upd initialized
// TODO: overwrite removed symbols

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

// TODO: make sure symbol not already in table?
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

// Return symbol index
int st_get(char *id)
{
	if (strcmp(id, "") != 0) {
		int i;
		for (i = 0; i < position; i++) {
			if (strcmp(id, table[i].id) == 0) {
				//Symbol *symbol = malloc(sizeof(Symbol));
				//*symbol = table[i];
				return i;
			}
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
		table[i].id = "";
}

/*
int main()
{
	st_print();
	st_add("michou", INTEGER, 0);
	st_add("michou2", INTEGER, 1);
	st_print();
	int index = st_get("michou");
	printf("michou=%d\n", table[index].depth);
	st_rm("michou");
	st_print();
	printf("%d\n", st_get("michou"));
}
*/