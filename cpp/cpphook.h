#ifndef CPPHOOK_H_
#define CPPHOOK_H_

#include "cpplib.h"

#ifdef 0
#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)
#endif


// start hook_index_constants
// Documentation strings below get pulled out using extract-latex-comments <cpphook.h
// the comments refer to the preceding hook.
typedef enum hook_index_constants {
  HI_STARTUP,
///% {} Called immediately after the perl parser is initialized.

  HI_STARTPARSE,
///% {} Called just before the bison parser is started (i.e., before yyparse()).

  HI_EXIT,
///% {$return_exit_code} Called just before the system exit() call.

  HI_HANDLE_DIRECTIVE,
///% {$directive_name} Called exactly once for each directive.  $directive_name is
///% the directive as it appeared in the source code with the leading # removed.

  HI_DO_DEFINE,
///% {$s_start,$s_end,$name_args_body} Called exactly once for each #define. 
///% Arguments give the source code character offsets of the line and the 
///% unprocessed rest of the line including the name of the macro, its arguments
///% and its definition.

  HI_PRE_DO_UNDEF,
///% {$s_start,$s_end,$mname} Called exactly once for each #undef.
///% Arguments give the source code character offsets of the line and the
///% name of the macro being undefined.  This hook is called just before
///% the macro is undefined, so its definition still exists 
///% in the preprocessor's state.

  HI_DO_UNDEF,
///% {$s_start,$s_end,$mname} Called exactly once for each #undef.
///% Arguments give the source code character offsets of the line and the
///% name of the macro being undefined.  This hook is called immediately after
///% the macro is undefined.

  HI_DO_INCLUDE,
///% {$s_start,$s_end,$filename_given, $filename_resolved, $flags} 
///% Called exactly once for each #include,
///% #include_next, or #import directive.  Source coded character offsets of
///% the line are given. Also, $filename_given is the name of the
///% file to be included as written in the source;  $filename_resolved is the
///% fully qualified path name of the file to be read; and  $flags is a bitmap
///% with three relevant masks:  $ANGLE_BRACKETS, for whether the filename appeared
///% in angle brackets signifying a system include file; $SKIP_DIRS, for whether this
///% is an #include_next directive; and $IMPORTING, for whether this is an #import
///% directive.

  HI_DO_IF,
///% {$s_start,$s_end, $conditional, $skipped, $value} 
///% Called exactly once for each #if 
///% (not #ifdef or #ifndef) directive seen by the preprocessor. In particular,
///% note that normally, nested #ifXX-s that are ignored will not invoke this hook.
///% Arguments give the source code character
///% offsets of the directive; $conditional is the guard checked, $skipped is
///% the literal text that is skipped (conditional was false if this is non-empty), and
///% $value is 1 iff the $conditional evaluated to true (defined), 0 otherwise.

  HI_DO_XIFDEF,
///% {}

  HI_DO_IFDEF,
///% {$s_start, $s_end, $conditional, $trailer, $skipped, $value}
///% Called exactly once for each #ifdef
///% (not #if or #ifndef) directive seen by the preprocessor. In particular,
///% note that normally, nested #ifXX-s that are ignored will not invoke this hook.
///% Arguments give the source code character
///% offsets of the directive; $conditional is the name checked for defined-ness;
///% $trailer is whatever follows that name on the same line (usually empty); $skipped is
///% the literal text that is skipped (conditional was false if this is non-empty), and
///% $value is 1 iff the name from the $conditional was defined, 0 otherwise.

  HI_DO_IFNDEF,
///% {$s_start, $s_end, $conditional, $trailer, $skipped, $value}
///% Called exactly once for each #ifndef
///% (not #if or #ifdef) directive seen by the preprocessor. In particular,
///% note that normally, nested #ifXX-s that are ignored will not invoke this hook.
///% Arguments give the source code character
///% offsets of the directive; $conditional is the name checked for defined-ness;
///% $trailer is whatever follows that name on the same line (usually empty); $skipped is
///% the literal text that is skipped (conditional was false if this is non-empty), and
///% $value is 1 iff the name from the $conditional was not defined, 0 otherwise.

  HI_DO_ELSE,
///% {$s_start, $s_end, $orig_conditional, $trailer, $skipped, $fSkipping, $s_start_branch}
///% Called exactly once for each #else directive seen by the preprocessor. In particular,
///% note that if the directive is skipped due to another outer conditional, this
///% hook does not get called.
///% Arguments give the source code character
///% offsets of the directive; $orig_conditional is the guard in the
///% matching #ifXX directive; 
///% $trailer is whatever follows #else on the same line (usually empty); $skipped is
///% the literal text that is skipped (if any); $fSkipping is 1 iff
///% this #else clause's guarded text got skipped; $s_start_branch is a souce code
///% character offset of where the branch begins, if it's used, or the character
///% following the skipped text if not.

  HI_DO_ELIF,
///% {$s_start, $s_end, $already_did_clause, $conditional, $skipped, $value}
///% Called exactly once for each #elif directive seen by the preprocessor. In particular,
///% note that if the directive is skipped due to another outer conditional, this
///% hook does not get called.
///% Arguments give the source code character
///% offsets of the directive; $already_did_clause is 1 iff one of the
///% earlier #ifXX or #elif-s succeeded (thus implying the code guarded will be skipped);
///% $conditional is the conditional tested; $skipped is the skipped code (if any);
///% and $value is what $conditional evaluated to.  The code guarded is
///% included iff !$conditional and $value, in which case $skipped will be empty.

  HI_DO_ENDIF,
///% {}

  HI_CREATE_PREDEF,
///% {}

  HI_CREATE_DEF,
///% {}

  HI_DELETE_DEF,
///% {}

  HI_SPECIAL_SYMBOL,
///% {}

  HI_EXPAND_MACRO,
///% {}

  HI_MACARG_EXP,
///% {}

  HI_MACRO_CLEANUP,
///% {}

  HI_IFDEF_MACRO,
///% {}

  HI_COMMENT,
///% {}

  HI_STRING_CONSTANT,
///% {}

  HI_CPP_ERROR,
///% {}

  HI_CPP_WARN,
///% {}

  HI_CPP_PEDWARN,
///% {}

  HI_CPP_OUT,
///% {}

  HI_ADD_IMPORT,
///% {}

  HI_INCLUDE_FILE,
///% {}

  HI_DONE_INCLUDE_FILE,
///% {}

  HI_TOKEN,
///% {}

  HI_FUNCTION,
///% {}

  HI_FUNC_CALL,
///% {}

  HI_ANNOTATE,
///% {}

  HI_POP_BUFFER,
///% {}

} HOOK_INDEX;
// end hook_index_constants

/* Notes:
 * DO_UNDEF gets called *after* DELETE_DEF for a #undef, since it gets
 * the extra arg about whether the name was defined
 */

void gjb_call_hooks_void(struct cpp_options *, HOOK_INDEX);

void gjb_call_hooks_i(struct cpp_options *, HOOK_INDEX, int);

void gjb_call_hooks_sz(struct cpp_options *, HOOK_INDEX, char *);

void gjb_call_hooks_sz_szl(struct cpp_options *, HOOK_INDEX, char *, char *, int);

void gjb_call_hooks_i_i_sz_szl(struct cpp_options *, HOOK_INDEX, int, int,
			       char *, char *, int);

void gjb_call_hooks_sz_szl_i(struct cpp_options *, HOOK_INDEX, char *, char *, int, int);

void gjb_call_hooks_sz_szl_i_i(struct cpp_options *, HOOK_INDEX, char *, char *, int, int, int);

void gjb_call_hooks_sz_i_i(struct cpp_options *, HOOK_INDEX, char *, int, int);

void gjb_call_hooks_i_i_sz(struct cpp_options *, HOOK_INDEX, int, int, char *);

void gjb_call_hooks_sz_szl_i_szl_i(struct cpp_options *, HOOK_INDEX, 
				   char *, char *, int, int, char *, int, int);

void gjb_call_hooks_pcat_szl(struct cpp_options *, HOOK_INDEX, cpp_annotated_token *,
			     char *, int);

void gjb_call_hooks_expansion(struct cpp_reader *pfile, HOOK_INDEX ih,
			      char *sz1, char *sz2, int cch2, int i1, 
			      char *sz3, int cch3, int ichSourceStart, int ichSourceEnd,
			      int has_escapes, int cbuffersDeep,
			      cpp_expand_info *pcei,
			      int nargs, struct argdata *args);

void gjb_call_hooks_macro_cleanup(struct cpp_options *opts, HOOK_INDEX ih,
				  char *sz1, int i1, int i2, cpp_expand_info *pcei);

void gjb_call_hooks_sz_szl_szl(struct cpp_options *, HOOK_INDEX, 
			       char *, char *, int, char *, int);

void gjb_call_hooks_sz_szl_szl_i(struct cpp_options *, HOOK_INDEX, 
				 char *, char *, int, char *, int, int);

void gjb_call_hooks_sz_szl_szl_i_i(struct cpp_options *, HOOK_INDEX, 
				   char *, char *, int, char *, int, int, int);

void gjb_call_hooks_i_i_sz_szl_szl_i_i(struct cpp_options *, HOOK_INDEX, int, int,
				       char *, char *, int, char *, int, int, int);

void gjb_call_hooks_szl_sz_i(struct cpp_options *, HOOK_INDEX, char *, int, char *, int);

void gjb_call_hooks_szl_szl_i(struct cpp_options *, HOOK_INDEX, char *, int,
			      char *, int, int);

void gjb_call_hooks_i_i_szl_szl_i(struct cpp_options *, HOOK_INDEX, int, int,
				  char *, int, char *, int, int);

void gjb_call_hooks_i_i_i_szl_szl_i(struct cpp_options *, HOOK_INDEX, int, int, int,
				    char *, int, char *, int, int);

void gjb_call_hooks_sz_sz_i(struct cpp_options *, HOOK_INDEX, char *, char *, int);

void gjb_call_hooks_i_i_sz_sz_i(struct cpp_options *, HOOK_INDEX, int, int,
				char *, char *, int);

void gjb_call_hooks_i_i_sz_sz_3flags(struct cpp_options *, HOOK_INDEX, int, int, 
				     char *, char *, 
				     int, int, int);


/* FIXGJB: beware _szl and _sz_i have some proto! */
void gjb_call_hooks_szl(struct cpp_options *, HOOK_INDEX, char *, int);

void gjb_call_hooks_szl_i(struct cpp_options *, HOOK_INDEX, char *, int, int);

void gjb_call_hooks_sz_i(struct cpp_options *, HOOK_INDEX, char *, int);

void gjb_call_hooks_sz_i_sz_i(struct cpp_options *, HOOK_INDEX, char *, int,
			      char *, int);

void gjb_call_hooks_sz_i_sz_i_i(struct cpp_options *, HOOK_INDEX, char *, int,
				char *, int, int);

void gjb_call_hooks_i_i_szl_sz_defn(struct cpp_options *, HOOK_INDEX, int, int,
				    char *, int, char *, DEFINITION *);

void gjb_call_hooks_i_i_szl_i(struct cpp_options *opts, HOOK_INDEX ih, int s, int e,
			      char *sz, int cch, int i);

void gjb_call_hooks_i_i_szl(struct cpp_options *opts, HOOK_INDEX ih, int s, int e,
			    char *sz, int cch);


void gjb_call_hooks_szx4(struct cpp_options *, HOOK_INDEX, char *, char *, char *, char *);

void gjb_call_hooks_sz_szlx3_i(struct cpp_options *, HOOK_INDEX, char *, 
			       char *, int,  char *, int,  char *, int,   int);

void gjb_call_hooks_i_i_sz_szlx3_i(struct cpp_options *, HOOK_INDEX, char *, int, int,
				   char *, int,  char *, int,  char *, int,   int);

void gjb_call_hooks_sz_szlx3_i_i(struct cpp_options *, HOOK_INDEX, char *, 
				 char *, int,  char *, int,  char *, int,   int, int);

void gjb_call_hooks_szlx3_i(struct cpp_options *, HOOK_INDEX,
			    char *, int,  char *, int,  char *, int,   int);

void gjb_call_hooks_i_i_szlx3_i(struct cpp_options *, HOOK_INDEX, int, int,
				char *, int,  char *, int,  char *, int,   int);


void gjb_call_hooks_sz_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, 
				 char *, char *, char *, char *);
void gjb_call_hooks_sz_i_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, int,
				   char *, char *, char *, char *);


char * SzFromToken(enum cpp_token_id kind);

#endif
