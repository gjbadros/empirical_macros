
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         prnttree.c
    ##
    ##     Programmer:   Shaun Flisakowski
    ##     Date:         March 27, 1995
    ##
    ##
    ###############################################################  */

#include    <string.h>

#include    "prnttree.h"
#include    "token.h"
#include    "gram.h"

int  ptline, ptpos;

#ifdef    CT_DEBUG
#define    FPUTS(X,Y)     do { if (debug_print_on) fputs((X),(Y)); } while(0)
#else
#define    FPUTS(X,Y)    /* Nop */
#endif

int debug_print_on;

/*  ###############################################################  */

static int decl_cnt = 0;
static int just_left_blk = 0;
static int enum_list_cnt = 0;

static void show_if(if_node *ifn, int tabs, FILE *fp);
static void show_for(for_node *forn, int tabs, FILE *fp);
static void show_any(treenode *child, int tabs, FILE *fp);
static void show_node(treenode *node, int tabs, FILE *fp);

/*  ###############################################################  */
/*  indent - 2 spaces per level */
void indent(int levels, FILE *fp)
{
    int j;
#ifdef    CT_DEBUG
    if (debug_print_on && (levels != 0))
      fprintf(fp,"\n<indent %d>",levels);
    else
#endif
    for (j=levels; j > 0; j--)
      fputs("  ",fp);
}

/*  ###############################################################  */
/* Print a char, converting chars to escape sequences. */
void fputs_metachr(char c, int in_str, FILE *fp)
{
    switch (c) {
      case '\'':
        if (in_str) 
          fputs("'",fp);
        else
          fputs("\\'",fp);
        break;
      case '"':
        if (in_str) 
          fputs("\\\"",fp);
        else
          fputs("\"",fp);
        break;
      case '\0':
        fputs("\\0",fp);
        break;
      case '\\':
        fputs("\\\\",fp);
        break;
      case '\n':
        fputs("\\n",fp);
        break;
      case '\t':
        fputs("\\t",fp);
        break;
      case '\r':
        fputs("\\r",fp);
        break;
      case '\f':
        fputs("\\f",fp);
        break;
      case '\b':
        fputs("\\b",fp);
        break;
      case '\v':
        fputs("\\v",fp);
        break;
      case '\a':
        fputs("\\a",fp);
        break;
      default:
        fputc(c,fp);
    }
}

/*  ###############################################################  */
/* Print a string, converting chars to escape sequences. */
void fputs_metastr(char *str, FILE *fp)
{
  while (*str) {
    fputs_metachr(*str,1,fp);
    str++;
  }
}

/*  ###############################################################  */
int  print_recur(treenode *root, int level, FILE *fp)
{
    if_node  *ifn;
    for_node *forn;
    leafnode *leaf;

    if (!root)
        return(0);

    just_left_blk = 0;

    switch (root->which){
   
    default:
    case NONE_T:
        fputs("\nERROR: Node with no type.\n", fp);
        return 0;

    case LEAF_T:
        leaf = (leafnode *) root;
        switch (leaf->type) {

        case TN_LABEL:
            FPUTS("[TN_LABEL]", fp);
            if (leaf->tok == DEFLT)
              fputs("default",fp);
            else
              fputs(leaf->data.sval->str,fp);
            fputs(":\n",fp);
            FPUTS("{TN_LABEL}", fp);
            break;

        case TN_IDENT:
            FPUTS("[TN_IDENT]", fp);
            fputs(leaf->data.sval->str,fp);
            FPUTS("{TN_IDENT}", fp);
            break;

        case TN_COMMENT:
            fputs("\n",fp);
            fputs(leaf->data.str, fp);
            fputs("\n",fp);
            break;

        case TN_STRING:
            fputs("\"", fp);
            fputs_metastr(leaf->data.str,fp);
            fputs("\"", fp);
            break;

        case TN_TYPE:
            FPUTS("[TN_TYPE]", fp);
            if (leaf->tok != TYPEDEF_NAME)
              fputs(toksym(leaf->tok,1), fp);
            else {
              fputs(leaf->data.sval->str,fp);
              fputs(" ", fp);
            }
            FPUTS("{TN_TYPE}", fp);
            break;

        case TN_INT:
            if (leaf->tok == CHAR_CONST) {
              fputs("'",fp);
              fputs_metachr(leaf->data.ival, 0, fp);
              fputs("'",fp);
            } else
              fprintf(fp, "%d", leaf->data.ival);
            break;

        case TN_REAL:
            fprintf(fp, "%f", leaf->data.dval);
            break;

        default:
            fprintf(fp, "Unknown leaf value\n" );
            break;
        }
        break;

    case IF_T:
        ifn = (if_node *) root;
        switch (ifn->type) {

        case TN_IF:
            FPUTS("[TN_IF]", fp);
            fputs("if (", fp);
            print_recur(ifn->cond, level, fp);
            fputs(")\n", fp);
            print_recur(ifn->then_n, level+1, fp);
            if (ifn->else_n) {
                if (just_left_blk) {
                  indent(level,fp);
                  fputs("else\n", fp);
                } else {
                  fputs(";\n",fp);
                  indent(level,fp);
                  fputs("else\n", fp);
                }
                print_recur(ifn->else_n, level+1, fp);
            }
            FPUTS("{TN_IF}", fp);
            return(0);

        case TN_COND_EXPR:
            FPUTS("[TN_COND_EXPR]", fp);
            fputs("(", fp);
            print_recur(ifn->cond, level, fp);
            fputs(") ? (", fp);
            print_recur(ifn->then_n, level, fp);
            fputs(") : (", fp);
            print_recur(ifn->else_n, level, fp);
            fputs(")", fp);
            FPUTS("{TN_COND_EXPR}", fp);
            break;

        default:
            fprintf(fp, "Unknown type of if node.\n");
            break;
        }
        break;

    case FOR_T:
        forn = (for_node *) root;
        switch (forn->type) {

        case TN_FUNC_DEF:
            FPUTS("[TN_FUNC_DEF]", fp);
            print_recur(forn->init, level, fp);
            print_recur(forn->test, level, fp);
            if (forn->test->which == LEAF_T)
                fputs("()", fp);
            print_recur(forn->incr, level, fp);
            fputs("\n", fp);
            print_recur(forn->stemnt, level, fp);
            fputs("\n", fp);
            FPUTS("{TN_FUNC_DEF}", fp);
            break;

        case TN_FOR:
            FPUTS("[TN_FOR]", fp);
            fputs("for (", fp);
            print_recur(forn->init, level, fp);
            fputs("; ", fp);
            print_recur(forn->test, level, fp);
            fputs("; ", fp);
            print_recur(forn->incr, level, fp);
            fputs(")\n", fp);
            print_recur(forn->stemnt, level+1, fp);
            FPUTS("{TN_FOR}", fp);
            return 0;

        default:
            fprintf(fp, "Unknown type of for node.\n");
            break;
        }
        break;

    case NODE_T:
        switch (root->type) {

        case TN_TRANS_LIST:
            FPUTS("[TN_TRANS_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_TRANS_LIST}", fp);
            break;

        case TN_FUNC_DECL:
            FPUTS("[TN_FUNC_DECL]", fp);
            decl_cnt++;
            if (root->lnode && (root->lnode->type == TN_IDENT))
                print_recur(root->lnode, level, fp);
            else {
                fputs("(",fp);
                print_recur(root->lnode, level, fp);
                fputs(")",fp);
            }
            fputs("(",fp);
            print_recur(root->rnode, level, fp);
            fputs(")",fp);
            decl_cnt--;
            FPUTS("{TN_FUNC_DECL}", fp);
            break;

        case TN_FUNC_CALL:
            FPUTS("[TN_FUNC_CALL]", fp);
            print_recur(root->lnode, level, fp);
            fputs("(", fp);
            print_recur(root->rnode, level, fp);
            fputs(")", fp);
            FPUTS("{TN_FUNC_CALL}", fp);
            break;

        case TN_BLOCK:
            FPUTS("[TN_BLOCK]", fp);
            fputs("{\n", fp);
            print_recur(root->lnode, level+1, fp);
            print_recur(root->rnode, level+1, fp);
            indent(level,fp);
            fputs("}\n", fp);
            just_left_blk = 1;
            FPUTS("{TN_BLOCK}", fp);
            return(0);

        case TN_ARRAY_DECL:
            FPUTS("[TN_ARRAY_DECL]", fp);
            print_recur(root->lnode, level, fp);
            fputs("[", fp);
            print_recur(root->rnode, level, fp);
            fputs("]", fp);
            FPUTS("{TN_ARRAY_DECL}", fp);
            break;

        case TN_EXPR_LIST:
            FPUTS("[TN_EXPR_LIST]", fp);
            print_recur(root->lnode, level, fp);
            if (root->rnode)
              fputs(",", fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_EXPR_LIST}", fp);
            break;

        case TN_NAME_LIST:
            FPUTS("[TN_NAME_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_NAME_LIST}", fp);
            break;

        case TN_ENUM_LIST:
            FPUTS("[TN_ENUM_LIST]", fp);
            if (root->lnode
                  && (root->lnode->type != TN_ENUM_LIST))
              indent(level,fp);
            enum_list_cnt++;
            print_recur(root->lnode, level, fp);
            if (root->rnode)
              fputs(",\n",fp);
            indent(level,fp);
            print_recur(root->rnode, level, fp);
            if (--enum_list_cnt == 0)
              fputs("\n",fp);
            FPUTS("{TN_ENUM_LIST}", fp);
            break;

        case TN_FIELD_LIST:
            FPUTS("[TN_FIELD_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_FIELD_LIST}", fp);
            break;

        case TN_PARAM_LIST:
            FPUTS("[TN_PARAM_LIST]", fp);
            print_recur(root->lnode, level, fp);
            if (root->rnode)
              fputs(",",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_PARAM_LIST}", fp);
            break;

        case TN_IDENT_LIST:
            FPUTS("[TN_IDENT_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_IDENT_LIST}", fp);
            break;

        case TN_TYPE_LIST:
            FPUTS("[TN_TYPE_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_TYPE_LIST}", fp);
            break;

        case TN_DECL:
            FPUTS("[TN_DECL]", fp);
            if (decl_cnt == 0)
              indent(level,fp);
            decl_cnt++;
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            if (--decl_cnt == 0)
              fputs(";\n",fp);
            FPUTS("{TN_DECL}", fp);
            break;

        case TN_DECL_LIST:
            FPUTS("[TN_DECL_LIST]", fp);
            print_recur(root->lnode, level, fp);
            if (root->rnode && (root->rnode->type == TN_IDENT))
              fputs(",",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_DECL_LIST}", fp);
            break;

        case TN_STEMNT_LIST:
            FPUTS("[TN_STEMNT_LIST]", fp);
            print_recur(root->lnode, level, fp);
            if (root->lnode
                    && (!just_left_blk)
                    && (root->lnode->type != TN_STEMNT_LIST)) {
                fputs(";\n", fp);
            }

            if (root->rnode != NULL) {
                print_recur(root->rnode, level, fp);
                if (!just_left_blk) {
                    fputs(";\n", fp);
                }
            }
            FPUTS("{TN_STEMNT_LIST}", fp);
            break;

        case TN_STEMNT:
            FPUTS("[TN_STEMNT]", fp);
            if (root->rnode && (root->rnode->type == TN_LABEL))
              indent(level-1,fp);
            else
              indent(level,fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_STEMNT}", fp);
            break;

        case TN_COMP_DECL:
            FPUTS("[TN_COMP_DECL]", fp);
            indent(level,fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            fputs(";\n",fp);
            FPUTS("{TN_COMP_DECL}", fp);
            break;

        case TN_BIT_FIELD:
            FPUTS("[TN_BIT_FIELD]", fp);
            print_recur(root->lnode, level, fp);
            fputs(":",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_BIT_FIELD}", fp);
            break;

        case TN_PNTR:
            FPUTS("[TN_PNTR]", fp);
            fputs("*", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_PNTR}", fp);
            break;

        case TN_TYPE_NME:
            FPUTS("[TN_TYPE_NME]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_TYPE_NME}", fp);
            break;

        case TN_INIT_LIST:
            FPUTS("[TN_INIT_LIST]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_INIT_LIST}", fp);
            break;

        case TN_INIT_BLK:
            FPUTS("[TN_INIT_BLK]", fp);
            print_recur(root->lnode, level, fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_INIT_BLK}", fp);
            break;

        case TN_OBJ_DEF:
            FPUTS("[TN_OBJ_DEF]", fp);
            leaf = (leafnode *) root;
            fputs(toksym(leaf->tok,1), fp);
            print_recur(root->lnode, level, fp);
            fputs(" {\n",fp);
            print_recur(root->rnode, level+1, fp);
            fputs("}",fp);
            FPUTS("{TN_OBJ_DEF}", fp);
            break;

        case TN_OBJ_REF:
            FPUTS("[TN_OBJ_REF]", fp);
            leaf = (leafnode *) root;
            fputs(toksym(leaf->tok,1), fp);
            print_recur(root->lnode, level, fp);
            fputs(" ",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_OBJ_REF}", fp);
            break;

        case TN_CAST:
            FPUTS("[TN_CAST]", fp);
            decl_cnt++;    /* Not really, it's a hack. */
            fputs("(",fp);
            print_recur(root->lnode, level, fp);
            fputs(")",fp);
            decl_cnt--;
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_CAST}", fp);
            break;

        case TN_JUMP:
            FPUTS("[TN_JUMP]", fp);
            fputs(toksym(root->tok,1), fp);
            if (root->tok == RETURN){
                /*  fputs("(",fp);  */
                print_recur(root->lnode, level, fp);
                /*  fputs(")",fp);  */
            }
            FPUTS("{TN_JUMP}", fp);
            break;

        case TN_SWITCH:
            FPUTS("[TN_SWITCH]", fp);
            fputs("switch (", fp);
            print_recur(root->lnode, level, fp);
            fputs(")\n", fp);
            print_recur(root->rnode, level+1, fp);
            FPUTS("{TN_SWITCH}", fp);
            break;

        case TN_INDEX:
            FPUTS("[TN_INDEX]", fp);
            print_recur(root->lnode, level, fp);
            fputs("[",fp);
            print_recur(root->rnode, level, fp);
            fputs("]",fp);
            FPUTS("{TN_INDEX}", fp);
            break;

        case TN_DEREF:
            FPUTS("[TN_DEREF]", fp);
            fputs("*",fp);
            print_recur(root->lnode, level, fp);
            if (root->rnode && (root->rnode->type == TN_IDENT))
              print_recur(root->rnode, level, fp);
            else {
              fputs("(",fp);
              print_recur(root->rnode, level, fp);
              fputs(")",fp);
            }
            FPUTS("{TN_DEREF}", fp);
            break;

        case TN_SELECT:
            FPUTS("[TN_SELECT]", fp);
            print_recur(root->lnode, level, fp);
            fputs(".",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_SELECT}", fp);
            break;

        case TN_ASSIGN:
            FPUTS("[TN_ASSIGN]", fp);
            print_recur(root->lnode, level, fp);
            fputs(toksym(root->tok,1), fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_ASSIGN}", fp);
            break;

        case TN_EXPR:
            FPUTS("[TN_EXPR]", fp);
            switch (root->tok) {
              case CASE:
                fputs(toksym(root->tok,1), fp);
                print_recur(root->lnode, level, fp);
                print_recur(root->rnode, level, fp);
                break;

              case SIZEOF:
                fputs(toksym(root->tok,0), fp);
                fputs("(", fp);
                print_recur(root->lnode, level, fp);
                print_recur(root->rnode, level, fp);
                fputs(")", fp);
                break;

              case INCR:
              case DECR:
                print_recur(root->lnode, level, fp);
                fputs(toksym(root->tok,1), fp);
                print_recur(root->rnode, level, fp);
                break;

              case B_AND:
                if (root->lnode == NULL) {
                  fputs(toksym(root->tok,1), fp);
                  fputs("(", fp);
                  print_recur(root->rnode, level, fp);
                  fputs(")", fp);
                  break;
                }

              default:
                fputs("(", fp);
                print_recur(root->lnode, level, fp);
                fputs(toksym(root->tok,1), fp);
                print_recur(root->rnode, level, fp);
                fputs(")", fp);
                break;
            }
            FPUTS("{TN_EXPR}", fp);
            break;

        case TN_WHILE:
            FPUTS("[TN_WHILE]", fp);
            fputs("while (", fp);
            print_recur(root->lnode, level, fp);
            fputs(")\n", fp);
            print_recur(root->rnode, level+1, fp);
            FPUTS("{TN_WHILE}", fp);
            return(0);

        case TN_DOWHILE:
            FPUTS("[TN_DOWHILE]", fp);
            fputs("do\n", fp);
            print_recur(root->rnode, level+1, fp);
            if (root->lnode && (root->lnode->type != TN_BLOCK))
                fputs(";", fp);
            fputs("\n",fp);
            indent(level,fp);
            fputs("while (", fp);
            print_recur(root->lnode, level, fp);
            fputs(")", fp);
            FPUTS("{TN_DOWHILE}", fp);
            break;

        case TN_LABEL:
            FPUTS("[TN_LABEL 2]", fp);
            print_recur(root->lnode, level, fp);
            if (root->lnode && (root->lnode->type != TN_LABEL))
              fputs(":\n",fp);
            print_recur(root->rnode, level, fp);
            FPUTS("{TN_LABEL 2}", fp);
            break;

        case TN_EMPTY:
        default:
            fprintf(fp, "Unknown type of tree node (%d).\n", root->type);
            return 0;
        }
        break;
    }

    return(1);
}
 
/*  ###############################################################  */
/* Print the tree back out (as code - or close) */
void  print_tree(treenode *root, FILE *fp)
{
    print_recur(root,0,fp);
}

/*  ###############################################################  */
void  print_frag(treenode *root, FILE *fp)
{
  decl_cnt = 1;
  print_recur(root,0,fp);
#ifdef  SHOW_TYPES
  if (root && (root->type == TN_DECL)) {
    treenode *typetree, *typenode;
    typetree = root->lnode;
    fputs("\nType: ",fp);

    while (typetree && (typetree->type == TN_TYPE_LIST)) {
      typenode = typetree->lnode;
      typetree = typetree->rnode;

      if (typenode && (typenode->type == TN_TYPE)) {
        print_recur(typenode,0,fp);
      }
    }
  }
#endif
  decl_cnt = 0;
}

/*  ###############################################################  */
void show_leaf(leafnode *leaf, int tabs, FILE *fp)
{
    indent(tabs,fp);
    fprintf(fp, "%d,%d Leaf node 0x%0x: ", leaf->line, leaf->col,
            (unsigned int) leaf);

    if (leaf == NULL){
        return;
    }

    switch(leaf->type){

    case TN_IDENT:
        fprintf(fp,"Identifier %s\n", nmestr(leaf->data.sval));
        break;

    case TN_TYPE:
        fprintf(fp,"Type %s\n", toksym(leaf->tok,0));
        break;

    case TN_INT:
        fprintf(fp,"Integer %d\n", leaf->data.ival);
        break;

    case TN_REAL:
        fprintf(fp,"Real %f\n", leaf->data.dval);
        break;

    case TN_STRING:
        fprintf(fp,"String \"%s\"\n", leaf->data.str);
        break;

    default:
        fprintf(fp,"Internal Error: Unknown type %d\n",
            leaf->type);
        break;
    }
}

/*  ###############################################################  */
static void show_node(treenode *node, int tabs, FILE *fp)
{
    indent(tabs,fp);

    if (node == NULL){
        fprintf(fp, "NULL node pointer 0x0\n");
        return;
    }

    fprintf(fp, "%d,%d ", node->line, node->col);
    switch(node->type){

    case TN_EMPTY:
        fprintf(fp, "Empty node 0x%0x; Token = \"%s\"\n",
                (unsigned int) node, toksym(node->tok,0)); 
        break;

    case TN_FUNC_DEF:
        fprintf(fp, "Function Definition node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_FUNC_DECL:
        fprintf(fp, "Function Declaration node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_FUNC_CALL:
        fprintf(fp, "Function Call node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_BLOCK:
        fprintf(fp, "Block Node 0x%0x:\n", (unsigned int) node);
        break;

    case TN_DECL:
        fprintf(fp, "Declaration node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_ARRAY_DECL:
        fprintf(fp, "Array Declaration node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_STEMNT_LIST:
        fprintf(fp, "Statement List Node 0x%0x:\n", (unsigned int) node);
        break;

    case TN_TRANS_LIST:
        fprintf(fp, "TN_TRANS_LIST node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_DECL_LIST:
        fprintf(fp, "TN_DECL_LIST node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_EXPR_LIST:
        fprintf(fp, "Expr list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_NAME_LIST:
        fprintf(fp, "Name list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_ENUM_LIST:
        fprintf(fp, "Enum list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_FIELD_LIST:
        fprintf(fp, "Field list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_PARAM_LIST:
        fprintf(fp, "Parameter list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_IDENT_LIST:
        fprintf(fp, "Identifier list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_COMP_DECL:
        fprintf(fp, "Component declarator node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_BIT_FIELD:
        fprintf(fp, "Bitfield node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_PNTR:
        fprintf(fp, "Pointer node 0x%0x:\n",
                (unsigned int) node);
        break;

    /* Stores a list of type specifiers/qualifiers (int:const:etc) */
    case TN_TYPE_LIST:
        fprintf(fp, "Type list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_TYPE_NME:
        fprintf(fp, "Type name node 0x%0x:\n",
                (unsigned int) node);
        break;

            /* Stores initial values for arrays */
    case TN_INIT_LIST:
        fprintf(fp, "Initializer list node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_INIT_BLK:
        fprintf(fp, "Initializer block node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_OBJ_DEF:    /* Definition of struct: union: or enum */
        fprintf(fp, "Struct/Union/Enum definition node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_OBJ_REF:    /* Reference to struct: union: or enum */
        fprintf(fp, "Struct/Union/Enum reference node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_CAST:
        fprintf(fp, "Cast node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_IF:
        fprintf(fp, "If node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_ASSIGN:
        fprintf(fp,"Assignment node 0x%0x: (%s)\n", (unsigned int) node,
                toksym(node->tok,0));
        break;

    case TN_JUMP:
        fprintf(fp,"Jump node 0x%0x: %s\n", (unsigned int) node,
                toksym(node->tok,0));
        break;

    case TN_FOR:
        fprintf(fp,"For node 0x%0x: %s\n", (unsigned int) node,
                toksym(node->tok,0)); 
        break;

    case TN_WHILE:
        fprintf(fp,"While node 0x%0x: %s\n", (unsigned int) node,
                toksym(node->tok,0)); 
        break;

    case TN_DOWHILE:
        fprintf(fp,"Do-while node 0x%0x: %s\n", (unsigned int) node,
                toksym(node->tok,0)); 
        break;

    case TN_SWITCH:
        fprintf(fp, "Switch node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_LABEL:
        fprintf(fp, "Label node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_STEMNT:
        fprintf(fp, "Statement node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_INDEX:     /* Index with [] */
        fprintf(fp, "Array index node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_DEREF:     /* Dereference with * */
        fprintf(fp, "Dereference node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_SELECT:    /* -> and . */
        fprintf(fp, "Struct selector node 0x%0x:\n",
                (unsigned int) node);
        break;

    case TN_EXPR:
        fprintf(fp,"Expression node 0x%0x: (%s)\n", (unsigned int) node,
                toksym(node->tok,0));
        break;

    case TN_COND_EXPR:
        fprintf(fp,"Conditional expression node 0x%0x: (%s)\n",
                (unsigned int) node, toksym(node->tok,0));
        break;

    case TN_IDENT:
        fprintf(fp,"Unexpected identifier node 0x%0x\n",
                (unsigned int) node);
        break;

    case TN_TYPE:
        fprintf(fp,"TN_TYPE node 0x%0x; Token is: %s\n",
                (unsigned int) node, toksym(node->tok,0)); 
        break;

    case TN_STRING:
        fprintf(fp,"Unexpected string node 0x%0x\n", (unsigned int) node);
        break;

    case TN_INT:
        fprintf(fp,"Unexpected integer node 0x%0x\n",
                (unsigned int) node);
        break;

    case TN_REAL:
        fprintf(fp,"Unexpected real node 0x%0x\n", (unsigned int) node);
        break;

    default:
        fprintf(fp,"Unknown node 0x%0x; internal error (type=%d)\n",
            (unsigned int) node, node->type);
        break;
    }

    indent(tabs,fp);
    fprintf(fp, "Left Child 0x%0x:\n", (unsigned int) node->lnode); 
    show_any(node->lnode,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, "Right Child 0x%0x:\n", (unsigned int) node->rnode); 
    show_any(node->rnode,tabs+1,fp);
}

/*  ###############################################################  */
static void show_if(if_node *ifn, int tabs, FILE *fp)
{
    int indx = 0;
    static char *heads[2][3] = {
        { "Test-expr 0x%0x:\n",
          "Then-statement 0x%0x:\n", "Else-statement 0x%0x:\n" },
        { "Conditional-expr 0x%0x:\n",
          "True-expr 0x%0x:\n", "False-expr 0x%0x:\n" }
    };

    indent(tabs,fp);

    if (ifn == NULL){
        fprintf(fp, "Unexpected Null If-node pointer 0x0\n");
        return;
    }

    if (ifn->tok == QUESTMARK)
        indx = 1;

    fprintf(fp, "%d,%d ", ifn->line, ifn->col);
    fprintf(fp, heads[indx][0], (unsigned int) ifn);
    show_any(ifn->cond,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, heads[indx][1], (unsigned int) ifn);
    show_any(ifn->then_n,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, heads[indx][2], (unsigned int) ifn);
    show_any(ifn->else_n,tabs+1,fp);
}

/*  ###############################################################  */
static void show_for(for_node *forn, int tabs, FILE *fp)
{
    int indx = 0;
    static char *heads[2][4] = {
        { "Initializer 0x%0x:\n", "Test 0x%0x:\n",
          "Incrementer 0x%0x:\n", "Statement 0x%0x:\n" },
        { "Function Type 0x%0x:\n", "Function Decl 0x%0x:\n",
          "Function Optional Decls (K&R) 0x%0x:\n", "Statement 0x%0x:\n" }
    };

    indent(tabs,fp);

    if (forn == NULL){
        fprintf(fp, "Unexpected Null For-node pointer 0x0\n");
        return;
    }

    if (forn->type == TN_FUNC_DEF)
        indx = 1;

    fprintf(fp, "%d,%d ", forn->line, forn->col);
    fprintf(fp, heads[indx][0], (unsigned int) forn);
    show_any(forn->init,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, heads[indx][1], (unsigned int) forn);
    show_any(forn->test,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, heads[indx][2], (unsigned int) forn);
    show_any(forn->incr,tabs+1,fp);

    indent(tabs,fp);
    fprintf(fp, heads[indx][3], (unsigned int) forn);
    show_any(forn->stemnt,tabs+1,fp);
}

/*  ###############################################################  */
static void show_any(treenode *child, int tabs, FILE *fp)
{
    if (!child){
        indent(tabs,fp);
        fputs("NULL node pointer 0x0\n",fp);
    } else {

        switch (child->which){
        case LEAF_T:
            show_leaf((leafnode *) child, tabs,fp);
            break;
     
        case NODE_T:
            show_node(child,tabs,fp);
            break;
        
        case IF_T:
            show_if((if_node *) child, tabs,fp);
            break;
        
        case FOR_T:
            show_for((for_node *) child, tabs,fp);
            break;
        
        case NONE_T:
			fprintf(fp, "Node 0x%0x: no-type\n", (unsigned int) child);
            break;

        default:
            fprintf(stderr,
                    "Node 0x%0x internal error: unknown which-type %d\n",
                    (unsigned int) child, child->which);
            break;
        }
    }
}

/*  ###############################################################  */
void show_tree(treenode *root, FILE *fp)
{
    fprintf(fp, "\nShowing parse tree 0x%0x:\n", (unsigned int) root);
    show_any(root,1,fp);
}

/*  ###############################################################  */
void show_int_ntype(treenode *root, FILE *fp)
{
  switch (root->type) {
    default:
      fputs("<Unknown node type>\n", fp);
      break;

    case TN_EMPTY:
      fputs("TN_EMPTY\n",fp);
      break;

    case TN_FUNC_DEF:
      fputs("TN_FUNC_DEF\n",fp);
      break;

    case TN_FUNC_DECL:
      fputs("TN_FUNC_DECL\n",fp);
      break;

    case TN_FUNC_CALL:
      fputs("TN_FUNC_CALL\n",fp);
      break;

    case TN_BLOCK:
      fputs("TN_BLOCK\n",fp);
      break;

    case TN_DECL:
      fputs("TN_DECL\n",fp);
      break;

    case TN_ARRAY_DECL:
      fputs("TN_ARRAY_DECL\n",fp);
      break;

    case TN_TRANS_LIST:
      fputs("TN_TRANS_LIST\n",fp);
      break;

    case TN_DECL_LIST:
      fputs("TN_DECL_LIST\n",fp);
      break;

    case TN_STEMNT_LIST:
      fputs("TN_STEMNT_LIST\n",fp);
      break;

    case TN_EXPR_LIST:
      fputs("TN_EXPR_LIST\n",fp);
      break;

    case TN_NAME_LIST:
      fputs("TN_NAME_LIST\n",fp);
      break;

    case TN_ENUM_LIST:
      fputs("TN_ENUM_LIST\n",fp);
      break;

    case TN_FIELD_LIST:
      fputs("TN_FIELD_LIST\n",fp);
      break;

    case TN_PARAM_LIST:
      fputs("TN_PARAM_LIST\n",fp);
      break;

    case TN_IDENT_LIST:
      fputs("TN_IDENT_LIST\n",fp);
      break;

    case TN_COMP_DECL:
      fputs("TN_COMP_DECL\n",fp);
      break;

    case TN_BIT_FIELD:
      fputs("TN_BIT_FIELD\n",fp);
      break;

    case TN_PNTR:
      fputs("TN_PNTR\n",fp);
      break;

    case TN_TYPE_LIST:
      fputs("TN_TYPE_LIST\n",fp);
      break;

    case TN_TYPE_NME:
      fputs("TN_TYPE_NME\n",fp);
      break;

    case TN_INIT_LIST:
      fputs("TN_INIT_LIST\n",fp);
      break;

    case TN_INIT_BLK:
      fputs("TN_INIT_BLK\n",fp);
      break;

    case TN_OBJ_DEF:
      fputs("TN_OBJ_DEF\n",fp);
      break;

    case TN_OBJ_REF:
      fputs("TN_OBJ_REF\n",fp);
      break;

    case TN_CAST:
      fputs("TN_CAST\n",fp);
      break;

    case TN_IF:
      fputs("TN_IF\n",fp);
      break;

    case TN_ASSIGN:
      fputs("TN_ASSIGN\n",fp);
      break;

    case TN_JUMP:
      fputs("TN_JUMP\n",fp);
      break;

    case TN_FOR:
      fputs("TN_FOR\n",fp);
      break;

    case TN_WHILE:
      fputs("TN_WHILE\n",fp);
      break;

    case TN_DOWHILE:
      fputs("TN_DOWHILE\n",fp);
      break;

    case TN_SWITCH:
      fputs("TN_SWITCH\n",fp);
      break;

    case TN_LABEL:
      fputs("TN_LABEL\n",fp);
      break;

    case TN_STEMNT:
      fputs("TN_STEMNT\n",fp);
      break;

    case TN_INDEX:
      fputs("TN_INDEX\n",fp);
      break;

    case TN_DEREF:
      fputs("TN_DEREF\n",fp);
      break;

    case TN_SELECT:
      fputs("TN_SELECT\n",fp);
      break;

    case TN_EXPR:
      fputs("TN_EXPR\n",fp);
      break;

    case TN_COND_EXPR:
      fputs("TN_COND_EXPR\n",fp);
      break;

    case TN_IDENT:
      fputs("TN_IDENT\n",fp);
      break;

    case TN_TYPE:
      fputs("TN_TYPE\n",fp);
      break;

    case TN_STRING:
      fputs("TN_STRING\n",fp);
      break;

    case TN_INT:
      fputs("TN_INT\n",fp);
      break;

    case TN_REAL:
      fputs("TN_REAL\n",fp);
      break;

  }
}

/*  ###############################################################  */
