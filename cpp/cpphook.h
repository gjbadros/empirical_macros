#ifndef CPPHOOK_H_
#define CPPHOOK_H_

#include "cpplib.h"

/* Beginnings of additions to cpp stuff by GJB */

#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)

// start hook_index_constants
typedef enum hook_index_constants {
  DO_DEFINE,
  HANDLE_DIRECTIVE,
  STARTUP,
  CREATE_PREDEF,
  CREATE_DEF,
} HOOK_INDEX;
// end hook_index_constants

void gjb_call_hooks_void(struct cpp_options *, HOOK_INDEX);

void gjb_call_hooks_sz(struct cpp_options *, HOOK_INDEX, char *);

void gjb_call_hooks_szl_defn(struct cpp_options *, HOOK_INDEX, char *, int, DEFINITION *);

#endif
