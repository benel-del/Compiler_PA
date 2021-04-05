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
%%

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