#include <stdio.h>
#include <string.h>

#define TRUE (0==0)
#define FALSE (0==1)

#define LINE_SIZE 128

#define CMD_PLUS 0
#define CMD_MULT 1
#define CMD_SUB  2
#define CMD_EXIT 3
#define CMD_EXIT_STRING "exit"

#define BEGIN {
#define END }

#define strn_matches(x,y,n) (strncasecmp((x),(y),(n))==0)

int main(int argc, char *argv[]) {
    char szLine[LINE_SIZE];

    while (TRUE) 
	BEGIN
#ifdef HAVE_READLINE
	readline(szLine,LINE_SIZE);
#else
	fgets(szLine,LINE_SIZE,stdin);
#endif
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
	END /* while */
} /* main */
