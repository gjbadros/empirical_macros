#ifndef CPPHOOK_H_
#define CPPHOOK_H_

/* Beginnings of additions to cpp stuff by GJB */

#define gjb_printf(s...) do { fflush(stdout); fprintf(stderr,##s); } while (0)

// start hook_index_constants
typedef enum hook_index_constants {
  DO_DEFINE,
  HANDLE_DIRECTIVE,
  STARTUP,
} HOOK_INDEX;
// end hook_index_constants

void gjb_call_hooks_void(HOOK_INDEX);

void gjb_call_hooks_sz(HOOK_INDEX, char *);

#endif
