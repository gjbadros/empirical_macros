/* #include <stdio.h> */
/* FOO is a number we use below */
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

int
main(char **argv, 
     int argc)
{
  int foo = FOO;
  fprintf(stderr,"Hello World! FOO = %d",FOO,notme);
  return 0;
}

#undef FOO
