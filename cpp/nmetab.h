
/*  ###############################################################
    ##
    ##     C Tree Builder
    ##
    ##     File:         nmetab.h
    ##
    ##     Programmer:   Shawn Flisakowski
    ##     Date:         Jan 11, 1995
    ##
    ##
    ###############################################################  */

#ifndef     NMETAB_H
#define     NMETAB_H

#define MAX_HASH_BCKTS	511

/*  ###############################################################  */

typedef struct string_str {
    unsigned int   hash;
    char          *str;
} str_t;

/*  ###############################################################  */

typedef struct hi {

    str_t      sym;
    struct hi *next;

} HashItem;

#define HASH_ITEM_SZE	(sizeof(HashItem))

/*  ###############################################################  */

extern HashItem  *NmeTab[MAX_HASH_BCKTS];

/*  ###############################################################  */

void   init_nmetab();
void   free_nmetab();
int    nme_equal( str_t *this, str_t *that );
str_t *nmelook( char *sym, int len );
int    nmehash( str_t *sym );
void   nmeshow();
char  *nmestr( str_t *sym );

/*  ###############################################################  */

#endif    /* NMETAB_H */
