
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         tree.h
    ##
    ##     Programmer:   Shawn Flisakowski
    ##     Date:         Jan 21, 1995
    ##
    ##
    ###############################################################  */

#ifndef   TREE_H
#define   TREE_H

#include    "nmetab.h"

/*  ###############################################################  */

typedef enum tn_type {

    TN_EMPTY,

    TN_FUNC_DEF,
    TN_FUNC_DECL,
    TN_FUNC_CALL,
    TN_BLOCK,
    TN_DECL,
    TN_ARRAY_DECL,

    TN_TRANS_LIST,
    TN_DECL_LIST,
    TN_STEMNT_LIST,
    TN_EXPR_LIST,
    TN_NAME_LIST,
    TN_ENUM_LIST,
    TN_FIELD_LIST,
    TN_PARAM_LIST,
    TN_IDENT_LIST,

        /* Dumb, but I'm not sure what to do yet */
    TN_COMP_DECL,
    TN_BIT_FIELD,
    TN_PNTR,

            /* Stores a list of type specifiers/qualifers (int,const,etc) */
    TN_TYPE_LIST,
    TN_TYPE_NME,

            /* Stores initial values for arrays */
    TN_INIT_LIST,
    TN_INIT_BLK,

    TN_OBJ_DEF,    /* Definition of struct, union, or enum */
    TN_OBJ_REF,    /* Reference to struct, union, or enum */

        /* More vague */
    TN_CAST,
    TN_IF,
    TN_ASSIGN,
    TN_JUMP,
    TN_FOR,
    TN_WHILE,
    TN_DOWHILE,
    TN_SWITCH,
    TN_LABEL,
    TN_STEMNT,

    TN_INDEX,     /* Index with [] */
    TN_DEREF,     /* Dereference with * */
    TN_SELECT,    /* -> and . */

    TN_EXPR,
    TN_COND_EXPR,

    TN_COMMENT,
    TN_CPP,

    TN_IDENT,
    TN_TYPE,
    TN_STRING,
    TN_INT,
    TN_REAL

} tn_t;


typedef enum ct_node_type {

    NONE_T,
    LEAF_T,
    IF_T,
    FOR_T,
    NODE_T

} ct_node_type;

/*  ###############################################################  */

typedef struct tn {

    ct_node_type   which;
    int         line;
    int         col;
    int         tok;

    tn_t        type;

    struct tn  *lnode;
    struct tn  *rnode;

} treenode;

#define TREENODE_SZE        (sizeof(treenode))

/*  ###############################################################  */

typedef struct if_n {

    ct_node_type   which;
    int         line;
    int         col;
    int         tok;

    tn_t        type;

    treenode   *cond;
    treenode   *then_n;
    treenode   *else_n;

} if_node;

#define IFNODE_SZE        (sizeof(if_node))

/*  ###############################################################  */

typedef struct for_n {

    ct_node_type   which;
    int         line;
    int         col;
    int         tok;

    tn_t        type;

    treenode   *init;
    treenode   *test;
    treenode   *incr;
    treenode   *stemnt;

} for_node;

#define FORNODE_SZE        (sizeof(for_node))

/*  ###############################################################  */

struct type_item;

typedef struct ln {

    ct_node_type   which;
    int     line;
    int     col;
    int     tok;

    tn_t    type;

    union {
      int               cval;
      str_t            *sval;
      char             *str;
      int               ival;
      long int          l_ival;
      unsigned int      u_ival;
      unsigned long int ul_ival; 
      float             fval;
      double            dval;
      long double       l_dval;
    } data;

} leafnode;

#define LEAFNODE_SZE        (sizeof(leafnode))

/*  ###############################################################  */

    /*  External Declarations */

leafnode *make_leaf();
if_node  *make_if(tn_t type);
for_node *make_for(tn_t type);
treenode *make_node(tn_t type);

void      free_tree(treenode *root);

leafnode *leftmost(treenode *root);
leafnode *rightmost(treenode *root);

leafnode *find_typedef_name(treenode *n);
leafnode *find_ident_name(treenode *n, treenode **rest);
leafnode *find_func_name(treenode *n);

/*  ###############################################################  */

#endif    /* TREE_H */
