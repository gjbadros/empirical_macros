// $Id$
// bison-stack.h
// By Greg J. Badros -- 9/28/97

#ifndef _BISON_STACK_H_
#define _BISON_STACK_H_

typedef YYSTYPE *yysstype_p;
typedef short   *yystate_p;

extern int yystacksize;
extern yystate_p yyss, yyssp;
extern yysstype_p yyvs, yyvsp;
#ifdef YYLSP_NEEDED
extern yysstype_p yyls, yylsp;
#endif

typedef int bool;
#ifndef TRUE
#define TRUE (1==1)
#endif
#ifndef FALSE
#define FALSE (1==0)
#endif

#define MAX_STATE_STACKS 32

void PushStackState();

bool FCompareTopStackState();

void PopAndRestoreStackState();

void PopAndDiscardStackState();

void SwapStackState();

void PushDupTopStackState();


#endif

