#include <stdio.h>
#define CCD2
#ifdef CCD1
#  define FOO 1
#endif
#ifdef CCD2
#  define FOO 2
#endif

static const int FUD = 3;
#define BAR 4
static const int baz = 5;
enum {BING = 6};

int
main(char **argv, int argc)
{
  int fud = FUD;
  int BONG = -1;
  int rgi[BING];
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,baz,BING,BONG);
#define BAR -2
#define BONG 7
  printf("%d, %d, %d, %d, %d, %d\n",FOO,FUD,BAR,baz,BING,BONG);
  return 0;
}
