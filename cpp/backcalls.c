/*
 * This file was generated automatically by xsubpp version 1.9402 from the 
 * contents of backcalls.xs. Do not edit this file, edit backcalls.xs instead.
 *
 *	ANY CHANGES MADE HERE WILL BE LOST! 
 *
 */

#line 1 "backcalls.xs"
/* $Id$
 * By Greg J. Badros, Aug. 27 1997
 * 
 * These are simple functions to expose some C data structures
 * to the perl callbacks called from pcpp
 *
 * FIXGJB: Need the below information available:	
   is_system_include_file()
   system_include_depth()
 */


#ifdef __cplusplus
extern "C" {
#endif
#define bool int
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "pcpp.h"
#include "cpplib.h"
#include "cpphash.h"
#include "bison-stack.h"
// #include "globals.h"
#include "tree_stk.h"
#include "nmetab.h"

#ifdef __cplusplus
}
#endif

extern TreeStack *ParseStack;

XS(XS_cpp_SzToken)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::SzToken(i)");
    {
	int	i = (int)SvIV(ST(0));
#line 44 "backcalls.xs"
	char *	RETVAL;
#line 44 "backcalls.xs"
#line 45 "backcalls.xs"
	RETVAL = SzFromToken((enum cpp_token_id) i);
#line 47 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 47 "backcalls.xs"
#line 47 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_SumCchExpansionOffset)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::SumCchExpansionOffset()");
    SP -= items;
    {
	cpp_buffer * buffer = parse_in.buffer;
	long sum = 0;
	int cbuffersBack = 0;
#line 68 "backcalls.xs"
#line 68 "backcalls.xs"
#line 69 "backcalls.xs"
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		/* do not count the leading "@ " */
		long cch = buffer->cur - buffer->buf - 2;
		sum += cch;
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	XPUSHs(sv_2mortal(newSViv(sum)));
	XPUSHs(sv_2mortal(newSViv(cbuffersBack)));
	PUTBACK;
	return;
#line 81 "backcalls.xs"
#line 81 "backcalls.xs"
#line 81 "backcalls.xs"
    }
}

XS(XS_cpp_CbuffersBack)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CbuffersBack()");
    {
#line 90 "backcalls.xs"
	int	RETVAL;
#line 90 "backcalls.xs"
#line 91 "backcalls.xs"
	RETVAL=CbuffersDeep(&parse_in);
#line 93 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 93 "backcalls.xs"
#line 93 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_MacroExpansionHistory)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::MacroExpansionHistory()");
    SP -= items;
    {
	cpp_buffer * buffer = parse_in.buffer;
	int cbuffersBack = 0;
#line 111 "backcalls.xs"
#line 111 "backcalls.xs"
#line 112 "backcalls.xs"
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->data == 0) {
		break;
	    } else {
		HASHNODE *macro = buffer->data;
		if (macro) {
		    int offset = buffer->cur - buffer->buf;
		    int cargs_or_negative = -1;
		    int from_what = 0;
		    if (macro->type == T_MACRO || macro->type == T_DISABLED)
			cargs_or_negative = macro->value.defn->nargs;
		    from_what = 1 + IargWithOffset(offset,
						   cargs_or_negative,
						   buffer->args);
		    XPUSHs(sv_2mortal(newSVpvf("%s#%d[%d]",macro->name,from_what,
					       offset)));
		} else
		    XPUSHs(sv_2mortal(newSVpv("",0)));
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	PUTBACK;
	return;
#line 133 "backcalls.xs"
#line 133 "backcalls.xs"
#line 133 "backcalls.xs"
    }
}

XS(XS_cpp_ArgOf)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::ArgOf()");
    {
	HASHNODE * macro = (HASHNODE*)(parse_in.buffer->data);
	int offset = parse_in.buffer->cur - parse_in.buffer->buf - 1;
	struct argdata * args = parse_in.buffer->args;
#line 143 "backcalls.xs"
	int	RETVAL;
#line 143 "backcalls.xs"
#line 144 "backcalls.xs"
	RETVAL = -2; /* FIXNOWGJB */
	if (args)
	  RETVAL = IargWithOffset(offset, 
				  macro->type==T_MACRO?macro->value.defn->nargs:
				  -macro->type, args) + 1;
#line 150 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 150 "backcalls.xs"
#line 150 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CchOffset)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CchOffset()");
    {
	cpp_buffer * buffer = parse_in.buffer;
	int cbuffersBack = 0;
#line 160 "backcalls.xs"
	int	RETVAL;
#line 160 "backcalls.xs"
#line 161 "backcalls.xs"
	RETVAL=0;
	if (buffer->cur == 0 || buffer->buf == 0)
     	  goto done;
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=buffer->cur - buffer->buf;
	done:
#line 175 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 175 "backcalls.xs"
#line 175 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_InFname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::InFname()");
    {
#line 193 "backcalls.xs"
	char *	RETVAL;
#line 193 "backcalls.xs"
#line 194 "backcalls.xs"
	RETVAL = options.in_fname;
#line 196 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 196 "backcalls.xs"
#line 196 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_Fname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::Fname()");
    {
	cpp_buffer * buffer = cpp_file_buffer(&parse_in);
#line 205 "backcalls.xs"
	char *	RETVAL;
#line 205 "backcalls.xs"
#line 206 "backcalls.xs"
	if (buffer && buffer->nominal_fname) {
	    RETVAL = buffer->nominal_fname;
	} else {
	    RETVAL = "@NONE@";
	}
#line 212 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 212 "backcalls.xs"
#line 212 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_FnameNominal)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::FnameNominal()");
    {
#line 221 "backcalls.xs"
	char *	RETVAL;
#line 221 "backcalls.xs"
#line 222 "backcalls.xs"
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->nominal_fname;
	else
	  RETVAL = "@NOFILE@";
#line 227 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 227 "backcalls.xs"
#line 227 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_ExpansionLookup)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::ExpansionLookup(sz)");
    {
	char *	sz = (char *)SvPV(ST(0),na);
#line 237 "backcalls.xs"
	char *	RETVAL;
#line 237 "backcalls.xs"
#line 238 "backcalls.xs"
	HASHNODE *hp = cpp_lookup(&parse_in,sz,-1,-1);
	RETVAL = "@NOTFOUND@";
	if (hp)
          RETVAL = hp->value.defn->expansion;
#line 243 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 243 "backcalls.xs"
#line 243 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CchOutput)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CchOutput()");
    {
#line 251 "backcalls.xs"
	int	RETVAL;
#line 251 "backcalls.xs"
#line 252 "backcalls.xs"
	RETVAL = cBytesOutput;
#line 254 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 254 "backcalls.xs"
#line 254 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CchCppRead)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CchCppRead()");
    {
#line 261 "backcalls.xs"
	int	RETVAL;
#line 261 "backcalls.xs"
#line 262 "backcalls.xs"
	RETVAL = cBytesCppRead;
#line 264 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 264 "backcalls.xs"
#line 264 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_FExpandingMacros)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::FExpandingMacros()");
    {
#line 272 "backcalls.xs"
	int	RETVAL;
#line 272 "backcalls.xs"
#line 273 "backcalls.xs"
	RETVAL = !parse_in.no_macro_expand;
#line 275 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 275 "backcalls.xs"
#line 275 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_ParseStateStack)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::ParseStateStack()");
    SP -= items;
    {
#line 284 "backcalls.xs"
	extern short *yyss;
	extern short *yyssp;
#line 286 "backcalls.xs"
#line 286 "backcalls.xs"
#line 287 "backcalls.xs"
	short *ssp1 = yyss - 1;
	if (!fShouldParse) {
	    XPUSHs(sv_2mortal(newSVpv("@NOT_PARSING@",0)));
	}
	while (ssp1+1 != NULL && ssp1 != yyssp)
	    XPUSHs(sv_2mortal(newSViv(*++ssp1)));
	PUTBACK;
	return;
#line 292 "backcalls.xs"
#line 292 "backcalls.xs"
#line 292 "backcalls.xs"
    }
}

XS(XS_cpp_SetParseStateStack)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::SetParseStateStack()");
    SP -= items;
    {
#line 300 "backcalls.xs"
#line 300 "backcalls.xs"
#line 301 "backcalls.xs"
	int i = 0;
	if (!fShouldParse) return;
	while (i < items) {
	    short val = (int)SvIV(ST(i));
	    i++;
	}
	PUTBACK;
	return;
#line 306 "backcalls.xs"
#line 306 "backcalls.xs"
#line 306 "backcalls.xs"
    }
}

XS(XS_cpp_PushBuffer)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::PushBuffer($buffer_to_push)");
    SP -= items;
    {
#line 315 "backcalls.xs"
#line 315 "backcalls.xs"
#line 316 "backcalls.xs"
	int length = 0;
	int len = 0;
 	char *szBuf = SvPV(ST(0),length);
	if ((len = strlen(szBuf)) != length) {
	    warn("PushBuffer cannot handle strings with embedded NULLs\n");
	}
	cpp_push_buffer(&parse_in,szBuf,len,1 /* FROM PERL */);
	PUTBACK;
	return;
#line 322 "backcalls.xs"
#line 322 "backcalls.xs"
#line 322 "backcalls.xs"
    }
}

XS(XS_cpp_EnterScope)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::EnterScope()");
    SP -= items;
    {
#line 330 "backcalls.xs"
#line 330 "backcalls.xs"
#line 331 "backcalls.xs"
	if (!fShouldParse) goto done;
	enter_scope(ParseStack->contxt);
	done:
	PUTBACK;
	return;
#line 333 "backcalls.xs"
#line 333 "backcalls.xs"
#line 333 "backcalls.xs"
    }
}

XS(XS_cpp_ExitScope)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::ExitScope()");
    SP -= items;
    {
#line 342 "backcalls.xs"
#line 342 "backcalls.xs"
#line 343 "backcalls.xs"
	if (!fShouldParse) goto done;
	exit_scope(ParseStack->contxt);
	done:
	PUTBACK;
	return;
#line 345 "backcalls.xs"
#line 345 "backcalls.xs"
#line 345 "backcalls.xs"
    }
}

XS(XS_cpp_PushHashTab)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::PushHashTab()");
    SP -= items;
    {
#line 352 "backcalls.xs"
#line 352 "backcalls.xs"
#line 353 "backcalls.xs"
	cpp_push_hashtab(&parse_in);
	PUTBACK;
	return;
#line 353 "backcalls.xs"
#line 353 "backcalls.xs"
#line 353 "backcalls.xs"
    }
}

XS(XS_cpp_PopHashTab)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::PopHashTab()");
    {
#line 360 "backcalls.xs"
#line 360 "backcalls.xs"
#line 361 "backcalls.xs"
	cpp_pop_hashtab(&parse_in);
#line 361 "backcalls.xs"
#line 361 "backcalls.xs"
#line 361 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_SetParseDebugging)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::SetParseDebugging()");
    {
#line 369 "backcalls.xs"
#line 369 "backcalls.xs"
#line 370 "backcalls.xs"
 	ct_yydebug = 1;
#line 370 "backcalls.xs"
#line 370 "backcalls.xs"
#line 370 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_ResetParseDebugging)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::ResetParseDebugging()");
    {
#line 379 "backcalls.xs"
#line 379 "backcalls.xs"
#line 380 "backcalls.xs"
	ct_yydebug = 0;
#line 380 "backcalls.xs"
#line 380 "backcalls.xs"
#line 380 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPushStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPushStackState()");
    {
#line 387 "backcalls.xs"
#line 387 "backcalls.xs"
#line 388 "backcalls.xs"
	if (!fShouldParse) goto done;
	PushStackState();
	done:
#line 390 "backcalls.xs"
#line 390 "backcalls.xs"
#line 390 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPopAndRestoreStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPopAndRestoreStackState()");
    {
#line 396 "backcalls.xs"
#line 396 "backcalls.xs"
#line 397 "backcalls.xs"
	if (!fShouldParse) goto done;
	PopAndRestoreStackState();
	done:
#line 399 "backcalls.xs"
#line 399 "backcalls.xs"
#line 399 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPopAndDiscardStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPopAndDiscardStackState()");
    {
#line 405 "backcalls.xs"
#line 405 "backcalls.xs"
#line 406 "backcalls.xs"
	if (!fShouldParse) goto done;
	PopAndDiscardStackState();
	done:
#line 408 "backcalls.xs"
#line 408 "backcalls.xs"
#line 408 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYSwapStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYSwapStackState()");
    {
#line 415 "backcalls.xs"
#line 415 "backcalls.xs"
#line 416 "backcalls.xs"
	if (!fShouldParse) goto done;
	SwapStackState();
	done:
#line 418 "backcalls.xs"
#line 418 "backcalls.xs"
#line 418 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPushDupTopStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPushDupTopStackState()");
    {
#line 425 "backcalls.xs"
#line 425 "backcalls.xs"
#line 426 "backcalls.xs"
	if (!fShouldParse) goto done;
	PushDupTopStackState();
	done:
#line 428 "backcalls.xs"
#line 428 "backcalls.xs"
#line 428 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYFCompareTopStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYFCompareTopStackState()");
    {
#line 435 "backcalls.xs"
	bool	RETVAL;
#line 435 "backcalls.xs"
#line 436 "backcalls.xs"
        RETVAL = TRUE;
	if (!fShouldParse) goto done;
	RETVAL = FCompareTopStackState();
	done:
#line 441 "backcalls.xs"
	ST(0) = boolSV(RETVAL);
	if (SvREFCNT(ST(0))) sv_2mortal(ST(0));
#line 441 "backcalls.xs"
#line 441 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_FLookupSymbol)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::FLookupSymbol(szSymbol)");
    {
	char *	szSymbol = (char *)SvPV(ST(0),na);
#line 450 "backcalls.xs"
	str_t *pstr;
	symentry_t *se;
#line 452 "backcalls.xs"
	bool	RETVAL;
#line 452 "backcalls.xs"
#line 453 "backcalls.xs"
	RETVAL = FALSE;
	if (!fShouldParse) goto done; 
	pstr = nmelook(szSymbol,strlen(szSymbol));
	if (!ParseStack || !ParseStack->contxt) {
	   RETVAL = FALSE;
	} else {
	  se = symtab_lookup(ParseStack->contxt->syms,
			     pstr);
	  RETVAL = (se != NULL);
	}
	done:
#line 465 "backcalls.xs"
	ST(0) = boolSV(RETVAL);
	if (SvREFCNT(ST(0))) sv_2mortal(ST(0));
#line 465 "backcalls.xs"
#line 465 "backcalls.xs"
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS(boot_backcalls)
{
    dXSARGS;
    char* file = __FILE__;

    XS_VERSION_BOOTCHECK ;

        newXS("cpp::SzToken", XS_cpp_SzToken, file);
        newXS("cpp::SumCchExpansionOffset", XS_cpp_SumCchExpansionOffset, file);
        newXS("cpp::CbuffersBack", XS_cpp_CbuffersBack, file);
        newXS("cpp::MacroExpansionHistory", XS_cpp_MacroExpansionHistory, file);
        newXS("cpp::ArgOf", XS_cpp_ArgOf, file);
        newXS("cpp::CchOffset", XS_cpp_CchOffset, file);
        newXS("cpp::InFname", XS_cpp_InFname, file);
        newXS("cpp::Fname", XS_cpp_Fname, file);
        newXS("cpp::FnameNominal", XS_cpp_FnameNominal, file);
        newXS("cpp::ExpansionLookup", XS_cpp_ExpansionLookup, file);
        newXS("cpp::CchOutput", XS_cpp_CchOutput, file);
        newXS("cpp::CchCppRead", XS_cpp_CchCppRead, file);
        newXS("cpp::FExpandingMacros", XS_cpp_FExpandingMacros, file);
        newXS("cpp::ParseStateStack", XS_cpp_ParseStateStack, file);
        newXS("cpp::SetParseStateStack", XS_cpp_SetParseStateStack, file);
        newXS("cpp::PushBuffer", XS_cpp_PushBuffer, file);
        newXS("cpp::EnterScope", XS_cpp_EnterScope, file);
        newXS("cpp::ExitScope", XS_cpp_ExitScope, file);
        newXS("cpp::PushHashTab", XS_cpp_PushHashTab, file);
        newXS("cpp::PopHashTab", XS_cpp_PopHashTab, file);
        newXS("cpp::SetParseDebugging", XS_cpp_SetParseDebugging, file);
        newXS("cpp::ResetParseDebugging", XS_cpp_ResetParseDebugging, file);
        newXS("cpp::YYPushStackState", XS_cpp_YYPushStackState, file);
        newXS("cpp::YYPopAndRestoreStackState", XS_cpp_YYPopAndRestoreStackState, file);
        newXS("cpp::YYPopAndDiscardStackState", XS_cpp_YYPopAndDiscardStackState, file);
        newXS("cpp::YYSwapStackState", XS_cpp_YYSwapStackState, file);
        newXS("cpp::YYPushDupTopStackState", XS_cpp_YYPushDupTopStackState, file);
        newXS("cpp::YYFCompareTopStackState", XS_cpp_YYFCompareTopStackState, file);
        newXS("cpp::FLookupSymbol", XS_cpp_FLookupSymbol, file);
    ST(0) = &sv_yes;
    XSRETURN(1);
}
