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
#ifdef __cplusplus
}
#endif


XS(XS_cpp_SzToken)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::SzToken(i)");
    {
	int	i = (int)SvIV(ST(0));
#line 36 "backcalls.xs"
	char *	RETVAL;
#line 36 "backcalls.xs"
#line 37 "backcalls.xs"
	RETVAL = SzFromToken((enum cpp_token_id) i);
#line 39 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 39 "backcalls.xs"
#line 39 "backcalls.xs"
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
#line 56 "backcalls.xs"
#line 56 "backcalls.xs"
#line 57 "backcalls.xs"
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
#line 69 "backcalls.xs"
#line 69 "backcalls.xs"
#line 69 "backcalls.xs"
    }
}

XS(XS_cpp_CbuffersBack)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CbuffersBack()");
    {
	cpp_buffer * buffer = parse_in.buffer;
	int cbuffersBack = 0;
#line 76 "backcalls.xs"
	int	RETVAL;
#line 76 "backcalls.xs"
#line 77 "backcalls.xs"
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=cbuffersBack;
#line 87 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 87 "backcalls.xs"
#line 87 "backcalls.xs"
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
#line 94 "backcalls.xs"
#line 94 "backcalls.xs"
#line 95 "backcalls.xs"
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->data == 0) {
		break;
	    } else {
		HASHNODE *macro = buffer->data;
		if (macro) {
		    int offset = buffer->cur - buffer->buf;
		    int from_what = 1 + 
			IargWithOffset(offset,
				       macro->type==T_MACRO?macro->value.defn->nargs:
				       -macro->type,
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
#line 114 "backcalls.xs"
#line 114 "backcalls.xs"
#line 114 "backcalls.xs"
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
#line 123 "backcalls.xs"
	int	RETVAL;
#line 123 "backcalls.xs"
#line 124 "backcalls.xs"
	RETVAL = -1;
	if (args)
	  RETVAL = IargWithOffset(offset, 
				  macro->type==T_MACRO?macro->value.defn->nargs:
				  -macro->type, args) + 1;
#line 130 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 130 "backcalls.xs"
#line 130 "backcalls.xs"
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
#line 138 "backcalls.xs"
	int	RETVAL;
#line 138 "backcalls.xs"
#line 139 "backcalls.xs"
	while (buffer != CPP_NULL_BUFFER(&parse_in)) {
	    if (buffer->nominal_fname) {
		break;
	    } else {
		cbuffersBack++;
		buffer = CPP_PREV_BUFFER(buffer);
	    }
	}
	RETVAL=buffer->cur - buffer->buf;
#line 149 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 149 "backcalls.xs"
#line 149 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_InFname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::InFname()");
    {
	struct cpp_options * opts = parse_in.data;
#line 163 "backcalls.xs"
	char *	RETVAL;
#line 163 "backcalls.xs"
#line 164 "backcalls.xs"
	RETVAL = opts?opts->in_fname:"@NONE@";
#line 166 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 166 "backcalls.xs"
#line 166 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_Fname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::Fname()");
    {
	cpp_buffer * buffer = parse_in.buffer;
#line 171 "backcalls.xs"
	char *	RETVAL;
#line 171 "backcalls.xs"
#line 172 "backcalls.xs"
	if (buffer == 0) {
	    RETVAL = "@NONE@";
	} else {
	    while (buffer != CPP_NULL_BUFFER(&parse_in)) {
		if (buffer->nominal_fname) {
		    RETVAL = buffer->nominal_fname;
		    break;
		} else {
		    buffer = CPP_PREV_BUFFER(buffer);
		}
	    }
	}
#line 185 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 185 "backcalls.xs"
#line 185 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_fname_obsoleted)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::fname_obsoleted()");
    {
#line 190 "backcalls.xs"
	char *	RETVAL;
#line 190 "backcalls.xs"
#line 191 "backcalls.xs"
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->fname;
	else
	  RETVAL = "@NOBUFFER@";
#line 196 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 196 "backcalls.xs"
#line 196 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_FnameNominal)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::FnameNominal()");
    {
#line 200 "backcalls.xs"
	char *	RETVAL;
#line 200 "backcalls.xs"
#line 201 "backcalls.xs"
	if (parse_in.buffer)
	  RETVAL = parse_in.buffer->nominal_fname;
	else
	  RETVAL = "@NOBUFFER@";
#line 206 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 206 "backcalls.xs"
#line 206 "backcalls.xs"
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
#line 211 "backcalls.xs"
	char *	RETVAL;
#line 211 "backcalls.xs"
#line 212 "backcalls.xs"
	HASHNODE *hp = cpp_lookup(&parse_in,sz,-1,-1);
	RETVAL = "@NOTFOUND@";
	if (hp)
          RETVAL = hp->value.defn->expansion;
#line 217 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 217 "backcalls.xs"
#line 217 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CbytesOutput)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CbytesOutput()");
    {
#line 221 "backcalls.xs"
	int	RETVAL;
#line 221 "backcalls.xs"
#line 222 "backcalls.xs"
	RETVAL = cBytesOutput;
#line 224 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 224 "backcalls.xs"
#line 224 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CbytesOutputAndBuffer_obsolete)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CbytesOutputAndBuffer_obsolete()");
    {
#line 230 "backcalls.xs"
	int	RETVAL;
#line 230 "backcalls.xs"
#line 231 "backcalls.xs"
	RETVAL = cBytesOutput + CPP_WRITTEN(&parse_in);
#line 233 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 233 "backcalls.xs"
#line 233 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_CbytesCppRead)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::CbytesCppRead()");
    {
#line 237 "backcalls.xs"
	int	RETVAL;
#line 237 "backcalls.xs"
#line 238 "backcalls.xs"
	RETVAL = cBytesCppRead;
#line 240 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 240 "backcalls.xs"
#line 240 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_FExpandingMacros)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::FExpandingMacros()");
    {
#line 244 "backcalls.xs"
	int	RETVAL;
#line 244 "backcalls.xs"
#line 245 "backcalls.xs"
	RETVAL = !parse_in.no_macro_expand;
#line 247 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), (IV)RETVAL);
#line 247 "backcalls.xs"
#line 247 "backcalls.xs"
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
#line 253 "backcalls.xs"
	extern short *yyss;
	extern short *yyssp;
#line 255 "backcalls.xs"
#line 255 "backcalls.xs"
#line 256 "backcalls.xs"
	short *ssp1 = yyss - 1;
	if (!fShouldParse) {
	    XPUSHs(sv_2mortal(newSVpv("@NOT_PARSING@",0)));
	}
	while (ssp1+1 != NULL && ssp1 != yyssp)
	    XPUSHs(sv_2mortal(newSViv(*++ssp1)));
	PUTBACK;
	return;
#line 261 "backcalls.xs"
#line 261 "backcalls.xs"
#line 261 "backcalls.xs"
    }
}

XS(XS_cpp_SetParseStateStack)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::SetParseStateStack()");
    SP -= items;
    {
#line 265 "backcalls.xs"
#line 265 "backcalls.xs"
#line 266 "backcalls.xs"
	int i = 0;
	if (!fShouldParse) return;
	while (i < items) {
	    short val = (int)SvIV(ST(i));
	    i++;
	}
	PUTBACK;
	return;
#line 271 "backcalls.xs"
#line 271 "backcalls.xs"
#line 271 "backcalls.xs"
    }
}

XS(XS_cpp_PushBuffer)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::PushBuffer($buffer_to_push)");
    SP -= items;
    {
#line 276 "backcalls.xs"
#line 276 "backcalls.xs"
#line 277 "backcalls.xs"
	int length = 0;
	int len = 0;
 	char *szBuf = SvPV(ST(0),length);
	if ((len = strlen(szBuf)) != length) {
	    warn("PushBuffer cannot handle strings with embedded NULLs\n");
	}
	cpp_push_buffer(&parse_in,szBuf,len);
	PUTBACK;
	return;
#line 283 "backcalls.xs"
#line 283 "backcalls.xs"
#line 283 "backcalls.xs"
    }
}

XS(XS_cpp_SetParseDebugging)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::SetParseDebugging()");
    {
#line 288 "backcalls.xs"
#line 288 "backcalls.xs"
#line 289 "backcalls.xs"
	ct_yydebug = 1;
#line 289 "backcalls.xs"
#line 289 "backcalls.xs"
#line 289 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_ResetParseDebugging)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::ResetParseDebugging()");
    {
#line 294 "backcalls.xs"
#line 294 "backcalls.xs"
#line 295 "backcalls.xs"
	ct_yydebug = 0;
#line 295 "backcalls.xs"
#line 295 "backcalls.xs"
#line 295 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPushStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPushStackState()");
    {
#line 299 "backcalls.xs"
#line 299 "backcalls.xs"
#line 300 "backcalls.xs"
	if (!fShouldParse) return;
	PushStackState();
#line 301 "backcalls.xs"
#line 301 "backcalls.xs"
#line 301 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPopAndRestoreStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPopAndRestoreStackState()");
    {
#line 305 "backcalls.xs"
#line 305 "backcalls.xs"
#line 306 "backcalls.xs"
	if (!fShouldParse) return;
	PopAndRestoreStackState();
#line 307 "backcalls.xs"
#line 307 "backcalls.xs"
#line 307 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPopAndDiscardStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPopAndDiscardStackState()");
    {
#line 311 "backcalls.xs"
#line 311 "backcalls.xs"
#line 312 "backcalls.xs"
	if (!fShouldParse) return;
	PopAndDiscardStackState();
#line 313 "backcalls.xs"
#line 313 "backcalls.xs"
#line 313 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYSwapStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYSwapStackState()");
    {
#line 317 "backcalls.xs"
#line 317 "backcalls.xs"
#line 318 "backcalls.xs"
	if (!fShouldParse) return;
	SwapStackState();
#line 319 "backcalls.xs"
#line 319 "backcalls.xs"
#line 319 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYPushDupTopStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYPushDupTopStackState()");
    {
#line 323 "backcalls.xs"
#line 323 "backcalls.xs"
#line 324 "backcalls.xs"
	if (!fShouldParse) return;
	PushDupTopStackState();
#line 325 "backcalls.xs"
#line 325 "backcalls.xs"
#line 325 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_YYFCompareTopStackState)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::YYFCompareTopStackState()");
    {
#line 329 "backcalls.xs"
	bool	RETVAL;
#line 329 "backcalls.xs"
#line 330 "backcalls.xs"
	if (!fShouldParse) return;
	RETVAL = FCompareTopStackState();
#line 333 "backcalls.xs"
	ST(0) = boolSV(RETVAL);
	if (SvREFCNT(ST(0))) sv_2mortal(ST(0));
#line 333 "backcalls.xs"
#line 333 "backcalls.xs"
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
        newXS("cpp::fname_obsoleted", XS_cpp_fname_obsoleted, file);
        newXS("cpp::FnameNominal", XS_cpp_FnameNominal, file);
        newXS("cpp::ExpansionLookup", XS_cpp_ExpansionLookup, file);
        newXS("cpp::CbytesOutput", XS_cpp_CbytesOutput, file);
        newXS("cpp::CbytesOutputAndBuffer_obsolete", XS_cpp_CbytesOutputAndBuffer_obsolete, file);
        newXS("cpp::CbytesCppRead", XS_cpp_CbytesCppRead, file);
        newXS("cpp::FExpandingMacros", XS_cpp_FExpandingMacros, file);
        newXS("cpp::ParseStateStack", XS_cpp_ParseStateStack, file);
        newXS("cpp::SetParseStateStack", XS_cpp_SetParseStateStack, file);
        newXS("cpp::PushBuffer", XS_cpp_PushBuffer, file);
        newXS("cpp::SetParseDebugging", XS_cpp_SetParseDebugging, file);
        newXS("cpp::ResetParseDebugging", XS_cpp_ResetParseDebugging, file);
        newXS("cpp::YYPushStackState", XS_cpp_YYPushStackState, file);
        newXS("cpp::YYPopAndRestoreStackState", XS_cpp_YYPopAndRestoreStackState, file);
        newXS("cpp::YYPopAndDiscardStackState", XS_cpp_YYPopAndDiscardStackState, file);
        newXS("cpp::YYSwapStackState", XS_cpp_YYSwapStackState, file);
        newXS("cpp::YYPushDupTopStackState", XS_cpp_YYPushDupTopStackState, file);
        newXS("cpp::YYFCompareTopStackState", XS_cpp_YYFCompareTopStackState, file);
    ST(0) = &sv_yes;
    XSRETURN(1);
}
