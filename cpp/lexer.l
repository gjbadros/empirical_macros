
%{
/*************************************************
 *    lexer.l
 *
 *    Revision 0.0.0.0  1996/04/01  06:20:40  kurt
 *    o	Wrong macro used in rule for character constants
 *    o	Minor spelling typos corrected
 *    -- Kurt Cockrum <kurt@grogatch.seaslug.org>
 *
 *    Programmer: Shaun Flisakowski
 *
 *************************************************/

int ct_yywrap();

#define  YY_BUFFER_STATE_DEFD

#include <stdio.h>
#include <stdlib.h>

#include "globals.h"
#include "gram.h"
#include "lexer.h"
#include "token.h"
#include "nmetab.h"
#include "symtab.h"
#include "heap.h"

FILE *yyin;
char line_buf[MAX_TOKN_LEN];

int  err_cnt = 0;
int  err_tok = 0;

int  in_preprocess = 0;
int  in_charconst = 0;

static int cpp_comment_warn = 1;
int  gcc2_paren_cnt = 0;

char  tokn_buff[MAX_TOKN_LEN];
char *tokn_end = &tokn_buff[MAX_TOKN_LEN-1];
char *tokn_ptr;

#undef YY_INPUT

#include "cpplib.h"
#include "pcpp.h"
#include "cpphook.h"

void count();

int cpp_got_eof = 0;

int /* result */
cpp_yy_input(char *buf,int max_size)
{
    int result;
    do {
	enum cpp_token kind = cpp_get_token (&parse_in);
	cBytesCppRead += CPP_WRITTEN(&parse_in);
	gjb_call_hooks_szl(CPP_OPTIONS(&parse_in),HI_CPP_OUT,
			   parse_in.token_buffer,CPP_WRITTEN(&parse_in));
	gjb_call_hooks_sz_szl(CPP_OPTIONS(&parse_in),HI_TOKEN,SzFromToken(kind),
			      parse_in.token_buffer,
			      CPP_WRITTEN(&parse_in));
	if (kind == CPP_EOF || cpp_got_eof == 1) {
	    fprintf(stderr,"Got kind == CPP_EOF\n");
	    result = YY_NULL;
	    buf[0] = 0;
	    cpp_got_eof = 1;
	    /* Return here, since we really want to return the YY_NULL == 0 */
	    return result;
	} else {
	    result = CPP_WRITTEN(&parse_in);
	    /* NOTE: result could be zero */
	    if (result > max_size-1) {
		fprintf(stderr,"OVERFLOWED max_size in YY_INPUT macro!\n");
		result = max_size-1;
	    }
	    strncpy(buf,parse_in.token_buffer,result);
	    parse_in.limit = parse_in.token_buffer;
	}
    } while (result == 0);
    buf[result] = 0;
#ifdef GJB_DEBUG_CPP_YY_INPUT
    fprintf(stderr,"Returning %d chars: %s\n",result,buf);
#endif
    return result;
}

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
         do { result = cpp_yy_input(buf,max_size); } while (0)

#define YY_USER_ACTION \
    { \
        Parse_TOS->yycolno = Parse_TOS->yynxtcol; \
        Parse_TOS->yynxtcol += yyleng; \
    }

#undef SETPOS_NDE
#define SETPOS_NDE(TYPE) \
	do { \
          lvalp->node = make_node(TN_EMPTY); \
          lvalp->node->line = Parse_TOS->yylineno; \
          lvalp->node->col  = Parse_TOS->yycolno; \
          err_tok = lvalp->node->tok = (TYPE); \
	} while(0)

#undef SETPOS_LEAF
#define SETPOS_LEAF(TOK_TYPE,PRSE_TYPE) \
	do { \
          lvalp->leaf = make_leaf((PRSE_TYPE)); \
          lvalp->leaf->line = Parse_TOS->yylineno; \
          lvalp->leaf->col  = Parse_TOS->yycolno; \
          err_tok = lvalp->leaf->tok  = (TOK_TYPE); \
	} while(0)

#undef SETPOS_IF
#define SETPOS_IF(TYPE) \
	do { \
          lvalp->ifn = make_if(TN_IF); \
          lvalp->ifn->line = Parse_TOS->yylineno; \
          lvalp->ifn->col  = Parse_TOS->yycolno; \
          err_tok = lvalp->ifn->tok  = (TYPE); \
	} while(0)

#undef SETPOS_FOR
#define SETPOS_FOR(TYPE) \
	do { \
          lvalp->forn = make_for(TN_FOR); \
          lvalp->forn->line = Parse_TOS->yylineno; \
          lvalp->forn->col  = Parse_TOS->yycolno; \
          err_tok = lvalp->forn->tok  = (TYPE); \
	} while(0)

#undef  LAST_STATE
#define LAST_STATE() \
        do { \
          if (in_preprocess) \
            BEGIN(PP); \
          else \
            BEGIN(INITIAL); \
        } while (0)  

#undef  BEGIN_PP
#define BEGIN_PP() \
        do { \
          BEGIN(PP); \
          in_preprocess = 1; \
        } while(0)

YYSTYPE my_var;

EXTERN int yylex (YYSTYPE *lvalp);

/*  To give some args to yylex */
#undef YY_DECL
#ifdef  __STDC__
/*  #define YY_DECL int yylex YY_PROTO((YYSTYPE *lvalp))  */
#define YY_DECL int yylex (YYSTYPE *lvalp)
#else
#define YY_DECL int yylex(lvalp) YYSTYPE *lvalp;
#endif

%}
%x Start PP CMMT CC STR GCC2
%a 9000
%o 9000

dot		"."
digit		[0-9]
octdigit	[0-7]
hexdigit	[0-9a-fA-F]
alpha		[a-zA-Z_]
alphanum	{alpha}|{digit}
litquote	\\\"

number		{digit}+
numsuffix       [uU]?[lL]?
intnum		{digit}+{numsuffix}
octnum		0{octdigit}+{numsuffix}
hexnum		0[xX]{hexdigit}+{numsuffix}

frac		{dot}{number}
mantissa	{number}|{number}{dot}|{number}{frac}|{frac}
exponent	[Ee][\+\-]?{number}
realsuffix      [fFlL]
real		{mantissa}{exponent}?{realsuffix}?

whitespace      [ \t\f\v]
allwhite        [ \t\f\b\v\r\n]

pp_strt         ^{whitespace}*"#"{whitespace}*
pp_line         ^{whitespace}*"#"{whitespace}*[0-9]

%%

<INITIAL>"/*"       { BEGIN(CMMT); }
<INITIAL>"'"        { BEGIN(CC);    SETPOS_LEAF(CHAR_CONST,TN_INT); }
<INITIAL>\"         { BEGIN(STR);   tokn_ptr = tokn_buff;
                         SETPOS_LEAF(STRING,TN_STRING);
                    }

<INITIAL>"//*"      { /* Ambiguous C++ style comment, must parse as
                            '/' '/*' to be Ansi compliant */
                         ct_yywarn(
                            "Ambiguous C++ comment, use '/ /*' -or- '// *'");
                         yyless(1);
                         SETPOS_NDE(DIV);
                         return(DIV);
                    }

<INITIAL>"//"[^*].*$ { /* C++ style comment */
                         if (cpp_comment_warn){
                             cpp_comment_warn = 0;
                             ct_yywarn("C++ style comment encountered");
                         }
                     }


<INITIAL>"auto"     { SETPOS_LEAF(AUTO,TN_TYPE); return(AUTO); }
<INITIAL>"break"    { SETPOS_NDE(BREAK); return(BREAK); }
<INITIAL>"case"     { SETPOS_NDE(CASE); return(CASE); }
<INITIAL>"char"     { SETPOS_LEAF(CHAR,TN_TYPE); return(CHAR); }
<INITIAL>"const"    { SETPOS_LEAF(CONST,TN_TYPE); return(CONST); }
<INITIAL>"continue" { SETPOS_NDE(CONT); return(CONT); }
<INITIAL>"default"  { SETPOS_LEAF(DEFLT,TN_LABEL); return(DEFLT); }
<INITIAL>"do"       { SETPOS_NDE(DO); return(DO); }
<INITIAL>"double"   { SETPOS_LEAF(DOUBLE,TN_TYPE); return(DOUBLE); }
<INITIAL>"else"     { SETPOS_NDE(ELSE); return(ELSE); }
<INITIAL>"enum"     { SETPOS_NDE(ENUM); return(ENUM); }
<INITIAL>"extern"   { SETPOS_LEAF(EXTRN,TN_TYPE); return(EXTRN); }
<INITIAL>"float"    { SETPOS_LEAF(FLOAT,TN_TYPE); return(FLOAT); }
<INITIAL>"for"      { SETPOS_FOR(FOR); return(FOR); }
<INITIAL>"goto"     { SETPOS_NDE(GOTO); return(GOTO); }
<INITIAL>"if"       { SETPOS_IF(IF); return(IF); }
<INITIAL>"int"      { SETPOS_LEAF(INT,TN_TYPE); return(INT); }
<INITIAL>"long"     { SETPOS_LEAF(LONG,TN_TYPE); return(LONG); }
<INITIAL>"register" { SETPOS_LEAF(REGISTR,TN_TYPE); return(REGISTR); }
<INITIAL>"return"   { SETPOS_NDE(CRETURN); return(CRETURN); }
<INITIAL>"short"    { SETPOS_LEAF(SHORT,TN_TYPE); return(SHORT); }
<INITIAL>"signed"   { SETPOS_LEAF(SGNED,TN_TYPE); return(SGNED); }
<INITIAL>"sizeof"   { SETPOS_NDE(SIZEOF); return(SIZEOF); }
<INITIAL>"static"   { SETPOS_LEAF(STATIC,TN_TYPE); return(STATIC); }
<INITIAL>"struct"   { SETPOS_NDE(STRUCT); return(STRUCT); }
<INITIAL>"switch"   { SETPOS_NDE(SWITCH); return(SWITCH); }
<INITIAL>"typedef"  { SETPOS_LEAF(TYPEDEF,TN_TYPE); return(TYPEDEF); }
<INITIAL>"union"    { SETPOS_NDE(UNION); return(UNION); }
<INITIAL>"unsigned" { SETPOS_LEAF(UNSGNED,TN_TYPE); return(UNSGNED); }
<INITIAL>"void"     { SETPOS_LEAF(VOID,TN_TYPE); return(VOID); }
<INITIAL>"volatile" { SETPOS_LEAF(VOLATILE,TN_TYPE); return(VOLATILE); }
<INITIAL>"while"    { SETPOS_NDE(WHILE); return(WHILE); }

   /* GCC2 Extensions */
<INITIAL>"__attribute"    { /* A gcc2 extension - get rid of it. */
                            BEGIN(GCC2);
                          }
<INITIAL>"__attribute__"  { BEGIN(GCC2); }

<GCC2>"("[^()]*           { gcc2_paren_cnt++; }
<GCC2>[^()]*              { /* Throw away */ }
<GCC2>")"                 { if (--gcc2_paren_cnt == 0)
                              BEGIN(INITIAL);
                          }

<INITIAL>"__const"    { SETPOS_LEAF(CONST,TN_TYPE); return(CONST); }
<INITIAL>"__const__"  { SETPOS_LEAF(CONST,TN_TYPE); return(CONST); }
<INITIAL>"__signed" { SETPOS_LEAF(SGNED,TN_TYPE); return(SGNED); }
<INITIAL>"__signed__" { SETPOS_LEAF(SGNED,TN_TYPE); return(SGNED); }
<INITIAL>"__volatile" { SETPOS_LEAF(VOLATILE,TN_TYPE); return(VOLATILE); }
<INITIAL>"__volatile__" { SETPOS_LEAF(VOLATILE,TN_TYPE); return(VOLATILE); }

<INITIAL>"typeof"      { }
<INITIAL>"__typeof"    { }
<INITIAL>"__typeof__"  { }

<INITIAL>"inline"      { }
<INITIAL>"__inline"    { }
<INITIAL>"__inline__"  { }

<INITIAL>"__extension__"  { }

<INITIAL>"alignof"      { }
<INITIAL>"__alignof"    { }
<INITIAL>"__alignof__"  { }

<INITIAL>"__asm"      { }
<INITIAL>"__asm__"    { }
<INITIAL>"__imag"     { }
<INITIAL>"__imag__"   { }
<INITIAL>"__real"     { }
<INITIAL>"__real__"   { }
<INITIAL>"__complex"    { }
<INITIAL>"__complex__"  { }
<INITIAL>"__iterator"   { }
<INITIAL>"__iterator__" { }
<INITIAL>"__label__"    { }

<INITIAL>"+"        { SETPOS_NDE(PLUS); return(PLUS); }
<INITIAL>"-"        { SETPOS_NDE(MINUS); return(MINUS); }
<INITIAL>"*"        { SETPOS_NDE(STAR); return(STAR); }
<INITIAL>"/"        { SETPOS_NDE(DIV); return(DIV); }
<INITIAL>"%"        { SETPOS_NDE(MOD); return(MOD); }

<INITIAL>"+="       { SETPOS_NDE(PLUS_EQ); return(ASSIGN); }
<INITIAL>"-="       { SETPOS_NDE(MINUS_EQ); return(ASSIGN); }
<INITIAL>"*="       { SETPOS_NDE(STAR_EQ); return(ASSIGN); }
<INITIAL>"/="       { SETPOS_NDE(DIV_EQ); return(ASSIGN); }
<INITIAL>"%="       { SETPOS_NDE(MOD_EQ); return(ASSIGN); }

<INITIAL>"!"        { SETPOS_NDE(NOT); return(NOT); }
<INITIAL>"&&"       { SETPOS_NDE(AND); return(AND); }
<INITIAL>"||"       { SETPOS_NDE(OR); return(OR); }
<INITIAL>"^^"       { SETPOS_NDE(XOR); return(XOR); }

<INITIAL>"~"        { SETPOS_NDE(B_NOT); return(B_NOT); }
<INITIAL>"&"        { SETPOS_NDE(B_AND); return(B_AND); }
<INITIAL>"|"        { SETPOS_NDE(B_OR); return(B_OR); }
<INITIAL>"^"        { SETPOS_NDE(B_XOR); return(B_XOR); }

<INITIAL>"~="       { SETPOS_NDE(B_NOT_EQ); return(ASSIGN); }
<INITIAL>"&="       { SETPOS_NDE(B_AND_EQ); return(ASSIGN); }
<INITIAL>"|="       { SETPOS_NDE(B_OR_EQ); return(ASSIGN); }
<INITIAL>"^="       { SETPOS_NDE(B_XOR_EQ); return(ASSIGN); }

<INITIAL>"<<"       { SETPOS_NDE(L_SHIFT); return(L_SHIFT); }
<INITIAL>">>"       { SETPOS_NDE(R_SHIFT); return(R_SHIFT); }
<INITIAL>"<<="      { SETPOS_NDE(L_SHIFT_EQ); return(ASSIGN); }
<INITIAL>">>="      { SETPOS_NDE(R_SHIFT_EQ); return(ASSIGN); }

<INITIAL>"=="       { SETPOS_NDE(EQUAL); return(COMP_EQ); }
<INITIAL>"<"        { SETPOS_NDE(LESS); return(COMP_ARITH); }
<PP>"<"             { SETPOS_NDE(LESS); return(LESS); }
<INITIAL>"<="       { SETPOS_NDE(LESS_EQ); return(COMP_ARITH); }
<INITIAL>">"        { SETPOS_NDE(GRTR); return(COMP_ARITH); }
<PP>">"             { SETPOS_NDE(GRTR); return(GRTR); }
<INITIAL>">="       { SETPOS_NDE(GRTR_EQ); return(COMP_ARITH); }
<INITIAL>"!="       { SETPOS_NDE(NOT_EQ); return(COMP_EQ); }

<INITIAL>"="        { SETPOS_NDE(EQ); return(EQ); }
<INITIAL>"++"       { SETPOS_NDE(INCR); return(INCR); }
<INITIAL>"--"       { SETPOS_NDE(DECR); return(DECR); }

<INITIAL>"("        { SETPOS_NDE(LPAREN); return(LPAREN); }
<INITIAL>")"        { SETPOS_NDE(RPAREN); return(RPAREN); }
<INITIAL>"["        { SETPOS_NDE(LBRCKT); return(LBRCKT); }
<INITIAL>"]"        { SETPOS_NDE(RBRCKT); return(RBRCKT); }
<INITIAL>"{"        { SETPOS_NDE(LBRACE); return(LBRACE); }
<INITIAL>"}"        { SETPOS_NDE(RBRACE); return(RBRACE); }

<INITIAL>"."        { SETPOS_NDE(DOT); return(DOT); }
<INITIAL>"->"       { SETPOS_NDE(ARROW); return(ARROW); }

<INITIAL>"?"        { SETPOS_NDE(QUESTMARK); return(QUESTMARK); }
<INITIAL>":"        { SETPOS_NDE(COLON); return(COLON); }
<INITIAL>";"        { SETPOS_NDE(SEMICOLON); return(SEMICOLON); }
<INITIAL>","        { SETPOS_NDE(COMMA); return(COMMA); }
<INITIAL>"..."      { SETPOS_NDE(ELIPSIS); return(ELIPSIS); }

	/* Unused (invalid) characters */
<INITIAL>"`"        { SETPOS_NDE(BACKQUOTE); return(BACKQUOTE); }
<INITIAL>"@"        { SETPOS_NDE(AT); return(AT); }
<INITIAL>"$"        { SETPOS_NDE(DOLLAR); return(DOLLAR); }

  /*
  <INITIAL>"#"        { SETPOS_NDE(LB_SIGN); return(LB_SIGN); }
  <INITIAL>"##"       { SETPOS_NDE(DOUB_LB_SIGN); return(DOUB_LB_SIGN); }
  */
	/* Preprocessor Stuff */
<INITIAL>{pp_strt}\n       { Parse_TOS->yylineno++; Parse_TOS->yynxtcol = 0; }
<INITIAL>{pp_line}         { BEGIN_PP(); get_lineno(); }
<INITIAL>{pp_strt}"line"   { BEGIN_PP(); get_lineno(); }
<INITIAL>{pp_strt}"pragma" { BEGIN_PP(); }
<INITIAL>{pp_strt}"ident"  { BEGIN_PP(); }

<PP>\\(\n)             {  /* Preprocessor continuation line */
                         Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                       }

<PP>\n                 {  /* End of this preprocessor logical line */
                         lvalp->node = (treenode *) NULL;
                         in_preprocess = 0;
                         yyless(0);    /* Hack! */
                         BEGIN(INITIAL);
                       }

<PP>[^\n\\]+           { /* Swallow cpp junk to prevent it being echo'd */
                       }

<INITIAL>[a-zA-Z_][a-zA-Z0-9_]*  {    /* Identifier */
                         SETPOS_LEAF(IDENT,TN_IDENT);
                         lvalp->leaf->data.sval = nmelook(yytext,yyleng+1);

                         {
                         symentry_t *se
                            = symtab_lookup(ParseStack->contxt->syms,
                                            lvalp->leaf->data.sval);
                         if (se && is_typedef(se))
                           {
                           lvalp->leaf->type = TN_TYPE;
                           lvalp->leaf->tok = TYPEDEF_NAME;
                           return(TYPEDEF_NAME);
                           }
                         }
                         return(IDENT);
                       }

<INITIAL>{octnum}  |
<INITIAL>{intnum}  |
<INITIAL>{hexnum}   {  /* An integer */
                         SETPOS_LEAF(INUM,TN_INT);
                         lvalp->leaf->data.ival 
                                = strtol(yytext,(char **) NULL,0);
                         return(INUM);
                    }
          
<INITIAL>[0-9]*"."?[0-9]*[eE][+-]?[0-9]+? |
<INITIAL>[0-9]*"."[0-9]+([eE][+-]?[0-9]+)? {
                         SETPOS_LEAF(RNUM,TN_REAL);
                         lvalp->leaf->data.dval = atof(yytext);
                         return(RNUM);
                       }

<STR>\"{allwhite}*\"   {   /* String Pasting */
                           /* This is a fast fix, it messes
                              up the line number count. */
                       }

<STR>\"                {   /* Closing quote */
                         LAST_STATE();
                         *tokn_ptr = '\0';
                         if ((lvalp->leaf->data.str
                                 = malloc(strlen(tokn_buff)+1)) == NULL){
                            fputs("Error: Out of memory in Lexer.\n",stderr);
                            return(INVALID);
                         } else {
                            strcpy(lvalp->leaf->data.str,tokn_buff);
                            return(STRING);
                         }
                       }

<STR>\n                { /* Error - unterminated string constant */
                         ct_yyerr("Unterminated string constant starting");
                         LAST_STATE();
                         return(INVALID);
                       }

<STR>\\[0-7]{1,3}      {   /* octal escape sequence */
                         int result;

                         (void) sscanf(yytext+1, "%o", &result );

                             /* error, constant is out-of-bounds */
                         if ( result > 0xff ){
                            ct_yyerr("Escape sequence out-of-bounds");
                         }

                         if (tokn_ptr < tokn_end)
                            *tokn_ptr++ = result;
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\x{hexdigit}+    {   /* hex escape sequence - ISO C */
                         int result;

                         (void) sscanf(yytext+2, "%x", &result );

                             /* error, constant is out-of-bounds */
                         if ( result > 0xff ){
                            ct_yyerr("Escape sequence out-of-bounds");
                         } else if (yyleng > 4){
                            ct_yywarn("Hexadecimal escape exceeds two chars");
                         }

                         if (tokn_ptr < tokn_end)
                            *tokn_ptr++ = result;
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\{number}        {  /* Bad escape sequence */
                         ct_yywarn("Bad escape sequence in string");
                        *tokn_ptr++ = '?';
                       }

<STR>\\n               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\n';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\t               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\t';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\r               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\r';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\b               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\b';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\f               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\f';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\v               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\v';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\a               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = '\a';
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>\\(\n)            {  /* String continuation */
                         Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                       }

<STR>\\.               {
                         if (tokn_ptr < tokn_end)
                           *tokn_ptr++ = yytext[1];
                         else
                            ct_yywarn("String constant too long");
                       }

<STR>[^\\\n\"]+        {
                         int n = yyleng;

                         if (tokn_ptr + n < tokn_end) {
                             memcpy(tokn_ptr,yytext,n);
                             tokn_ptr += n;
                         } else 
                            ct_yywarn("String constant too long");
                       }

<CMMT>[^*\n/\\]*       ;   /* Inside C-style comment */
<CMMT>[^*\n/\\]*\n     { Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                         in_preprocess = 0;
                       }
<CMMT>"/"[^*\n]        ;
<CMMT>\\\n             { Parse_TOS->yylineno++; Parse_TOS->yynxtcol = 0; }
<CMMT>\\[^\n]          { yyless(1); }
<CMMT>"/"\n            { Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                         in_preprocess = 0;
                       }
<CMMT>"/*"             { ct_yywarn("/* inside comment"); }
<CMMT>"*"+[^*/\n\\]*     ;       /* Stars */
<CMMT>"*"+[^*/\n\\]*\n   { Parse_TOS->yylineno++;
                           Parse_TOS->yynxtcol = 0;
                           in_preprocess = 0;
                         }
<CMMT>"*"+"/"          {
                        LAST_STATE();
                       }



<CC>\\[0-7]{1,3}"'"    {   /* octal escape sequence */
                         int result;
                         (void) sscanf(yytext+1, "%o", &result );

                             /* error, constant is out-of-bounds */
                         if ( result > 0xff ){
                             ct_yywarn("Escape sequence out-of-bounds");
                             result = 0;
                         }

                         lvalp->leaf->data.cval = result;
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\x{hexdigit}+"'"  {   /* hex escape sequence - ISO C */
                         int result;
                         (void) sscanf(yytext+1, "%x", &result );

                             /* error, constant is out-of-bounds */
                         if ( result > 0xff ){
                             ct_yywarn("Escape sequence out-of-bounds");
                             result = 0;
                         } else if (yyleng > 5){
                             ct_yywarn("Hexadecimal escape exceeds two chars");
                             result = 0;
                         }

                         lvalp->leaf->data.cval = (char) result;
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\{number}"'"      {  /* Bad escape sequence */
                         ct_yywarn("Bad escape sequence in char constant");
                         lvalp->leaf->data.cval = '\0';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\n                 { /* Error unterminated char constant */
                         Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                         ct_yywarn("Unterminated char constant");
                         lvalp->leaf->data.cval = '\0';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\n"'"             {
                         lvalp->leaf->data.cval = '\n';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\t"'"             {
                         lvalp->leaf->data.cval = '\t';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\r"'"             {
                         lvalp->leaf->data.cval = '\r';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\b"'"             {
                         lvalp->leaf->data.cval = '\b';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\f"'"             {
                         lvalp->leaf->data.cval = '\f';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\v"'"             {
                         lvalp->leaf->data.cval = '\v';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\a"'"             {
                         lvalp->leaf->data.cval = '\a';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\\n"'"            {
                         Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 1;  /* Oddity */
                         lvalp->leaf->data.cval = '\n';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>\\."'"             {
                         lvalp->leaf->data.cval = yytext[1];
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>[^']"'"            {
                         lvalp->leaf->data.cval = *yytext;
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>"'"                { /* Empty */
                         ct_yywarn("Empty character constant");
                         lvalp->leaf->data.cval = '\0';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<CC>[^\\\n][^']+"'"    { /* Multiple characters */
                         ct_yywarn("Invalid character constant");
                         lvalp->leaf->data.cval = '\0';
                         LAST_STATE();
                         return(CHAR_CONST);
                       }

<INITIAL>{whitespace}+ ;   /* space/tab/formfeed/vertical tab (ignore) */

<INITIAL,CMMT>\n|\r    { Parse_TOS->yylineno++;
                         Parse_TOS->yynxtcol = 0;
                         in_preprocess = 0;
                       }

<CMMT><<EOF>>          { 
                         ct_yyerr("EOF reached inside comment");
                         in_preprocess = 0;
                         return(0);
                       }

<CC><<EOF>>            { 
                         ct_yyerr("EOF reached inside character constant");
                         return(0);
                       }

<STR><<EOF>>           { 
                         ct_yyerr("EOF reached inside string constant");
                         return(0);
                       }

.                      { /* Any unknown char is an error */
                        fprintf(stderr,
                            "Error: Line %d: Illegal Character",
                            Parse_TOS->yylineno);
                        if ((yytext[0] >= ' ') && (yytext[0] <= '~'))
                            fprintf(stderr,": '%c'\n", yytext[0]);
                        else
                            fprintf(stderr,
                                ", ASCII: %03o (octal)\n", yytext[0]);
                       }

%%

/************************************************************************
//
// ct_yywrap() - This function is called by the lexer [yylex() or sslex()] when
//               the end-of-file (or end-of-string for sslex()) is reached.
//               It gets the next file/string ready (if any) and returns 1
//               which indicates to the lexer that there are no more files
//               remaining.  The lexer returns 0 to the parser, indicating
//               no more tokens are remaining. The parser function, yyparse(),
//               then returns 0, indicating that the parse is done.  This
//               behaviour allows a single item to be parsed to be placed
//               on the stack and parsed without the entire stack being consumed.
//
// **********************************************************************/

int ct_yywrap()
{
    in_preprocess = 0;

    /* Prepare the next file if there is one but return 1 */
    /* so that yyparse returns anyway. */

    /*  get_next_file(ParseStack);  */
    return(1);
}

/***********************************************************************/
/*  Process a #line directive */
void get_lineno()
{
    char *pnt;
    int   ln = 0;

    pnt = strchr(line_buf,'#');

    do {

        if (pnt) {

            pnt++;
            if (sscanf(pnt,"%d", &ln) < 1)
                break;

            Parse_TOS->yylineno = ln - 1;
           
            pnt = strchr(pnt,'"');

            if (pnt) {
                char *pnt_end;

                pnt++;

                pnt_end = strchr(pnt,'"');
                if (pnt_end)
                    *pnt_end = '\0';
                else
                    break;

                free(Parse_TOS->filename);
                Parse_TOS->filename = malloc(strlen(pnt)+1);
                assert(Parse_TOS->filename);
                strcpy(Parse_TOS->filename,pnt); 
            }

            return;
        }

    } while(0);

    ct_yywarn("Malformed #line directive");
}

/***********************************************************************/

void print_caret(char *s, int pos)
{
    char *str;
    int i = 0;

    for (str=s; *str && (i<pos); i++, str++)
        if (*str=='\t')
            fputs("\t",stderr);
        else
            fputs(" ",stderr);

    fputs("^\n",stderr);
}
 
/***********************************************************************/

void ct_yywarn(char *s)
{
    fprintf(stderr,"%s:%d: Warning - %s:\n%s",
         Parse_TOS->filename, Parse_TOS->yylineno, s, line_buf); 
    print_caret(line_buf,Parse_TOS->yycolno);
}

/***********************************************************************/

int ct_yyerr(char *s)
{
    fprintf(stderr,"%s:%d: %s:\n%s",
         Parse_TOS->filename, Parse_TOS->yylineno, s, line_buf); 
    print_caret(line_buf,Parse_TOS->yycolno);

    if (++err_cnt >= 10){
        fprintf(stderr,"Too many errors (%d detected) - quitting.\n",
                err_cnt );
        fclose(yyin);
        return(1);
    }
    return(0); 
}

/***********************************************************************/

int ct_yyerror(char *s)
{
        /* Insure temination */
    line_buf[MAX_TOKN_LEN-1] = '\0';
    fprintf(stderr,"%s:%d: Parse error before '%s'\n%s",
         Parse_TOS->filename, Parse_TOS->yylineno, toksym(err_tok,0),
         line_buf); 
    print_caret(line_buf,Parse_TOS->yycolno);

    if (++err_cnt >= 10){
        fprintf(stderr,"Too many errors (%d detected) - quitting.\n",
                err_cnt );
        fclose(yyin);
        return(1);
    }
    return(0);
}

/***********************************************************************/
