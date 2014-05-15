#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "y.tab.h"

int ex(nodeType *p) {
    if(!p)return 0;
    int oper = p->opr.oper;
    if(p->type == typeOpr && (
        oper == '+' || oper == '-' || oper == '*' || oper == '/' || 
        oper == '<' || oper == '>' || oper == GE || oper == LE ||
        oper == NE || oper == EQ)
    ) {
        
    }
    return 0;
}
