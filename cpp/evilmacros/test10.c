#define __P(protos) protos

#define foo foodleydoo

void bar __P((baz, baz));

void bar __P((baz, foo));

void bar __P((foo, foo));
