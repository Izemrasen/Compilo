#define TABLE_SIZE 1024

typedef enum Type {INTEGER, CHAR} Type;

// TODO: opti (bit fields)
typedef struct Entry
{
	char *id;
	Type type;
	char initialized;
	char depth; 
} Entry;

void st_print();
void st_add(char *id, Type type, char depth);
int st_get(char *id);
void st_init(char *id);
char st_is_init(char *id);
char st_get_pos();
void st_set_pos(char position_new);
