#define __P(protos) protos

#define foo foodleydoo

void bar __P((baz, foo));

#ifdef NOT_DEFFED

void bar __P((__P((foo,bar)),bar));

void bar __P((baz, foo));

void bar __P((foo, foo));


#endif
