#include <stdio.h>

#ifdef CCD1
static const int FOO = 1;
#else
static const int FOO = 2;
#endif

static const int FUD = 3;
static const int BAR = 4;
static const int BAZ = 5;
static const int BING = 6;

int
main(char **argv, int argc)
{
  int fud = FUD;
  int BONG = -1;
  int rgi[BING];         /* Forbidden in ANSI C */
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,BAZ,BING,BONG);
//  static const int BAR = -2;  /* Syntax error */
//  static const int BONG = 7;  /* Syntax error */
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,BAZ,BING,BONG);
  return 0;
}

#undef FUD
