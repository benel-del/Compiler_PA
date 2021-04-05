%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

char* tokenType[] = {"Keyword", "Identifier", "Integer", "Real", "String", "Comment", "Operator", "Punctuation"};

char character[] = {'a', 'b', 'f', 'n', 'r', 't', 'v', '0', '\\', '\'', '\"', '\"'};
char escape[] = {'\a', '\b', '\f', '\n', '\r', '\t', '\v', '\0', '\\', '\'', '\"', '\"'};

int process_int(char *);
char* process_str(char *);
%}

WS              [ \t\n]+
DIGIT           [0-9]
LETTER_         [A-Za-z_]
PUNCT           \(|\)|\{|\}|\[|\]|\;|\:|\,
OPERATOR        \=|\<|\>|\+|\-|\*|\/|\%
ID              {LETTER_}({LETTER_}|{DIGIT})*
_CHARACTER      \\[abfnrtv0\\\'\"\?]|[^\\\'\"\@\$]
CHARACTER       \'{_CHARACTER}\'
STRING          \"{_CHARACTER}*\"
INTEGER         [1-9]{DIGIT}*|0|0[0-7]+|0[xX][A-Fa-f0-9]+
_REAL           {DIGIT}+\.{DIGIT}+
REAL            {_REAL}|{_REAL}[eE]{DIGIT}+|{_REAL}[eE][+-]{DIGIT}+
COMMENT         \/\/[^\n]*|\/\*([^\*]|\*+[^\*\/])*\*+\/
PM              \+\+|\-\-
OP1             \+\=|\-\=|\*\=|\/\=|%\=
OP2             \<\=|\>\=|\=\=|\!\=
OR              \|\|
AND             \&\&

%%

{WS}                    {}
void                  {return TVOID;}
return                {return TRETURN;}
break                 {return TBREAK;}
switch                {return TSWITCH;}
case                  {return TCASE;}
default               {return TDEFAULT;}
do               {return TDO;}
for                   {return TFOR;}
while                 {return TWHILE;}
if                    {return TIF;}
else                  {return TELSE;}
int                   {return TINT;}
float                 {return TFLOAT;}
char                  {return TCHAR;}

{PM} {yylval.sVal = yytext; return PM;}
{OP1} {yylval.sVal = yytext; return OP1;}
{OP2} {yylval.sVal = yytext; return OP2;}
{OPERATOR} {return yytext[0];}
{OR} {yylval.sVal = yytext; return OR;}
{AND} {yylval.sVal = yytext; return AND;}

{ID}                    {yylval.sVal = yytext; return TIDENTIFIER;}
{INTEGER}               {yylval.iVal = process_int(yytext); return TINTEGER;}
{CHARACTER}             {yylval.iVal = process_int(yytext); return TINTEGER;}
{REAL}                  {yylval.rVal = atof(yytext);return TREAL;}
{STRING}                {yylval.sVal = process_str(yytext); return TSTRING;}
{COMMENT}               {return yytext[0];}
{PUNCT}                 {return yytext[0];}
.                       {printf("Error\n"); return yytext[0];}

%%

int process_int(char* yytext){
        if(yytext[0] == '\''){
                if(yytext[1] == '\\')   // escape
                        for(int i = 0; i < sizeof(escape)/sizeof(char); i++)
                                if(yytext[2] == character[i])
                                         return escape[i];
                return yytext[1];       // character
        }
        if(strstr(yytext, "0x") != NULL || strstr(yytext, "0X") != NULL)
                return strtol(yytext, NULL, 16);
        if(yytext[0] == '0' && yyleng > 1)
                return strtol(yytext, NULL, 8);
        return atoi(yytext);
}

char* process_str(char* yytext){
        char* str = (char *)malloc(sizeof(char)*(yyleng));
        for(int i = 1, j = 0; i < yyleng-1; i++, j++){
                if(i < yyleng-2 && yytext[i] == '\\'){  // escape
                        for(int k = 0; k < sizeof(escape)/sizeof(char); k++){
                                if(yytext[i+1] == character[k]){
                                        str[j] = escape[k];
                                        i++;
                                        break;
                                }
                        }
                }
                else
                        str[j] = yytext[i];
         }
        return str;
}