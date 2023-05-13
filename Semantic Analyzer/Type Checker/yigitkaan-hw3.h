#ifndef __YIGITKAAN_HW3_H
#define __YIGITKAAN_HW3_H
#include <stdbool.h>

typedef struct StrNode
{
	char *value;
	int lineNo;
} StrNode;

typedef struct NumberNode
{
	char *value;
	int lineNo;
} NumberNode;

typedef struct ExpressionNode
{
	int counter;
	int checker;
	int type;
	bool flag;
	char *str_value;
	int value_int;
	double value_real;
	int lineNo;
} ExpressionNode;

#endif

