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

int process_int(char *);
char* process_str(char *);

%}

WS              [ \t\n]+
KEYWORD         break|case|char|default|do|else|float|for|if|int|return|swith|void|while
DIGIT           [0-9]
LETTER_         [A-Za-z_]
ID              {LETTER_}({LETTER_}|{DIGIT})*
_CHARACTER      \\[abfnrtv0\\\'\"\?]|[^\\\'\n\"\@\$]
CHARACTER       \'{_CHARACTER}\'
STRING          \"{_CHARACTER}*\"
INTEGER         [1-9]{DIGIT}*|0|0[0-7]+|0[xX][A-Fa-f0-9]+
_REAL           {DIGIT}+\.{DIGIT}+
REAL            {_REAL}|{_REAL}[eE]{DIGIT}+|{_REAL}[eE][+-]{DIGIT}+
COMMENT         \/\/[^\n]*|\/\*([^\*]|(\*)+[^\*\/])*(\*)+\/
_OPERATOR       [\+\-\*\/%!=<>]
OPERATOR        {_OPERATOR}|{_OPERATOR}=|&&|\|\||\+\+|\-\-|,
PUNCT           [\(|\)|\{|\}|\[|\]|;|:]
ERROR           [^{WS}{KEYWORD}{ID}{CHARACTER}{STRING}{INTEGER}{REAL}{COMMENT}{OPERATOR}{PUNCT}]

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
        int isError = 0;;
        char *str;
        while((tn = yylex()) != TEOF){
                switch(tn){
                        case TINTEGER:
                                yylval.iVal = process_int(yytext);
                                printf("%-15s:%19s, %5d\n", yytext, tokenType[tn-1], yylval.iVal);
                                break;
                        case TREAL:
                                yylval.rVal = atof(yytext);
                                printf("%-15s:%19s, %5.2f\n", yytext, tokenType[tn-1], yylval.rVal);
                                break;
                        case TSTRING:
                                yylval.sVal = process_str(yytext);
                                printf("%-15s:%19s, %s\n", yytext, tokenType[tn-1], yylval.sVal);
                                break;
                        case TKEYWORD: case TIDENTIFIER: case TCOMMENT: case TOPERATOR: case TPUNCTUATION:
                                printf("%-15s:%19s\n", yytext, tokenType[tn-1]);
                                break;
                        case TERROR:
                                printf("Error occurred\n");
                                isError = 1;
                }
                if(isError)
                        return -1;
        }
        fclose(yyin);
        return 0;
}

int process_int(char* yytext){
        static char character[] = {'a', 'b', 'f', 'n', 'r', 't', 'v', '0', '\\', '\'', '\"', '\"'};
        static char escape[] = {'\a', '\b', '\f', '\n', '\r', '\t', '\v', '\0', '\\', '\'', '\"', '\"'};

        if(yytext[0] == '\''){  // character
                for(int i = 0; i < sizeof(escape)/sizeof(char); i++)
                        if(yytext[2] == character[i])
                                 return escape[i];
        }
        if(strstr(yytext, "0x") != NULL || strstr(yytext, "0X") != NULL)
                return strtol(yytext, NULL, 16);
        if(strchr(yytext, '0') != NULL && yyleng > 1)
                return strtol(yytext, NULL, 8);
        return atoi(yytext);
}

char* process_str(char* yytext){
        char* str = (char *)malloc(sizeof(char)*(yyleng));
        for(int i = 1, j = 0; i < yyleng-1; i++){
                if(i < yyleng-2 && yytext[i] == '\\'){
                        if(yytext[i+1] == 't'){
                                str[j] = '\t';
                                i++;
                        }
                        else if(yytext[i+1] == 'n'){
                                str[j] = '\n';
                                i++;
                        }
                }
                else
                        str[j] = yytext[i];
                j++;
         }
        return str;
}
