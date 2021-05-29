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
        if(getTkNum(arg) == _INTEGER){
                printf("PushParam %d\n", getIVal(arg));
                emit(tac, "PushParam %d", getIVal(arg));
        }
        else{
                printf("PushParam %s\n", getName(arg));
                emit(tac, "PushParam %n", arg);
        }
}
void foo(TAC* tac, ASTNode* args){
        argCnt = 0;
        bar(tac, getChild(args));
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
        char *L[20];
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
                        //printf("BeginFunc\n");
                        emit(tac, "BeginFunc");
                        genTAC(tac, r);
                }
                enterChildNode = 0;
                break;
        case _ID:       // ?
                //setName(node, getSVal(node));
                break;
        case _ARRAY:    // x
                break;
        case _TYPE:
                break;
        case _PARAMS:
                break;
        case _PARAM:
                //setName(node, getTmp());
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
                l = getChild(node), m = getSibling(l), r = getSibling(m);
                pushLabel(ls, L0);

                genTAC(tac, l);
                printf("IFZ %s Goto %s\n", getName(l), L0);
                emit(tac, "IFZ %n Goto %s", l, L0);
                genTAC(tac, m);
                
                if(r){
                        L1 = getLabel();
                        printf("Goto %s\n", L1);
                        emit(tac, "Goto %s", L1);
                }
                printf("%s: \n", L0);
                emit(tac, "%s:", L0);
                if(r){
                        pushLabel(ls, L1);
                        genTAC(tac, r);
                        printf("%s:\n", L1);
                        emit(tac, "%s:", L1);
                        popLabel(ls);
                }
                enterChildNode = 0;
                break;
        case _SWSTMT:   // ?
                L0 = getLabel();
                pushLabel(ls, L0);
                m = getChild(node);
                genTAC(tac, m); // switch(exp)

                for(l = getSibling(m); getSibling(l); l = getSibling(l)){
                        L1 = getLabel(ls);
                        r = makeASTNodeTYPE(NO_TYPE);
                        if(getTkNum(getSibling(l)) != _DEFAULT)
                                emit(tac, "%n = %n != %n", r, m, getChild(l));
                        else
                                emit(tac, "%n = %n == %n", r, m, getChild(l));
                        emit(tac, "IFZ %n Goto %s", r, L1);
                }

                l = getSibling(m);
                do{
                        genTAC(tac, l);
                        emit(tac, "%s: ", );
                }while(l = getSibling(l));


                break;
        case _RTSTMT:   // o
                l = getChild(node);
                if(l){
                        if(getTkNum(l) == _INTEGER){
                                printf("return %d\n", getIVal(l));
                                emit(tac, "Return %d", getIVal(l));
                        }
                        else{
                                printf("return %s\n", getName(l));
                                emit(tac, "Return %n", l);
                        }
                }
                else{
                        printf("return\n");
                        emit(tac, "Return");
                }
                enterChildNode = 0;
                break;
        case _BRKSTMT:  // o
                printf("Goto %s\n", topLabel(ls));
                emit(tac, "Goto %s", topLabel(ls));
                break;
        case _WHLSTMT:  // o
                L0 = getLabel(), L1 = getLabel();
                l = getChild(node), r = getSibling(l);
                printf("%s:\n", L0);
                emit(tac, "%s:", L0);
                pushLabel(ls, L1);

                genTAC(tac, l);
                printf("IFZ %s Goto %s\n", getName(l), L1);
                emit(tac, "IFZ %n Goto %s", l, L1);

                genTAC(tac, r);
                printf("Goto %s\n", L0);
                emit(tac, "Goto %s", L0);
                printf("%s:\n", topLabel(ls));
                emit(tac, "%s:", topLabel(ls));

                // printf("Goto %s\n", L2);
                emit(tac, "Goto %s", L2);
                // printf("%s:\n", topLabel(ls));
                // emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _DOWHLSTMT:        // ?
                L0 = getLabel(), L1 = getLabel(), L2 = getLabel();
                printf("%s:\n", L0);
                emit(tac, "%s:", L0);
                pushLabel(ls, L0);
                pushLabel(ls, L1);

                genTAC(tac, l);
                printf("Goto %s\n", L2);
                emit(tac, "Goto %s", L2);
                printf("%s:\n", L2);
                emit(tac,"%s:", L2);

                genTAC(tac, r);
                printf("IFZ %s Goto %s\n", getName(r), topLabel(ls));
                emit(tac, "IFZ %n Goto %s", r, popLabel(ls));
                printf("Goto %s\n", topLabel(ls));
                emit(tac, "Goto %s", popLabel(ls));
                enterChildNode = 0;
                break;
        case _FORSTMT:  // o
                L0 = getLabel(), L1 = getLabel();
                l = getChild(node), m = getSibling(l), r = getSibling(m);
                genTAC(tac, l);
                printf("%s:\n", L0);
                emit(tac, "%s:", L0);
                genTAC(tac, m);
                printf("IFZ %s Goto %s\n", getName(m), L1);
                emit(tac, "IFZ %n Goto %s", m, L1);
                pushLabel(ls, L1);

                genTAC(tac, getSibling(r));     // _CPNDSTMT
                genTAC(tac, r);
                printf("Goto %s\n", L0);
                emit(tac, "Goto %s", L0);
                printf("%s:\n", topLabel(ls));
                emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _CASE:     // o
                l = getChild(node), r = getSibling(l);
                genTAC(tac, r);
                enterChildNode = 0;
                break;
        case _DEFAULT:
                break;
        case _INCDECEXP:        // ?
                l = getChild(node), r = getSibling(l);
                if(getTkNum(r) == _ID){   // 전위 증감자 ++id
                        if(getTkNum(r) == _ARRAY)
                                L0 = makePointer(getName(r));
                        else
                                L0 = getName(r);
                        if(getOperator(l) == INC_){
                                printf("%s = %s + 1\n", L0, L0);
                                emit(tac, "%s = %s + %d", L0, L0, 1);
                        }
                        else if(getOperator(l) == DEC_){
                                printf("%s = %s - 1\n", L0, L0);
                                emit(tac, "%s = %s - %d", L0, L0, 1);
                        }
                        setName(node, getName(r));
                }
                else if(getTkNum(l) == _ID){   // 후위 증감자 id++
                        setName(node, getTmp());
                        if(getTkNum(l) == _ARRAY)
                                L0 = makePointer(getName(l));
                        else
                                L0 = getName(l);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        if(getOperator(r) == INC_){
                                printf("%s = %s + 1\n", L0, L0);
                                emit(tac, "%s = %s + %d", L0, L0, 1);
                        }
                        else if(getOperator(r) == DEC_){
                                printf("%s = %s - 1\n", getName(l), getName(l));
                                emit(tac, "%s = %s - %d", L0, L0, 1);
                        }
                }
                enterChildNode = 0;
                break;
        case _OPER:     // ?
                break;
        case _INTEGER:  // ???
                sprintf(temp, "%d", getIVal(node));
                setName(node, temp);
                break;
        case _REAL:     // x
                break;
        case _ARGS:     // x
                break;
        case _FUNCCALL: // ?
                l = getChild(node), r = getSibling(l);
                foo(tac, r);
                //genTAC(tac, getSibling(getChild(node)));        // r
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
                l = getChild(node);
                if(r = getSibling(getSibling(getSibling(l)))){      // _CPNDSTMT
                        printf("EndFunc\n");
                        emit(tac, "EndFunc");
                }
                break;
        case _ID:
                break;
        case _ARRAY:    // o
                l = getChild(node), r = getSibling(l);
                m = makeASTNodeTYPE(NO_TYPE);
                setName(m, getTmp());
                printf("%s = %s * %d\n", getName(m), getName(r), 4);
                emit(tac, "%n = %n * %d", m, r, 4);
                setName(node, getTmp());
                printf("%s = %s + %s\n", getName(node), getName(l), getName(m));
                emit(tac, "%n = %n + %n", node, l, m);
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
                if(getTkNum(l) == _ARRAY)
                        L0 = makePointer(getName(l));
                else
                        L0 = getName(l);
                if(getTkNum(r) == _ARRAY)
                        L1 = makePointer(getName(r));
                else
                        L1 = getName(r);
                switch(getOperator(node)){
                case PLUS_:
                        printf("%s = %s + %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s + %s", node, L0, L1);
                        break;
                case MINUS_:
                        printf("%s = %s - %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s - %s", node, L0, L1);
                        break;
                case MULT_:
                        printf("%s = %s * %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s * %s", node, L0, L1);
                        break;
                case DIV_:
                        printf("%s = %s / %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s / %s", node, L0, L1);
                        break;
                case MOD_:
                        printf("%s = %s %% %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s %% %s", node, L0, L1);
                        break;
                case EQ_:
                        printf("%s = %s == %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s == %s", node, L0, L1);
                        break;
                case NE_:
                        printf("%s = %s != %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s != %s", node, L0, L1);
                        break;
                case GT_:
                        printf("%s = %s > %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s > %s", node, L0, L1);
                        break;
                case LT_:
                        printf("%s = %s < %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s < %s", node, L0, L1);
                        break;
                case GE_:
                        printf("%s = %s >= %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s >= %s", node, L0, L1);
                        break;
                case LE_:
                        printf("%s = %s <= %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s <= %s", node, L0, L1);
                        break;
                case AND_:
                        printf("%s = %s && %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s && %s", node, L0, L1);
                        break;
                case OR_:
                        printf("%s = %s || %s\n", getName(node), L0, L1);
                        emit(tac, "%n = %s || %s", node, L0, L1);
                        break;
                case ASSIGN_:
                        printf("%s = %s\n", L0, L1);
                        emit(tac, "%s = %s", L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                case ADDASSIGN_:
                        printf("%s = %s + %s\n", L0, L0, L1);
                        emit(tac, "%s = %s + %s", L0, L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                case SUBASSIGN_:
                        printf("%s = %s - %s\n", L0, L0, L1);
                        emit(tac, "%s = %s - %s", L0, L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                case MULTASSIGN_:
                        printf("%s = %s * %s\n", L0, L0, L1);
                        emit(tac, "%s = %s * %s", L0, L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                case DIVASSIGN_:
                        printf("%s = %s / %s\n", L0, L0, L1);
                        emit(tac, "%s = %s / %s", L0, L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                case MODASSIGN_:
                        printf("%s = %s %% %s\n", L0, L0, L1);
                        emit(tac, "%s = %s %% %s", L0, L0, L1);
                        printf("%s = %s\n", getName(node), L0);
                        emit(tac, "%n = %s", node, L0);
                        break;
                }
                break;
        case _INTEGER:  // x
                break;
        case _REAL:     // x
                break;
        case _ARGS:     // x
                break;
        case _FUNCCALL: // o
                l = getChild(node);
                setName(node, getTmp());
                printf("%s = LCall %s\n", getName(node), getName(l));
                emit(tac, "%n = LCall %n", node, l);
                printf("PopParam %d\n", argCnt * 4);
                emit(tac, "PopParam %d", argCnt * 4);
                break;
        }
}
