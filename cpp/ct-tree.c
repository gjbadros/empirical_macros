
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         tree.c
    ##
    ##     Revision 0.0.0.2  1996/04/03  10:26:06  kurt
    ##     Added line,column to some printouts;
    ##     addresses of nodes printed out, too.
    ##     -- Kurt Cockrum <kurt@grogatch.seaslug.org>
    ##
    ##     Revision 0.0.0.1  1996/04/03  10:08:46  kurt
    ##     o	missing return() in make_for()
    ##     o misc. cleanups
    ##     -- Kurt Cockrum <kurt@grogatch.seaslug.org>
    ##
    ##     Revision 0.0.0.0  1996/03/30  02:49:41  kurt
    ##     o	added right curly brackets inside comments for benefit of vi
    ##     o	Addresses of tree nodes are printed in messages;
    ##     	minor content changes to some messages
    ##     o	Threw away ntype[]
    ##     o   Rev. 0.0 from
    ##         -rw-r--r--  1 1047 1047 44198 Aug  7 19:32
    ##             ftp://ftp.cs.wisc.edu/coral/tmp/spf/ctree.0.01.tar.gz
    ##     -- Kurt Cockrum <kurt@grogatch.seaslug.org>
    ##
    ##     Programmer:   Shaun Flisakowski
    ##     Date:         Jan 21, 1995
    ##
    ##
    ###############################################################  */

#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>
#include    <assert.h>

#include    "tree.h"
#include    "gram.h"
#include    "globals.h"
#include    "token.h"

/*  ###############################################################  */
if_node *make_if(tn_t type)
{
    if_node *tmp_node;

    if ((tmp_node = (if_node *) HeapAlloc(Parse_TOS->node_heap)) != NULL){
        tmp_node->which = IF_T;
        tmp_node->type  = type;
        tmp_node->cond  = (treenode *) NULL;
        tmp_node->then_n = (treenode *) NULL;
        tmp_node->else_n = (treenode *) NULL;
        return(tmp_node);
    } 

    fputs("Error: Out of memory in make_if().\n",stderr);
    exit(1);
}

/*  ###############################################################  */
for_node *make_for(tn_t type)
{
    for_node *tmp_node;

    if ((tmp_node = (for_node *) HeapAlloc(Parse_TOS->node_heap)) != NULL){
        tmp_node->which = FOR_T;
        tmp_node->type = type;
        tmp_node->init = (treenode *) NULL;
        tmp_node->test = (treenode *) NULL;
        tmp_node->incr = (treenode *) NULL;
        tmp_node->stemnt = (treenode *) NULL;
		return(tmp_node);
    } 

    fputs("Error: Out of memory in make_for().\n",stderr);
    exit(1);
}

/*  ###############################################################  */
leafnode *make_leaf(tn_t type)
{
    leafnode *tmp_node;

    if ((tmp_node = (leafnode *) HeapAlloc(Parse_TOS->node_heap)) != NULL){

        tmp_node->which = LEAF_T;
        tmp_node->type = type;
        return(tmp_node);
    } 

    fputs("Error: Out of memory in make_leaf().\n",stderr);
    exit(1);
}

/*  ###############################################################  */
treenode *make_node(tn_t type)
{
    treenode *tmp_node;

    if ((tmp_node = (treenode *) HeapAlloc(Parse_TOS->node_heap)) != NULL){

        tmp_node->which = NODE_T;
        tmp_node->type  = type;

        tmp_node->lnode = (treenode *) NULL;
        tmp_node->rnode = (treenode *) NULL;

        return(tmp_node);
    } 

    fputs("Error: Out of memory in make_node().\n",stderr);
    exit(1);
}

/*  ###############################################################  */
void free_tree(treenode *root)
{
    leafnode *leaf;
    if_node  *ifn;
    for_node *forn;

    if (!root)
        return;

    switch (root->which){
  
    case LEAF_T:
        leaf = (leafnode *) root;
        if (leaf->tok == STRING)
            free(leaf->data.str);
        break;
 
    case NODE_T:
        free_tree(root->lnode);
        free_tree(root->rnode);
        break;
    
    case IF_T:
        ifn = (if_node *) root; 
        free_tree(ifn->cond);
        free_tree(ifn->then_n);
        free_tree(ifn->else_n);
        break;
    
    case FOR_T:
        forn = (for_node *) root;
        free_tree(forn->init);
        free_tree(forn->test);
        free_tree(forn->incr);
        free_tree(forn->stemnt);
        break;
    
    default:
    case NONE_T:
        break;
    }

    HeapFree(Parse_TOS->node_heap,root);
    /*  free(root);  */
}

/*  ###############################################################  */
leafnode *leftmost(treenode *root)
{
    if_node *ifn;
    for_node *forn;
    
    switch (root->which){
      
    case LEAF_T:
        return((leafnode *) root);
        break;
     
    case NODE_T:
        if (root->lnode)
            return(leftmost(root->lnode));
        else if (root->rnode)
            return(leftmost(root->rnode));
        fprintf(stderr,"\
Tree node 0x%0x with no children reached in leftmost().\n",
                (unsigned int) root); 
        break;
        
    case IF_T:
        ifn = (if_node *) root;
        if (ifn->cond)
            return(leftmost(ifn->cond));
        else if (ifn->then_n)
            return(leftmost(ifn->then_n));
        else if (ifn->else_n)
            return(leftmost(ifn->else_n));
        fprintf(stderr,"\
If-node 0x%0x with no children reached in leftmost().\n", 
                (unsigned int) root); 
        break;
        
    case FOR_T:
        forn = (for_node *) root;
        if (forn->init)
            return(leftmost(forn->init));
        else if (forn->test)
            return(leftmost(forn->test));
        else if (forn->incr)
            return(leftmost(forn->incr));
        else if (forn->stemnt)
            return(leftmost(forn->stemnt));
        fprintf(stderr,"\
For-node 0x%0x with no children reached in leftmost().\n",
                (unsigned int) root); 
        break;
        
    case NONE_T:
    default:
        fprintf(stderr, "\
Internal error: unknown node 0x%0x in leftmost();\n\
	type is: %d\n", (unsigned int) root, root->which);
        break;
    }

    return((leafnode *) NULL);
}

/*  ###############################################################  */
leafnode *rightmost(treenode *root)
{
    if_node *ifn;
    for_node *forn;
    
    switch (root->which){
      
    case LEAF_T:
        return((leafnode *) root);
        break;
     
    case NODE_T:
        if (root->rnode)
            return(rightmost(root->rnode));
        else if (root->lnode)
            return(rightmost(root->lnode));
        fprintf(stderr,"\
Tree node 0x%0x with no children reached in rightmost().\n",
                (unsigned int) root); 
        break;
        
    case IF_T:
        ifn = (if_node *) root;
        if (ifn->else_n)
            return(rightmost(ifn->else_n));
        else if (ifn->then_n)
            return(rightmost(ifn->then_n));
        else if (ifn->cond)
            return(rightmost(ifn->cond));
        fprintf(stderr,"\
If node 0x%0x with no children reached in rightmost().\n",
                (unsigned int) root); 
        break;
        
    case FOR_T:
        forn = (for_node *) root;
        if (forn->stemnt)
            return(rightmost(forn->stemnt));
        else if (forn->incr)
            return(rightmost(forn->incr));
        else if (forn->test)
            return(rightmost(forn->test));
        else if (forn->init)
            return(rightmost(forn->init));
        fprintf(stderr,"\
For node 0x%0x with no children reached in rightmost().\n",
                (unsigned int) root); 
        break;
        
    case NONE_T:
    default:
        fprintf(stderr, "\
Internal error: unknown node 0x%0x in rightmost();\n\
	type is: %d\n", (unsigned int) root, root->which);
        break;
    }

    return((leafnode *) NULL);
}
    
/*  ###############################################################  */
/* Scans the typedef declaration node N for the ident
   naming the new type. --jsh */
leafnode *find_typedef_name(treenode *n)
{
    switch(n->which)
    {
    case LEAF_T:
	return (leafnode *)n;
	    
    case NODE_T:
	while(n != 0 && n->which != LEAF_T)
	{
	    switch(n->type)
	    {
	    case TN_DECL:
		n = n->rnode;
		break;

	    case TN_ARRAY_DECL:
		n = n->lnode;
		break;

	    case TN_PNTR:
		fprintf(stderr,
                    "Internal error: TN_PNTR reached in find_typedef_name!\n");
		return 0;

	    case TN_FUNC_DECL:
		n = n->rnode;
		break;

            case TN_PARAM_LIST:
              fprintf(stderr,
                      "find_typedef_name: got TN_PARAM_LIST\n");
              return 0;
              break;
              
	    default:
		fprintf(stderr,
                    "Internal error: "
                    "unknown node type (%d) in find_typedef_name()\n",
                    n->type);
		return 0;
	    }
	}
	return (leafnode *)n;

    case IF_T:
    case FOR_T:
    case NONE_T:
    default:
	fprintf(stderr,
            "Internal error: unknown node 0x%0x in find_typedef_name();\n"
            "  type is: %d\n", (unsigned int) n, n->which);
    }
    return 0;
}

/*  ###############################################################  */
leafnode *find_ident_name(treenode *n, treenode **rest)
{
    if (rest)
        *rest = (treenode*) NULL;

    switch(n->which)
    {
    case LEAF_T:
	return (leafnode *)n;
	    
    case NODE_T:
	while(n != 0 && n->which != LEAF_T)
	{
	    switch(n->type)
	    {
	    case TN_DECL:
		n = n->rnode;
		break;

	    case TN_ASSIGN:
	    case TN_ARRAY_DECL:
		n = n->lnode;
		break;

	    case TN_DECL_LIST:
	    case TN_PARAM_LIST:
                if (rest)
                  *rest = n->rnode;
		n = n->lnode;
		break;

	    case TN_PNTR:
		return 0;

	    case TN_FUNC_DECL:
		n = n->rnode;
		break;

            case TN_EMPTY:
              fprintf(stderr,
                      "find_ident_name -- got TN_EMPTY\n");
              return 0;
              break;
              
                
	    default:
		fprintf(stderr,
                    "Internal error: "
                    "unknown node type (%d) in find_ident_name()\n",
                    n->type);
		return 0;
	    }
	}
	return (leafnode *)n;

    case IF_T:
    case FOR_T:
    case NONE_T:
    default:
	fprintf(stderr,
            "Internal error: unknown node 0x%0x in find_ident_name();\n"
            "  type is: %d\n", (unsigned int) n, n->which);
    }
    return 0;
}

/*  ###############################################################  */
/* Scans the function declaration node N for the ident
   naming the new function. */
leafnode *find_func_name(treenode *n)
{
  for_node *f;

  while((n != 0) && (n->which != LEAF_T))
  {
    switch(n->which)
    {
    case LEAF_T:
      return (leafnode *)n;
        
    case NODE_T:
      switch(n->type)
        {
        case TN_DECL:
          n = n->rnode;
          break;

        case TN_PNTR:
          fprintf(stderr,
            "Internal error: TN_PNTR reached in find_func_name!\n");
          n = NULL;
          break;

        case TN_FUNC_DECL:
        n = n->lnode;
        break;

        default:
          fprintf(stderr,
                    "Internal error: "
                    "unknown node type (%d) in find_func_name()\n",
                    n->type);
          n = NULL;
          break;
        }
      break;

    case FOR_T:
        f = (for_node *) n;
        switch(n->type)
          {
          case TN_FUNC_DEF:
            n = f->test;
            break;

          default:
            break;
          }
        break;

    case IF_T:
    case NONE_T:
    default:
    fprintf(stderr,
            "Internal error: unknown node 0x%0x in find_func_name();\n"
            "  type is: %d\n", (unsigned int) n, n->which);
        n = NULL;
        break;
    }
  }

  return (leafnode*) n;
}

/*  ###############################################################  */
