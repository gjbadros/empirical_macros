#define foo a
#define bar(x) x

/* expansions after comments in a macro argument are mis-marked
   because the expansion buffer has comments eliminated  --01/13/99 gjb */

bar(foo /* a comment, with a comma */ foo /* another comment */)

bar((foo /* a comment */, foo /*another comment */))

bar((foo /% a comment %/, foo /% another comment %/))
