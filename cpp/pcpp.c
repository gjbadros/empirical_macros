/* CPP main program, using CPP Library.
   Copyright (C) 1995 Free Software Foundation, Inc.
   Written by Per Bothner, 1994-95.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

 In other words, you are welcome to use, share and improve this program.
 You are forbidden to forbid anyone else to use, share and improve
 what you give them.   Help stamp out software-hoarding!  */

#define bool int
#include <EXTERN.h>               /* from the Perl distribution     */
#include <perl.h>                 /* from the Perl distribution     */
#undef yywarn
#undef yydebug
#undef yyparse
#undef warn
#undef assert
#include "perly-undefs.h"

/* Avoid some warnings by undef-fing  perl's TRUE and FALSE macros, 
   since cpp redefs them */
#undef FALSE
#undef TRUE

#include <stdio.h>
#include "cpplib.h"
#include "cpphook.h"
#include "pcpp.h"

#ifdef CTGRAMMAR
#define DEFINE_GLOBALS
#include "globals.h"
#undef DEFINE_GLOBALS
#include "utype.h"
#include "lexer.h"
#include "token.h"
#include "gram.h"
#include "tree.h"

#include "prnttree.h"

char  *cur_file;
int    show_as_code = 1;
int    show_syms = 0;
int cBytesOutput = 0;
int cBytesCppRead = 0;

#define    CT_VERSION    "C-Tree Version 0.05"

#endif /* CTGRAMMAR */

#ifndef EMACS
#include "config.h"
#endif /* not EMACS */

extern char *getenv ();

char *progname;

cpp_reader parse_in;
/* FIXGJB: pcr not used for now, but perhaps it'd be better in 
   case I need to save all of cpp state by making a deep copy;
   if so, then most places that referred to &parse_in would instead
   use pcr, and I'd make a deep copy of the old pcr and point the new
   pcr to it, with a backpointer */
cpp_reader *pcr = &parse_in;
cpp_options options;

char *szHooksFile = "cpphook.pm";


/* More 'friendly' abort that prints the line and file.
   config.h can #define abort fancy_abort if you like that sort of thing.  */

void
fancy_abort ()
{
  fatal ("Internal gcc abort.",0);
}




static PerlInterpreter *my_perl;

// This fn is defined in backcalls.c, #included at bottom of this file
// That .c file is created using .xs and perl xsubpp
void  boot_backcalls (CV* cv);

// This is the function pssed as the 2nd arg to perl_parse, which
// calls the above function to make those C functions defined in
// cpp.xs visible; only exists because the prototype for boot_backcalls
// isn't quite right
void cpp_functions_init(void) {
  boot_backcalls(NULL);
}

int fShouldParse = 1;


/* These are used by ctree's lexer to avoid really getting
   upset about errors and to augment the error output */
int
FIsSpeculative()
{
  cpp_buffer *buffer = parse_in.buffer;
  return (buffer->fFromPerl);
}

char *
SzIsSpeculative()
{
  return FIsSpeculative()?"SPECULATIVE:":"";
}

int
main (int argc, char **argv, char **env)
{
#ifdef CTGRAMMAR
  treenode   *parse_tree;
  context_t  *contxt;
#endif /* CTGRAMMAR */

  char *p;
  int i;
  int argi = 1;  /* Next argument to handle. */
  int perl_exit_status = 0;
  struct cpp_options *opts = &options;
  int return_exit_code = SUCCESS_EXIT_CODE;

  /* Perl startup code */
  char szUseFilename[256];
  char *startup_code[] = { "", "-I", ".", "-I", "/scratch/gjb/cpp", "-e", szUseFilename };

  p = argv[0] + strlen (argv[0]);
  while (p != argv[0] && p[-1] != '/') --p;
  progname = p;

  init_parse_file (&parse_in);
  parse_in.data = opts;

  init_parse_options (opts);

  argi += cpp_handle_options (&parse_in, argc - argi , argv + argi);
  if (argi < argc)
    fatal ("Invalid option `%s'", argv[argi]);

  sprintf(szUseFilename,"require \'%s\';",szHooksFile);
/* FIXGJB: make runtime option */
#ifdef VERBOSE
  fprintf(stderr,"Trying file \"%s\"\n",szUseFilename);
#endif

  my_perl = perl_alloc();
  perl_construct( my_perl );     
  perl_exit_status = perl_parse(my_perl, cpp_functions_init, 
				sizeof(startup_code)/sizeof(startup_code[0]), 
				startup_code, NULL);

  // exit if we got compilation (parse) errors!
  if (perl_exit_status)
    die("Problem with hooks file!  Check that perl file for compilation errors.");

  perl_run(my_perl);
  gjb_call_hooks_void(opts,HI_STARTUP);

  parse_in.show_column = 1;

  i = push_parse_file (&parse_in, opts->in_fname);
  if (i != SUCCESS_EXIT_CODE)
    return i;

  /* Now that we know the input file is valid, open the output.  */

  if (!opts->out_fname || !strcmp (opts->out_fname, ""))
    opts->out_fname = "stdout";
  else if (! freopen (opts->out_fname, "w", stdout))
    cpp_pfatal_with_name (&parse_in, opts->out_fname);


#ifdef CTGRAMMAR
  parse_tree = (treenode *) NULL;
  
  init_nmetab();
  ParseStack = new_tree_stk();
  DoneStack  = new_tree_stk();
  contxt = new_context();
  
  if (!ParseStack || !DoneStack || !contxt) 
    {
    delete_tree_stk(ParseStack);
    delete_tree_stk(DoneStack);
    free_context(contxt);
    fputs("Out of memory.\n", stderr);
    exit(1);
    }
#endif /* CTGRAMMAR */

  if (!fShouldParse)
    {
    /* FIXGJB make runtime option */
#ifdef VERBOSE
    fprintf(stderr,"Option --noparse given, just running cpp w/o grammar!\n");
#endif
    for (;;)
      {
      cpp_annotated_token *pcat = cpp_get_token (&parse_in,0,0);
      cBytesCppRead += CPP_WRITTEN(&parse_in);
      if (! opts->no_output)
	{
	fwrite (parse_in.token_buffer, 1, CPP_WRITTEN (&parse_in), stdout);
	}
      cBytesOutput += CPP_WRITTEN(&parse_in);
      gjb_call_hooks_szl(opts,HI_CPP_OUT,parse_in.token_buffer,CPP_WRITTEN(&parse_in));
      gjb_call_hooks_pcat_szl(opts,HI_TOKEN,pcat,parse_in.token_buffer,
			      CPP_WRITTEN(&parse_in));
      if (pcat->id == CPP_EOF)
	break;
      parse_in.limit = parse_in.token_buffer;
      }
    }
  else
    {
    gjb_call_hooks_void(opts,HI_STARTPARSE);
    if (ct_yydebug)
      fprintf(stderr,"Calling yyparse()...\n");
#ifndef CTGRAMMAR
    yyparse();
#else /* CTGRAMMAR */
    ParseStack->contxt = contxt;
    
    handle_new_file(ParseStack, stdin, "stdin");    
    enter_scope(contxt);
    
    tree_parse(ParseStack, 0);
    fprintf(stderr,"Done tree_parse!\n");
  
    // parse_tree = (top_of_stack(DoneStack))->parse_tree;

#endif /* CTGRAMMAR */
    if (ct_yydebug)
      fprintf(stderr,"Returned from yyparse()!\n");
    }


  if (parse_in.errors)
    {
    return_exit_code = FATAL_EXIT_CODE;
    }

  gjb_call_hooks_i(opts,HI_EXIT,return_exit_code);

  cpp_finish (&parse_in);

  /* Perl shutdown code */
  perl_destruct(my_perl);
  perl_free(my_perl);

  exit (return_exit_code);
}
