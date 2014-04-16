yacc -d bs.y
lex bs.l
cc lex.yy.c y.tab.c compiler.c -o bs.exe
