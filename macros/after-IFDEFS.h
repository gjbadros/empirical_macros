#ifdef HAVE_READLINE
#define HAVE_READLINE_OR_NOT(x,y) REMOVE_PARENS x
#else
#define HAVE_READLINE_OR_NOT(x,y) REMOVE_PARENS y
#endif

#define REMOVE_PARENS(x) x
