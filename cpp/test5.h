#if !defined(FOO)
Next line here
#elif defined(BAR)
Another set of lines that 
all get skipped over
#else
and this goes out
#endif


#ifdef FOO
FOO defined
#elif defined(BAR)
BAR defined
#else
Neither defined
#endif


#define foo(x,y)  x y x x y testing

#undef foo
