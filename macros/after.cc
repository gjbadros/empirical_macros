#include <stdio.h>
#include <string.h>
#include "after-IFDEFS.h"

enum { LINE_SIZE = 128 };

enum { CMD_PLUS = 0, CMD_MULT, CMD_SUB, CMD_EXIT };

const char *CMD_EXIT_STRING = "exit";

inline bool strn_matches(const char *s1, const char *s2, int n) {
    return (strncasecmp(s1,s2,n) == 0); }

int main(int argc, char *argv[]) {
    char szLine[LINE_SIZE];

    while (true) 
	{
	HAVE_READLINE_OR_NOT((
	    readline(szLine,LINE_SIZE);
	    ),(
	    fgets(szLine,LINE_SIZE,stdin);
	    ))

	int cchLine = strlen(szLine)-1;
	if (strn_matches(szLine,CMD_EXIT_STRING,cchLine))
	    exit(0);
	else if (strn_matches(szLine,"+",cchLine))
	    fprintf(stderr,"Add\n");
	else if (strn_matches(szLine,"-",cchLine))
	    fprintf(stderr,"Sub\n");
	else if (strn_matches(szLine,"*",cchLine))
	    fprintf(stderr,"Mult\n");
	else fprintf(stderr, "Unknown cmd.\n");
	} /* while */
} /* main */
