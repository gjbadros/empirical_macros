
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         nmetab.c
    ##
    ##     Revision 0.0.0.0  1996/04/03  23:20:41  kurt
    ##     Assertion failing for some mysterious reason
    ##     (some symbols hash to 0);
    ##     wrapped in "#if 0/#endif" pair.
    ##     -- Kurt Cockrum <kurt@grogatch.seaslug.org>
    ##
    ##     Programmer:   Shaun Flisakowski
    ##     Date:         Jan 11, 1995
    ##
    ##
    ###############################################################  */

#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>
#include    <assert.h>

#include    "globals.h"
#include    "lexer.h"
#include    "macro.h"
#include    "nmetab.h"

HashItem  *NmeTab[MAX_HASH_BCKTS];

/*  ###############################################################  */
int  nmehash( str_t *sym )
{
    if (sym)
      return sym->hash;
    else
      return 0;
}

/*  ###############################################################  */
char *nmestr( str_t *sym )
{
    if (sym)
      return sym->str;
    else
      return NULL;
}

/*  ###############################################################  */
unsigned int calc_hash( char *str )
{
  unsigned int hsh = 0, c;

  while(*str)
    {
    c = *str++;
    hsh = (hsh << 1) ^ (hsh >> 20) ^ c;
    }

  return(hsh);
}

/*  ###############################################################  */
void init_nmetab()
{
  int j;

  for (j=0; j < MAX_HASH_BCKTS; j++)
      NmeTab[j] = (HashItem *) NULL;
}

/*  ###############################################################  */
void  free_nmetab()
{
int j;
HashItem  *hptr, *hfree;

    for (j=0; j < MAX_HASH_BCKTS; j++){

        hfree = (HashItem *) NULL;

        for (hptr=NmeTab[j]; hptr; hptr=hptr->next){
            if (hptr->sym.str)
                free(hptr->sym.str);
            if (hfree)
                free(hfree);
            hfree = hptr;
        }

        if (hfree)
            free(hfree);
    }
}

/*  ###############################################################  */
int    nme_equal( str_t *this, str_t *that )
{
    if (!this || !that)
      return 0;

    return (this->str == that->str);
}

/*  ###############################################################  */
str_t *nmelook( char *sym, int len )
{
unsigned int  hsh;
int bckt;
HashItem *hptr;

    hsh  = calc_hash(sym);
    bckt = hsh % MAX_HASH_BCKTS;

    for (hptr=NmeTab[bckt]; hptr; hptr=hptr->next)
      {

      if ((hptr->sym.hash == hsh) && (STRCMP(sym,hptr->sym.str) == 0))
        return(&(hptr->sym));
      } 

    if ((hptr = (HashItem *) malloc( HASH_ITEM_SZE )) == NULL)
      return((str_t *) NULL);

    if (!len)
      len = strlen(sym);

    if ((hptr->sym.str = malloc(len+1)) == NULL)
      {
      free(hptr);
      return((str_t *) NULL);
      }

    hptr->sym.hash = hsh;
    strncpy(hptr->sym.str, sym, len);

    hptr->next = NmeTab[bckt];
    NmeTab[bckt] = hptr;

    return(&(hptr->sym));
}

/*  ###############################################################  */
void nmeshow()
{
int  j;
HashItem *hptr;

    fprintf(stdout,"        Name Table\n");
    fprintf(stdout,"       ------------\n\n");

    for (j=0; j < MAX_HASH_BCKTS; j++){
    fprintf(stdout,"Examining bucket: %d\n", j);
        for (hptr=NmeTab[j]; hptr; hptr=hptr->next){
            fprintf(stdout,"Name: %s\n",hptr->sym.str);
        } 
    } 

    fputs("\n\n",stdout);
}

/*  ###############################################################  */
