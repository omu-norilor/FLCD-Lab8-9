%token<row> PLUS
%token<row> MINUS
%token<row> MULT
%token<row> DIV
%token<row> MOD
%token<row> EQUAL
%token<row> NOT_EQUAL
%token<row> LT
%token<row> LE
%token<row> GT
%token<row> GE
%token<row> ASSIGNMENT
%token<row> L_BRACKET
%token<row> R_BRACKET
%token<row> L_PARANTHESIS
%token<row> R_PARANTHESIS
%token<row> PERIOD
%token<row> IF
%token<row> ELSE
%token<row> THEN
%token<row> WHILE
%token<row> FOR
%token<row> PRINT
%token<row> READ
%token<row> IDENTIFIER 
%token<row> NUMBER
%token<row> ENTER
%token<row> CONSTANT

%{
  #include "include.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  static struct row_entry* cons(const char* name, struct row_entry* first_child) {
    struct row_entry* answer = malloc(sizeof(struct row_entry));
    answer->name = strdup(name);
    answer->first_child = first_child;
    answer->next_sibling = NULL;
    return answer;
  }

  static void display(struct row_entry* node, int count_tabs) {
    if(node == NULL) return;
    for(int i = 0; i < count_tabs; i++) {
      printf("\t");
    }
    printf("%s\n", node->name);
    display(node->first_child, count_tabs + 1);
    display(node->next_sibling, count_tabs);
  }
  static void free_row_entry(struct row_entry* node) {
    if(node == NULL) return;
    free_row_entry(node->first_child);
    free_row_entry(node->next_sibling);
    free(node->name);
    free(node);
  }
  extern int yylex();
  extern int yylex_destroy();
%}

%union {
  struct row_entry* row;  
}

%type<row> program
%type<row> cmpdstmt
%type<row> stmtlist
%type<row> stmt
%type<row> simplstmt
%type<row> structstmt
%type<row> assignstmt
%type<row> iostmt
%type<row> ifstmt
%type<row> whilestmt
%type<row> expression
%type<row> term
%type<row> factor
%type<row> operator
%type<row> relation
%type<row> op
%type<row> condition

%%
accept: program             { display($1, 0); free_row_entry($1); }

program: cmpdstmt             { $$ = cons("program", $1); }
      ;

cmpdstmt: L_BRACKET stmtlist R_BRACKET               { $$ = cons("cmpdstmt", $1); $1->next_sibling = $2; $2->next_sibling = $3; }
       ;

stmtlist: stmt  { $$ = cons("stmtlist", $1); }
        | stmt stmtlist   { $$ = cons("stmtlist", $1); $1->next_sibling = $2; }
        ;

stmt:  simplstmt            { $$ = cons("stmt", $1); }  
         | structstmt       { $$ = cons("stmt", $1); } 
         ;

simplstmt: assignstmt   { $$ = cons("simplstmt", $1); }
          | iostmt      { $$ = cons("simplstmt", $1); }
          ;

assignstmt: IDENTIFIER ASSIGNMENT expression       { $$ = cons("assignstmt", $1); $1->next_sibling = $2; $2->next_sibling = $3; }
          ; 

expression: expression operator term    { $$ = cons("expression", $1); $1->next_sibling = $2; $2->next_sibling = $3; }
          | term                          { $$ = cons("expression", $1); }
          ;

term: term op factor      { $$ = cons("term", $1); $1->next_sibling = $2; $2->next_sibling = $3; }
    | factor                    { $$ = cons("term", $1); }
    ;

factor: L_PARANTHESIS expression R_PARANTHESIS { $$ = cons("factor", $1); $1->next_sibling = $2; $2->next_sibling = $3; }
        | IDENTIFIER                           { $$ = cons("factor", $1); }
        | NUMBER                             { $$ = cons("factor", $1); }
        ;

iostmt: PRINT factor      { $$ = cons("iostmt", $1); $1->next_sibling = $2; }
      | READ IDENTIFIER   { $$ = cons("iostmt", $1); $1->next_sibling = $2; }

structstmt: ifstmt     { $$ = cons("structstmt", $1); }
          | whilestmt  { $$ = cons("structstmt", $1); }
        ;

ifstmt: IF condition THEN stmt              { $$ = cons("ifstmt", $1); $1->next_sibling = $2; $2->next_sibling = $3; $3->next_sibling = $4; } 
      | IF condition THEN stmt ELSE stmt    { $$ = cons("ifstmt", $1); $1->next_sibling = $2; $2->next_sibling = $3; $3->next_sibling = $4; $4->next_sibling = $5; $5->next_sibling = $6; }
      ;
            
whilestmt: WHILE condition L_BRACKET stmt R_BRACKET  { $$ = cons("while_statement", $1); $1->next_sibling = $2; $2->next_sibling = $3; $3->next_sibling = $4; $4->next_sibling = $5; } 
                ;

condition: expression relation expression          { $$ = cons("condition", $1); $1->next_sibling = $2; $2->next_sibling = $3; } 
        ;
   
operator: PLUS              { $$ = cons("operator", $1); } 
        | MINUS             { $$ = cons("operator", $1); }
        ;

op: MULT              { $$ = cons("op", $1); }
    | DIV               { $$ = cons("op", $1); }
    | MOD               { $$ = cons("op", $1); }
    ;

relation: EQUAL             { $$ = cons("relation", $1); }
        | NOT_EQUAL         { $$ = cons("relation", $1); }
        | LT                { $$ = cons("relation", $1); }
        | LE                { $$ = cons("relation", $1); }
        | GT                { $$ = cons("relation", $1); }
        | GE                { $$ = cons("relation", $1); }
        ;
%%

int yyerror(char *s) {
  fprintf(stderr, "Error: %s\n", s); 
  return 0; 
}

int main() {
  yyparse();
  yylex_destroy();
  return 0;
}