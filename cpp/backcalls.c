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
#include "cppmain.h"
#include "cpplib.h"
#include "cpphash.h"
#ifdef __cplusplus
}
#endif


XS(XS_cpp_hello)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::hello()");
    {
#line 34 "backcalls.xs"
#line 34 "backcalls.xs"
#line 35 "backcalls.xs"
	fprintf(stdout,"Hello world!\n");
#line 35 "backcalls.xs"
#line 35 "backcalls.xs"
#line 35 "backcalls.xs"
    }
    XSRETURN_EMPTY;
}

XS(XS_cpp_SzToken)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::SzToken(i)");
    {
	int	i = (int)SvIV(ST(0));
#line 40 "backcalls.xs"
	char *	RETVAL;
#line 40 "backcalls.xs"
#line 41 "backcalls.xs"
	RETVAL = SzFromToken((enum cpp_token) i);
#line 41 "backcalls.xs"
#line 41 "backcalls.xs"
#line 41 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_fname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::fname()");
    {
#line 45 "backcalls.xs"
	char *	RETVAL;
#line 45 "backcalls.xs"
#line 46 "backcalls.xs"
	RETVAL = parse_in.buffer->fname;
#line 48 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 48 "backcalls.xs"
#line 48 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_nominal_fname)
{
    dXSARGS;
    if (items != 0)
	croak("Usage: cpp::nominal_fname()");
    {
#line 52 "backcalls.xs"
	char *	RETVAL;
#line 52 "backcalls.xs"
#line 53 "backcalls.xs"
	RETVAL = parse_in.buffer->nominal_fname;
#line 55 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 55 "backcalls.xs"
#line 55 "backcalls.xs"
    }
    XSRETURN(1);
}

XS(XS_cpp_lookup)
{
    dXSARGS;
    if (items != 1)
	croak("Usage: cpp::lookup(sz)");
    {
	char *	sz = (char *)SvPV(ST(0),na);
#line 60 "backcalls.xs"
	char *	RETVAL;
#line 60 "backcalls.xs"
#line 61 "backcalls.xs"
	HASHNODE *hp = cpp_lookup(&parse_in,sz,-1,-1);
	RETVAL = hp->value.defn->expansion;
#line 64 "backcalls.xs"
	ST(0) = sv_newmortal();
	sv_setpv((SV*)ST(0), RETVAL);
#line 64 "backcalls.xs"
#line 64 "backcalls.xs"
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

        newXS("cpp::hello", XS_cpp_hello, file);
        newXS("cpp::SzToken", XS_cpp_SzToken, file);
        newXS("cpp::fname", XS_cpp_fname, file);
        newXS("cpp::nominal_fname", XS_cpp_nominal_fname, file);
        newXS("cpp::lookup", XS_cpp_lookup, file);
    ST(0) = &sv_yes;
    XSRETURN(1);
}