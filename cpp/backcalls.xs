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
// #include "globals.h"
#include "tree_stk.h"
#include "nmetab.h"
#include "lexer.h"

#ifdef __cplusplus
}
#endif

extern TreeStack *ParseStack;

MODULE = backcalls		PACKAGE = pcp3

PROTOTYPES: disable


###%\backcall{$token_type}{SzToken}{$id}
###%Returns a string identifying what kind of token \textit{id} (an integer) represents.
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

###%\backcallobsoleted{($cchOffset,$cbuffersback)}{SumCchExpansionOffset}{}
###% Gives the source code character position offset and the number of expansions
###% deep that we currently are.
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

###%\backcall{$cbuffersback}{CbuffersBack}{}
###% Return the number of macro expansions deep that we currently are in
###% the current expansion.  This returns 0 if we are not expanding a macro.
###% The number returned is the number of non-file buffers in the current
###% stack of expansions (so it is not increased by nested #include-s).
int
CbuffersBack()
        CODE:
	RETVAL=CbuffersDeep(&parse_in);
	OUTPUT:
	RETVAL

###%\backcall{@expanded_macros_list}{MacroExpansionHistory}{}
###% Returns a list of strings of the form 
###% \textit{macro_name}#\textit{arg_num}[\textit{cchOffsetEnd}]. 
###% Each string explains the contents of a current expansion buffer,
###% and the first string is the top of the expansion stack.
###% For example, if there is a single item in the returned list
###% which is the string "MAX#1[3]", this means that the current
###% token came from the expansion of macro MAX and was the first argument
###% to that macro, ending at character offset 3.  Multiple items
###% in the returned list mean that a macro expanded to some other
###% macro which was subsequently expanded.  Argument number 0 signifies
###% that the token came from the literal body of the macro.
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
		    int cargs_or_negative = -1;
		    int from_what = 0;
		    if (macro->type == T_MACRO || macro->type == T_DISABLED)
			cargs_or_negative = macro->value.defn->nargs;
		    from_what = 1 + IargWithOffset(offset,
						   cargs_or_negative,
						   buffer->args);
		    XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",macro->name,from_what,
					       offset)));
		} else
		    XPUSHs(sv_2mortal(newSVpv("",0)));
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}

###%\backcallobsoleted{$index_of_argument}{ArgOf}{}
###% Returns the number of the argument from which the current token came.
###% Prefer using the $argno parameter passed to the TOKEN hook.
int
ArgOf()
	HASHNODE *macro = (HASHNODE*)(parse_in.buffer->data);
	int offset = parse_in.buffer->cur - parse_in.buffer->buf - 1;
	struct argdata *args = parse_in.buffer->args;
	CODE:
	RETVAL = -2; /* FIXNOWGJB */
	if (args)
	  RETVAL = IargWithOffset(offset, 
				  macro->type==T_MACRO?macro->value.defn->nargs:
				  -macro->type, args) + 1;
	OUTPUT:
	RETVAL


###%\backcall{$cch_source_offset}{CchOffset}{}
###% Returns the character position offset into the current source file.
###% Use Fname() to get the source file name.
int
CchOffset()
	cpp_buffer *buffer = parse_in.buffer;
	int cbuffersBack = 0;
	CODE:
	RETVAL=0;
	if (buffer->cur == 0 || buffer->buf == 0)
     	  goto done;
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=buffer->cur - buffer->buf;
	done:
	OUTPUT:
	RETVAL
	

 # When expanding macros inside arguments of another expansion,
 # the STATIC_BUFFERS of parse_in are used.  use "print parse_in" from gdb
 # to show everything.
 # What this means is that the fname returned is NULL when we are 
 # using a macro-expansion buffer, and we need to follow the stack
 # of buffers up until we get an actual filename for the real filename
 # --09/17/97 gjb


###%\backcall{$filename}{InFname}{}
###% Returns a string giving the name of the main input file (the one
###% that appeared on the command line.
char *
InFname()
 #	struct cpp_options *opts = parse_in.data;
	CODE:
	RETVAL = options.in_fname;
	OUTPUT:
	RETVAL

###%\backcall{$filename}{Fname}{}
###% Returns a string giving the name of the current input file.  This
###% tracks include-d files and, combined with CchOffset, gives a
###% unique location in the package.  "@NONE@" returned if no current file.
char *
Fname()
	cpp_buffer *buffer = cpp_file_buffer(&parse_in);
	CODE:
	if (buffer && buffer->nominal_fname) {
	    RETVAL = buffer->nominal_fname;
	} else {
	    RETVAL = "@NONE@";
	}
	OUTPUT:
	RETVAL

###%\backcall{$filename}{FnameNominal}{}
###% Returns a string giving the filename corresponding to the current
###% buffer.  This will be "@NOFILE@" if there is no such file (as is
###% the case when reading tokens from a macro expansion).
###% Otherwise it will correspond to Fname().
char *
FnameNominal()
	CODE:
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->nominal_fname;
	else
	  RETVAL = "@NOFILE@";
	OUTPUT:
	RETVAL

###%\backcall{$encoded_expansion}{ExpansionLookup}{$macro_name}
###% Returns the internally-encoded (cpplib-specific) expansion of
###% the macro with name \texttt{$macro_name}.  Note that this the string
###% returned is delimited on either end by "@ " and omits argument occurrences.
###% "@NOTFOUND@" is return if there is no current macro of the given name.
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


###%\backcall{$cchOutput}{CchOutput}{}
###% Returns the number of characters already output.  Only non-zero when 
###% --noparse option is given.
int
CchOutput()
	CODE:
	RETVAL = cBytesOutput;
	OUTPUT:
	RETVAL

###%\backcallobsoleted{$cchCppRead}{CchCppRead}{}
###% Returns the number of characters that have been read from the
###% input files.  Prefer using the offsets passed in the various hooks.
int
CchCppRead()
	CODE:
	RETVAL = cBytesCppRead;
	OUTPUT:
	RETVAL

###%\backcall{$fExpandingMacros}{FExpandingMacros}{}
###% Returns TRUE iff macros are currently being expanded.
###% Returns FALSE otherwise.  As arguments are read, macros are not expanded,
###% and this will return FALSE.
int
FExpandingMacros()
	CODE:
	RETVAL = !parse_in.no_macro_expand;
	OUTPUT:
	RETVAL

###%\backcall{@parse_state_list}{ParseStateStack}{}
###% Returns the current stack of parse state numbers.  The first element is
###% the top state on the stack.  See the gram.output
###% file for a listing of what the numbers correspond to.
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

###%\backcall{}{SetParseStateStack}{@parse_state_list}
###% Resets the current stack of parse states so that it is @parse_state_list.
###% This has the potential to break the parse, and often will outside
###% of the trivial case of setting the stack of states to what it already is.
void
SetParseStateStack(...)
	PREINIT:
	extern short *yyss;
	extern short *yyssp;
	extern yysstype_p yyvsp;
	PPCODE:
	int i = 0;
	if (!fShouldParse) return;
        /* Reset stack to empty */
        yyssp = yyss-1;
	while (i < items) {
	    short val = (int)SvIV(ST(i));
            *++yyssp = val;
            *++yyvsp = NULL;
	    i++;
	}


###%\backcall{}{PushBuffer}{$source_code_string, $s_start}
###% Adds $source_code_string to the being-processed text 
###% as if it existed in the input at the
###% current location in the current file. $s_start tells
###% where the code to be processed is in the current source
###% file, or is negative if it does not exist there.
void
PushBuffer($buffer_to_push, $s_start)
	PPCODE:
	int length = 0;
	int len = 0;
 	char *szBuf = SvPV(ST(0),length);
	cpp_buffer *pbuf;
	int ichStart = SvIV(ST(1));
	if ((len = strlen(szBuf)) != length) {
	    warn("PushBuffer cannot handle strings with embedded NULLs\n");
	}
	
	pbuf = cpp_push_buffer(&parse_in,szBuf,length,1 /* FROM PERL */);
	pbuf->ichSourceStart = ichStart - 1;
	pbuf->ichSourceEnd = ichStart + length;
        pbuf->nominal_fname = "FromPerl";


###%\backcall{}{EnterScope}{}
###% Enters a new scoping level; useful in combination
###% with PushBuffer() for causing code to be parsed without
###% affecting the current symbol table directly.
void
EnterScope()
	PPCODE:
	if (!fShouldParse) goto done;
	enter_scope(ParseStack->contxt);
	done:


###%\backcall{}{ExitScope}{}
###% Exits the current scoping level; useful in combination
###% with PushBuffer() for causing code to be parsed without
###% affecting the current symbol table directly.
void
ExitScope()
	PPCODE:
	if (!fShouldParse) goto done;
	exit_scope(ParseStack->contxt);
	done:

###%\backcall{}{PushHashTab}{}
###% Copies the current cpp hash table and begins using the copy;  the copy
###% can later be thrown out using PopHashTab()
void
PushHashTab()
	PPCODE:
	cpp_push_hashtab(&parse_in);

###%\backcall{}{PopHashTab}{}
###% Throw out a previously pushed cpp hash table; revert to the prior
###% hash table
void
PopHashTab()
	CODE:
	cpp_pop_hashtab(&parse_in);

###%\backcall{}{SetParseDebugging}{}
###% Set the yydebug flag to TRUE for the underlying parser.
###% This results in extra state change information being sent to stderr.
###% It has no affect if --noparse is used.  Initially, parser debugging is off.
void
SetParseDebugging()
 	CODE:
 	ct_yydebug = 1;
 

###%\backcall{}{ResetParseDebugging}{}
###% Reset the yydebug flag to FALSE for the underlying parser.  
###% This terminates sending extra state change information to stderr.
###% It has no affect if --noparse is used.
void
ResetParseDebugging()
	CODE:
	ct_yydebug = 0;


###%\backcall{}{YYPushStackState}{}
###% Save the entire current state of the parse stack onto a meta stack.
void
YYPushStackState()
	CODE:
	if (!fShouldParse) goto done;
	PushStackState();
	done:

###%\backcall{}{YYPopAndRestoreStackState}{}
###% Restore the entire current state of the parse stack from the meta stack.
void
YYPopAndRestoreStackState()
	CODE:
	if (!fShouldParse) goto done;
	PopAndRestoreStackState();
	done:

###%\backcall{}{YYPopAndRestoreStackState}{}
###% Throws out the top state stack from the meta stack.
void
YYPopAndDiscardStackState()
	CODE:
	if (!fShouldParse) goto done;
	PopAndDiscardStackState();
	done:


###%\backcall{}{YYSwapStackState}{}
###% Switch the current stack state and the one on the top of the meta stack.
void
YYSwapStackState()
	CODE:
	if (!fShouldParse) goto done;
	SwapStackState();
	done:

###%\backcall{}{YYPushDupTopStackState}{}
###% Push another copy of the top element of the meta stack of stack states onto
###% the meta stack.
void
YYPushDupTopStackState()
	CODE:
	if (!fShouldParse) goto done;
	PushDupTopStackState();
	done:

###%\backcall{$fStacksEqual}{YYFCompareTopStackState}{}
###% Return TRUE iff the top of the meta stack of state stacks is
###% identical to the current state stack. Return FALSE otherwise.
bool
YYFCompareTopStackState()
	CODE:
        RETVAL = TRUE;
	if (!fShouldParse) goto done;
	RETVAL = FCompareTopStackState();
	done:
	OUTPUT:
	RETVAL

###%\backcall{$state_num}{YYGetState}{}
###% Return the current state of the parser.
bool
YYGetState()
        PREINIT:
	extern int yystate;
	CODE:
        RETVAL = 0;
	if (!fShouldParse) goto done;
        RETVAL = yystate;
	done:
	OUTPUT:
	RETVAL

###%\backcall{$state_num}{YYGetNode}{}
###% Return the current state of the parser.
unsigned int
YYGetNode()
        PREINIT:
	extern int yystate;
        extern tree_union ct_yylval;
	CODE:
        RETVAL = 0;
	if (!fShouldParse) goto done;
        RETVAL = (unsigned int) ct_yylval.node;
	done:
	OUTPUT:
	RETVAL


###%\backcall{}{YYSetState}{$state_number}
###% Set the current state of the parser to $state_number
void
YYSetState(state_num)
        int state_num;
        PREINIT:
	extern int yystate;
        extern tree_union ct_yylval;
	CODE:
	if (fShouldParse) {
          yystate = state_num;
          ct_yylval.node = 0;
        }

###%\backcall{$state_num}{YYGetNode}{}
###% Return the current state of the parser.
void
YYSetNode(node)
	unsigned int node;
        PREINIT:
	extern int yystate;
        extern tree_union ct_yylval;
	CODE:
	if (fShouldParse) {
          ct_yylval.node = node;
        }


###%\backcall{$fDefined}{FLookupSymbol}{$symbol_id}
###% Return TRUE iff $symbol_id is found in the current scope.
###% Return FALSE otherwise.
bool
FLookupSymbol(szSymbol)
        char *szSymbol;
	PREINIT:
	str_t *pstr;
	symentry_t *se;
	CODE:
	RETVAL = FALSE;
	if (!fShouldParse) goto done; 
	pstr = nmelook(szSymbol,strlen(szSymbol));
	if (!ParseStack || !ParseStack->contxt) {
	   RETVAL = FALSE;
	} else {
	  se = symtab_lookup(ParseStack->contxt->syms,
			     pstr);
	  RETVAL = (se != NULL);
	}
	done:
	OUTPUT:
	RETVAL


###%\backcall{$fDefined}{FLookupSymbolAt}{$symbol_id}{$level}
###% Return TRUE iff $symbol_id is found in the scope at level $level.
###% Return FALSE otherwise.
bool
FLookupSymbolAt(szSymbol,level)
        char *szSymbol;
        int level;
	PREINIT:
	str_t *pstr;
	symentry_t *se;
	CODE:
	RETVAL = FALSE;
	if (!fShouldParse) goto done; 
	pstr = nmelook(szSymbol,strlen(szSymbol));
	if (!ParseStack || !ParseStack->contxt) {
	   RETVAL = FALSE;
	} else {
	  se = symtab_lookup_at(ParseStack->contxt->syms,
                                pstr,level);
	  RETVAL = (se != NULL);
	}
	done:
	OUTPUT:
	RETVAL
