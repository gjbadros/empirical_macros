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

AV *
newAVfromReverseCommaDelimitedString(char *sz)
{
  AV *pav = newAV();
  int cch = 0;
  char *next = strrchr(sz,',');
  while (next != NULL)
    {
    cch = next-sz;
    av_unshift(pav,1);
    fprintf(stderr,"ARG: %s\n",sz);
    av_store(pav,0,sv_2mortal(newSVpv(sz,cch)));
    sz = next+1;

    next = strrchr(sz,',');
    }
  return pav;
}
  
  


void
gjb_call_hooks_szl_sz_defn(struct cpp_options *opts, HOOK_INDEX ih, 
			char *sz, int cch, char *expn, DEFINITION *defn)
{
  SV *psvFunc = NULL;
  struct reflist *prlCurr = NULL;
  AV *pavArgnames = newAVfromReverseCommaDelimitedString(defn->args.argnames);

  dSP;
  
  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz, cch)));
  XPUSHs(sv_2mortal(newSVpv(expn, 0)));
  XPUSHs(sv_2mortal(newSViv(defn->nargs)));
  XPUSHs(sv_2mortal(newSVpv(defn->expansion, 0)));
  XPUSHs(sv_2mortal(newSVpv(defn->file, 0)));
  XPUSHs(sv_2mortal(newSViv(defn->line)));
  XPUSHs(sv_2mortal(newSVpv(defn->args.argnames,0 )));
  XPUSHs(newRV_inc((SV*) pavArgnames));
  XPUSHs(sv_2mortal(newSViv(defn->predefined)));
  XPUSHs(sv_2mortal(newSViv(defn->rest_args)));
  prlCurr = defn->pattern;
  while (prlCurr != NULL)
    {
    XPUSHs(sv_2mortal(newSViv(prlCurr->stringify)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->raw_before)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->raw_after)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->rest_args)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->argno)));
    XPUSHs(sv_2mortal(newSViv(prlCurr->nchars)));
    prlCurr = prlCurr->next;
    }
  PUTBACK ;
     
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) != 0)
    perl_call_sv(psvFunc, G_DISCARD);
}
  
