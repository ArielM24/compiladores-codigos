%{
    #include "hoc.h"
    //#include "vector_cal.h"
    #include <math.h>
    #include <stdio.h>

    void yyerror(char* s);
    int yylex();
    void warning(char* s, char* t);
%}  
%union{
    double comp;
    Vector* vec;
    Symbol* sym;
} 

%token<comp> NUMBER     
%type<vec> exp       
%type<vec> vect       
%type<comp> number     
%token<sym> VAR BLTIN  
%token<sym> UNDEF      
%type<vec>  asgn       

%right '='
%left '+' '-'
%left '*'
%left '&' '.'
%%

    list: 
      | list '\n'
      | list asgn '\n'
      | list exp '\n'     {imprimeVector($2);}
      | list number '\n'  {printf("\t%lf\n", $2);}
      | list error '\n'   {yyerror;}
      ;
    
    asgn: VAR '=' exp     {$$ = $1 -> u.vec = $3;
                            $1 -> type = VAR;}
    ;

    exp: vect           {$$ = $1;}
      | VAR {
        printf("\n%s = ", $1 -> name);
        if($1 -> type == UNDEF) 
            printf("Variable no definida %s\n", $1 -> name);
            $$ = $1 -> u.vec;
          }
      | asgn
      | exp '+' exp     {$$ = sumaVector($1, $3);}
      | exp '-' exp     {$$ = restaVector($1, $3);}
      | NUMBER '*' exp  {$$ = escalarVector($1, $3);}
      | exp '*' NUMBER  {$$ = escalarVector($3, $1);}
      | exp '&' exp     {$$ = productoCruz($1, $3);}
    ;
    number: NUMBER
      | exp '.' exp {$$ = productoPunto($1, $3);}
      | '|' exp '|' {$$ = vectorMagnitud($2);}
      ;

    vect: '[' NUMBER NUMBER NUMBER ']'   {  
      Vector* v = creaVector(3);
      v -> vec[0] = $2;
      v -> vec[1] = $3;
      v -> vec[2] = $4;
      $$ = v;
      }
      ;
%%
#include <stdio.h>
#include <ctype.h>

char* progname;
int lineno = 1;

void main(int argc, char* argv[]){
  progname = argv[0];
  yyparse();
}

int yylex(){
  int c;
  while((c = getchar()) == ' '|| c == '\t')
  /**Salta blancos**/;
  if(c == EOF)
    return 0;
  if(isdigit(c)){
    ungetc(c, stdin);
    scanf("%lf", &yylval.comp);
    return NUMBER;
  }

  if(isalpha(c)){
    Symbol* s;
    char sbuf[200];
    char* p = sbuf;
    do{
      *p++ = c;
    } while((c = getchar()) != EOF && isalnum(c));

    ungetc(c, stdin);
    *p = '\0';
    if((s = lookup(sbuf)) == (Symbol* )NULL)
      s = install(sbuf, UNDEF, NULL);
    yylval.sym = s;

    if(s -> type == UNDEF)
      return VAR;
    else 
      return s -> type;
  }
  if(c == '\n')
    lineno++;
  return c; 
}

void yyerror(char* s){
  warning(s, (char* )0);
}

void warning(char* s, char* t){
  fprintf(stderr, "%s: %s", progname, s);
  if(t)
    fprintf(stderr, "%s", t);
  fprintf(stderr, "\tCerca de la linea %d\n", lineno);
}
