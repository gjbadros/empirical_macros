/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o
    o+
    o+     File:         tree_stk.c
    o+
    o+     Programmer:   Shaun Flisakowski
    o+     Date:         Apr 7, 1995
    o+
    o+     Stacks of trees being parsed
    o+         (to parse included files, as soon as they're seen)
    o+
    o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#include <stdio.h>

#include "globals.h"
#include "tree_stk.h"

char what_version[] = "@(#) Ctree Version 0.05";

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */

extern FILE *ct_yyin;

extern YY_BUFFER_STATE ct_yy_create_buffer( FILE *file, int size );
extern void            ct_yy_switch_to_buffer( YY_BUFFER_STATE buff );
extern void            ct_yy_delete_buffer( YY_BUFFER_STATE buff );

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
Stk_Item  *new_stk_item( FILE *fp, char *fname )
{
    Stk_Item *stk_item;

    if ((stk_item = malloc(STK_ITEM_SZE)) == NULL){
        return((Stk_Item *) NULL);
    }

    if ((stk_item->filename = malloc(strlen(fname)+1)) == NULL){
        free(stk_item);
        return((Stk_Item *) NULL);
    }
    strcpy(stk_item->filename, fname);

    if ((stk_item->yybuff = ct_yy_create_buffer(fp, YYBUFF_SIZE )) == NULL){
        free(stk_item->filename);
        free(stk_item);
        return((Stk_Item *) NULL);
    }

    if ((stk_item->node_heap  = CreateHeap(MX_NODE_SZE, 0)) == NULL){
        free(stk_item->filename);
        ct_yy_delete_buffer( stk_item->yybuff );
        free(stk_item);
        return((Stk_Item *) NULL);
    }

    stk_item->yyin     = fp;

    stk_item->yylineno = 1;
    stk_item->yycolno  = 0;
    stk_item->yynxtcol = 0;

    stk_item->parse_tree = (treenode *) NULL;

    stk_item->next = (Stk_Item *) NULL;

    return(stk_item);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void delete_stk_item( Stk_Item *stk_item )
{
    if (! stk_item)
        return;

    if (stk_item->yyin)
        fclose(stk_item->yyin);

    if (stk_item->parse_tree)
        free_tree(stk_item->parse_tree);

    if (stk_item->filename)
        free(stk_item->filename);

    if (stk_item->yybuff)
        ct_yy_delete_buffer(stk_item->yybuff);

    if (stk_item->node_heap)
        DestroyHeap(stk_item->node_heap);

    free(stk_item);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
TreeStack *new_tree_stk()
{
    TreeStack    *tree_stk;

    if ((tree_stk = malloc(TREESTK_SZE)) == NULL){
        return NULL;
    }

    tree_stk->top    = NULL;
    tree_stk->bottom = NULL;

    tree_stk->contxt = NULL;
    return tree_stk;
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void delete_tree_stk(TreeStack *tree_stk)
{
    if (! tree_stk)
        return;

    while(! is_empty(tree_stk))
        delete_stk_item(pop(tree_stk));

    free(tree_stk);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void push(TreeStack *tree_stk, Stk_Item *stk_item )
{
    if (! tree_stk || ! stk_item)
        return;

    stk_item->next = tree_stk->top;

    if (! tree_stk->top)
        tree_stk->bottom = stk_item;

    tree_stk->top = stk_item;
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
Stk_Item *pop(TreeStack *tree_stk)
{
    Stk_Item *stk_item, *nxt_item;

    if (is_empty(tree_stk))
        return((Stk_Item *) NULL);

    stk_item = tree_stk->top;
    nxt_item = tree_stk->top->next;

    if (! nxt_item)
        tree_stk->bottom = (Stk_Item *) NULL;

    tree_stk->top = nxt_item;

    return(stk_item);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void put_on_bottom(TreeStack *tree_stk, Stk_Item *stk_item)
{
    if (! tree_stk || ! stk_item)
        return;

    if (tree_stk->bottom)
        tree_stk->bottom->next = stk_item;

    if (! tree_stk->top)
        tree_stk->top = stk_item;

    tree_stk->bottom = stk_item;
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
int is_empty(TreeStack *tree_stk)
{
    if (! tree_stk)
        return(1);

    return(tree_stk->top == NULL);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
Stk_Item *top_of_stack(TreeStack *tree_stk)
{
    if (is_empty(tree_stk))
        return((Stk_Item *) NULL);
    else
        return(tree_stk->top);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
FILE *top_file(TreeStack *tree_stk)
{
    if (is_empty(tree_stk))
        return((FILE *) NULL);
    else
        return(tree_stk->top->yyin);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
char *top_filename(TreeStack *tree_stk)
{
    if (is_empty(tree_stk))
        return((char *) NULL);
    else
        return(tree_stk->top->filename);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void reset_position(TreeStack *tree_stk)
{
    if ( !(Parse_TOS = top_of_stack(tree_stk)))
        return;

    ct_yy_switch_to_buffer(Parse_TOS->yybuff);
    ct_yyin = top_file(tree_stk);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
int tree_parse(TreeStack *tree_stk, int parse_all)
{
    int cnt = 0;

    if (is_empty(tree_stk))
        return(0);

    do {
    
        while(ct_yyparse())
            ;

        cnt++;
        get_next_file(tree_stk);

        if (is_empty(tree_stk))
            break;

    } while (parse_all);

    return(cnt);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void handle_new_file(TreeStack *tree_stk, FILE *fp, char *fname)
{
    Stk_Item *stk_item;

    if ((stk_item = new_stk_item(fp, fname)) == NULL)
        return;

    push(tree_stk, stk_item);
    reset_position(tree_stk);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
int  get_next_file(TreeStack *tree_stk)
{
    if (is_empty(tree_stk)){
        Parse_TOS = (Stk_Item *) NULL;
        return(0);
    }

    if (DoneStack)
        push(DoneStack, pop(tree_stk));
    else {
        fputs("DoneStack was NULL.\n", stdout);
        delete_stk_item(pop(tree_stk));
    }

    reset_position(tree_stk);

    if (is_empty(tree_stk))
        return(0);

    return(1);
}

/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
void abort_file(TreeStack *tree_stk)
{
    if (is_empty(tree_stk)){
        Parse_TOS = (Stk_Item *) NULL;
        return;
    }

    delete_stk_item(pop(tree_stk));
    reset_position(tree_stk);
}
    
/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
#ifdef    CT_DEBUG
void show_stack(TreeStack *tree_stk)
{
    Stk_Item *tmp;

    fputs("-----Showing Stack: \n",stderr);
    if (tree_stk && tree_stk->top){

        fputs("Starting at top (current item being Parsed).\n",stderr);
        for (tmp=tree_stk->top; tmp; tmp=tmp->next){
            if (tmp->filename)
                fprintf(stderr, "%s:\t", tmp->filename);
            else
                fputs("--no name--:\t", stderr);
            fprintf(stderr, "Line: %d  Column: %d\n", tmp->yylineno, 
                    tmp->yycolno );
        }

    } else
        fputs("Stack is Empty.\n",stderr);

    fputs("-----Done Showing Stack \n",stderr);
}

#endif
/* o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o */
