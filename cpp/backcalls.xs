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
#include "bison-stack.h"
#ifdef __cplusplus
}
#endif


MODULE = backcalls		PACKAGE = cpp

PROTOTYPES: disable

char *
SzToken(i)
	int i
	CODE:
	RETVAL = SzFromToken((enum cpp_token_id) i);
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


int
CbuffersBack()
	cpp_buffer *buffer = parse_in.buffer;
	int cbuffersBack = 0;
	CODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=cbuffersBack;
	OUTPUT:
	RETVAL


void
MacroExpansionHistory()
	cpp_buffer *buffer = parse_in.buffer;
	int cbuffersBack = 0;
	PPCODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->data == 0) {
		break;
	    } else {
		HASHNODE *macro = buffer->data;
		if (macro) {
		    int offset = buffer->cur - buffer->buf;
		    int from_what = 1 + 
			IargWithOffset(offset,
				       macro->type==T_MACRO?macro->value.defn->nargs:
				       -macro->type,
				       buffer->args);
		    XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",macro->name,from_what,
					       offset)));
		} else
		    XPUSHs(sv_2mortal(newSVpv("",0)));
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}

 # FIXGJB: This returns use_count as a test, instead of computing
 # which argument is being expanded
int
ArgOf()
	HASHNODE *macro = (HASHNODE*)(parse_in.buffer->data);
	int offset = parse_in.buffer->cur - parse_in.buffer->buf - 1;
	struct argdata *args = parse_in.buffer->args;
	CODE:
	RETVAL = -1;
	if (args)
	  RETVAL = IargWithOffset(offset, 
				  macro->type==T_MACRO?macro->value.defn->nargs:
				  -macro->type, args) + 1;
	OUTPUT:
	RETVAL


	
int
CchOffset()
	cpp_buffer *buffer = parse_in.buffer;
	int cbuffersBack = 0;
	CODE:
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=buffer->cur - buffer->buf;
	OUTPUT:
	RETVAL

 # When expanding macros inside arguments of another expansion,
 # the STATIC_BUFFERS of parse_in are used.  use "print parse_in" from gdb
 # to show everything.
 # What this means is that the fname returned is NULL when we are 
 # using a macro-expansion buffer, and we need to follow the stack
 # of buffers up until we get an actual filename for the real filename
 # --09/17/97 gjb


char *
InFname()
	struct cpp_options *opts = parse_in.data;
	CODE:
	RETVAL = opts?opts->in_fname:"@NONE@";
	OUTPUT:
	RETVAL

char *
Fname()
	cpp_buffer *buffer = parse_in.buffer;
	CODE:
	if (buffer == 0) {
	    RETVAL = "@NONE@";
	} else {
	    while (buffer != CPP_NULL_BUFFER(&parse_in)) {
		if (buffer->nominal_fname) {
		    RETVAL = buffer->nominal_fname;
		    break;
		} else {
		    buffer = CPP_PREV_BUFFER(buffer);
		}
	    }
	}
	OUTPUT:
	RETVAL

# FIXGJB: obsoleted
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
FnameNominal()
	CODE:
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->nominal_fname;
	else
	  RETVAL = "@NOBUFFER@";
	OUTPUT:
	RETVAL

char *
ExpansionLookup(sz)
	char *sz
	CODE:
	HASHNODE *hp = cpp_lookup(&parse_in,sz,-1,-1);
	RETVAL = "@NOTFOUND@";
	if (hp)
          RETVAL = hp->value.defn->expansion;
	OUTPUT:
	RETVAL

int
CbytesOutput()
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
CbytesCppRead()
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


void
ParseStateStack()
	PREINIT:
	extern short *yyss;
	extern short *yyssp;
	PPCODE:
	short *ssp1 = yyss - 1;
	if (!fShouldParse) {
	    XPUSHs(sv_2mortal(newSVpv("@NOT_PARSING@",0)));
	}
	while (ssp1+1 != NULL && ssp1 != yyssp)
	    XPUSHs(sv_2mortal(newSViv(*++ssp1)));

void
SetParseStateStack()
	PPCODE:
	int i = 0;
	if (!fShouldParse) return;
	while (i < items) {
	    short val = (int)SvIV(ST(i));
	    i++;
	}


void
PushBuffer($buffer_to_push)
	PPCODE:
	int length = 0;
	int len = 0;
 	char *szBuf = SvPV(ST(0),length);
	if ((len = strlen(szBuf)) != length) {
	    warn("PushBuffer cannot handle strings with embedded NULLs\n");
	}
	cpp_push_buffer(&parse_in,szBuf,len);


void
SetParseDebugging()
	CODE:
	ct_yydebug = 1;


void
ResetParseDebugging()
	CODE:
	ct_yydebug = 0;

void
YYPushStackState()
	CODE:
	if (!fShouldParse) return;
	PushStackState();

void
YYPopAndRestoreStackState()
	CODE:
	if (!fShouldParse) return;
	PopAndRestoreStackState();

void
YYPopAndDiscardStackState()
	CODE:
	if (!fShouldParse) return;
	PopAndDiscardStackState();

void
YYSwapStackState()
	CODE:
	if (!fShouldParse) return;
	SwapStackState();

void
YYPushDupTopStackState()
	CODE:
	if (!fShouldParse) return;
	PushDupTopStackState();

bool
YYFCompareTopStackState()
	CODE:
	if (!fShouldParse) return;
	RETVAL = FCompareTopStackState();
	OUTPUT:
	RETVAL

