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
#include "cpphash.h"
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

inline SV *newSVpv_safe(char *sz, int cch) {
  if (sz)
    return newSVpv(sz,cch);
  else
    return newSVpv("",0);
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
gjb_call_hooks_sz_i_i(struct cpp_options *opts, HOOK_INDEX ih,
		      char *sz1, int i1, int i2)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_szl_i_szl_i(struct cpp_options *opts, HOOK_INDEX ih,
			      char *sz1, char *sz2, int cch2, int i1, 
			      char *sz3, int cch3, int i2)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz3, cch3)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}


int CNestedArgExpansions(cpp_expand_info *pcei)
{
  int cexpansions = 0;
  while (pcei != NULL)
    {
    cexpansions++;
    pcei = pcei->pceiPrior;
    }
  return cexpansions;
}

// Returns ($token_type,$mname_from,$argno,$raw)
void gjb_call_hooks_pcat_szl(struct cpp_options *opts, HOOK_INDEX ih, 
			     cpp_annotated_token *pcat,
			     char *szRaw, int cchRaw)
{
  SV *psvFunc = NULL;
  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(SzFromToken(pcat->id), 0)));
  XPUSHs(sv_2mortal(newSVpv_safe(pcat->szMnameFrom,0)));
  XPUSHs(sv_2mortal(newSViv(pcat->from_what)));
  XPUSHs(sv_2mortal(newSVpvlen(szRaw, cchRaw)));

  if (pcat->args && pcat->from_what > 0) 
    {
    cpp_expand_info *pcei = pcat->args[pcat->from_what-1].pcei;
    
    while (pcei != NULL) 
      {
      XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",pcei->hp?(char *)pcei->hp->name:"",
				 pcei->argno+1,
				 pcei->offset)));
      pcei = pcei->pceiPrior;
      }
    }

  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}


void
gjb_call_hooks_expansion(struct cpp_reader *pfile, HOOK_INDEX ih,
			 char *sz1, char *sz2, int cch2, int i1, 
			 char *sz3, int cch3, int ichSourceStart, int ichSourceEnd,
			 int has_escapes, int cbuffersDeep,
			 cpp_expand_info *pcei,
			 int nargs, struct argdata *args)
{
  SV *psvFunc = NULL;
  int iarg = 0;
  int iuse = 0;
  struct cpp_options *opts = CPP_OPTIONS(pfile);
  int cNestedArgExpansions = CNestedArgExpansions(pcei);

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSVpvlen(sz2, cch2)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSVpvlen(sz3, cch3)));
  XPUSHs(sv_2mortal(newSViv(ichSourceStart)));
  XPUSHs(sv_2mortal(newSViv(ichSourceEnd)));
  XPUSHs(sv_2mortal(newSViv(has_escapes)));
  XPUSHs(sv_2mortal(newSViv(cbuffersDeep)));
  XPUSHs(sv_2mortal(newSViv(cNestedArgExpansions)));
  while (pcei != NULL) 
    {
    XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",pcei->hp->name,pcei->argno+1,
			       pcei->offset)));
    pcei = pcei->pceiPrior;
    }
  XPUSHs(sv_2mortal(newSViv(nargs)));
  for (iarg = 0; iarg < nargs; iarg++)
    {
    int len = args[iarg].raw_length;
    XPUSHs(sv_2mortal(newSVpvlen(pfile->token_buffer+args[iarg].raw,
				 len)));
    XPUSHs(sv_2mortal(newSViv(len<0?-1:args[iarg].raw)));

    len = args[iarg].expand_length;
    XPUSHs(sv_2mortal(newSVpvlen(pfile->token_buffer+args[iarg].expanded,
				 len)));
    XPUSHs(sv_2mortal(newSViv(len<0?-1:args[iarg].expanded)));

    len = args[iarg].stringified_length;
    XPUSHs(sv_2mortal(newSVpvlen(pfile->token_buffer+args[iarg].stringified,
				 len)));
    XPUSHs(sv_2mortal(newSViv(len<0?-1:args[iarg].stringified)));

    XPUSHs(sv_2mortal(newSViv(args[iarg].use_count)));
    for (iuse = 0; iuse < args[iarg].use_count; iuse++) 
      {
      XPUSHs(sv_2mortal(newSViv(args[iarg].dchUsesStart[iuse])));
      XPUSHs(sv_2mortal(newSViv(args[iarg].dchUsesEnd[iuse])));
      }

    }
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}



void
gjb_call_hooks_macro_cleanup(struct cpp_options *opts, HOOK_INDEX ih,
			     char *sz1, int i1, int i2, cpp_expand_info *pcei)
{
  SV *psvFunc = NULL;
  int cNestedArgExpansions = CNestedArgExpansions(pcei);

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  XPUSHs(sv_2mortal(newSViv(cNestedArgExpansions)));
  while (pcei != NULL) 
    {
    XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",pcei->hp->name,pcei->argno,
			       pcei->offset)));
    pcei = pcei->pceiPrior;
    }
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
gjb_call_hooks_sz_i_sz_i(struct cpp_options *opts, HOOK_INDEX ih, 
			 char *sz1, int i1, char *sz2, int i2)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  PUTBACK ;
     
  perl_call_sv(psvFunc, G_DISCARD);
}

void
gjb_call_hooks_sz_i_sz_i_i(struct cpp_options *opts, HOOK_INDEX ih, 
			   char *sz1, int i1, char *sz2, int i2, int i3)
{
  SV *psvFunc = NULL;

  dSP;
  
  if ((psvFunc = get_hook_for(ih,opts->fWarnMissingHooks)) == 0)
    return;

  PUSHMARK(sp);
  XPUSHs(sv_2mortal(newSVpv(sz1, 0)));
  XPUSHs(sv_2mortal(newSViv(i1)));
  XPUSHs(sv_2mortal(newSVpv(sz2, 0)));
  XPUSHs(sv_2mortal(newSViv(i2)));
  XPUSHs(sv_2mortal(newSViv(i3)));
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

char *
SzFromToken(enum cpp_token_id kind) {
  char *s = "";
  switch (kind)
    {
    case CPP_EOF:
      s = "CPP_EOF";
      break;
    case CPP_OTHER:
      s = "CPP_OTHER";
      break;
    case CPP_COMMENT:
      s = "CPP_COMMENT";
      break;
    case CPP_HSPACE:
      s = "CPP_HSPACE";
      break;
    case CPP_VSPACE:
      s = "CPP_VSPACE";
      break;
    case CPP_NAME:
      s = "CPP_NAME";
      break;
    case CPP_NUMBER:
      s = "CPP_NUMBER";
      break;
    case CPP_CHAR:
      s = "CPP_CHAR";
      break;
    case CPP_STRING:
      s = "CPP_STRING";
      break;
    case CPP_DIRECTIVE:
      s = "CPP_DIRECTIVE";
      break;
    case CPP_LPAREN:
      s = "CPP_LPAREN";
      break;
    case CPP_RPAREN:
      s = "CPP_RPAREN";
      break;
    case CPP_LBRACE:
      s = "CPP_LBRACE";
      break;
    case CPP_RBRACE:
      s = "CPP_RBRACE";
      break;
    case CPP_COMMA:
      s = "CPP_COMMA";
      break;
    case CPP_SEMICOLON:
      s = "CPP_SEMICOLON";
      break;
    case CPP_3DOTS:
      s = "CPP_3DOTS";
      break;
#if 0
    case CPP_ANDAND:
      s = "CPP_ANDAND";
      break;
    case CPP_OROR:
      s = "CPP_OROR";
      break;
    case CPP_LSH:
      s = "CPP_LSH";
      break;
    case CPP_RSH:
      s = "CPP_RSH";
      break;
    case CPP_EQL:
      s = "CPP_EQL";
      break;
    case CPP_NEQ:
      s = "CPP_NEQ";
      break;
    case CPP_LEQ:
      s = "CPP_LEQ";
      break;
    case CPP_GEQ:
      s = "CPP_GEQ";
      break;
    case CPP_PLPL:
      s = "CPP_PLPL";
      break;
    case CPP_MINMIN:
      s = "CPP_MINMIN";
      break;
#endif
  /* POP_TOKEN is returned when we've popped a cpp_buffer. */
    case CPP_POP:
      s = "CPP_POP";
      break;
    }
  return s;
}
