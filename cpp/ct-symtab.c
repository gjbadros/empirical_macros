/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o
    o+
    o+     File:         symtab.c
    o+
    o+     Programmer:   Shaun Flisakowski
    o+     Date:         Jul 15, 1997
    o+
    o+     Implements a scoped symbol table.
    o+
    o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

#include  <stdio.h>
#include  <stdlib.h>
#include  <assert.h>

#include  "symtab.h"
#include  "nmetab.h"

#include  "prnttree.h"

/*  #define  PRINT_LEVEL  */

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */

static void po_deltabs(scopetab_t *this);
static int  child_insert(scopetab_t *mom, scopetab_t *kid);
static symentry_t *mk_generic(str_t *sym, treenode *tn, int knd);

static void show_symentry(symentry_t *this, FILE *fp);
static void show_hashtab(hashtab_t *this, FILE *fp);
static void show_scopetab(scopetab_t *this, FILE *fp);

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
free_symentry(symentry_t *this)
{
  free(this);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static void
show_symentry(symentry_t *this, FILE *fp)
{
  fputs("Name: ", fp);
  fputs(this->nme->str,fp);
  fputs(":\n", fp);
  print_frag(this->node, fp);
  fputs("\n-------------\n", fp);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static symentry_t*
mk_generic(str_t *sym, treenode *tn, int knd)
{
  symentry_t *this = malloc(sizeof(symentry_t));

  if (this)
    {
    this->kind = knd;
    this->nme  = sym;
    this->node = tn;
    } 

  return this;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_typedef(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,TYPEDEF_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_funcdef(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,FUNCDEF_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_vardecl(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,VARDECL_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_enum_const(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,ENUM_CONST_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_label(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,LABEL_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_tag(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,TAG_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
mk_component(str_t *sym, treenode *tn)
{
  return mk_generic(sym,tn,COMP_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int   is_typedef(symentry_t *this)
{
  return this && (this->kind == TYPEDEF_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int   is_funcdef(symentry_t *this)
{
  return this && (this->kind == FUNCDEF_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int   is_vardecl(symentry_t *this)
{
  return this && (this->kind == VARDECL_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int   is_enum_const(symentry_t *this)
{
  return this && (this->kind == ENUM_CONST_ENTRY);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static void
free_symlist(symentry_t *list)
{
  symentry_t *curr, *prev = NULL;

  for (curr=list; curr; curr = curr->next)
    {
    free_symentry(prev);
    prev = curr;
    }
  free_symentry(prev);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
hashtab_t *
new_hashtab()
{
  int j;
  hashtab_t *this = malloc(sizeof(hashtab_t));

  if (this) 
    {
    this->nent = 0;
    this->tsize = INIT_HASHTAB_SIZE;
  
    this->tab = malloc( sizeof(symentry_t*) * this->tsize );
    if (! this->tab)
      {
      free(this);
      return NULL;
      }

    for (j=0; j < this->tsize; j++)
      this->tab[j] = NULL;
    }

  return this;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
free_hashtab(hashtab_t *this)
{
  int j;

  if (this)
    {
    for (j=0; j < this->tsize; j++)
      free_symlist(this->tab[j]);

    free(this->tab);
    free(this);
    }
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t *
hashtab_lookup(hashtab_t *this, str_t *nme)
{
  symentry_t *curr;
  int j = nme->hash % this->tsize;
  
  for (curr = this->tab[j]; curr; curr = curr->next)
    if (nme_equal(curr->nme,nme)) 
      return curr;

  return NULL;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
hashtab_insert(hashtab_t *this, symentry_t *entry)
{
  int j;

  if (hashtab_lookup(this,entry->nme))
    return 0;

  j = entry->nme->hash % this->tsize;
  entry->next = this->tab[j];
  this->tab[j] = entry;

  return 1;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static void
show_hashtab(hashtab_t *this, FILE *fp)
{
  int j;
  symentry_t *list;

  fprintf(fp, "HashTab:  nent: %d  size: %d\n",
              this->nent, this->tsize );

  for (j=0; j < this->tsize; j++)
    {
    list = this->tab[j];
    if (list)
      {
      fprintf(fp, "[%d]: ", j);
      for (; list; list=list->next)
        show_symentry(list,fp);
      fputs("\n", fp);
      }
    }
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
scopetab_t*
new_scopetab(scopetab_t *mom)
{
  int j;
  scopetab_t *this = malloc(sizeof(scopetab_t));

  if (this)
    {
    this->htab = NULL;
    this->nchild = 0;
    this->size = INIT_CHILD_SIZE;
    this->children = malloc( sizeof(scopetab_t*) * this->size );

    if (!this->children)
      {
      free(this->children);
      free(this);
      return NULL;
      }

    for (j=0; j < this->size; j++)
      this->children[j] = NULL;

    this->nsyms = 0;
    this->parent = mom;
    if (mom)
      this->level = mom->level + 1;
    else
      this->level = EXTERN_SCOPE;
    }

  return this;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
free_scopetab(scopetab_t *this)
{
  if (this)
    {
    free_hashtab(this->htab);
    free(this->children);
    free(this);
    }
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
scopetab_lookup(scopetab_t *this, str_t *nme)
{
  symentry_t *ret = NULL;

  if (this && this->htab)
    ret = hashtab_lookup(this->htab, nme);

  return ret;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
scopetab_find(scopetab_t *this, str_t *nme)
{
  symentry_t *ret = NULL;

#ifdef  PRINT_LEVEL
  fprintf(stdout, "Looking for '%s' in level %d (<entry>)\n",
              nme->str, this->level);
#endif
  if (this)
    {
    if (this->htab)
      ret = hashtab_lookup(this->htab,nme);

    if (!ret)
      return scopetab_find(this->parent,nme);
    }

#ifdef  PRINT_LEVEL
  fprintf(stdout, "Looking for '%s' in level %d (%s)\n",
              nme->str, this->level, (ret ? "found": "NOT found"));
#endif
  return ret;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
scopetab_insert(scopetab_t *this, symentry_t *entry)
{
#ifdef  PRINT_LEVEL
  fprintf(stdout, "Inserting '%s' in level %d\n",
              entry->nme->str, this->level);
#endif
  if (! this->htab)
    {
    this->htab = new_hashtab();
    if (!this->htab)
      return 0;
    }

  return hashtab_insert(this->htab,entry);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static void
po_deltabs(scopetab_t *this)
{
  int j;

  if (this)
    {
    for (j=0; j < this->nchild; j++)
      po_deltabs(this->children[j]);

    free_scopetab(this);
    }
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static int
child_insert(scopetab_t *mom, scopetab_t *kid)
{
  int j;

  if (mom->nchild >= mom->size)
    {
    scopetab_t **oldkids = mom->children;
    mom->size += mom->size;
    mom->children = malloc( sizeof(scopetab_t*) * mom->size );

    if (!mom->children)
      return 0;

    for (j=0; j < mom->nchild; j++)
      mom->children[j] = oldkids[j];
    }

  mom->children[mom->nchild] = kid;
  (mom->nchild)++;

  return 1;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
static void
show_scopetab(scopetab_t *this, FILE *fp)
{
  int j;
  fprintf(fp,"\nScopeTab (%p): (parent: %p)\n", this, this->parent);

  fprintf(fp, "level: %d  nsyms: %d  nchild: %d\n",
          this->level, this->nsyms, this->nchild );

  if (this->htab)
    show_hashtab(this->htab, fp);
  else
    fputs("HashTab: NULL\n", fp);

  for (j=0; j < this->nchild; j++)
    show_scopetab(this->children[j], fp);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symtab_t*
new_symtab()
{
  symtab_t *this = malloc(sizeof(symtab_t));

  if (this)
    {
    this->root = new_scopetab(NULL);
    this->clevel = EXTERN_SCOPE;
    this->current = this->root;

    if (!this->root)
      {
      free(this);
      this = NULL;
      }
    }

  return this;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
free_symtab(symtab_t *this)
{
  if (this)
    {
    /* delete all scopetab's (post-order traversal). */ 
    po_deltabs(this->root);
    free(this);
    }
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
symtab_lookup(symtab_t *this, str_t *nme)
{
  symentry_t *ret = NULL;

  if (this->current)
    ret = scopetab_find(this->current,nme);

  return ret;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
symentry_t*
symtab_lookup_at(symtab_t *this, str_t *nme, int level)
{
  scopetab_t *scp = this->current;

  while (scp && scp->level < level)
    scp = scp->parent;

  return scopetab_find(scp,nme);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
symtab_insert(symtab_t *this, symentry_t *entry)
{
  while (this->clevel > this->current->level)
    {
    scopetab_t *child = new_scopetab(this->current);

    if (!child || !child_insert(this->current,child))
      return 0;

    this->current = child;
    }

  return scopetab_insert(this->current,entry);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
symtab_insert_at(symtab_t *this, symentry_t *entry, int level)
{
  scopetab_t *scp;

#ifdef  PRINT_LEVEL
  fprintf(stderr, "scope level %d\n", this->current->level);
  fprintf(stderr, "Current level %d\n", this->clevel);
  fprintf(stderr, "request level %d\n", level);
#endif

  while ((this->clevel > this->current->level)
      && (this->clevel >= level))
    {
    scopetab_t *child = new_scopetab(this->current);

    if (!child || !child_insert(this->current,child))
      return 0;

    this->current = child;
    }

  scp = this->current;
  while (scp && (scp->level > level))
    scp = scp->parent;

  if (scp)
    return scopetab_insert(scp,entry);
  else
    return 0;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
st_enter_scope(symtab_t *this)
{
  return ++(this->clevel);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
st_exit_scope(symtab_t *this)
{
  (this->clevel)--;
  if (this->current->level > this->clevel)
    this->current = this->current->parent;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
show_symtab(symtab_t *this, FILE *fp)
{
  fputs("\n-------------\nSymbol Table:\n", fp);
 
  fprintf(fp, "current level: %d  (%p)  parent: (%p)\n",
               this->clevel, this->current, this->current->parent);
  show_scopetab(this->root, fp);

  fputs("\n-------------\n", fp);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
context_t*
new_context()
{
  context_t *this = malloc( sizeof(context_t) );

  if (this)
    {
    this->labels = new_symtab();
    this->tags   = new_symtab();
    this->syms   = new_symtab();

    if (!this->labels || !this->tags || !this->syms)
      {
      free_symtab(this->labels);
      free_symtab(this->tags);
      free_symtab(this->syms);
      free(this);
      this = NULL;
      }
    }

  return this;
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
free_context(context_t *this)
{
  free_symtab(this->labels);
  free_symtab(this->tags);
  free_symtab(this->syms);

  free(this);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
int
enter_scope(context_t *this)
{
#ifdef  PRINT_LEVEL
  /*  fprintf(stdout, "Entering Scope: %d\n", this->syms->clevel + 1);  */
#endif
  st_enter_scope(this->labels);
  st_enter_scope(this->tags);
  return st_enter_scope(this->syms);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
exit_scope(context_t *this)
{
#ifdef  PRINT_LEVEL
  /*  fprintf(stdout, "Exiting Scope: %d\n", this->syms->clevel);  */
#endif
  st_exit_scope(this->labels);
  st_exit_scope(this->tags);
  st_exit_scope(this->syms);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
void
exit_scopes(context_t *this, int newlev)
{
  if (newlev < EXTERN_SCOPE)
    newlev = EXTERN_SCOPE;

  while (newlev < this->syms->current->level)
    exit_scope(this);
}

/*  o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o+o  */
