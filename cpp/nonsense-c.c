#define START_PARAMS (
#define END_PARAMS )
#define START_CALL (
#define END_CALL )
#define BEGIN {
#define END }
#define ARRAY []
#define NL ;
#define POINTER *
#define COMMA ,
#define STRING(x) #x

#include <stdio.h>

int main START_PARAMS int argc COMMA char POINTER argv ARRAY END_PARAMS BEGIN
  printf START_CALL STRING(Hello world\n) END_CALL NL
  return 0 NL
END
