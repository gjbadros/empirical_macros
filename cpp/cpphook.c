/* $Id$
 * By Greg J. Badros, 8/25/97
 *
 * FIXGJB:
 * Perhaps there should be some implicit arguments to each callback;
 * Maybe they should be global variables;  a lot of cpp state needs
 * to be exposed to perl to make the callback code have the potential
 * to do interesting things
 */

#define bool int
#include <EXTERN.h>               /* from the Perl distribution     */
#include <perl.h>                 /* from the Perl distribution     */
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

SV *
get_hook_for(HOOK_INDEX ih, bool fWarnMissingHooks)
{
  SV **ppsvFunc = NULL;
  AV *pavHooks = perl_get_av("Hooks", FALSE); /* access @Hooks */
  ppsvFunc = av_fetch(pavHooks,ih,0);
  if (ppsvFunc == 0)
    {
    if (fWarnMissingHooks)
      warn("Could not fetch hook index %d\n",ih);
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
  
  PUSHMARK(sp);
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) != 0)
    perl_call_sv(psvFunc, G_DISCARD|G_NOARGS);
}


void
gjb_call_hooks_sz(struct cpp_options *opts, HOOK_INDEX ih, char *sz)
{
  SV *psvFunc = NULL;

  dSP;
  
  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  PUTBACK ;
     
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) != 0)
    perl_call_sv(psvFunc, G_DISCARD);
}


void
gjb_call_hooks_szl_defn(struct cpp_options *opts, HOOK_INDEX ih, 
			char *sz, int cch, DEFINITION *defn)
{
  SV *psvFunc = NULL;

  dSP;
  
  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  PUTBACK ;
     
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) != 0)
    perl_call_sv(psvFunc, G_DISCARD);
}
  
