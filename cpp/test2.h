#define FOO foo_but_longer
#define LONG_BAR bar
#define BAZ BAZ

#define MACRO_ALPHA FOO/LONG_BAR * BAZ
#define MACRO_ECHO LONG_BAR/FOO * BAZ

#define __P(protos) protos
#define MAX(x,y)     (x,   y)
#define MANY(xxxx,yy)    Initial Offset xxxx yy xxxx xxxx xxxx yy Terminating offset
#define HELLO LONG_BAR LONG_BAR
#define GOODBYE BAZ
#define MULTI HELLO
#define GMULTI GOODBYE

int main (char *argv, int argc)
{
 NEWTEST:
  HELLO;
  GOODBYE;
  MULTI;
  GMULTI;
 TESTMANY:
  MANY(a,b);
 TEST1:
  FOO;
  LONG_BAR;
  BAZ;
 TEST2:
  MACRO_ALPHA;
  MACRO_ECHO;
 TEST3:
  MAX(FOO,LONG_BAR);
  MAX(LONG_BAR,FOO);
 TEST4:
  MAX(MACRO_ALPHA,MACRO_ECHO);
 TEST5:
  __P((int, long));
  __P((FOO, LONG_BAR));
  __P((MACRO_ALPHA));

}

