#define FOO BAR a
#define BAR BAZ b
#define BAZ BAR BOD c
#define BOD BING
#define BING foo


#define BING(a,b,c)  a a #a

BING(x,y,z)

FOO


