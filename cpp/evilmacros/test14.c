#define __P(protos) protos

#define foo foodleydoo

#define yyconst const

void bar __P((baz, foo));

#ifdef NOT_DEFFED

#ifdef NOT_DEF2

void bar __P((__P((yyconst foo foo,bar)),bar));

void bar __P((baz, foo));

void bar __P((foo, foo));

#endif

#endif
