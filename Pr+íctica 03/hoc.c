#include "hoc.h" 
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

static Symbol *symlist=0;    

Symbol *lookup(char *s)    
{
Symbol  *sp;
	for (sp = symlist; sp != (Symbol *)0; sp = sp->next) 
		if (strcmp(sp->name, s)== 0) 
			return sp;
	return 0;      
}

Symbol *install(char *s,int t, Vector *vec) {
	Symbol *sp;
	char *emalloc();
	sp = (Symbol *) emalloc(sizeof(Symbol));
	sp->name = emalloc(strlen(s)+ 1) ; 
	strcpy(sp->name, s);
	sp->type = t;
	sp->u.vec= vec;
	sp->next  =  symlist;   
	symlist =  sp; 
    return sp; 
}

char  *emalloc(unsigned n)	
{
	void *p;
	p = malloc(n); 
	return p; 
}
