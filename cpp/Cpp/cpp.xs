#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif


MODULE = cpp		PACKAGE = cpp		

PROTOTYPES: disable

void
hello()
	CODE:
	fprintf(stdout,"Hello world!\n");

void
print_token_kind(i)
	int i
	CODE:
	print_token_kind((enum cpp_token) i);

char *
fname()
	CODE:
	RETVAL = parse_in.buffer->fname;
	OUTPUT:
	RETVAL

char *
nominal_fname()
	CODE:
	RETVAL = parse_in.buffer->nominal_fname;
	OUTPUT:
	RETVAL

