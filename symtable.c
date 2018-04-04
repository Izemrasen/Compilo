#include "symtable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define NOT_FOUND -1

Entry table[TABLE_SIZE];
char position = 0;

// TODO: upd initialized
// TODO: rm_entry() (+ free(id))

void st_print_e(Entry entry)
{
	printf("%s\t%d\t%d\t%d\n", entry.id, entry.type, entry.initialized,
		entry.depth);
}

void st_print()
{
	char i;
	printf("Table: \n");
	for (i = 0; i < position; i++) {
		printf("%d\t", i);
		st_print_e(table[i]);
	}
}

void st_add(char *id, Type type, char depth)
{
	Entry *e = malloc(sizeof(*e));
	e->id = id;
	e->type = type;
	e->initialized = 0;
	e->depth = depth;
	if (position >= TABLE_SIZE)
		return;
	table[position] = *e;
	position++;
}

int st_get(char *id)
{
	char i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0) {
			//Entry *entry = malloc(sizeof(Entry));
			//*entry = table[i];
			return i;
		}
	}
	return NOT_FOUND;
}

void st_init(char *id)
{
	char i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0) {
			table[i].initialized = 1;
			return;
		}
	}
}

char st_is_init(char *id)
{
	char i;
	for (i = 0; i < position; i++) {
		if (strcmp(id, table[i].id) == 0)
			return table[i].initialized;
	}
}

char st_get_pos()
{
	return position;
}

void st_set_pos(char position_new)
{
	position = position_new;
}

/*
int main()
{
	print_table();
	add_entry("michou", INTEGER, 0);
	print_table();
	Entry *pe2 = get_entry("michou");
}*/
