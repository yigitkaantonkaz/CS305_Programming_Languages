%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "yigitkaan-hw3.h"
void yyerror (const char *s) 
{}

ExpressionNode * create_empty(StrNode);
ExpressionNode * create_numNode(NumberNode);
ExpressionNode * create_strNode(StrNode);
ExpressionNode * addFunc(int, ExpressionNode *, ExpressionNode *);
ExpressionNode * subFunc(int, ExpressionNode *, ExpressionNode *);
ExpressionNode * mulFunc(int, ExpressionNode *, ExpressionNode *);
ExpressionNode * divFunc(int, ExpressionNode *, ExpressionNode *);
ExpressionNode * Function_null(ExpressionNode *);

int checkFunc(ExpressionNode *);
void addList(ExpressionNode *);
ExpressionNode ** expressionList;
int expressionSize = 100;
int expressionIndex = 0;

%}

%union
{
 StrNode strNode;
 NumberNode numberNode;
 ExpressionNode * expressionNodePtr;
 int lineNo;
 int num;
}


%token <expressionNodePtr> tIDENT tPRINT tGET tSET tFUNCTION tRETURN tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC
%token <lineNo> tADD tSUB tMUL tDIV
%token <numberNode> tNUM
%token <strNode> tSTRING

%start prog
%type <expressionNodePtr> function condition getExpr operation
%type <expressionNodePtr> expr

%%
prog:		'[' stmtlst ']'
;

stmtlst:	stmtlst stmt |
;

stmt:		setStmt | if | print | unaryOperation | expr | returnStmt
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']'{ 
		$$ = Function_null($2);}
		| '[' tGET ',' tIDENT ',' '[' ']' ']'{ 
		$$ = Function_null($2);}
		| '[' tGET ',' tIDENT ']'{ $$ = Function_null($2);}
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']'
;

if:		'[' tIF ',' condition ',' '[' stmtlst ']' ']'
		| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']'
;

print:		'[' tPRINT ',' expr ']'
;

operation:	'[' tADD ',' expr ',' expr ']' {
		$$ = addFunc($2, $4, $6);
		}
		| '[' tSUB ',' expr ',' expr ']' {
		$$ = subFunc($2, $4, $6);
		}
		| '[' tMUL ',' expr ',' expr ']' {
		$$ = mulFunc($2, $4, $6);
		}
		| '[' tDIV ',' expr ',' expr ']' {
		$$ = divFunc($2, $4, $6);
		}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;

expr:		tNUM {
		$$ = create_numNode($1);
		}
		| tSTRING {
		$$ = create_strNode($1);
		} 
		| getExpr {$$ = $1;}
		| function {$$ = $1;}
		| operation {$$ = $1;}
		| condition {$$ = $1;}
;

function:	 '[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'{ $$ = Function_null($2) ;}
		| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'{ $$ = Function_null($2) ;}
;

condition:	'[' tEQUALITY ',' expr ',' expr ']' {$$ = Function_null($2);}
		| '[' tGT ',' expr ',' expr ']' {$$ = Function_null($2);}
		| '[' tLT ',' expr ',' expr ']' {$$ = Function_null($2);}
		| '[' tGEQ ',' expr ',' expr ']' {$$ = Function_null($2);}
		| '[' tLEQ ',' expr ',' expr ']' {$$ = Function_null($2);}
;

returnStmt:	'[' tRETURN ',' expr ']'
		| '[' tRETURN ']'
;

parametersList: parametersList ',' tIDENT | tIDENT
;

exprList:	exprList ',' expr | expr
;

%%
/*
type
0->int
1->real
2->string
3->other
*/

ExpressionNode * Function_null(ExpressionNode * e){
	ExpressionNode * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
	temp->checker = -1;
	temp->type = 3;
	return temp;
}

ExpressionNode * create_numNode(NumberNode n){
	ExpressionNode * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
	int k = 0;
	// 0->integer
	// 1->real number
	if(strchr(n.value,'.') != NULL){
		k = 1;
	}
	temp->counter = 0;
	temp->checker = 1;
	temp->str_value = NULL;
	if(k == 0){
	temp->type = 0;
	temp->flag = 0;
	temp->value_int = atoi(n.value);
	temp->value_real = -1;
	}
	else if(k == 1){
	temp->type = 1;
	temp->flag = 1;
	temp->value_int = -1;
	temp->value_real = atof(n.value);
	}
	temp->lineNo = n.lineNo;
	return temp;
}

ExpressionNode * create_strNode(StrNode s){
	ExpressionNode * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
	temp->lineNo = s.lineNo;
	temp->checker =	1;
	temp->type = 2;
	temp->counter = 0;
	temp->value_int = -1;
	temp->value_real = -1;
	temp->str_value = s.value;
	return temp;
}

ExpressionNode * addFunc(int t, ExpressionNode * e1, ExpressionNode * e2){
	// -1->other, invalid
	// 0->int
	// 1->real
	// 2->string
	int a1 = checkFunc(e1);
	int a2 = checkFunc(e2);
	
	ExpressionNode  * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
	temp->lineNo = t;	

	if(e1->checker == 1 && e2->checker == 1){
	temp->checker = 1;

	if(e1->counter != e2->counter){
		if(e1->counter > e2->counter){ temp->counter = e1->counter + 1;}
		else{ temp->counter = e2->counter + 1;}
	}
	else{ temp->counter = e1->counter + 1;}

	if(a1 == 2 && a2 == 2){ // string-string
		temp->type = 2;
		temp->str_value = strcat(e1->str_value, e2->str_value);
		temp->value_int = e1->value_int;
		temp->value_real = e1->value_real;
		temp->flag = e1->flag;

	}
	else if(a1 == 0 && a2 == 0){ // int-int
		int m = (e1->value_int) + (e2->value_int);
		//char * int_to_str;
		//itoa(m,int_to_str,10);
		temp->type = 0;
		temp->value_int = m;
		temp->flag = e1->flag;
		temp->str_value = e1->str_value;
		temp->value_real = e1->value_real;
	}
	else if(a1 == 1 && a2 == 1){ // real-real
		double m = e1->value_real + e2->value_real;
		//char * d_to_s;
		//sprintf(d_to_s, "%f", m);
		temp->type = 1;
		temp->value_real = m;
		temp->value_int = e1->value_int;
		temp->flag = e1->flag;
		temp->str_value = e1->str_value;
	}
	else if(a1 == 0 && a2 == 1){ // int-real
		double m = e1->value_int + e2->value_real;
		//char * s;
		//sprintf(s, "%f", m);
		temp->type = 1;
		temp->value_real = m;
		temp->value_int = e2->value_int;
		temp->flag = e2->flag;
                temp->str_value = NULL;
	}
	else if(a1 == 1 && a2 == 0){// real-int
		double m = e1->value_real + e2->value_int;
		//char * s;
		//sprintf(s, "%f", m);
		temp->value_int = e1->value_int;
		temp->value_real = m;
		temp->flag = e1->flag;
		temp->str_value = NULL;
		temp->type = 1;
	}
	else{
		temp->checker = -1;
		temp->type = 3;
		temp->str_value = NULL;
		temp->value_int = -1;
		temp->value_real = -1;
	}
	addList(temp);
	}
	else{
	temp->checker = -1;
	}
	return temp;
}

void addList(ExpressionNode * e){

	if(e->counter > 1 && e->checker == 1){ // replace
		if(expressionIndex < expressionSize){
                	expressionList[expressionIndex - 1] = e;
        	}
		else{
             		expressionSize = expressionSize + expressionSize;
          		expressionList = realloc(expressionList, expressionSize);
                	expressionList[expressionIndex - 1] = e;
        	}
	}
	else{
		if(e->checker == -1){
			if(e->counter == 1){
			if(expressionIndex < expressionSize){
        	                expressionList[expressionIndex] = e;
                	        expressionIndex += 1;
                	}
                	else{
                        	expressionSize = expressionSize + expressionSize;
                        	expressionList = realloc(expressionList, expressionSize);
                        	expressionList[expressionIndex] = e;
                        	expressionIndex += 1;
                	}
			}
			else if(e->counter > 1){
				ExpressionNode  * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
				temp->counter = expressionList[expressionIndex-1]->counter;
				temp->checker = expressionList[expressionIndex-1]->checker;
				temp->type = expressionList[expressionIndex-1]->type;
				temp->str_value = expressionList[expressionIndex-1]->str_value;
				temp->value_int = expressionList[expressionIndex-1]->value_int;
				temp->value_real = expressionList[expressionIndex-1]->value_real;
				temp->lineNo = expressionList[expressionIndex-1]->lineNo;			
			if(expressionIndex < expressionSize){
                                expressionList[expressionIndex] = temp;
				expressionList[expressionIndex-1] = e;
                                expressionIndex += 1;
                        }
			else{
                             	expressionSize = expressionSize + expressionSize;
                                expressionList = realloc(expressionList, expressionSize);
                                expressionList[expressionIndex] = temp;
				expressionList[expressionIndex-1] = e;
                                expressionIndex += 1;
                        }
			}	
		}
		else{
		if(expressionIndex < expressionSize){
                        expressionList[expressionIndex] = e;
                        expressionIndex += 1;
                }
		else{
                        expressionSize = expressionSize + expressionSize;
                     	expressionList = realloc(expressionList, expressionSize);
                        expressionList[expressionIndex] = e;
			expressionIndex += 1;
		}
		}
	}
	
}


int checkFunc(ExpressionNode * e1){
	// -1->other
	// 0->int
        // 1->real
        // 2->string
        int a1 = -1;

	// check e1
        if(e1->str_value == NULL){
                if(e1->type == 0){
                a1 = 0;
                }
                else if(e1->type == 1){
                a1 = 1;
                }
        }
	else if(e1->str_value != NULL){
                if(e1->type == 2){
                a1 = 2;
                }
        }
	
	return a1;
}


ExpressionNode * subFunc(int t, ExpressionNode * e1, ExpressionNode * e2){
	int a1 = checkFunc(e1);
	int a2 = checkFunc(e2);
	
	ExpressionNode  * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
        temp->lineNo = t;

	if(e1->checker == 1 && e2->checker == 1){
	temp->checker = 1;

	if(e1->counter != e2->counter){
	        if(e1->counter > e2->counter){ temp->counter = e1->counter + 1;}
                else{ temp->counter = e2->counter + 1;}
        }
	else{ temp->counter = e1->counter + 1;}

	if(a1 == 0 && a2 == 0){ // int-int
                int m = (e1->value_int) - (e2->value_int);
                temp->value_int = m;
		temp->type = 0;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
                temp->value_real = e1->value_real;
	}
        else if(a1 == 1 && a2 == 1){ // real-real
                double m = e1->value_real - e2->value_real;
                temp->value_real = m;
		temp->type = 1;
                temp->value_int = e1->value_int;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
        }
	else if(a1 == 0 && a2 == 1){ // int-real
                double m = e1->value_int - e2->value_real;
          	temp->value_real = m;
		temp->type = 1;
                temp->value_int = e2->value_int;
             	temp->flag = e2->flag;
                temp->str_value = NULL;
        }
        else if(a1 == 1 && a2 == 0){// real-int
                double m = e1->value_real - e2->value_int;
                //char * s;
		temp->type = 1;
                //sprintf(s, "%f", m);
                temp->value_int = e1->value_int;
                temp->value_real = m;
                temp->flag = e1->flag;
                temp->str_value = NULL;
        }
	else{
		temp->checker = -1;
		temp->type = 3;
		temp->str_value = NULL;
                temp->value_int = -1;
                temp->value_real = -1;
	}
	addList(temp);
	}
	else{
	temp->checker = -1;
	}
	return temp;
}

ExpressionNode * divFunc(int t, ExpressionNode * e1, ExpressionNode * e2){
	int a1 = checkFunc(e1);
        int a2 = checkFunc(e2);

	ExpressionNode  * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
        temp->lineNo = t;

	if(e1->checker == 1 && e2->checker == 1){
	temp->checker = 1;
	
	if(e1->counter != e2->counter){
	        if(e1->counter > e2->counter){ temp->counter = e1->counter + 1;}
                else{ temp->counter = e2->counter + 1;}
        }
	else{ temp->counter = e1->counter + 1;}

	if(a1 == 0 && a2 == 0){ // int-int
                int m = (e1->value_int) / (e2->value_int);
                temp->value_int = m;
		temp->type = 0;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
                temp->value_real = e1->value_real;
        }
	else if(a1 == 1 && a2 == 1){ // real-real
                double m = e1->value_real / e2->value_real;
                temp->value_real = m;
		temp->type = 1;
                temp->value_int = e1->value_int;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
        }
	else if(a1 == 0 && a2 == 1){ // int-real
                double m = e1->value_int / e2->value_real;
                temp->value_real = m;
		temp->type = 1;
                temp->value_int = e2->value_int;
                temp->flag = e2->flag;
	        temp->str_value = NULL;
        }
        else if(a1 == 1 && a2 == 0){// real-int
                double m = e1->value_real / e2->value_int;
                //char * s;
                //sprintf(s, "%f", m);
                temp->type = 1;
		temp->value_int = e1->value_int;
                temp->value_real = m;
                temp->flag = e1->flag;
                temp->str_value = NULL;
        }
        else{
		temp->checker = -1;
		temp->type = 3;
                temp->str_value = NULL;
                temp->value_int = -1;
                temp->value_real = -1;
        }
	addList(temp);
	}
	else{
	temp->checker = -1;
        }
	return temp;
}


ExpressionNode * mulFunc(int t, ExpressionNode * e1, ExpressionNode * e2){
	int a1 = checkFunc(e1);
        int a2 = checkFunc(e2);
	
	ExpressionNode * temp = (ExpressionNode *)malloc(sizeof(ExpressionNode));
        temp->lineNo = t;

	if(e1->checker == 1 && e2->checker == 1){
	temp->checker = 1;
	
	if(e1->counter != e2->counter){
	        if(e1->counter > e2->counter){ temp->counter = e1->counter + 1;}
                else{ temp->counter = e2->counter + 1;}
        }
	else{ temp->counter = e1->counter + 1;}

	if(a1 == 0 && a2 == 0){ // int-int
                int m = (e1->value_int) * (e2->value_int);
                temp->value_int = m;
		temp->type = 0;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
                temp->value_real = e1->value_real;
        }
	else if(a1 == 1 && a2 == 1){ // real-real
                double m = e1->value_real * e2->value_real;
                temp->value_real = m;
		temp->type = 1;
                temp->value_int = e1->value_int;
                temp->flag = e1->flag;
                temp->str_value = e1->str_value;
        }
	else if(a1 == 0 && a2 == 1){ // int-real
             	double m = e1->value_int * e2->value_real;
                temp->value_real = m;
		temp->type = 1;
                temp->value_int = e2->value_int;
                temp->flag = e2->flag;
                temp->str_value = NULL;
	}
        else if(a1 == 1 && a2 == 0){// real-int
                double m = e1->value_real * e2->value_int;
                //char * s;
                //sprintf(s, "%f", m);
                temp->type = 1;
		temp->value_int = e1->value_int;
                temp->value_real = m;
                temp->flag = e1->flag;
                temp->str_value = NULL;
        }
	else if(a1 == 0 && a2 == 2){// int-string
		int m = e1->value_int;
		char * s = (char *)malloc(sizeof(char));
		sprintf(s, "%d", m);
		if(strchr(s, '-') == NULL){// non-negative
		char * s1 = (char *)malloc(sizeof(char));
		char * s2;
		s2 = e2->str_value;
		int i = 0;
		for(;i<e1->value_int; i++){
			strcat(s1,s2);
		}
		temp->type = 2;
		temp->str_value = s1;
		temp->value_int = e2->value_int;
                temp->value_real = e2->value_real;
                temp->flag = e2->flag;
		}
		else{
		temp->type = 3;
		temp->str_value = NULL;
                temp->value_int = -1;
                temp->value_real = -1;
		}
	}
        else{
		temp->checker = -1;
		temp->type = 3;
                temp->str_value = NULL;
                temp->value_int = -1;
                temp->value_real = -1;
        }
	addList(temp);
	}
	else{
	temp->checker = -1;
        }
	return temp;
}

int main ()
{
	expressionList = (ExpressionNode **)malloc(expressionSize * sizeof(ExpressionNode*));
	
	if (yyparse()) {
		// parse error
		printf("ERROR\n");
		return 1;
	}
	else {	
		int i = 0;
		for(; i < expressionIndex; i++){
		if(expressionList[i]->type == 2){
		printf("Result of expression on %d is (%s)\n", expressionList[i]->lineNo, expressionList[i]->str_value);
		}
		else if(expressionList[i]->type == 0){
		printf("Result of expression on %d is (%d)\n", expressionList[i]->lineNo, expressionList[i]->value_int);
		}
		else if(expressionList[i]->type == 1){
		printf("Result of expression on %d is (%.1f)\n", expressionList[i]->lineNo, expressionList[i]->value_real);
		}
		else if (expressionList[i]->type == 3){
		printf("Type mismatch on %d\n", expressionList[i]->lineNo);
		}
		}
		return 0;
	}
}

