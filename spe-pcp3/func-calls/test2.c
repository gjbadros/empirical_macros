int foo();
int bar();
int baz();
int bing();

#define FOO foo()
#define BONG(x) x

int foo() {
  bar();
}

int main(char **argv, int argc) {
  FOO;
  baz();
  BONG(bing());
}
