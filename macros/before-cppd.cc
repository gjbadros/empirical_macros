# 1 "before.cc"
# 1 "/usr/include/stdio.h" 1 3
...
# 1 "/usr/include/features.h" 1 3
...
# 1 "/usr/include/sys/cdefs.h" 1 3
........
# 34 "/usr/include/stdio.h" 2 3
...
# 1 "before.cc" 2
# 1 "/usr/include/string.h" 1 3
...
# 2 "before.cc" 2
...
int main(int argc, char *argv[]) {
    char szLine[128 ];

    while ((0==0) ) 
	{ 



	fgets(szLine,128 ,((_IO_FILE*)(&_IO_stdin_))  );

	int cchLine = strlen(szLine)-1;
	if ((strncasecmp(( szLine ),( "exit"  ),( cchLine ))==0) )
	    exit(0);
	else if ((strncasecmp(( szLine ),( "+" ),( cchLine ))==0) )
	    fprintf(((_IO_FILE*)(&_IO_stderr_))  ,"Add\n");
	else if ((strncasecmp(( szLine ),( "-" ),( cchLine ))==0) )
	    fprintf(((_IO_FILE*)(&_IO_stderr_))  ,"Sub\n");
	else if ((strncasecmp(( szLine ),( "*" ),( cchLine ))==0) )
	    fprintf(((_IO_FILE*)(&_IO_stderr_))  ,"Mult\n");
	else fprintf(((_IO_FILE*)(&_IO_stderr_))  , "Unknown cmd.\n");
	}   
}  
