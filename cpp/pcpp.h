/* $Id$
 * By Greg J. Badros -- Aug. 28th, 1997
 */

#ifndef _CPPMAIN_H_
#define _CPPMAIN_H_

#include "cpplib.h"
#include "cpphook.h"

extern cpp_reader parse_in;
extern cpp_options options;
extern int cBytesOutput;
extern int cBytesCppRead;
extern int fShouldParse;

extern int ct_yydebug;

int  FIsSpeculative();
char * SzIsSpeculative();
 
extern char szHooksFile[];
extern int fShouldParse;

#endif _CPPMAIN_H_
