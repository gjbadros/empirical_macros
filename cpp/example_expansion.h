#define TA3(x,y) y + x
#define TA4(x,y) x + y
#define PA2(x) x + FOO
#define PA3(x) x + 4
#define FOO bar

TA4(TA3(PA2(a),PA3(b)),FOO)

/*
TA3's 2nd arg (first to be expanded) is not a macro

               ^^^^^^
expand_macro PA3 = @  + 4@ , source offset: 12 - 18, 2 [1]; 1 in example_expansion
 : nests = TA3#2[11]->TA4#1[111]
 : MEH = 

macro_cleanup PA3; [12 - 18] source 134, 3; output 30
 : nests = TA3#1[11]->TA4#0[111]
 : MEH = PA3#0[7]



        ^^^^^^
expand_macro PA2 = @  + FOO@ , source offset: 5 - 11, 2 [1]; 1 in example_expansion
 : nests = TA3#1[4]->TA4#1[111]
 : MEH = 


expand_macro FOO = @ bar@ , source offset: 5 - 11, 3 [1]; 1 in example_expansion
 : nests = TA3#1[4]->TA4#1[111]
 : MEH = PA2#0[9]

macro_cleanup FOO; [5 - 11] source 134, 4; output 30
 : nests = TA3#0[4]->TA4#0[111]
 : MEH = FOO#-1[5]<-PA2#0[9]

macro_cleanup PA2; [5 - 11] source 134, 3; output 0
 : nests = TA3#0[4]->TA4#0[111]
 : MEH = PA2#0[9]

   ^^^^^^^^^^^^^^^^^^^
expand_macro TA3 = @  + @ , source offset: 112 - 130, 1 [1]; 1 in example_expansion
 : nests = TA4#1[111]
 : MEH = 

macro_cleanup TA3; [112 - 130] source 134, 2; output 30
 : nests = TA4#0[111]
 : MEH = TA3#1[17]


expand_macro FOO = @ bar@ , source offset: 131 - 134, 1 [1]; 1 in example_expansion
 : expansion of FOO => bar (length 3:offset 31 - 34 [30 +  + 1])
 : nests = TA4#2[130]
 : MEH = 

macro_cleanup FOO; [131 - 134] source 134, 2; output 30
 : nests = TA4#1[130]
 : MEH = FOO#-1[5]


expand_macro TA4 = @  + @ , source offset: 108 - 135, 0 [0]; 1 in example_expansion
 : expansion of TA4 => y + 4 + x + bar + bar (length 21:offset 31 - 52 [30 +  + 1])
 : nests = 
 : MEH = 
  
macro_cleanup TA4; [108 - 135] source 134, 1; output 51
 : nests = 
 : MEH = TA4#2[23]

*/
