#include <stdio.h>
int alpha;
#ifdef BAR
#define FOO 5
typedef int BOOL;
int a;
#else
#define FOO 6
typedef char BOOL;
typedef long LONG;
int a;
#endif

#ifdef BAR2
#define BAZ 1
#else
#define BAZ 2
#endif

#define BING 8

int
main(char **argv, 
     int argc)
{
  int foo = FOO;
  int rgi[BING];
  fprintf(stderr,"Hello World! FOO = %d\n",FOO);
  return 0;
}

#undef FOO
