/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o
    o+
    o+     File:         symtab.c
    o+
    o+     Programmer:   Shaun Flisakowski
    o+     Date:         Jul 12, 1997
    o+
    o+     Implements a scoped symbol table.
    o+
    o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o 

    SymTab:  A tree of scope tables,
             one for each scope that declares something, or has a
             child scope that declares something:

         Level
           1              external
                         /        \
           2          file        file 
                      scope       scope 
                                /       \
           3              prototype    function
                            scope        scope
                                        /     \
           4                         block    block
                                     scope    scope    
                                                 \
           5                                     block
                                                 scope    
                                                    \
                                                   (etc.)

    At any particular point you can see all the symbols 
    (variables, types, functions, etc) declared above you in the tree.

    The scope tables are recreated in a lazy fashion, so entering
    and exiting scopes that don't declare new symbols is cheap.

    o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
   
#ifndef   SYMTAB_H
#define   SYMTAB_H

#include  "nmetab.h"
#include  "tree.h"

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

/* Different kinds of entries in the symbol table. */

/* These things are all in the same namespace. */
#define    TYPEDEF_ENTRY      (1)    /* type definition. */
#define    FUNCDEF_ENTRY      (2)    /* function definition. */
#define    VARDECL_ENTRY      (3)    /* variable declaration. */
#define    ENUM_CONST_ENTRY   (4)    /* enum constants. */

/* These things are in seperate namespaces. */
#define    LABEL_ENTRY        (5)    /* label definition. */
#define    TAG_ENTRY          (6)    /* struct/union/enum tags. */

/* There is also a separate namespace for each struct/union. */
#define    COMP_ENTRY         (7)    /* components of struct/union. */

/* These might be convienent. */
#define    CURRENT_SCOPE   (0)    /* the default */
#define    EXTERN_SCOPE    (1)
#define    FILE_SCOPE      (2)
#define    FUNCTION_SCOPE  (3)
#define    BLOCK_SCOPE     (4)    /* really, 4 or more. */

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

typedef struct symentry {
    int          kind;   /* What kind of thing it is. */
    str_t       *nme;    /* The name of the thing. */
    treenode    *node;   /* ptr to it's definition/declaration. */

   /* This would probably be a good place to add some attributes, 
      but none come to mind at the moment. */

    struct symentry  *next;    /* For convienent storage in a hashtab_t. */
} symentry_t;

symentry_t *mk_typedef(str_t *sym, treenode *tn);
symentry_t *mk_funcdef(str_t *sym, treenode *tn);
symentry_t *mk_vardecl(str_t *sym, treenode *tn);
symentry_t *mk_enum_const(str_t *sym, treenode *tn);
symentry_t *mk_label(str_t *sym, treenode *tn);
symentry_t *mk_tag(str_t *sym, treenode *tn);
symentry_t *mk_component(str_t *sym, treenode *tn);

int   is_typedef(symentry_t *this);
int   is_funcdef(symentry_t *this);
int   is_vardecl(symentry_t *this);
int   is_enum_const(symentry_t *this);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#define    INIT_HASHTAB_SIZE    (5)

typedef struct hashtab {
    int            tsize;     /* The current size of the table. */
    int            nent;      /* The number of entries being stored. */
    symentry_t   **tab;       /* The table. */
} hashtab_t;

hashtab_t  *new_hashtab();
void        free_hashtab(hashtab_t *this);
symentry_t *hashtab_lookup(hashtab_t *this, str_t *nme);
int         hashtab_insert(hashtab_t *this, symentry_t *entry);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#define    INIT_CHILD_SIZE     4

typedef struct scopetab {
    int               nsyms; /* The num of syms declared at this scope. */
    int               level; /* This scopetab's scoping level. */

    hashtab_t        *htab;  /* A hash table - to store the symbols. */

    struct scopetab  *parent; /* The scope enclosing us, if any. */

    /* A doubling array of scopes we enclose. */
    int               nchild;
    int               size;
    struct scopetab **children;
} scopetab_t;

scopetab_t *new_scopetab(scopetab_t *mom);
void        free_scopetab(scopetab_t *this);
symentry_t *scopetab_lookup(scopetab_t *this, str_t *nme);
symentry_t *scopetab_find(scopetab_t *this, str_t *nme);
int         scopetab_insert(scopetab_t *this, symentry_t *entry);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

typedef struct symtab {
    scopetab_t      *root;    /* The top scopetab - external scope. */

    int              clevel;  /* The current level. */
    scopetab_t      *current; /* The current scopetab, or one of its
                                 ancestors, if it doesn't exist yet. */
} symtab_t;

symtab_t   *new_symtab();
void        free_symtab(symtab_t *this);

symentry_t *symtab_lookup(symtab_t *this, str_t *nme);
symentry_t *symtab_lookup_at(symtab_t *this, str_t *nme, int level);
int         symtab_insert(symtab_t *this, symentry_t *entry);
int         symtab_insert_at(symtab_t *this, symentry_t *entry, int level);

int         st_enter_scope(symtab_t *this);
void        st_exit_scope(symtab_t *this);
void        show_symtab(symtab_t *this, FILE *fp);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

typedef struct ct_context {

    symtab_t    *labels;    /* Statement labels. */
    symtab_t    *tags;      /* Struct/Union/Enum tags. */
    symtab_t    *syms;      /* Vars, Types, Functions, etc. */

} context_t;

context_t  *new_context();
void        free_context(context_t *this);
int         enter_scope(context_t *this);
void        exit_scope(context_t *this);
void        exit_scopes(context_t *this, int newlev);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#endif    /* SYMTAB_H */
