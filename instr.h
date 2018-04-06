#define NO_INSTR 1024
#define INSTR_NOT_FOUND -1

// TODO: opti (bit fields)
typedef struct Instruction
{
	char *op;
	char *a;
	char *b;
	char *c;
} Instruction;

void instr_print();
void instr_add(char *op, char *a, char *b, char *c);
Instruction instr_get(int offset); // Stack-like
void instr_set(int offset, Instruction instr);
