/* $Id$
 * By Greg J. Badros, 8/25/97
 *
 * FIXGJB:
 * Perhaps there should be some implicit arguments to each callback;
 * Maybe they should be global variables;  a lot of cpp state needs
 * to be exposed to perl to make the callback code have the potential
 * to do interesting things
 *
 */

#define bool int
#include <EXTERN.h>               /* from the Perl distribution     */
#include <perl.h>                 /* from the Perl distribution     */
#include <stdarg.h>

/* Avoid some warnings by undef-fing  perl's TRUE and FALSE macros, 
   since cpp redefs them */
#undef FALSE
#undef TRUE

#include "cpplib.h"
#include <stdio.h>

#ifndef EMACS
#include "config.h"
#endif /* not EMACS */

#include "cpphook.h"
#include "cpphook_names.h"
/*
 * NOTE: newSVpv(sz,cch) crashes when cch < 0;  it also has special behaviour
 * when cch == 0 (it uses strlen to get sz's length.
 * newSVpvlen(sz,cch) works around both of these problems
 *   it will not crash, and it will give "" for len = 0
 */

inline SV *newSVpvlen(char *sz, int cch) {
  if (cch <= 0)
    return newSVpv("",0);
  return newSVpv(sz,cch);
}

inline SV *newSVpvOrNull(char *sz, int cch) {
  if (sz)
    return newSVpv(sz,cch);
  else
    return newSVpv("@NULL@",6);
}


/* return a single new SV * which is the various arguments
 * OR-ed in together into one integer, each integer getting a bit
 * The list should be terminated with a negative number
 * e.g., newSVbitmap(1,0,1,1,-1) return 1+0+4+8 = 13, the binary
 * number gotten when reading the arguments in right->left order
 * Note that stdarg-s requires at least one fixed argument
 */
static 
SV *
newSVbitmap(int iFirst, ...)  // VERY IMPORTANT: must end in arg == -1
{
  va_list ap;
  int i;
  int retval = iFirst;
  int bitvalue = 2;

  va_start(ap,iFirst);
  
  while ((i = va_arg(ap, int)) >= 0 )
    {
    if (i != 0)
      retval |= bitvalue;
    bitvalue *= 2;
    /* only allow 16 bits for now-- prevent infinite loops */
    if (bitvalue > 65536)
      break;
    }
  va_end(ap);
  return newSViv(retval);
}

static
SV *
get_hook_for(HOOK_INDEX ih, bool fWarnMissingHooks)
{
  SV **ppsvFunc = NULL;
  AV *pavHooks = perl_get_av("Hooks", FALSE); /* access @Hooks */
  ppsvFunc = av_fetch(pavHooks,ih,0);
  if (ppsvFunc == 0)
    {
    if (fWarnMissingHooks)
      warn("Could not fetch hook for %s (index %d)\n",hook_names[ih],ih);
    return NULL;
    }
  return *ppsvFunc;
}

/* Just a sample test hook */
void
gjb_call_hooks_void(struct cpp_options *opts, HOOK_INDEX ih)
{
  SV *psvFunc = NULL;
  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  perl_call_sv(psvFunc, G_DISCARD|G_NOARGS);
}


void
gjb_call_hooks_i(struct cpp_options *opts, HOOK_INDEX ih, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz(struct cpp_options *opts, HOOK_INDEX ih, char *sz)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_szl(struct cpp_options *opts, HOOK_INDEX ih,
		      char *sz1, char *sz2, int cch)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_szl_i(struct cpp_options *opts, HOOK_INDEX ih,
			char *sz1, char *sz2, int cch, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_szl_i_i(struct cpp_options *opts, HOOK_INDEX ih,
			  char *sz1, char *sz2, int cch, int i1, int i2)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_szl_szl(struct cpp_options *opts, HOOK_INDEX ih,
			  char *sz, char *sz1, int cch1, char *sz2, int cch2)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz1, cch1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_szl(struct cpp_options *opts, HOOK_INDEX ih,
		      char *sz, int cch)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz, cch)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_szl_sz_i(struct cpp_options *opts, HOOK_INDEX ih,
			char *sz1, int cch1, char *sz2, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz1, cch1)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_szl_szl_i(struct cpp_options *opts, HOOK_INDEX ih,
			char *sz1, int cch1, char *sz2, int cch2, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz1, cch1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void 
gjb_call_hooks_szlx3_i(struct cpp_options *opts, HOOK_INDEX ih,
		       char *sz1, int cch1,  char *sz2, int cch2,
		       char *sz3, int cch3,  int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz1, cch1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  XPUSHs(sv_2mortal(newSVpvlen(sz3, cch3)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void 
gjb_call_hooks_sz_szlx3_i(struct cpp_options *opts, HOOK_INDEX ih, char *sz, 
			  char *sz1, int cch1,  char *sz2, int cch2,
			  char *sz3, int cch3,  int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz1, cch1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  XPUSHs(sv_2mortal(newSVpvlen(sz3, cch3)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_sz_i(struct cpp_options *opts, HOOK_INDEX ih,
			char *sz1, char *sz2, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_sz_3flags(struct cpp_options *opts, HOOK_INDEX ih,
			    char *sz1, char *sz2, int f1, int f2, int f3)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvOrNull(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSVbitmap(f1,f2,f3,-1)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_i(struct cpp_options *opts, HOOK_INDEX ih, char *sz, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_szl_i(struct cpp_options *opts, HOOK_INDEX ih, char *sz, int cch, int i)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz, cch)));
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}


void
gjb_call_hooks_szl_sz_defn(struct cpp_options *opts, HOOK_INDEX ih, 
			   char *sz, int cch, char *expn, DEFINITION *defn)
{
  SV *psvFunc = NULL;
  struct reflist *prlCurr = NULL;
  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpvlen(sz, cch)));
  XPUSHs(sv_2mortal(newSVpv(expn, 0)));
  XPUSHs(sv_2mortal(newSViv(defn->nargs)));
  XPUSHs(sv_2mortal(newSVpv(defn->expansion, 0)));
  XPUSHs(sv_2mortal(newSVpv(defn->file, 0)));
  XPUSHs(sv_2mortal(newSViv(defn->line)));
  XPUSHs(sv_2mortal(newSVpv(defn->args.argnames,0 )));
  XPUSHs(sv_2mortal(newSVbitmap(defn->predefined, defn->rest_args, -1)));
  prlCurr = defn->pattern;
  while (prlCurr != NULL)
    {
    XPUSHs(sv_2mortal(newSViv(prlCurr->argno)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->nchars)));
    XPUSHs(sv_2mortal(newSVbitmap(prlCurr->stringify,
				  prlCurr->raw_before,prlCurr->raw_after,
				  prlCurr->rest_args, -1)));
    prlCurr = prlCurr->next;
    }
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}
  
void
gjb_call_hooks_szx4(struct cpp_options *opts, HOOK_INDEX ih, 
		    char *sz1, char *sz2, char *sz3, char *sz4)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSVpv(sz3, 0)));
  XPUSHs(sv_2mortal(newSVpv(sz4, 0)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void gjb_call_hooks_sz_i_sprintf(struct cpp_options *opts, HOOK_INDEX ih, 
				 char *file, int line, char *msg, 
				 char *a1, char *a2, char *a3)
{
  SV *psvFunc = NULL;
  char szMsg[256];
  int cch = 0;
  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(file, 0)));
  XPUSHs(sv_2mortal(newSViv(line)));
  cch = sprintf(szMsg,msg,a1,a2,a3);
  XPUSHs(sv_2mortal(newSVpvlen(szMsg, cch)));
  PUTBACK ;

  perl_call_sv(psvFunc, G_DISCARD);
}

void gjb_call_hooks_sz_i_i_sprintf(struct cpp_options *opts, HOOK_INDEX ih, 
				   char *file, int line, int col, char *msg, 
				   char *a1, char *a2, char *a3)
{
  SV *psvFunc = NULL;
  char szMsg[256];
  int cch = 0;
  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(file, 0)));
  XPUSHs(sv_2mortal(newSViv(line)));
  XPUSHs(sv_2mortal(newSViv(col)));
  cch = sprintf(szMsg,msg,a1,a2,a3);
  XPUSHs(sv_2mortal(newSVpvlen(szMsg, cch)));
  PUTBACK ;

  perl_call_sv(psvFunc, G_DISCARD);
}
