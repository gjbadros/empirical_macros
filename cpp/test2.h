#define FOO foo_but_longer
#define LONG_BAR bar
#define BAZ BAZ

#define MACRO_ALPHA FOO/LONG_BAR * BAZ
#define MACRO_ECHO LONG_BAR/FOO * BAZ

#define __P(protos) protos
#define MAX(x,y)     (x,   y)
#define Max(x,y)     (x,   y)
#define MANY(xxxx,yy)    Initial Offset xxxx yy xxxx xxxx xxxx yy Terminating offset
#define HELLO LONG_BAR LONG_BAR
#define GOODBYE BAZ
#define MULTI HELLO
#define GMULTI GOODBYE
#define REVERSE MAX(foo,bar)
#define DEEP MAX((MAX(1,2)),MAX(MAX(3,MAX(4,5)),7))
#define COMPLEX(wow) MANY(MAX((MAX(1,2)),MAX(MAX(3,MAX(4,5)),wow)),__P(wow))


int main (char *argv, int argc)
{
 TEST3:
  MAX(Max(simpled1,simpled2),simple3);
  MAX   (  FOO,     LONG_BAR);
  MAX(LONG_BAR,FOO);
 NEWTEST:
  /* MULTI -> HELLO -> LONG_BAR LONG_BAR -> bar bar */
  /* Need: (source_start, source_end, expansion, expansion_derivation) */ 
  MULTI;
  HELLO;
  GOODBYE;
  GMULTI;
 TESTMANY:
  /* MANY(a,b) -> Initial Offset a b a a a b Terminating offset */
  /* Need: (source_start, source_end, expansion, expansion_dervication, @s_start_args, @s_end_args, @expansions_args */
  MANY(a,b);
 TEST1:
  FOO;
  LONG_BAR;
  BAZ;
 TEST2:
  MACRO_ALPHA;
  MACRO_ECHO;
 TEST4:
  MAX(MACRO_ALPHA,    MACRO_ECHO);
 TEST5:
  __P((int, long));
  __P((FOO,   LONG_BAR));
  __P((MACRO_ALPHA));
 TEST6:
   REVERSE;
 TEST7:
   DEEP;
 TEST8:
   COMPLEX(whoaza);
   COMPLEX(MULTI);

}
