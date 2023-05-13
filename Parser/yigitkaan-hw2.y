%{
#include <stdio.h>
void yyerror(const char *s){
return;}
%}

/* bison declerations */
%token tSTRING tGET tSET tFUNCTION tPRINT tIF tRETURN tADD tSUB tMUL tDIV tINC tGT tDEC tLT tEQUALITY tLEQ tGEQ tIDENT tNUM
%start starting

%%
/* grammer rules */

starting: '[' ']'
	|'[' statements ']'
;

statements: statement
	| statement statements
;

statement: set_s
	| if_s
	| print_s
	| inc_s
	| dec_s
	| return_s
	| expression
;

set_s: '[' tSET ',' tIDENT ',' expression ']'
;

if_s: '[' tIF ',' condition ',' then_part ']' 
	| '[' tIF ',' condition ',' then_part else_part ']'
;

else_part: '[' ']' 
	| '[' statements ']'
;

then_part: '[' ']'
	| '[' statements ']'
;

inc_s: '[' tINC ',' tIDENT ']'
;

dec_s: '[' tDEC ',' tIDENT ']'
;

print_s: '[' tPRINT ',' expression ']'
;

return_s: '[' tRETURN ']'
	| '[' tRETURN ',' expression ']'
;

condition: '[' tGT ',' expression ',' expression ']'
	| '[' tLT ',' expression ',' expression ']'
	| '[' tGEQ ',' expression ',' expression ']' 
	| '[' tLEQ ',' expression ',' expression ']'
	| '[' tEQUALITY ',' expression ',' expression ']' 
;

expression: tNUM
	| tSTRING
	| function_declaration
	| get_exp
	| condition
	| operator_app
;

expressionList: 
	| expression
	| expression ',' expressionList
;

operator_app: '[' tADD ',' expression ',' expression ']'
	| '[' tSUB ',' expression ',' expression ']'
	| '[' tMUL ',' expression ',' expression ']'
	| '[' tDIV ',' expression ',' expression ']'
;

get_exp: '[' tGET ',' tIDENT ']'
	| '[' tGET ',' tIDENT ',' '[' expressionList ']' ']'
;

statementList:
	| statements
	| statements ',' statementList
;

parameters: 
	| tIDENT
	| tIDENT ',' parameters
;

function_declaration: '[' tFUNCTION ',' '[' parameters ']' ',' '[' statementList ']' ']'
;

%%
int main(){
 if(yyparse()){
  printf("ERROR\n");
  return 1;
 }
 else{
  printf("OK\n");
  return 0;
 }
}
