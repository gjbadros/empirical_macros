#ifndef CPPHOOK_H_
#define CPPHOOK_H_

#include "cpplib.h"

#ifdef 0
#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)
#endif

// start hook_index_constants
typedef enum hook_index_constants {
  HI_STARTUP,
  HI_STARTPARSE,
  HI_EXIT,
  HI_HANDLE_DIRECTIVE,
  HI_DO_DEFINE,
  HI_DO_UNDEF,
  HI_DO_INCLUDE,
  HI_DO_IF,
  HI_DO_XIFDEF,
  HI_DO_IFDEF,
  HI_DO_IFNDEF,
  HI_DO_ELSE,
  HI_DO_ELIF,
  HI_DO_ENDIF,
  HI_CREATE_PREDEF,
  HI_CREATE_DEF,
  HI_DELETE_DEF,
  HI_SPECIAL_SYMBOL,
  HI_EXPAND_MACRO,
  HI_MACARG_EXP,
  HI_IFDEF_MACRO,
  HI_COMMENT,
  HI_STRING_CONSTANT,
  HI_CPP_ERROR,
  HI_CPP_WARN,
  HI_CPP_PEDWARN,
  HI_CPP_OUT,
  HI_ADD_IMPORT,
  HI_INCLUDE_FILE,
  HI_DONE_INCLUDE_FILE,
  HI_TOKEN,
  HI_FUNCTION,
  HI_FUNC_CALL,
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

void gjb_call_hooks_sz_szl_i(struct cpp_options *, HOOK_INDEX, char *, char *, int, int);

void gjb_call_hooks_sz_szl_i_i(struct cpp_options *, HOOK_INDEX, char *, char *, int, int, int);

void gjb_call_hooks_sz_szl_i_szl_i(struct cpp_options *, HOOK_INDEX, 
				   char *, char *, int, int, char *, int, int);

void gjb_call_hooks_expansion(struct cpp_reader *pfile, HOOK_INDEX ih,
			      char *sz1, char *sz2, int cch2, int i1, 
			      char *sz3, int cch3, int has_escapes, int cbuffersDeep,
			      int nargs, struct argdata *args);

void gjb_call_hooks_sz_szl_szl(struct cpp_options *, HOOK_INDEX, 
			       char *, char *, int, char *, int);

void gjb_call_hooks_szl_sz_i(struct cpp_options *, HOOK_INDEX, char *, int, char *, int);

void gjb_call_hooks_szl_szl_i(struct cpp_options *, HOOK_INDEX, 
			      char *, int, char *, int, int);

void gjb_call_hooks_sz_sz_i(struct cpp_options *, HOOK_INDEX, char *, char *, int);

void gjb_call_hooks_sz_sz_3flags(struct cpp_options *, HOOK_INDEX, char *, char *, 
				 int, int, int);

/* FIXGJB: beware _szl and _sz_i have some proto! */
void gjb_call_hooks_szl(struct cpp_options *, HOOK_INDEX, char *, int);

void gjb_call_hooks_szl_i(struct cpp_options *, HOOK_INDEX, char *, int, int);

void gjb_call_hooks_sz_i(struct cpp_options *, HOOK_INDEX, char *, int);

void gjb_call_hooks_szl_sz_defn(struct cpp_options *, HOOK_INDEX, char *, 
				int, char *, DEFINITION *);

void gjb_call_hooks_szx4(struct cpp_options *, HOOK_INDEX, char *, char *, char *, char *);

void gjb_call_hooks_sz_szlx3_i(struct cpp_options *, HOOK_INDEX, char *, 
			       char *, int,  char *, int,  char *, int,   int);

void gjb_call_hooks_szlx3_i(struct cpp_options *, HOOK_INDEX,
			    char *, int,  char *, int,  char *, int,   int);

void gjb_call_hooks_sz_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, 
				 char *, char *, char *, char *);
void gjb_call_hooks_sz_i_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, int,
				   char *, char *, char *, char *);
#endif
