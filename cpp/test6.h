#define A zeroth
#define AB nextone
#define ABC thirdone
#define ABCD andafourth

#define A2 A
#define A3 A2
#define A4 A3

#define PA1(x) zeroth
#define PA2(x) x + FOO
#define PA3(x) x + 4

#define TA1(x,y) zeroth
#define TA2(x,y) x + 2
#define TA3(x,y) y + x
#define TA4(x,y) x + y
#define TA5(x,y) x ## y
#define TA6(x,y) x/**/y
#define TA7(x,y) #x, #y
#define FOO bar

#define N1 A
#define N2 A AB ABC ABCD

#define NPA1 PA1(z)

#define NPA3 PA3(z)

#define NPA4 PA3(A4)

TA4(TA3(PA2(a),PA3(b)),c)


TA4(ABCD,ABCD)

PA2(foo)

A

AB

ABC

ABCD

A4

PA2(ABCD)

NPA1

NPA3

