#line 4

static int FnFoo(int a) {
  return a+1;
}

int bar;

int main(int, char **) {
  int baz = FnFoo(5);
}
