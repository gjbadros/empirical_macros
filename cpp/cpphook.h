#ifndef CPPHOOK_H_
#define CPPHOOK_H_

#include "cpplib.h"

/* Beginnings of additions to cpp stuff by GJB */

#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)

// start hook_index_constants
typedef enum hook_index_constants {
  STARTUP,
  HANDLE_DIRECTIVE,
  DO_DEFINE,
  DO_UNDEF,
  CREATE_PREDEF,
  CREATE_DEF,
  DELETE_DEF,
  SPECIAL_SYMBOL,
  EXPAND_MACRO,
  COMMENT,
  CPP_ERROR,
  CPP_WARN,
  CPP_PEDWARN
} HOOK_INDEX;
// end hook_index_constants

/* Notes:
 * DO_UNDEF gets called *after* DELETE_DEF for a #undef, since it gets
 * the extra arg about whether the name was defined
 */

void gjb_call_hooks_void(struct cpp_options *, HOOK_INDEX);

void gjb_call_hooks_sz(struct cpp_options *, HOOK_INDEX, char *);

void gjb_call_hooks_sz_szl(struct cpp_options *, HOOK_INDEX, char *, char *, int);

void gjb_call_hooks_szl_sz_i(struct cpp_options *, HOOK_INDEX, char *, int, char *, int);

void gjb_call_hooks_sz_i(struct cpp_options *, HOOK_INDEX, char *, int);

void gjb_call_hooks_szl_sz_defn(struct cpp_options *, HOOK_INDEX, char *, 
				int, char *, DEFINITION *);

void gjb_call_hooks_szx4(struct cpp_options *, HOOK_INDEX, char *, char *, char *, char *);

void gjb_call_hooks_sz_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, 
				 char *, char *, char *, char *);
void gjb_call_hooks_sz_i_i_sprintf(struct cpp_options *, HOOK_INDEX, char *, int, int,
				   char *, char *, char *, char *);
#endif
