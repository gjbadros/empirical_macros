//#include <stdio.h>

#ifdef CCD1
#  define FOO 1
#else
#  define FOO 2
#endif

#define FUD 3
#define BAR 4
#define BAZ 5
#define BING 6

int
main(char **argv, int argc)
{
  int foo = FOO;
  int rgi[BING];
  printf("%d, %d, %d, %d, %d",FOO,FUD,BAR,BAZ,BING);
#define BAR 5
  printf("%d, %d, %d, %d, %d",FOO,FUD,BAR,BAZ,BING);
  return 0;
}

#undef FUD
