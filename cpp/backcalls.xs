/* $Id$
 * By Greg J. Badros, Aug. 27 1997
 * 
 * These are simple functions to expose some C data structures
 * to the perl callbacks called from pcpp
 *
 * FIXGJB: Need the below information available:	
   is_system_include_file()
   system_include_depth()
 */


#ifdef __cplusplus
extern "C" {
#endif
#define bool int
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "cppmain.h"
#include "cpplib.h"
#include "cpphash.h"
#ifdef __cplusplus
}
#endif


MODULE = backcalls		PACKAGE = cpp

PROTOTYPES: disable

void
hello()
	CODE:
	fprintf(stdout,"Hello world!\n");

char *
SzToken(i)
	int i
	CODE:
	RETVAL = SzFromToken((enum cpp_token) i);

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

char *
lookup(sz)
	char *sz
	CODE:
	HASHNODE *hp = cpp_lookup(&parse_in,sz,-1,-1);
	RETVAL = hp->value.defn->expansion;
	OUTPUT:
	RETVAL
