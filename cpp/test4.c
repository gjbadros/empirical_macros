#include <stdio.h>

#ifdef BAR
#define FOO 5
#else
#define FOO 6
#endif

#ifdef FOO
#define baz 1
#else
#define baz 2
#endif

int
main(char **argv, 
     int argc)
{
  int foo = FOO;
  fprintf(stderr,"Hello World! FOO = %d",FOO);
  return 0;
}

#undef FOO
