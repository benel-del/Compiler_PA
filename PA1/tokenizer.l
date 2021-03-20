%{
#include <stdio.h>
#include <stdlib.h>

char* tokenType[] = {"Keyword", "Identifier", "Integer", "Real", "String", "Comment", "Operator", "Punctuation"};
enum tnumber {TEOF, TKEYWORD, TIDENTIFIER, TINTEGER, TREAL, TSTRING, TCOMMENT, TOPERATOR, TPUNCTUATION, TERROR};

union{
        int iVal;
        float rVal;
        char* sVal;
} yylval;

%}

WS              [ \t\n]+
KEYWORD         break|case|char|default|do|else|float|for|if|int|return|swith|void|while
DIGIT           [0-9]
LETTER_         [A-Za-z_]
ID              {LETTER_}({LETTER_}|{DIGIT})*
_CHARACTER      \\[abfnrtv0\\\'\"\?]|[^\\\'\"\n\t\@\$]
CHARACTER       \'{_CHARACTER}\'
INTEGER         [1-9]{DIGIT}*|0|0[0-7]+|0[xX][A-Fa-f0-9]+
_REAL           {DIGIT}+\.{DIGIT}+
REAL            {_REAL}|{_REAL}[eE]{DIGIT}+|{_REAL}[eE][+-]{DIGIT}+
COMMENT         \/\/{CHARACTER}*|\/\*{CHARACTER}\*\/
_OPERATOR       \+|\-|\/|%|!|=|<|>
OPERATOR        {_OPERATOR}|{_OPERATOR}=|&&|\|\||\+\+|\-\-|,
PUNCT           [\(|\)|\{|\}|\[|\]|;|:]
STRING          \"{_CHARACTER}+\"
ERROR           ^[{WS}{KEYWORD}{ID}{CHARACTER}{STRING}{INTEGER}{REAL}{COMMENT}{OPERATOR}{PUNCT}]+

%%

{WS}                    {}
{KEYWORD}               {return TKEYWORD;}
{ID}                    {return TIDENTIFIER;}
{INTEGER}               {return TINTEGER;}
{CHARACTER}             {return TINTEGER;}
{REAL}                  {return TREAL;}
{STRING}                {return TSTRING;}
{COMMENT}               {return TCOMMENT;}
{OPERATOR}              {return TOPERATOR;}
{PUNCT}                 {return TPUNCTUATION;}
{ERROR}                 {return TERROR;}

%%
int main(int argc, char *argv[]){
        enum tnumber tn;
        if(!argc)       exit(0);
        yyin = fopen(argv[1], "r");

// Insert source code here
        char *str;
        while((tn = yylex()) != TEOF){
                switch(tn){
                        case TINTEGER:
                                if(strstr(yytext, "0x") != NULL || strstr(yytext, "0X") != NULL)
                                        yylval.iVal = strtol(yytext, NULL, 16);
                                else if(strchr(yytext, '0') != NULL && strlen(yytext) > 1)
                                        yylval.iVal = strtol(yytext, NULL, 8);
                                else
                                        yylval.iVal = atoi(yytext);
                                printf("%-15s:%19s, %5d\n", yytext, tokenType[tn-1], yylval.iVal);
                                break;
                        case TREAL:
                                yylval.rVal = atof(yytext);
                                printf("%-15s:%19s, %5.2f\n", yytext, tokenType[tn-1], yylval.rVal);
                                break;
                        case TSTRING:
                                str = (char *)malloc(sizeof(char)*(strlen(yytext)-2));
                                strcpy(str, yytext+1);
                                yylval.sVal = str;
                                printf("%-15s:%19s, %s\n", yytext, tokenType[tn-1], yylval.sVal);
                                break;
                        case TERROR:
                                printf("Error occurred\n");
                                return -1;
                        case TKEYWORD: case TIDENTIFIER: case TCOMMENT: case TOPERATOR: case TPUNCTUATION:
                                printf("%-15s:%19s\n", yytext, tokenType[tn-1]);
                                break;
                }
        }
        fclose(yyin);
        return 0;
}