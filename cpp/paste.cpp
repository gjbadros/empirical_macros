#define paste(x,y) x##y
#define paste_trace(x) paste(_trace_,x)
#define TRACE(s) paste_trace(__LINE__)(#s)

#define Trace(s) _trace_##__LINE__(#s))


Trace(Test)

TRACE(Test)

