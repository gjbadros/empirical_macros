
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         prnttree.h
    ##
    ##     Programmer:   Shawn Flisakowski
    ##     Date:         March 27, 1995
    ##
    ##
    ###############################################################  */

#ifndef   PRNTTREE_H
#define   PRNTTREE_H

#include    <stdio.h>
#include    "tree.h"

/*  ###############################################################  */

    /*  External Declarations */
extern int debug_print_on;

   /*  indent - 2 spaces per level */
void  indent(int levels, FILE *fp);

void  fputs_metachr(char c, int in_str, FILE *fp);
   /* Print the string, converting chars to escape sequences. */
void  fputs_metastr(char *str, FILE *fp);

      /* Print the tree back out (as code - or close) */
void  print_tree(treenode *root, FILE *fp);
void  print_frag(treenode *root, FILE *fp);

void  show_leaf(leafnode *leaf, int tabs, FILE *fp);
void  show_tree(treenode *root, FILE *fp);

void  show_int_ntype(treenode *root, FILE *fp);

/*  ###############################################################  */

#endif    /* PRNTTREE_H */
