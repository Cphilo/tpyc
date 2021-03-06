%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdarg.h>
    #include "ast.h"
    nodeType *opr(int oper, int nops, ...);
    nodeType *id(int i);
    nodeType *con(int value);
    void freeNode(nodeType *p);
    int ex(nodeType *p);
    void yyerror(char *s);
    int yylex(void);
    int sym[26]; /* system table */
%}

%union {
    int iValue;
    char sIndex;
    nodeType *nPtr;
};

%token <iValue> INTEGER FLOAT
%token <sIndex> VARIABLE
%token WHILE IF ELSE PRINT LINE
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-' 
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%
program:
    function { exit(0); }
    ;

function:
    function stmt { ex($2);freeNode($2); }
    |
    ;

stmt: 
    expr LINE { $$ = $1; }
    | PRINT expr LINE { $$ = opr(PRINT, 1, $2); }
    | VARIABLE '=' expr LINE { $$ = opr('=', 2, id($1), $3); }
    | WHILE expr ':' LINE stmt { $$ = opr(WHILE, 2, $2, $5); }
    | IF expr ':' LINE stmt %prec IFX { $$ = opr(IF, 2, $2, $5); }
    | IF expr ':' LINE stmt ELSE ':' LINE stmt { $$ = opr(IF, 3, $2, $5, $9); }
    | '{' stmt_list '}' { $$ = $2; }
    ;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { $$ = opr(';', 2, $1, $2); }
    ;

expr:
    INTEGER { $$ = con($1); }
    | FLOAT { $$ = con($1); }
    | VARIABLE { $$ = id($1); }
    | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
    | expr '+' expr { $$ = opr('+', 2, $1, $3); }
    | expr '-' expr { $$ = opr('-', 2, $1, $3); }
    | expr '*' expr { $$ = opr('*', 2, $1, $3); }
    | expr '/' expr { $$ = opr('/', 2, $1, $3); }
    | expr '<' expr { $$ = opr('<', 2, $1, $3); }
    | expr '>' expr { $$ = opr('>', 2, $1, $3); }
    | expr GE expr { $$ = opr(GE, 2, $1, $3); }
    | expr LE expr { $$ = opr(LE, 2, $1, $3); }
    | expr NE expr { $$ = opr(NE, 2, $1, $3); }
    | expr EQ expr { $$ = opr(EQ, 2, $1, $3); }
    | '(' expr ')' { $$ = $2; }
    ;
%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p) 

nodeType *con(int value) {
    nodeType *p;
    size_t nodeSize;
    nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);
    if((p=malloc(nodeSize)) == NULL) {
        yyerror("out of memory!\n");      
    }
    p->type = typeCon;
    p->con.value = value;    
    return p;
}

nodeType *id(int i) {
    nodeType *p;
    size_t nodeSize;    
    nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);
    if((p=malloc(nodeSize)) == NULL) {
        yyerror("out of memory!\n");
    }
    p->type = typeId;
    p->id.i = i;    
    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t nodeSize;
    int i;
    
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) + 
        (nops - 1) * sizeof(nodeType*);
    if((p = malloc(nodeSize)) == NULL) {
        yyerror("out of memory!\n");
    }
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for(i=0;i<nops;i++) {
        p->opr.op[i] = va_arg(ap, nodeType*);
    }
    va_end(ap);
    return p;
}


void freeNode(nodeType *p) {
    int i;
    if(!p)return;
    if(p->type == typeOpr) {
        for(i=0;i<p->opr.nops;i++) {
            freeNode(p->opr.op[i]);
        }
    }
    free(p);
} 

void yyerror(char *s) {
    printf("%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}

