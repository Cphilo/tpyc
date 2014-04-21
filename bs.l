%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "ast.h"
    #include "y.tab.h"
    void yyerror(char *);
    int cnt, stk[100], top;
%}

comment #.*\n
%x INDENT

%%
"\n" { BEGIN INDENT; cnt = 0;}
<INDENT>" " { cnt += 1; }
<INDENT>"\t" { cnt += 8; }
<INDENT>"\n" { cnt = 0; }
<INDENT>. { 
    unput(*yytext); 
    if(cnt > stk[top-1]) {
        stk[top++] = cnt;
        return '{';
    } else if(cnt < stk[top-1]) {
        top--;
        return '}';
    } else {
        BEGIN 0;
    }
}
{comment} ;
[a-z] {
    yylval.sIndex = *yytext - 'a';
    return VARIABLE;
}

[0-9]+ {
    yylval.iValue = atoi(yytext);
    return INTEGER;
}
[-+()<>=*\/:.] {return *yytext;}
">=" { return GE; }
"<=" { return LE; }
"==" { return EQ; }
"!=" { return NE; }
"while" { return WHILE; }
"if" { return IF; }
"else" { return ELSE; }
"print" { return PRINT; }
[ \t]+ ;
. yyerror("invalid character");

%% 

int yywrap(void) {
    return 1;
}
