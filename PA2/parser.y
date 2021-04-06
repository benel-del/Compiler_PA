%{
        #include <stdio.h>
        #include <stdlib.h>
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
Program         : DecList       { printf("Program -> DecList\n"); }
                ;
DecList         : DecList Dec   { printf("DecList -> DecList Dec\n"); }
                | Dec           { printf("DecList -> Dec\n"); }
                ;
Dec             : VarDec        { printf("Dec -> VarDec\n"); }
                | FuncDec       { printf("Dec -> FuncDec\n"); }
                ;
FuncDec         : VarType TIDENTIFIER '(' Params ')' CpndStmt           { printf("FuncDec -> VarType %s ( Params ) CpndStmt\n", $2); }
                | VarType TIDENTIFIER '(' Params ')' ';'                { printf("FuncDec -> VarType %s ( Params ) ;\n", $2); }
                | TVOID TIDENTIFIER '(' Params ')' CpndStmt             { printf("FuncDec -> void %s ( Params ) CpndStmt\n", $2); }
                | TVOID TIDENTIFIER '(' Params ')' ';'                  { printf("FuncDec -> void %s ( Params ) ;\n", $2); }
                ;
Params          : ParamList     { printf("Params -> ParamList\n"); }
                | TVOID         { printf("Params -> void\n"); }
                |               { printf("Params -> Empty\n"); }
                ;
ParamList       : ParamList ',' Param   { printf("ParamList -> ParamList , Param\n"); }
                | Param                 { printf("ParamList -> Param\n"); }
                ;
Param           : VarType Value         { printf("Param -> VarType Value\n"); }
                ;
CpndStmt        : '{' LDecList StmtList '}'     { printf("CpndStmt -> { LDecList StmtList }\n"); }
                ;
LDecList        : LDecList VarDec       { printf("LDecList -> LDecList VarDec\n"); }
                |                       { printf("LDecList -> Empty\n"); }
                ;
VarDec          : VarType IDs ';'       { printf("VarDec -> VarType IDs ;\n"); }
                ;
VarType         : TINT          { printf("VarType -> int\n"); }
                | TCHAR         { printf("VarType -> char\n"); }
                | TFLOAT        { printf("VarType -> float\n"); }
                ;
IDs             : IDs ',' Value { printf("IDs -> IDs , Value\n"); }
                | Value         { printf("IDs -> Value\n"); }
                ;
Value           : TIDENTIFIER '[' TINTEGER ']'  { printf("Value -> %s [ TINTEGER ]\n", $1); }
                | TIDENTIFIER                   { printf("Value -> %s\n", $1); }
                ;
StmtList        : StmtList Stmt         { printf("StmtList -> StmtList Stmt\n"); }
                |                       { printf("StmtList -> Empty\n"); }
                ;
Stmt            : MatchedStmt           { printf("Stmt -> MatchedStmt\n"); }
                | OpenStmt              { printf("Stmt -> OpenStmt\n"); }
                ;
MatchedStmt     : ExprStmt              { printf("MatchedStmt -> ExprStmt\n"); }
                | ForMatchedStmt        { printf("MatchedStmt -> ForMatchedStmt\n"); }
                | WhileMatchedStmt      { printf("MatchedStmt -> WhileMatchedStmt\n"); }
                | DoWhileStmt           { printf("MatchedStmt -> DoWhileStmt\n"); }
                | ReturnStmt            { printf("MatchedStmt -> ReturnStmt\n"); }
                | CpndStmt              { printf("MatchedStmt -> CpndStmt\n"); }
                | BreakStmt             { printf("MatchedStmt -> BreakStmt\n"); }
                | SwitchStmt            { printf("MatchedStmt -> SwitchStmt\n"); }
                | TIF '(' Expr ')' MatchedStmt TELSE MatchedStmt        { printf("MatchedStmt -> TIF ( Expr ) MatchedStmt TELSE MatchedStmt\n"); }
                ;
OpenStmt        : ForOpenStmt           { printf("OpenStmt -> ForOpenStmt\n"); }
                | WhileOpenStmt         { printf("OpenStmt -> WhileOpenStmt\n"); }
                | TIF '(' Expr ')' Stmt { printf("OpenStmt -> TIF ( Expr ) Stmt\n"); }
                | TIF '(' Expr ')' MatchedStmt TELSE OpenStmt   { printf("OpenStmt -> TIF ( Expr ) MatchedStmt TELSE OpenStmt\n"); }
                ;
SwitchStmt      : TSWITCH '(' Expr ')' '{' CaseList DefaultCase '}'     { printf("SwitchStmt -> TSWITCH ( Expr ) { CaseList DefaultCase }\n"); }
                ;
CaseList        : CaseList TCASE TINTEGER ':' StmtList  { printf("CaseList -> CaseList TCASE TINTEGER : StmtList\n"); }
                | TCASE TINTEGER ':' StmtList           { printf("CaseList -> TCASE TINTEGER : StmtList\n"); }
                ;
DefaultCase     : TDEFAULT ':' StmtList { printf("DefaultCase -> TDEFAULT : StmtList\n"); }
                |                       { printf("DefaultCase -> Empty\n"); }
                ;
ReturnStmt      : TRETURN Expr ';'      { printf("ReturnStmt -> TRETURN Expr ;\n"); }
                | TRETURN ';'           { printf("ReturnStmt -> TRETURN ;\n"); }
                ;
BreakStmt       : TBREAK ';'    { printf("BreakStmt -> TBREAK ;\n"); }
                ;
ExprStmt        : Expr ';'      { printf("ExprStmt -> Expr ;\n"); }
                | ';'           { printf("ExprStmt -> ;\n"); }
                ;
Expr            : AssignExpr    { printf("Expr -> AssignExpr\n"); }
                | SimpleExpr    { printf("Expr -> SimpleExpr\n"); }
                ;
AssignExpr      : Variable '=' Expr     { printf("AssignExpr -> Variable = Expr\n"); }
                | Variable OP1 Expr     { printf("AssignExpr -> Variable %s Expr\n", $2); }
                ;
Variable        : TIDENTIFIER '[' Expr ']'      { printf("Variable -> %s [ Expr ]\n", $1); }
                | TIDENTIFIER                   { printf("Variable -> %s\n", $1); }
                ;
SimpleExpr      : SimpleExpr OR AndExpr { printf("SimpleExpr -> SimpleExpr || AndExpr\n"); }
                | AndExpr               { printf("SimpleExpr -> AndExpr\n"); }
                ;
AndExpr         : AndExpr AND RelExpr   { printf("AndExpr -> AndExpr && RelExpr\n"); }
                | RelExpr               { printf("AndExpr -> RelExpr\n"); }
                ;
RelExpr         : RelExpr '<' AddExpr   { printf("RelExpr -> RelExpr < AddExpr\n"); }
                | RelExpr '>' AddExpr   { printf("RelExpr -> RelExpr > AddExpr\n"); }
                | RelExpr OP2 AddExpr   { printf("RelExpr -> RelExpr %s AddExpr\n", $2); }
                | AddExpr               { printf("RelExpr -> AddExpr\n"); }
                ;
AddExpr         : AddExpr '+' Term      { printf("AddExpr -> AddExpr + Term\n"); }
                | AddExpr '-' Term      { printf("AddExpr -> AddExpr - Term\n"); }
                | Term                  { printf("AddExpr -> Term\n"); }
                ;
Term            : Term '*' Factor       { printf("Term -> Term * Factor\n"); }
                | Term '/' Factor       { printf("Term -> Term / Factor\n"); }
                | Term '%' Factor       { printf("Term -> Term %% Factor\n"); }
                | Factor                { printf("Term -> Factor\n"); }
                ;
Factor          : '(' Expr ')'          { printf("Factor -> ( Expr )\n"); }
                | FuncCall              { printf("Factor -> FuncCall\n"); }
                | '-' Factor            { printf("Factor -> - Factor\n"); }
                | Variable              { printf("Factor -> Variable\n"); }
                | Variable IncDec       { printf("Factor -> Variable IncDec\n"); }
                | IncDec Variable       { printf("Factor -> IncDec Variable\n"); }
                | NumberLiteral         { printf("Factor -> NumberLiteral\n"); }
                ;
NumberLiteral   : TINTEGER      { printf("NumberLiteral -> %d\n", $1); }
                | TREAL         { printf("NumberLiteral -> %.2f\n", $1); }
                ;
IncDec          : PM            { printf("IncDec -> %s\n", $1); }
                ;
WhileMatchedStmt: TWHILE '(' Expr ')' MatchedStmt       { printf("WhileMatchedStmt -> TWHILE ( Expr ) MatchedStmt\n"); }
                ;
WhileOpenStmt   : TWHILE '(' Expr ')' OpenStmt          { printf("WhileOpenStmt -> TWHILE ( Expr ) OpenStmt\n"); }
                ;
DoWhileStmt     : TDO Stmt TWHILE '(' Expr ')' ';'      { printf("DoWhileStmt -> TDO Stmt TWHILE ( Expr ) ;\n"); }
                ;
ForMatchedStmt  : TFOR '(' Expr ';' Expr ';' Expr ')' MatchedStmt       { printf("ForMatchedStmt -> TFOR ( Expr ; Expr ; Expr ) MatchedStmt\n"); }
                ;
ForOpenStmt     : TFOR '(' Expr ';' Expr ';' Expr ')' OpenStmt  { printf("ForOpenStmt -> TFOR ( Expr ; Expr ; Expr ) OpenStmt\n"); }
                ;
FuncCall        : TIDENTIFIER '(' Arguments ')'         { printf("FuncCall -> %s ( Arguments )\n", $1); }
                ;
Arguments       : ArgumentList  { printf("Arguments -> ArgumentList\n"); }
                |               { printf("Arguments -> Empty\n"); }
                ;
ArgumentList    : ArgumentList ',' Expr         { printf("ArgumentList -> ArgumentList , Expr\n"); }
                | ArgumentList ',' TSTRING      { printf("ArgumentList -> ArgumentList , %s\n", $3); }
                | Expr                          { printf("ArgumentList -> Expr\n"); }
                | TSTRING                       { printf("ArgumentList -> %s\n", $1); }
                ;

%%
int main(int argc, char* argv[]){
        extern FILE *yyin;
        yyin = fopen(argv[1], "r");
        yyparse();
        fclose(yyin);
        return 0;
}

int yyerror(char *s){
        printf("Parse error : %s\n", s);
        return 0;
}