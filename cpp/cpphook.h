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
///% {$s_start, $s_end, $orig_conditional, $trailer}
///% Called exactly once for each #endif directive seen by the preprocessor. In particular,
///% note that if the directive is skipped due to another outer conditional, this
///% hook does not get called.
///% Arguments give the source code character
///% offsets of the directive; $orig_conditional is the guard of the matching
///% #ifXX directive; $trailer is the text following the #endif (often empty);

  HI_CREATE_PREDEF,
///% {$mname, $expansion, $num_args, $internal_expansion, $file, $line, $r_argnames, $flags,
///% $internal_expansion_args_uses... }
///% Called once for each predefined macro CPP installs.
///% $mname is the name of the macro, $expansion is its expansion [as literal text], 
///% $num_args is the number of arguments it takes, $internal_expansion is an
///% internal representation of the expansion (which is interpreted in the 
///% context of $internal_expansion_args_uses, see cpplib.c), $file and $line
///% can safely be ignored, $r_argnames is a comma separated list of the
///% argument names in reversed order, and $flags is a bitmask of two flags
///% $flags & $PREDEFINED is true if this is a predefined macro (always for this hook)
///% and $flags & $RESTARGS is true if this macro's last argument swallows 
///% remaining arguments (special gcc cpp feature).

  HI_CREATE_DEF,
///% {$s_start, $s_end, $mname, $expansion, $num_args, $internal_expansion,
///%  $file, $line, $r_argnames, $flags, $internal_expansion_args_uses... }
///% Called once for each macro definition read by  CPP.
///% $s_start and $s_end are the source code character offsets of the definition,
///% $mname is the name of the macro, $expansion is its expansion [as literal text], 
///% $num_args is the number of arguments it takes, $internal_expansion is an
///% internal representation of the expansion (which is interpreted in the 
///% context of $internal_expansion_args_uses, see cpplib.c), $file and $line
///% give the filename and line number where the definition occurs, 
///% $r_argnames is a comma separated list of the
///% argument names in reversed order, and $flags is a bitmask of two flags
///% $flags & $PREDEFINED is true if this is a predefined macro (never for this hook)
///% and $flags & $RESTARGS is true if this macro's last argument swallows 
///% remaining arguments (special gcc cpp feature).

  HI_DELETE_DEF,
///% {$mname, $fExists}
///% Called once for each macro name that is undefined for any reason (this is
///% a low level hook called when you attempt to remove a macro name from the 
///% table of macros,
///% also HI_DO_UNDEF for the high level hook).  $mname is the name of the
///% macro, and $fExists is 1 iff that macro name used to be defined.

  HI_SPECIAL_SYMBOL,
///% {$symbol,$enum_node_type}
///% Called once for each special symbol (e.g., __FILE__) that gets expanded.
///% $symbol is the literal text of the symbol, $enum_node_type is an index
///% into @enum_node_type giving the C constant corresponding to that symbol
///% (usually better to just use $symbol instead).

  HI_EXPAND_MACRO,
///% {$s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,
///% $cnested,@nests,$cargs,@args}
///% Called once for each macro expansion in C source (i.e., not for expansions
///% in #ifXX guards). $s_start and $s_end are the source code character offsets
///% of the macro invocation; $mname is name of the macro, $expansion is what
///% replaces $mname in the text (subject to further expansion, of course); $length
///% is the number of characters in that expansion, $raw_call is how the call
///% appeared in the source (includes the macro name), $has_escapes is 0 if the
///% source buffer is actual source text (i.e., if this is a top level expansion),
///% otherwise it is a 1 (escapes has marked with @- preceding the macro name)
///% FIXGJB: is that right?; $cbuffersDeep is how many levels of expansion the text
///% has undergone beyond the source text (0 means the macro occurrence appeared
///% directly in the source code); $cnested tells how many elements are in @nests
///% (so you can separate its arguments from @args); @nests is obsoleted FIXGJB:;
///% $cargs tells how many arguments $mname takes; and @args contains argument
///% expansion and use information.  Each argument contributes 7 elements to @args
///% plus a pair of elements for each use;  e.g., if the first argument was used 3 times
///% it would have 7 + 3*2 = 13 elements in @args describing its expansion.  The
///% first 6 arguments are $raw,$r_offset,$expanded,$e_offset,$stringified,$s_offset
///% which correspond to the raw, expanded, and stringified representations of the
///% argument.  The $X_offset elements are internal offsets into a token buffer
///% and can usually be ignored.  $stringified may be empty if the argument was
///% never stringified during the macro expansion.  The seventh element for each
///% argument tells how many times that argument was used in the expansion, and
///% successive pairs of elements give character offsets to the appearance of those
///% arguments in the expansion.  For example if argument 1 is used 3 times, there could
///% be (3, 5,6, 9,11,  14,18) as the final elements of the @args list.  Note that
///% because the third expansion is longer than the first two (4 characters instead of
///% just two), it must have been stringified. FIXGJB is this true?

  HI_MACARG_EXP,
///% {$mname,$raw,$number}

  HI_MACRO_CLEANUP,
///% {$s_start, $s_end, $mname, $c_nested, @nests}
///% Called once for each macro expansion buffer as it is removed 
///% from the stack of text buffers.  $s_start and $s_end give the source
///% code character position offset of the text which expanded into the text
///% that is in the buffer currently being cleaned and pop-ped;  $mname is the
///% name of the macro that resulted in that expansion; $c_nested and @nests
///% are obsoleted.  Note that to get the full text of the expansion, you must
///% track successive strings passed to the CPP_OUT hook, and reset the
///% string used to accumulate the expansion when the CbuffersBack backcall
///% is 1 in this hook (meaning you are cleaning up a top level macro expansion).
///% See cpphook.pm for an example.

  HI_IFDEF_MACRO,
///% {$s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,
///% $cnested,@nests,$cargs,@args}
///% Called once for each macro expansion in #ifXX directives.  The arguments
///% passed to the hook are the same as those for the EXPAND_MACRO hook, see its
///% documentation for details.

  HI_COMMENT,
///% {$s_start, $s_end, $comment_text, $how_terminated, $c_lines}
///% Called once for each comment in the source code seen by preprocessor (i.e.,
///% comments conditionally-compiiled out will not normally invoke this hook).
///% $comment_text is the text of the comment, $how_term is "*/" for C-style
///% comments, "nl" for a C++ style comment, or "eof" if the comment
///% was ended by the end of file.
///% $c_lines is the number of lines that the comment spans, including partial lines.


  HI_STRING_CONSTANT,
///% {$s_start, $s_end, $string, $lines}
///% Called once for each string in the source code or macro/special symbol expansion.
///% Note that both stringization and symbols like __FILE__ will invoke this hook
///% with their string expansions.
///% Arguments give the source code character offsets of the string, $string is
///% the string, and $lines is the number of lines (or partial lines) that the
///% string spans.  $s_start == $s_end if the string does not actually appear
///% in the top level source code (e.g, __LINE__ or gcc's __FUNCTION__).
///% The source code offsets include the string delimiters, the $string argument
///% has them stripped, but has not had backslash sequences replaced.

  HI_CPP_ERROR,
///% {$nominal_fname,$line_number,$message,@extra_args}
///% Called once each time CPP issues an error.  The hook does not interfere
///% with normal error handling.  Arguments give the current filename and line
///% number where the error occurred;  $message is the string (containing printf
///% percent-escapes) to be printed, and @extra_args are the values to be 
///% interpolated into the string.

  HI_CPP_WARN,
///% {$nominal_fname,$line_number,$message,@extra_args}
///% Called once each time CPP issues a warning.  The hook does not interfere
///% with normal warning handling.  Arguments give the current filename and line
///% number where the warning occurred;  $message is the string (containing printf
///% percent-escapes) to be printed, and @extra_args are the values to be 
///% interpolated into the string.

  HI_CPP_PEDWARN,
///% {$nominal_fname,$line_number,$message,@extra_args}
///% Called once each time CPP issues a pedantic warning.  The hook does not interfere
///% with normal pedantic warning handling.  Arguments give the current filename and line
///% number where the pedantic warning occurred;  $message is the string (containing printf
///% percent-escapes) to be printed, and @extra_args are the values to be 
///% interpolated into the string.

  HI_CPP_OUT,
///% {$string}
///% Called for each sequence of characters cpp is outputting.  This is the
///% same text as would go to the output file when using just cpp (as in gcc -E).
///% Full tokens and/or whitespace are emitted per each call to the hook.
///% Use the CchOutput() and CchOffset() backcalls for output character offset
///% and source code character offset, respectively.

  HI_ADD_IMPORT,
///% {$filename,$was_found} FIXGJB: 2nd arg right?
///% Called for each filename that is #import-ed.  Arguments give that
///% file name and $was_found, which is negative iff the file was not found.

  HI_INCLUDE_FILE,
///% {$filename, $system_include}
///% Called for each file that is #include-d (not necessarily for each #include
///% directive; this hook won't be called if the file cannot be found).
///% Arguments are the filename and $system_include, which is non-zero if the filename
///% appears to be a system include file (absolute pathname and in a known
///% system directory);  it is exactly 2 iff the file is a C-language
///% system header file for which C++ should assume extern "C".

  HI_DONE_INCLUDE_FILE,
///% {$filename}
///% Called upon completion of parsing of an included file.  The filename
///% that what just finished being parsed is the only argument.

  HI_TOKEN,
///% {$token,$raw,$macro_name,$arg_num,@history}
///% Called once for each token CPP reads.  $token is the type of token,
///% with a leading CPP_; $raw is the raw characters which constitute that
///% token; $macro_name is the name of the macro that expanded to create this token,
///% or is empty if the token did not result from macro expansion; $arg_num is -1
///% if the token did not come from a macro expansion, 0 if it came from the
///% body of a macro expansion (i.e., not an argument), or positive and equal
///% to the argument number that produced the token, if from an substitution
///% of an argument in a macro expansion; @history is obsoleted, use the
///% MacroExpansionHistory() backcall instead.  Note that the token "CPP_POP"
///% means that an expansion buffer has been popped from the stack of expansions,
///% and is not a real lexical token.  This may be removed from future version
///% so use the POP_BUFFER hook to handle those events.

  HI_FUNCTION,
///% {$name,$fStatic}
///% Called once after an entire function is parsed.  Arguments
///% give the name of the newly defined function, and $fStatic is non-zero
///% iff the function was declared to be static (i.e. not global).

  HI_FUNC_CALL,
///% {$name}
///% Called once after each function call is parsed.  Only argument is
///% the name of the function being called.

  HI_ANNOTATE,
///% {} Obsoleted

  HI_POP_BUFFER,
///% {$cbuffersDeep}
///% Called once for each buffer that is popped off of the stack of
///% buffers to be parsed. The only argument is the new (after the pop)
///% number of non-file buffers
///% deep the stack is.  In particular, when that number is 0, 
///% the parser is not parsing a macro expansion any longer.

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
			      int ichSourceStart, int ichSourceEnd,
			      char *sz1, char *sz2, int cch2, int i1, 
			      char *sz3, int cch3, 
			      int has_escapes, int cbuffersDeep,
			      cpp_expand_info *pcei,
			      int nargs, struct argdata *args);

void gjb_call_hooks_macro_cleanup(struct cpp_options *opts, HOOK_INDEX ih, int s, int e,
				  char *sz1, cpp_expand_info *pcei);

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

void gjb_call_hooks_i_i_szl_sz_i(struct cpp_options *, HOOK_INDEX, int, int,
				  char *, int, char *, int );


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

void gjb_call_hooks_szl_sz_defn(struct cpp_options *, HOOK_INDEX,
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
