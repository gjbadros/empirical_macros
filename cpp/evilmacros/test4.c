#define ERROR_IF_EOF(i)       { if ((i) == EOF)  ioError(); }

int i;

int foo()
{
ERROR_IF_EOF(i);

}
