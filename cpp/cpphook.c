/* $Id$
 * By Greg J. Badros, 8/25/97
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

/* Just a sample test hook */
void
gjb_call_hooks_void(HOOK_INDEX ih)
{
  AV *pavHooks = NULL;
  SV *psvFunc = NULL;
  SV **ppsvFunc = NULL;
  dSP;
  
  PUSHMARK(sp);
  pavHooks = perl_get_av("Hooks", FALSE); /* access @Hooks */
  ppsvFunc = av_fetch(pavHooks,ih,0);
  if (ppsvFunc == 0)
    {
    warn("Could not fetch hook index %d\n",ih);
    return;
    }
  psvFunc = *ppsvFunc;
  perl_call_sv(psvFunc, G_DISCARD|G_NOARGS);
}


void
gjb_call_hooks_sz(HOOK_INDEX ih, char *sz)
{
  AV *pavHooks = NULL;
  SV *psvFunc = NULL;
  SV **ppsvFunc = NULL;

  dSP;
  
  PUSHMARK(sp);
  pavHooks = perl_get_av("Hooks", FALSE); /* access @Hooks */
  ppsvFunc = av_fetch(pavHooks,ih,0);
  if (ppsvFunc == 0)
    {
    warn("Could not fetch hook index %d\n",ih);
    return;
    }
  psvFunc = *ppsvFunc;
  XPUSHs(sv_2mortal(newSVpv(sz, 0)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

