#define FOO BAR a
#define BAR BAZ b
#define BAZ BAR BOD c
#define BOD BING
#define BING foo

#define C 8
#define C 9
#undef C
C


#define BING(a,b,c)  a a #a

int rgi[C]

BING(x,y,z)

FOO


