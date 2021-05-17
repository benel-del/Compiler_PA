#ifndef _TACLIB_H_
#define _TACLIB_H_

#include "ast.h"

typedef struct labelStack_t LABELSTACK;
typedef struct TAC_t TAC;

void genTAC(TAC* tac, ASTNode *node);
void generate(ASTNode* root, char* filename);

char* getLabel(void);
char* getTmp(void);
char* makePointer(char* id);

LABELSTACK *initLabelStack(void);
void delLabelStack(LABELSTACK *ls);
void pushLabel(LABELSTACK *ls, char *label);
char* popLabel(LABELSTACK *ls);
char* topLabel(LABELSTACK *ls);

TAC* initTAC(void);
void delTAC(TAC* tac);

char* emit(TAC* tac, const char* s, ...);
void printTAC(TAC* tac, FILE* fp);

#endif