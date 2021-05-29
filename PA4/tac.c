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
        if(getTkNum(arg) == _INTEGER)
                emit(tac, "PushParam %d", getIVal(arg));
        else if(getTkNum(arg) == _ARRAY)
                emit(tac, "PushParam %s", makePointer(getName(arg)));
        else
                emit(tac, "PushParam %n", arg);
}
void foo(TAC* tac, ASTNode* args){
        argCnt = 0;
        bar(tac, getChild(args));
}
void generate(ASTNode* root, char* filename){
        int len;
        char *tacfile = 0;
        FILE *fp;
        TAC* tac = initTAC();

        for(len=0;filename[len];len++);
        tacfile = (char*)malloc(len+1);
        tacfile[len--] = '\0';
        tacfile[len--] = 't';
        for(;len>=0;len--)      tacfile[len] = filename[len];
        fp = fopen(tacfile, "w");

        checkSymbols(root);
        ls = initLabelStack();
        genTAC(tac, root);

        printTAC(tac, fp);      // If you want to see TAC, use stdout instead of fp
        fclose(fp);
        free(tacfile);
        delLabelStack(ls);
        delTAC(tac);
        return;
}
void genTAC(TAC* tac, ASTNode* node){
        int enterChildNode = 1, i = 0;
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
                        emit(tac, "%s:", getSVal(getSibling(l)));
                        emit(tac, "BeginFunc");
                        genTAC(tac, r);
                }
                enterChildNode = 0;
                break;
        case _ID:       // x
                break;
        case _ARRAY:    // x
                break;
        case _TYPE:
                break;
        case _PARAMS:
                break;
        case _PARAM:
                break;
        case _CPNDSTMT: // o
                if(r = getSibling(getChild(node)))     // _STMTLIST
                        genTAC(tac, r);
                enterChildNode = 0;     // LDECLIST
                break;
        case _LDECLIST: // x
                break;
        case _STMTLIST: // x
                break;
        case _EXPRSTMT:
                break;
        case _IFSTMT:   // o
                L[0] = getLabel();
                l = getChild(node), m = getSibling(l), r = getSibling(m);
                pushLabel(ls, L[0]);

                genTAC(tac, l);
                emit(tac, "IFZ %n Goto %s", l, L[0]);
                genTAC(tac, m);
                
                if(r){
                        L[1] = getLabel();
                        emit(tac, "Goto %s", L[1]);
                }
                emit(tac, "%s:", L[0]);
                if(r){
                        pushLabel(ls, L[1]);
                        genTAC(tac, r);
                        emit(tac, "%s:", L[1]);
                        popLabel(ls);
                }
                popLabel(ls);
                enterChildNode = 0;
                break;
        case _SWSTMT:   // o
                m = getChild(node);
                genTAC(tac, m); // switch(exp)
                L[0] = getName(m);

                m = getSibling(m);      // case1
                for(l = getSibling(m), i = 1; getSibling(l); l = getSibling(l), i++){
                        L[i] = getLabel();
                        r = makeASTNodeTYPE(NO_TYPE);
                        setName(r, getTmp());
                        genTAC(tac, getChild(l));
                        emit(tac, "%n = %s != %n", r, L[0], getChild(l));
                        emit(tac, "IFZ %n Goto %s", r, L[i]);
                }
                L[i] = getLabel();
                r = makeASTNodeTYPE(NO_TYPE);
                setName(r, getTmp());
                genTAC(tac, getChild(m));
                emit(tac, "%n = %s == %n", r, L[0], getChild(m));
                emit(tac, "IFZ %n Goto %s", r, L[i]);

                l = m;
                genTAC(tac, l);
                for(int j = 1; l && j <= i; j++){
                        emit(tac, "%s: ", L[j]);
                        l = getSibling(l);
                        genTAC(tac, l);
                }
                enterChildNode = 0;
                break;
        case _RTSTMT:   // o
                l = getChild(node);
                if(l){
                        if(getTkNum(l) == _INTEGER)
                                emit(tac, "Return %d", getIVal(l));
                        else
                                emit(tac, "Return %n", l);
                }
                else{
                        emit(tac, "Return");
                }
                enterChildNode = 0;
                break;
        case _BRKSTMT:  // o
                emit(tac, "Goto %s", topLabel(ls));
                break;
        case _WHLSTMT:  // o
                L[0] = getLabel(), L[1] = getLabel();
                l = getChild(node), r = getSibling(l);
                emit(tac, "%s:", L[0]);
                pushLabel(ls, L[1]);

                genTAC(tac, l);
                emit(tac, "IFZ %n Goto %s", l, L[1]);

                genTAC(tac, r);
                emit(tac, "Goto %s", L[0]);
                emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _DOWHLSTMT:        // ?
                L[0] = getLabel(), L[1] = getLabel(), L[2] = getLabel();
                emit(tac, "%s:", L[0]);
                pushLabel(ls, L[0]);
                pushLabel(ls, L[1]);
                pushLabel(ls, L[2]);

                l = getChild(node), r = getSibling(l);
                genTAC(tac, l);
                //emit(tac, "Goto %s", L[2]);
                emit(tac,"%s:", L[2]);

                popLabel(ls);
                genTAC(tac, r); // exp
                emit(tac, "IFZ %n Goto %s", r, popLabel(ls));
                emit(tac, "Goto %s", popLabel(ls));

                //printf(":::%s\n", L[1]);
                emit(tac,"%s:", L[1]);
                //popLabel(ls);
                enterChildNode = 0;
                break;
        case _FORSTMT:  // o
                L[0] = getLabel(), L[1] = getLabel();
                l = getChild(node), m = getSibling(l), r = getSibling(m);
                genTAC(tac, l);
                emit(tac, "%s:", L[0]);

                genTAC(tac, m);
                emit(tac, "IFZ %n Goto %s", m, L[1]);
                pushLabel(ls, L[1]);

                genTAC(tac, getSibling(r));     // _CPNDSTMT
                genTAC(tac, r);
                emit(tac, "Goto %s", L[0]);
                emit(tac, "%s:", popLabel(ls));
                enterChildNode = 0;
                break;
        case _CASE:     // o
                l = getChild(node), r = getSibling(l);
                genTAC(tac, r);
                enterChildNode = 0;
                break;
        case _DEFAULT:  // o
                genTAC(tac, getChild(node));
                enterChildNode = 0;
                break;
        case _INCDECEXP:        // ?
                l = getChild(node), r = getSibling(l);
                if(getTkNum(r) == _ID){   // 전위 증감자 ++id
                        if(getTkNum(r) == _ARRAY)
                                L[0] = makePointer(getName(r));
                        else
                                L[0] = getName(r);
                        if(getOperator(l) == INC_){
                                emit(tac, "%s = %s + %d", L[0], L[0], 1);
                        }
                        else if(getOperator(l) == DEC_){
                                emit(tac, "%s = %s - %d", L[0], L[0], 1);
                        }
                        setName(node, getName(r));
                }
                else if(getTkNum(l) == _ID){   // 후위 증감자 id++
                        setName(node, getTmp());
                        if(getTkNum(l) == _ARRAY)
                                L[0] = makePointer(getName(l));
                        else
                                L[0] = getName(l);
                        emit(tac, "%n = %s", node, L[0]);
                        if(getOperator(r) == INC_){
                                emit(tac, "%s = %s + %d", L[0], L[0], 1);
                        }
                        else if(getOperator(r) == DEC_){
                                emit(tac, "%s = %s - %d", L[0], L[0], 1);
                        }
                }
                enterChildNode = 0;
                break;
        case _OPER:     // x
                break;
        case _INTEGER:  // ???
                sprintf(temp, "%d", getIVal(node));
                setName(node, temp);
                break;
        case _REAL:     // x
                break;
        case _ARGS:     // x
                break;
        case _FUNCCALL: // o
                l = getChild(node), r = getSibling(l);
                foo(tac, r);
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
                        emit(tac, "EndFunc");
                }
                break;
        case _ID:
                break;
        case _ARRAY:    // o
                l = getChild(node), r = getSibling(l);
                m = makeASTNodeTYPE(NO_TYPE);
                setName(m, getTmp());
                emit(tac, "%n = %n * %d", m, r, 4);
                setName(node, getTmp());
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
                        L[0] = makePointer(getName(l));
                else
                        L[0] = getName(l);
                if(getTkNum(r) == _ARRAY)
                        L[1] = makePointer(getName(r));
                else
                        L[1] = getName(r);
                switch(getOperator(node)){
                case PLUS_:
                        emit(tac, "%n = %s + %s", node, L[0], L[1]);
                        break;
                case MINUS_:
                        emit(tac, "%n = %s - %s", node, L[0], L[1]);
                        break;
                case MULT_:
                        emit(tac, "%n = %s * %s", node, L[0], L[1]);
                        break;
                case DIV_:
                        emit(tac, "%n = %s / %s", node, L[0], L[1]);
                        break;
                case MOD_:
                        emit(tac, "%n = %s %% %s", node, L[0], L[1]);
                        break;
                case EQ_:
                        emit(tac, "%n = %s == %s", node, L[0], L[1]);
                        break;
                case NE_:
                        emit(tac, "%n = %s != %s", node, L[0], L[1]);
                        break;
                case GT_:
                        emit(tac, "%n = %s > %s", node, L[0], L[1]);
                        break;
                case LT_:
                        emit(tac, "%n = %s < %s", node, L[0], L[1]);
                        break;
                case GE_:
                        emit(tac, "%n = %s >= %s", node, L[0], L[1]);
                        break;
                case LE_:
                        emit(tac, "%n = %s <= %s", node, L[0], L[1]);
                        break;
                case AND_:
                        emit(tac, "%n = %s && %s", node, L[0], L[1]);
                        break;
                case OR_:
                        emit(tac, "%n = %s || %s", node, L[0], L[1]);
                        break;
                case ASSIGN_:
                        emit(tac, "%s = %s", L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
                        break;
                case ADDASSIGN_:
                        emit(tac, "%s = %s + %s", L[0], L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
                        break;
                case SUBASSIGN_:
                        emit(tac, "%s = %s - %s", L[0], L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
                        break;
                case MULTASSIGN_:
                        emit(tac, "%s = %s * %s", L[0], L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
                        break;
                case DIVASSIGN_:
                        emit(tac, "%s = %s / %s", L[0], L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
                        break;
                case MODASSIGN_:
                        emit(tac, "%s = %s %% %s", L[0], L[0], L[1]);
                        emit(tac, "%n = %s", node, L[0]);
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
                emit(tac, "%n = LCall %n", node, l);
                emit(tac, "PopParam %d", argCnt * 4);
                break;
        }
}
