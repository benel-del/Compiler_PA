#include <stdio.h>
#include <stdlib.h>
#include "taclib.h"

LABELSTACK* ls;

int argCnt = 0;
void bar(TAC* tac, ASTNode* arg){
        argCnt++;
        if(getSibling(arg))
                bar(tac, getSibling(arg));
        genTAC(tac, arg);
        emit(tac, "PushParam %n", arg);
}

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
        ASTNode *l, *r, *m;
        char *L0, *L1;
        char temp[10];
        if(!tac)        return;
        if(!node)       return;

        // For Preorder Traversal
        switch(getTkNum(node)){
        case _PROG:     // x
                break;
        case _VARDEC:   // o
                enterChildNode = 0;
                break;
        case _FUNCDEC:  // o
                l = getChild(node);
                if(r = getSibling(getSibling(getSibling(l)))){      // _CPNDSTMT
                        emit(tac, "BeginFunc");
                        genTAC(tac, r);
                }
                enterChildNode = 0;
                break;
        case _ID:       // ?
                //setName(node, getSVal(node));
                break;
        case _ARRAY:
                break;
        case _TYPE:
                break;
        case _PARAMS:
                break;
        case _PARAM:
                break;
        case _CPNDSTMT: // o
                if(r = getSibling(getChild(node))){     // _STMTLIST
                        genTAC(tac, r);
                }
                enterChildNode = 0;     // LDECLIST
                break;
        case _LDECLIST: // x
                break;
        case _STMTLIST: // x
                break;
        case _EXPRSTMT:
                break;
        case _IFSTMT:   // o
                L0 = getLabel();
                l = getChild(node), m = getSibling(l), r = getSibling(r);
                //pushLabel(ls, L0);

                genTAC(tac, l);
                emit(tac, "IFZ %n Goto %s", l, L0);
                genTAC(tac, m);
                if(r){
                        L1 = getLabel();
                        emit(tac, "Goto %s", L1);
                }
                emit(tac, "%s:", L0/*popLabel(ls)*/);
                if(r){
                        //pushLabel(ls, L1);
                        genTAC(tac, r);
                        emit(tac, "%s:", L1/*popLabel(ls)*/);
                }
                enterChildNode = 0;
                break;
        case _SWSTMT:
                break;
        case _RTSTMT:   // o
                l = getChild(node);
                if(l)
                        emit(tac, "Return %n", l);
                else
                        emit(tac, "Return");
                enterChildNode = 0;
                break;
        case _BRKSTMT:  // o
                emit(tac, "Goto %s", topLabel(ls));
                break;
        case _WHLSTMT:  // o
                L0 = getLabel(), L1 = getLabel();
                l = getChild(node), r = getSibling(l);
                emit(tac, "%s:", L0);
                pushLabel(ls, L1);

                genTAC(tac, l);
                emit(tac, "IFZ %n Goto %s", l, L1);

                genTAC(tac, r);
                emit(tac, "Goto %s", L0);
                emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _DOWHLSTMT:
                break;
        case _FORSTMT:  // o
                L0 = getLabel(), L1 = getLabel();
                l = getChild(node), m = getSibling(l), r = getSibling(m);
                genTAC(tac, l);
                emit(tac, "%s:", L0);
                genTAC(tac, m);
                emit(tac, "IFZ %n Goto %s", m, L1);
                pushLabel(ls, L1);

                genTAC(tac, getSibling(r));     // _CPNDSTMT
                genTAC(tac, r);
                emit(tac, "Goto %s", L0);
                emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _CASE:
                break;
        case _DEFAULT:
                break;
        case _INCDECEXP:        // o
                setName(node, getTmp());
                l = getChild(node), r = getSibling(l);
                if(getTkNum(l) == _OPER){   // operator:: 전위 증감자
                        if(getOperator(l) == INC_)
                                emit(tac, "%n = %n + 1", r, r);
                        else if(getOperator(l) == DEC_)
                                emit(tac, "%n = %n - 1", r, r);
                }
                else if(getTkNum(r) == _OPER){   // 후위 증감자
                        emit(tac, "%n = %n", node, l);
                        if(getOperator(r) == INC_)
                                emit(tac, "%n = %n + 1", l, l);
                        else if(getOperator(r) == DEC_)
                                emit(tac, "%n = %n - 1", l, l);
                }
                enterChildNode = 0;
                break;
        case _OPER:     // x
                break;
        case _INTEGER:  // o
                sprintf(temp, "%d", getIVal(node));     // ???
                setName(node, temp);
                break;
        case _REAL:     // x
                break;
        case _ARGS:     // o
                argCnt = 0;
                bar(tac, getChild(node));
                enterChildNode = 0;
                break;
        case _FUNCCALL: // o
                genTAC(tac, getSibling(getChild(node)));        // r
                enterChildNode = 0;
                break;
        }

        if(enterChildNode){
                l = getChild(node);
                while(l){
                        genTAC(tac, l);
                        l = getSibling(l);
                }
        }

        // For Postorder Traversal
        switch(getTkNum(node)){
        case _PROG:     // x
                break;
        case _VARDEC:
                break;
        case _FUNCDEC:  // o
                emit(tac, "EndFunc");
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
        case _CPNDSTMT: // x
                break;
        case _LDECLIST: // x
                break;
        case _STMTLIST: // x
                break;
        case _EXPRSTMT:
                break;
        case _IFSTMT:   // x
                break;
        case _SWSTMT:
                break;
        case _RTSTMT:   // x
                break;
        case _BRKSTMT:  // x
                break;
        case _WHLSTMT:  // x
                break;
        case _DOWHLSTMT:        // x
                break;
        case _FORSTMT:  // x
                break;
        case _CASE:
                break;
        case _DEFAULT:
                break;
        case _INCDECEXP:        // x
                break;
        case _OPER:     // o
                setName(node, getTmp());
                l = getChild(node), r = getSibling(l);
                switch(getOperator(node)){
                case PLUS_:
                        emit(tac, "%n = %n + %n", node, l, r);
                        break;
                case MINUS_:
                        emit(tac, "%n = %n - %n", node, l, r);
                        break;
                case MULT_:
                        emit(tac, "%n = %n * %n", node, l, r);
                        break;
                case DIV_:
                        emit(tac, "%n = %n / %n", node, l, r);
                        break;
                case MOD_:
                        emit(tac, "%n = %n %% %n", node, l, r);
                        break;
                case EQ_:
                        emit(tac, "%n = %n == %n", node, l, r);
                        break;
                case NE_:
                        emit(tac, "%n = %n != %n", node, l, r);
                        break;
                case GT_:
                        emit(tac, "%n = %n > %n", node, l, r);
                        break;
                case LT_:
                        emit(tac, "%n = %n < %n", node, l, r);
                        break;
                case GE_:
                        emit(tac, "%n = %n >= %n", node, l, r);
                        break;
                case LE_:
                        emit(tac, "%n = %n <= %n", node, l, r);
                        break;
                case AND_:
                        emit(tac, "%n = %n && %n", node, l, r);
                        break;
                case OR_:
                        emit(tac, "%n = %n || %n", node, l, r);
                        break;
                case ASSIGN_:
                        emit(tac, "%n = %n", l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                case ADDASSIGN_:
                        emit(tac, "%n = %n + %n", l, l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                case SUBASSIGN_:
                        emit(tac, "%n = %n - %n", l, l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                case MULTASSIGN_:
                        emit(tac, "%n = %n * %n", l, l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                case DIVASSIGN_:
                        emit(tac, "%n = %n / %n", l, l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                case MODASSIGN_:
                        emit(tac, "%n = %n %% %n", l, l, r);
                        emit(tac, "%n = %n", node, l);
                        break;
                }
                break;
        case _INTEGER:  // x
                break;
        case _REAL:     // x
                break;
        case _ARGS:     // x
                break;
        case _FUNCCALL:
                setName(node, getTmp());
                emit(tac, "%n = LCALL %n", node, getChild(node));
                emit(tac, "PopParam %d", argCnt * 4);
                break;
        }
}
