#include <stdio.h>

#ifdef CCD1
#  define FOO 1
#endif
#ifdef CCD2
#  define FOO 2
#endif

#define FUD 3
#define BAR 4
#define BAZ 5
#define BING 6

int main(char **argv, int argc)
{
  int fud = FUD;
  int BONG = -1;
  int rgi[BING];
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,BAZ,BING,BONG);
#define BAR -2
#define BONG 7
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,BAZ,BING,BONG);
  return 0;
}

#undef FUD
