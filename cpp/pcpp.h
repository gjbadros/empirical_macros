/* $Id$
 * By Greg J. Badros -- Aug. 28th, 1997
 */

#ifndef _CPPMAIN_H_
#define _CPPMAIN_H_

#include "cpplib.h"
#include "cpphook.h"

extern cpp_reader parse_in;
extern cpp_options options;

char * SzFromToken(enum cpp_token kind);

extern int ct_yydebug;

#endif _CPPMAIN_H_
