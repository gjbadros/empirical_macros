#define FOO BAR
#define BAR hello
/* both of the below lines expand to hello */

// another comment
FOO
BAR

#define MANY(x,y) output x and y
#define BAZ MANY (a,b)
BAZ(z,y)
#define BAZ2 MANY
BAZ2(z,y)

