#include <stdio.h>

#define FOO 5

int
main(char **argv, int argc)
{
  fprintf(stderr,"Hello World! FOO = %d",FOO);
  return 0;
}
