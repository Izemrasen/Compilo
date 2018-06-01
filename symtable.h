#define TABLE_SIZE 1024
#define SYMBOL_NOT_FOUND -1
#define EMPTY_SYMBOL ""

typedef enum Type {INTEGER, CHAR} Type;

// TODO: opti (bit fields)
typedef struct Symbol
{
	char *id;
	Type type;
	char initialized;
	char depth; 
} Symbol;

void st_print();
void st_add(char *id, Type type, char depth);
int st_get(char *id);
void st_init(char *id);
char st_is_init(char *id);
int st_get_pos();
void st_set_pos(int position_new);
void st_rm(char *id);
void st_rm_block(int depth);
