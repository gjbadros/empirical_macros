extern int yydebug;

int main(int argc, char *argv[])
{
  yydebug = 0;
  yyparse();
}
