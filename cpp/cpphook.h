
/* Beginnings of additions to cpp stuff by GJB */

#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)
