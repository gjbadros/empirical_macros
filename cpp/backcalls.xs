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
#include "pcpp.h"
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
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->fname;
	else
	  RETVAL = "@NOBUFFER@";
	OUTPUT:
	RETVAL

char *
nominal_fname()
	CODE:
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->nominal_fname;
	else
	  RETVAL = "@NOBUFFER@";
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

int
CBytesOutput()
	CODE:
	RETVAL = cBytesOutput;
	OUTPUT:
	RETVAL

int
CBytesCppRead()
	CODE:
	RETVAL = cBytesCppRead;
	OUTPUT:
	RETVAL

int
FExpandingMacros()
	CODE:
	RETVAL = !parse_in.no_macro_expand;
	OUTPUT:
	RETVAL
