/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o
    o+
    o+     File:         tree_stk.h
    o+
    o+     Programmer:   Shawn Flisakowski
    o+     Date:         Apr 7, 1995
    o+
    o+     Stacks of trees being parsed
    o+         (to parse included files, as soon as they're seen)
    o+
    o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#ifndef TREE_STK_H
#define TREE_STK_H

#include <stdio.h>

#include "heap.h"
#include "tree.h"
#include "macro.h"
#include "symtab.h"

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

#define    YYBUFF_SIZE    4096

    /*  Redefinition - original provided by flex/lex */
#ifndef    YY_BUFFER_STATE_DEFD
typedef  struct yy_buffer_state  *YY_BUFFER_STATE;
#endif

#define    MX_NODE_1      max(LEAFNODE_SZE, TREENODE_SZE)
#define    MX_NODE_2      max(IFNODE_SZE, FORNODE_SZE)
#define    MX_NODE_SZE    max( MX_NODE_1 , MX_NODE_2 )

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

typedef  struct stk_item {

    treenode          *parse_tree;  /* Pointer to the parse tree */
    Heap              *node_heap;   /* Allocated tree nodes */

    char              *filename;    /* The name of the file */
    FILE              *yyin;        /* A pointer to an open file */

    int                yylineno;    /* Line number */
    int                yycolno;     /* Column number */
    int                yynxtcol;    /* next Column number */

    YY_BUFFER_STATE    yybuff;      /* A buffer for the lexer */

    struct stk_item   *next;        /* Ptr to next item in the stack */

} Stk_Item;

#define    STK_ITEM_SZE    (sizeof(Stk_Item))

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

typedef struct tree_stk {

    Stk_Item    *top;
    Stk_Item    *bottom;

    context_t   *contxt;

} TreeStack;

#define    TREESTK_SZE    (sizeof(TreeStack))

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

TreeStack *new_tree_stk();
void       delete_tree_stk(TreeStack *tree_stk);

Stk_Item  *new_stk_item( FILE *fp, char *fname);
void       delete_stk_item( Stk_Item *stk_item);

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

void      push(TreeStack *tree_stk, Stk_Item *stk_item);
void      put_on_bottom(TreeStack *tree_stk, Stk_Item *stk_item);
Stk_Item *pop(TreeStack *tree_stk);
int       is_empty(TreeStack *tree_stk);

Stk_Item *top_of_stack(TreeStack *tree_stk);
FILE     *top_file(TreeStack *tree_stk);
char     *top_filename(TreeStack *tree_stk);

void      reset_position(TreeStack *tree_stk);

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

int  tree_parse(TreeStack *tree_stk, int parse_all);

void handle_new_file(TreeStack *tree_stk, FILE *fp, char *fname);
int  get_next_file(TreeStack *tree_stk);
void abort_file(TreeStack *tree_stk);
   
#ifdef    CT_DEBUG 
void show_stack(TreeStack *tree_stk);
#endif

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

#endif    /* TREE_STK_H  */
