// $Id$
// bison-stack.c
// By Greg J. Badros -- 9/28/97
// 
// This file defines various utility functions for manipulating
// the bison stacks together.  My goal is to permit saving
// entire parse state, comparing the current parse state to a previously
// saved state, and restoring the parse state to a previously saved one.
//
// Initially, it appears that I'll want to be able to support these opns:
//   void PushStackState()
//   bool FCompareTopStackState()
//   void PopAndRestoreStackState()
//   void PopAndDiscardStackState()
//   void SwapStackState()
//   void PushDupTopStackState() -- duplicate top element of stack state
//
// #if    -> PushStackState()
// #else  -> SwapStackState()
// #endif -> PopAndDiscardStackState()
//
// #include -> PushStackState()
// done inclusion -> PopAndDiscardStackState()
//
// As far as I can tell, Bison uses 3 sets of 3 variables to maintain its state:
// yystacksize == the current stack size
//
// yyssa  ==  the initially allocated state stack
// yyss  --  the state stack
// yyssp --  the top of the state stack (== yyss-1 when empty)
//
// yyvsa  ==  the initially allocated semantic value stack
// yyvs  --  the semantic value stack
// yyvsp --  the top of the semantic value stack (== yyvs when empty)
//
// yylsa  ==  the initially allocated location stack
// yyls  --  the location stack
// yylsp --  the top of the location stack (== yyls when empty)
//
// Stacks all grow upward, and are doubled in size when filled.
//
// Current size is yyssp - yyss + 1
//
// These fns access the above bison information via variables made
// global by hand-editing of gram.tab.c, the bison output generated from the .y file

// Need to get the definition of YYSTYPE
#include <stdlib.h>
#include <assert.h>
#include "lexer.h"
#include "bison-stack.h"
// rgcelemState[0] is the number of elements in the oldest-saved (first-pushed)
// stack
static int rgcelemState[MAX_STATE_STACKS];
// rgpyystate[0] is the oldest element (first pushed) on the state
// it is a pointer to an array of shorts
static yystate_p rgpyyss[MAX_STATE_STACKS+1];
static yysstype_p rgpyyvs[MAX_STATE_STACKS+1];
#ifdef YYLSP_NEEDED
static yysstype_p rgpyyls[MAX_STATE_STACKS+1];
#endif
// isss == index into the stack of state stacks
static int isss = -1;

static yystate_p NewCopyOfRgss(yystate_p yyss,int csize)
{
  int cbyte = sizeof(yyss[0]) * (csize+1);
  yystate_p yyss_new = (yystate_p) malloc(cbyte);
  return memcpy(yyss_new,yyss,cbyte);
}

static yysstype_p NewCopyOfRgyystype(yysstype_p yysstype,int csize)
{
  int cbyte = sizeof(yysstype[0]) * (csize+1);
  yysstype_p yysstype_new = (yysstype_p) malloc(cbyte);
  return memcpy(yysstype_new,yysstype,cbyte);
}


// Copy current ss into rgXXX[isssDest]
static void CopyStackState(int isssDest)
{
  int size = yyssp-yyss+1;
  int celem = yyssp-yyss+1;
  rgcelemState[isssDest] = size;
  assert(rgpyyss[isssDest] == 0);
  rgpyyss[isssDest] = NewCopyOfRgss(yyss,celem);
  assert(rgpyyvs[isssDest] == 0);
  rgpyyvs[isssDest] = NewCopyOfRgyystype(yyvs,celem);
#ifdef YYLSP_NEEDED
  assert(rgpyyls[isssDest] == 0);
  rgpyyls[isssDest] = NewCopyOfRgyystype(yyls,celem);
#endif
}

// Get current ss from rgXXX[isssSource]
static void GetStackState(int isssSource)
{
  int size = rgcelemState[isssSource];
  yystate_p yyss_cur = yyss;
  yysstype_p yyvs_cur = yyvs;
#ifdef YYLSP_NEEDED
  yysstype_p yyls_cur = yyls;
#endif
  int i;
  assert(size <= yystacksize);
  for (i=0; i<size; i++)
    {
    *yyss_cur++ = *(rgpyyss[isssSource]+i);
    *yyvs_cur++ = *(rgpyyvs[isssSource]+i);
#ifdef YYLSP_NEEDED   
    *yyls_cur++ = *(rgpyyls[isssSource]+i);
#endif
    }
}

// Compare current ss to rgXXX[isssCompare]
static bool FCompareStackState(int isssCompare)
{
  int size = rgcelemState[isssCompare];
  yystate_p yyss_cur = yyss;
#ifdef 0
  //FIXGJB
  yysstype_p yyvs_cur = yyvs;
#endif
#ifdef YYLSP_NEEDED
  yysstype_p yyls_cur = yyls;
#endif
  int i;
  if (size != yyssp-yyss+1)
    return FALSE;

  assert(size <= yystacksize);
  for (i=0; i<size; i++)
    {
    if (*yyss_cur++ != *(rgpyyss[isssCompare]+i))
      return FALSE;
#ifdef 0
    //FIXGJB
    if (*yyvs_cur++ != *(rgpyyvs[isssCompare]+i))
      return FALSE;
#endif
#ifdef YYLSP_NEEDED   
    if (*yyls_cur++ != *(rgpyyls[isssCompare]+i))
      return FALSE;
#endif
    }
  return TRUE;
}

// Free memory and --isss
static void PopStackState()
{
  if (isss < 0)
    {
    fprintf(stderr,"****WARNING: PopStackState called with isss < 0!");
    return;
    }
  assert(isss >= 0);
  free(rgpyyss[isss]); rgpyyss[isss] = 0;
  free(rgpyyvs[isss]); rgpyyvs[isss] = 0;
#ifdef YYLSP_NEEDED
  free(rgpyyls[isss]); rgpyyls[isss] = 0;
#endif
  --isss;
}

void PushStackState()
{
  assert(isss < MAX_STATE_STACKS);
  CopyStackState(++isss);
}

bool FCompareTopStackState()
{
  return FCompareStackState(isss);
}

void PopAndRestoreStackState()
{
  GetStackState(isss);
  PopStackState();
}

void PopAndDiscardStackState()
{
  PopStackState();
}

void SwapStackState()
{
  CopyStackState(MAX_STATE_STACKS);
  GetStackState(isss);
  PopStackState();
  ++isss;
  rgpyyss[isss] = rgpyyss[MAX_STATE_STACKS];
  rgpyyvs[isss] = rgpyyvs[MAX_STATE_STACKS];
#ifdef YYLSP_NEEDED
  rgpyyls[isss] = rgpyyls[MAX_STATE_STACKS];
#endif
}

void PushDupTopStackState()
{
  rgpyyss[isss+1] = NewCopyOfRgss(rgpyyss[isss],rgcelemState[isss]);
  rgpyyvs[isss+1] = NewCopyOfRgyystype(rgpyyvs[isss],rgcelemState[isss]);
#ifdef YYLSP_NEEDED
  rgpyyls[isss+1] = NewCopyOfRgyystype(rgpyyls[isss],rgcelemState[isss]);
#endif
  ++isss;

}

int CStacksDeep()
{
  return isss+1;
}
