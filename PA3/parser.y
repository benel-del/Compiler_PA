%{
        #include <stdio.h>
        #include <stdlib.h>
        #include "ast.h"
        STACK *stack;
        int yylex(void);
        int yyerror(char* s);
%}
%union{
        int iVal;
        float rVal;
        char* sVal;
}

//
%token          TVOID TINT TFLOAT TCHAR TIF TELSE TSWITCH TCASE TDEFAULT TRETURN TBREAK TWHILE TDO TFOR
%token<sVal>    PM OP1 OP2 OR AND TIDENTIFIER TSTRING
%token<iVal>    TINTEGER
%token<rVal>    TREAL

%%

//
Program         : DecList       {
                        push(stack, setChild(makeASTNode(_PROG), pop(stack)));
                }
                ;
DecList         : DecList Dec   {
                        ASTNode *decList, *dec;
                        dec = pop(stack);
                        decList = pop(stack);
                        setLastSibling(decList, dec);
                        push(stack, decList);
                }
                | Dec           {}
                ;
Dec             : VarDec        {}
                | FuncDec       {}
                ;
FuncDec         : VarType TIDENTIFIER '(' Params ')' CpndStmt           {
                        ASTNode *type, *params, *cpnd, *funcDec = makeASTNode(_FUNCDEC), *id = makeASTNodeID($2);
                        cpnd = pop(stack);
                        params = pop(stack);
                        type = pop(stack);
                        setSibling(params, cpnd);
                        setSibling(id, params);
                        setSibling(type, id);
                        setChild(funcDec, type);
                        push(stack, funcDec);
                }
                | VarType TIDENTIFIER '(' Params ')' ';'                {
                        ASTNode *type, *params, *funcDec = makeASTNode(_FUNCDEC), *id = makeASTNodeID($2);
                        params = pop(stack);
                        type = pop(stack);
                        setSibling(id, params);
                        setSibling(type, id);
                        setChild(funcDec, type);
                        push(stack, funcDec);
                }
                | TVOID TIDENTIFIER '(' Params ')' CpndStmt             {
                        ASTNode *type, *params, *cpnd, *funcDec = makeASTNode(_FUNCDEC), *id = makeASTNodeID($2);
                        cpnd = pop(stack);
                        params = pop(stack);
                        type = makeASTNodeTYPE(TYPE_VOID);
                        setSibling(params, cpnd);
                        setSibling(id, params);
                        setSibling(type, id);
                        setChild(funcDec, type);
                        push(stack, funcDec);
                }
                | TVOID TIDENTIFIER '(' Params ')' ';'                  {
                        ASTNode *type, *params, *funcDec = makeASTNode(_FUNCDEC), *id = makeASTNodeID($2);
                        params = pop(stack);
                        type = makeASTNodeTYPE(TYPE_VOID);
                        setSibling(id, params);
                        setSibling(type, id);
                        setChild(funcDec, type);
                        push(stack, funcDec);
                }
                ;
Params          : ParamList     {
                        ASTNode *paramList, *params = makeASTNode(_PARAMS);
                        paramList = pop(stack);
                        setChild(params, paramList);
                        push(stack, params);
                }
                | TVOID         {
                        push(stack, makeASTNode(_PARAMS));
                }
                |               {
                        push(stack, makeASTNode(_PARAMS));
                }
                ;
ParamList       : ParamList ',' Param   {
                        ASTNode *paramList, *param;
                        param = pop(stack);
                        paramList = pop(stack);
                        setLastSibling(paramList, param);
                        push(stack, paramList);
                }
                | Param                 {}
                ;
Param           : VarType Value         {
                        ASTNode *type, *value, *param = makeASTNode(_PARAM);
                        value = pop(stack);
                        type = pop(stack);
                        setSibling(type, value);
                        setChild(param, type);
                        push(stack, param);
                }
                ;
CpndStmt        : '{' LDecList StmtList '}'     {
                        ASTNode *lDec, *stmt, *cpnd = makeASTNode(_CPNDSTMT);
                        stmt = pop(stack);
                        lDec = pop(stack);
                        setSibling(lDec, stmt);
                        setChild(cpnd, lDec);
                        push(stack, cpnd);
                }
                ;
LDecList        : LDecList VarDec       {
                        ASTNode * lDecList, *varDec, *temp;
                        varDec = pop(stack);
                        lDecList = pop(stack);
                        temp = getChild(lDecList);
                        if(temp == NULL)
                                setChild(lDecList, varDec);
                        else
                                setLastSibling(temp, varDec);
                        push(stack, lDecList);
                }
                |                       {
                        push(stack, makeASTNode(_LDECLIST));
                }
                ;
VarDec          : VarType IDs ';'       {
                        ASTNode *type, *id, *varDec = makeASTNode(_VARDEC);
                        id = pop(stack);
                        type = pop(stack);
                        setSibling(type, id);
                        setChild(varDec, type);
                        push(stack, varDec);
                }
                ;
VarType         : TINT          {
                        push(stack, makeASTNodeTYPE(TYPE_INT));
                }
                | TFLOAT        {
                        push(stack, makeASTNodeTYPE(TYPE_FLOAT));
                }
                ;
IDs             : IDs ',' Value {
                        ASTNode *idList, *value;
                        value = pop(stack);
                        idList = pop(stack);
                        setLastSibling(idList, value);
                        push(stack, idList);
                }
                | Value         {}
                ;
Value           : TIDENTIFIER '[' TINTEGER ']'  {
                        ASTNode *array, *id, *integer;
                        integer = makeASTNodeINT($3);
                        id = makeASTNodeID($1);
                        array = makeASTNode(_ARRAY);
                        setSibling(id, integer);
                        setChild(array, id);
                        push(stack, array);
                }
                | TIDENTIFIER                   {
                        push(stack, makeASTNodeID($1));
                }
                ;
StmtList        : StmtList Stmt         {
                        ASTNode * stmtList, *stmt, *temp;
                        stmt = pop(stack);
                        stmtList = pop(stack);
                        temp = getChild(stmtList);
                        if(temp == NULL)
                                setChild(stmtList, stmt);
                        else
                                setLastSibling(temp, stmt);
                        push(stack, stmtList);
                }
                |                       {
                        push(stack, makeASTNode(_STMTLIST));
                }
                ;
Stmt            : MatchedStmt           {}
                | OpenStmt              {}
                ;
MatchedStmt     : ExprStmt              {}
                | ForMatchedStmt        {}
                | WhileMatchedStmt      {}
                | DoWhileStmt           {}
                | ReturnStmt            {}
                | CpndStmt              {}
                | BreakStmt             {}
                | SwitchStmt            {}
                | TIF '(' Expr ')' MatchedStmt TELSE MatchedStmt        {
                        ASTNode *expr, *stmt, *stmt2, *ifStmt = makeASTNode(_IFSTMT);
                        stmt2 = pop(stack);
                        stmt = pop(stack);
                        expr = pop(stack);
                        setSibling(stmt, stmt2);
                        setSibling(expr, stmt);
                        setChild(ifStmt, expr);
                        push(stack, ifStmt);
                }
                ;
OpenStmt        : ForOpenStmt           {}
                | WhileOpenStmt         {}
                | TIF '(' Expr ')' Stmt {
                        ASTNode *expr, *stmt, *ifStmt = makeASTNode(_IFSTMT);
                        stmt = pop(stack);
                        expr = pop(stack);
                        setSibling(expr, stmt);
                        setChild(ifStmt, expr);
                        push(stack, ifStmt);
                }
                | TIF '(' Expr ')' MatchedStmt TELSE OpenStmt   {
                        ASTNode *expr, *stmt, *stmt2, *ifStmt = makeASTNode(_IFSTMT);
                        stmt2 = pop(stack);
                        stmt = pop(stack);
                        expr = pop(stack);
                        setSibling(stmt, stmt2);
                        setSibling(expr, stmt);
                        setChild(ifStmt, expr);
                        push(stack, ifStmt);
                }
                ;
SwitchStmt      : TSWITCH '(' Expr ')' '{' CaseList DefaultCase '}'     {
                        ASTNode *expr, *caseList, *defaultStmt, *switchStmt = makeASTNode(_SWSTMT);
                        defaultStmt = pop(stack);
                        caseList = pop(stack);
                        expr = pop(stack);
                        setLastSibling(caseList, defaultStmt);
                        setSibling(expr, caseList);
                        setChild(switchStmt, expr);
                        push(stack, switchStmt);
                }
                ;
CaseList        : CaseList TCASE TINTEGER ':' StmtList  {
                        ASTNode *caseList, *stmtList, *integer, *caseStmt;
                        caseStmt = makeASTNode(_CASE);
                        integer = makeASTNodeINT($3);
                        stmtList = pop(stack);
                        caseList = pop(stack);
                        setSibling(integer, stmtList);
                        setChild(caseStmt, integer);
                        setLastSibling(caseList, caseStmt);
                        push(stack, caseList);
                }
                | TCASE TINTEGER ':' StmtList           {
                        ASTNode *stmt, *integer, *caseStmt;
                        caseStmt = makeASTNode(_CASE);
                        integer = makeASTNodeINT($2);
                        stmt = pop(stack);
                        setSibling(integer, stmt);
                        setChild(caseStmt, integer);
                        push(stack, caseStmt);
                }
                ;
DefaultCase     : TDEFAULT ':' StmtList {
                        ASTNode *stmtList, *defaultStmt = makeASTNode(_DEFAULT);
                        setChild(defaultStmt, stmtList);
                        push(stack, defaultStmt);
                }
                |                       {
                        push(stack, makeASTNode(_DEFAULT));
                }
                ;
ReturnStmt      : TRETURN Expr ';'      {
                        ASTNode *expr = pop(stack), *top = pop(stack);
                        switch(getTkNum(top)){
                                case 3:
                                        push(stack, top);
                                        push(stack, setChild(makeASTNode(_RTSTMT), expr));
                                default:
                                        push(stack, top);
                        }
                }
                | TRETURN ';'           {
                        ASTNode *top = pop(stack);
                        switch(getTkNum(top)){
                                case 3:
                                        push(stack, top);
                                        push(stack, makeASTNode(_RTSTMT));
                                default:
                                        push(stack, top);
                        }
                }
                ;
BreakStmt       : TBREAK ';'    {
                        ASTNode *top = pop(stack);
                        switch(getTkNum(top)){
                                case 14: case 17: case 18: case 19:
                                        push(stack, top);
                                        push(stack, makeASTNode(_BRKSTMT));
                                default:
                                        push(stack, top);
                        }
                }
                ;
ExprStmt        : Expr ';'      {
                        push(stack, setChild(makeASTNode(_EXPRSTMT), pop(stack)));
                }
                | ';'           {
                        push(stack, makeASTNode(_EXPRSTMT));
                }
                ;
Expr            : AssignExpr    {}
                | SimpleExpr    {}
                ;
AssignExpr      : Variable '=' Expr     {
                        ASTNode *var, *expr, *assign = makeASTNodeOP(ASSIGN_);
                        expr = pop(stack);
                        var = pop(stack);
                        setSibling(var, expr);
                        setChild(assign, var);
                        push(stack, assign);
                }
                | Variable OP1 Expr     {
                        ASTNode *var, *expr, *op1;
                        expr = pop(stack);
                        var = pop(stack);
                        setSibling(var, expr);
                        char *op = $2;
                        if(op[0] == '+')
                                op1 = makeASTNodeOP(ADDASSIGN_);
                        else if(op[0] == '-')
                                op1 = makeASTNodeOP(SUBASSIGN_);
                        else if(op[0] == '*')
                                op1 = makeASTNodeOP(MULTASSIGN_);
                        else if(op[0] == '/')
                                op1 = makeASTNodeOP(DIVASSIGN_);
                        else if(op[0] == '%')
                                op1 = makeASTNodeOP(MODASSIGN_);
                        setChild(op1, var);
                        push(stack, op1);
                }
                ;
Variable        : TIDENTIFIER '[' Expr ']'      {
                        ASTNode *expr, *id = makeASTNodeID($1), *array = makeASTNode(_ARRAY);
                        expr = pop(stack);
                        setSibling(id, expr);
                        setChild(array, id);
                        push(stack, array);
                }
                | TIDENTIFIER                   {
                        push(stack, makeASTNodeID($1));
                }
                ;
SimpleExpr      : SimpleExpr OR AndExpr {
                        ASTNode *simpleExpr, *andExpr, *or = makeASTNode(OR_);
                        andExpr = pop(stack);
                        simpleExpr = pop(stack);
                        setSibling(simpleExpr, andExpr);
                        setChild(or, simpleExpr);
                        push(stack, or);
                }
                | AndExpr               {}
                ;
AndExpr         : AndExpr AND RelExpr   {
                        ASTNode *andExpr, *relExpr, *and = makeASTNode(AND_);
                        relExpr = pop(stack);
                        andExpr = pop(stack);
                        setSibling(andExpr, relExpr);
                        setChild(and, andExpr);
                        push(stack, and);
                }
                | RelExpr               {}
                ;
RelExpr         : RelExpr '<' AddExpr   {
                        ASTNode *relExpr, *addExpr, *lt = makeASTNodeOP(LT_);
                        addExpr = pop(stack);
                        relExpr = pop(stack);
                        setSibling(relExpr, addExpr);
                        setChild(lt, relExpr);
                        push(stack, lt);
                }
                | RelExpr '>' AddExpr   {
                        ASTNode *relExpr, *addExpr, *gt = makeASTNodeOP(GT_);
                        addExpr = pop(stack);
                        relExpr = pop(stack);
                        setSibling(relExpr, addExpr);
                        setChild(gt, relExpr);
                        push(stack, gt);
                }
                | RelExpr OP2 AddExpr   {
                        ASTNode *relExpr, *addExpr, *op2;
                        addExpr = pop(stack);
                        relExpr = pop(stack);
                        setSibling(relExpr, addExpr);
                        char *op = $2;
                        if(op[0] == '<')
                                op2 = makeASTNodeOP(LE_);
                        else if(op[0] == '>')
                                op2 = makeASTNodeOP(GE_);
                        else if(op[0] == '=')
                                op2 = makeASTNodeOP(EQ_);
                        else if(op[0] == '!')
                                op2 = makeASTNodeOP(NE_);
                        setChild(op2, relExpr);
                        push(stack, op2);
                }
                | AddExpr               {}
                ;
AddExpr         : AddExpr '+' Term      {
                    ASTNode *addExpr, *term, *plus = makeASTNodeOP(PLUS_);
                    term = pop(stack);
                    addExpr = pop(stack);
                    setSibling(addExpr, term);
                    setChild(plus, addExpr);
                    push(stack, plus);
                }
                | AddExpr '-' Term      {
                    ASTNode *addExpr, *term, *min = makeASTNodeOP(MINUS_);
                    term = pop(stack);
                    addExpr = pop(stack);
                    setSibling(addExpr, term);
                    setChild(min, addExpr);
                    push(stack, min);
                }
                | Term                  {}
                ;
Term            : Term '*' Factor       {
                    ASTNode *term, *factor, *mul = makeASTNodeOP(MULT_);
                    factor = pop(stack);
                    term = pop(stack);
                    setSibling(term, factor);
                    setChild(mul, term);
                    push(stack, mul);
                }
                | Term '/' Factor       {
                    ASTNode *term, *factor, *div = makeASTNodeOP(DIV_);
                    factor = pop(stack);
                    term = pop(stack);
                    setSibling(term, factor);
                    setChild(div, term);
                    push(stack, div);
                }
                | Term '%' Factor       {
                    ASTNode *term, *factor, *mod = makeASTNodeOP(MOD_);
                    factor = pop(stack);
                    term = pop(stack);
                    setSibling(term, factor);
                    setChild(mod, term);
                    push(stack, mod);
                }
                | Factor                {}
                ;
Factor          : '(' Expr ')'          {}
                | FuncCall              {}
                | '-' Factor            {
                    push(stack, setChild(makeASTNodeID("-"), pop(stack)));
                }
                | Variable              {}
                | Variable IncDec       {
                        ASTNode *var, *inc, *incDecExp = makeASTNode(_INCDECEXP);
                        inc = pop(stack);
                        var = pop(stack);
                        setSibling(var, inc);
                        setChild(incDecExp, var);
                        push(stack, incDecExp);
                }
                | IncDec Variable       {
                        ASTNode *inc, *var, *incDecExp = makeASTNode(_INCDECEXP);
                        var = pop(stack);
                        inc = pop(stack);
                        setSibling(inc, var);
                        setChild(incDecExp, inc);
                        push(stack, incDecExp);
                }
                | NumberLiteral         {}
                ;
NumberLiteral   : TINTEGER      {
                        push(stack, makeASTNodeINT($1));
                }
                | TREAL         {
                        push(stack, makeASTNodeREAL($1));
                }
                ;
IncDec          : PM            {
                        ASTNode *pm;
                        char *op = $1;
                        if(op[0] == '+')
                                pm = makeASTNodeOP(INC_);
                        else
                                pm = makeASTNodeOP(DEC_);
                        push(stack, pm);
                }
                ;
WhileMatchedStmt: TWHILE '(' Expr ')' MatchedStmt       {
                        ASTNode *expr, *stmt, *whileStmt = makeASTNode(_WHLSTMT);
                        stmt = pop(stack);
                        expr = pop(stack);
                        setSibling(expr, stmt);
                        setChild(whileStmt, expr);
                        push(stack, whileStmt);
                }
                ;
WhileOpenStmt   : TWHILE '(' Expr ')' OpenStmt          {
                        ASTNode *expr, *stmt, *whileStmt = makeASTNode(_WHLSTMT);
                        stmt = pop(stack);
                        expr = pop(stack);
                        setSibling(expr, stmt);
                        setChild(whileStmt, expr);
                        push(stack, whileStmt);
                }
                ;
DoWhileStmt     : TDO Stmt TWHILE '(' Expr ')' ';'      {
                        ASTNode *stmt, *expr, *doWhile = makeASTNode(_DOWHLSTMT);
                        expr = pop(stack);
                        stmt = pop(stack);
                        setSibling(stmt, expr);
                        setChild(doWhile, stmt);
                        push(stack, doWhile);
                }
                ;
ForMatchedStmt  : TFOR '(' Expr ';' Expr ';' Expr ')' MatchedStmt       {
                        ASTNode *expr1, *expr2, *expr3, *stmt, *forStmt = makeASTNode(_FORSTMT);
                        stmt = pop(stack);
                        expr3 = pop(stack);
                        expr2 = pop(stack);
                        expr1 = pop(stack);
                        setSibling(expr3, stmt);
                        setSibling(expr2, expr3);
                        setSibling(expr1, expr2);
                        setChild(forStmt, expr1);
                        push(stack, forStmt);
                }
                ;
ForOpenStmt     : TFOR '(' Expr ';' Expr ';' Expr ')' OpenStmt  {
                        ASTNode *expr1, *expr2, *expr3, *stmt, *forStmt = makeASTNode(_FORSTMT);
                        stmt = pop(stack);
                        expr3 = pop(stack);
                        expr2 = pop(stack);
                        expr1 = pop(stack);
                        setSibling(expr3, stmt);
                        setSibling(expr2, expr3);
                        setSibling(expr1, expr2);
                        setChild(forStmt, expr1);
                        push(stack, forStmt);
                }
                ;
FuncCall        : TIDENTIFIER '(' Arguments ')'         {
                        ASTNode *args, *id = makeASTNodeID($1), *func = makeASTNode(_FUNCCALL);
                        args = pop(stack);
                        setSibling(id, args);
                        setChild(func, id);
                        push(stack, func);
                }
                ;
Arguments       : ArgumentList  {
                        ASTNode *argList, *args = makeASTNode(_ARGS);
                        argList = pop(stack);
                        setChild(args, argList);
                        push(stack, args);
                }
                |               {
                        push(stack, makeASTNode(_ARGS));
                }
                ;
ArgumentList    : ArgumentList ',' Expr         {
                        ASTNode *argList, *expr;
                        expr = pop(stack);
                        argList = pop(stack);
                        setLastSibling(argList, expr);
                        push(stack, argList);
                }
                | Expr                          {}
                ;

%%
int main(int argc, char* argv[]){
        ASTNode *prog = 0;
        extern FILE *yyin;
        stack = initStack();
        yyin = fopen(argv[1], "r");
        yyparse();
        fclose(yyin);
        printAST(prog = pop(stack));
        //delAST(prog);
        delStack(stack);
        return 0;
}

int yyerror(char *s){
        printf("Parse error : %s\n", s);
        return 0;
}