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

char *
SzToken(i)
	int i
	CODE:
	RETVAL = SzFromToken((enum cpp_token) i);
	OUTPUT:
	RETVAL

 # See note below about Fname(); roughly the 
 # same thing applies here.  My current position
 # is the deltas for cur-buf when we 
 # hit a buffer with a real name (FIX: Better test than filename?)


 # Returns a list, (CchOffset,expansion buffer depth)
 # (Uses PPCODE directive, below)
 # This does *not* add the offset into the file,
 # only the offsets of the macro expansion buffers
void
SumCchExpansionOffset()
	cpp_buffer *buffer = parse_in.buffer;
	long sum = 0;
	int cbuffersBack = 0;
	PPCODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		/* do not count the leading "@ " */
		long cch = buffer->cur - buffer->buf - 2;
		sum += cch;
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	XPUSHs(sv_2mortal(newSViv(sum)));
	XPUSHs(sv_2mortal(newSViv(cbuffersBack)));
	

 # Returns a list, (CchOffset,expansion buffer depth)
void
CchOffset()
	cpp_buffer *buffer = parse_in.buffer;
	int cbuffersBack = 0;
	PPCODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	XPUSHs(sv_2mortal(newSViv(buffer->cur - buffer->buf)));
	XPUSHs(sv_2mortal(newSViv(cbuffersBack)));


 # When expanding macros inside arguments of another expansion,
 # the STATIC_BUFFERS of parse_in are used.  use "print parse_in" from gdb
 # to show everything.
 # What this means is that the fname returned is NULL when we are 
 # using a macro-expansion buffer, and we need to follow the stack
 # of buffers up until we get an actual filename for the real filename
 # --09/17/97 gjb

char *
Fname()
	cpp_buffer *buffer = parse_in.buffer;
	CODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		RETVAL = buffer->nominal_fname;
		break;
	    } else {
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	OUTPUT:
	RETVAL


char *
fname_obsoleted()
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


 # FIXGJB: This is obsolete
int
CbytesOutputAndBuffer_obsolete()
	CODE:
	RETVAL = cBytesOutput + CPP_WRITTEN(&parse_in);
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
