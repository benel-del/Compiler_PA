#include <stdio.h>
#include <stdlib.h>
#include "taclib.h"

LABELSTACK* ls;

void generate(ASTNode* root, char* filename){
        checkSymbols(root);
        TAC* tac = initTAC();
        ls = initLabelStack();
        genTAC(tac, root);
//      printTAC(tac);
        delTAC(tac);
        return;
}
void genTAC(TAC* tac, ASTNode* node){
        int enterChildNode = 1;
        if(!tac)        return;
        if(!node)       return;

        // For Preorder Traversal
        switch(getTkNum(node)){
        case _PROG:
                break;
        case _VARDEC:
                break;
        case _FUNCDEC:
                break;
        case _ID:
                break;
        case _ARRAY:
                break;
        case _TYPE:
                break;
        case _PARAMS:
                break;
        case _PARAM:
                break;
        case _CPNDSTMT:
                break;
        case _LDECLIST:
                break;
        case _STMTLIST:
                break;
        case _EXPRSTMT:
                break;
        case _IFSTMT:
                break;
        case _SWSTMT:
                break;
        case _RTSTMT:
                break;
        case _BRKSTMT:
                break;
        case _WHLSTMT:
                break;
        case _DOWHLSTMT:
                break;
        case _FORSTMT:
                break;
        case _CASE:
                break;
        case _DEFAULT:
                break;
        case _INCDECEXP:
                break;
        case _OPER:
                break;
        case _INTEGER:
                break;
        case _REAL:
                break;
        case _ARGS:
                break;
        case _FUNCCALL:
                break;
        }

        if(enterChildNode){
                ASTNode *c = getChild(node);
                while(c){
                        genTAC(tac, c);
                        c = getSibling(c);
                }
        }
        // For Postorder Traversal
        switch(getTkNum(node)){
        case _PROG:
                break;
        case _VARDEC:
                break;
        case _FUNCDEC:
                break;
        case _ID:
                break;
        case _ARRAY:
                break;
        case _TYPE:
                break;
        case _PARAMS:
                break;
        case _PARAM:
                break;
        case _CPNDSTMT:
                break;
        case _LDECLIST:
                break;
        case _STMTLIST:
                break;
        case _EXPRSTMT:
                break;
        case _IFSTMT:
                break;
        case _SWSTMT:
                break;
        case _RTSTMT:
                break;
        case _BRKSTMT:
                break;
        case _WHLSTMT:
                break;
        case _DOWHLSTMT:
                break;
        case _FORSTMT:
                break;
        case _CASE:
                break;
        case _DEFAULT:
                break;
        case _INCDECEXP:
                break;
        case _OPER:
                break;
        case _INTEGER:
                break;
        case _REAL:
                break;
        case _ARGS:
                break;
        case _FUNCCALL:
                break;
        }
}
