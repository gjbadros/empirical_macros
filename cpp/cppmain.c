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
#undef yydebug
#undef yyparse
/* Avoid some warnings by undef-fing  perl's TRUE and FALSE macros, 
   since cpp redefs them */
#undef FALSE
#undef TRUE

#include "cpplib.h"
#include "cpphook.h"
#include "cppmain.h"
#include <stdio.h>

#ifndef EMACS
#include "config.h"
#endif /* not EMACS */

extern char *getenv ();

char *progname;

cpp_reader parse_in;
cpp_options options;

/* More 'friendly' abort that prints the line and file.
   config.h can #define abort fancy_abort if you like that sort of thing.  */

void
fancy_abort ()
{
  fatal ("Internal gcc abort.");
}



char *
SzFromToken(enum cpp_token kind) {
  char *s = "";
  switch (kind)
    {
    case CPP_EOF:
      s = "CPP_EOF";
      break;
    case CPP_OTHER:
      s = "CPP_OTHER";
      break;
    case CPP_COMMENT:
      s = "CPP_COMMENT";
      break;
    case CPP_HSPACE:
      s = "CPP_HSPACE";
      break;
    case CPP_VSPACE:
      s = "CPP_VSPACE";
      break;
    case CPP_NAME:
      s = "CPP_NAME";
      break;
    case CPP_NUMBER:
      s = "CPP_NUMBER";
      break;
    case CPP_CHAR:
      s = "CPP_CHAR";
      break;
    case CPP_STRING:
      s = "CPP_STRING";
      break;
    case CPP_DIRECTIVE:
      s = "CPP_DIRECTIVE";
      break;
    case CPP_LPAREN:
      s = "CPP_LPAREN";
      break;
    case CPP_RPAREN:
      s = "CPP_RPAREN";
      break;
    case CPP_LBRACE:
      s = "CPP_LBRACE";
      break;
    case CPP_RBRACE:
      s = "CPP_RBRACE";
      break;
    case CPP_COMMA:
      s = "CPP_COMMA";
      break;
    case CPP_SEMICOLON:
      s = "CPP_SEMICOLON";
      break;
    case CPP_3DOTS:
      s = "CPP_3DOTS";
      break;
#if 0
    case CPP_ANDAND:
      s = "CPP_ANDAND";
      break;
    case CPP_OROR:
      s = "CPP_OROR";
      break;
    case CPP_LSH:
      s = "CPP_LSH";
      break;
    case CPP_RSH:
      s = "CPP_RSH";
      break;
    case CPP_EQL:
      s = "CPP_EQL";
      break;
    case CPP_NEQ:
      s = "CPP_NEQ";
      break;
    case CPP_LEQ:
      s = "CPP_LEQ";
      break;
    case CPP_GEQ:
      s = "CPP_GEQ";
      break;
    case CPP_PLPL:
      s = "CPP_PLPL";
      break;
    case CPP_MINMIN:
      s = "CPP_MINMIN";
      break;
#endif
  /* POP_TOKEN is returned when we've popped a cpp_buffer. */
    case CPP_POP:
      s = "CPP_POP";
      break;
    }
  return s;
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


int
cppmain_handle_options (cpp_reader *pfile, int argc, char **argv)
{
  int i;
  for (i = 0; i < argc; i++) 
    {
    if (argv[i][0] == '-' && argv[i][1]== '-')
      {
      if (strcmp(argv[i]+2,"yydebug") == 0)
	yydebug = 1;
      else if (strcmp(argv[i]+2,"noparse") == 0)
	fShouldParse = 0;
      continue;
      }
    return i;
    }
  return i;
}

int
main (int argc, char **argv, char **env)
{
  char *p;
  int i;
  int argi = 1;  /* Next argument to handle. */
  int perl_exit_status = 0;
  struct cpp_options *opts = &options;
  int return_exit_code = SUCCESS_EXIT_CODE;

  /* Perl startup code */
  char *startup_code[] = { "", "-I", "/tmp/gjb/cpp", "-e", "use cpphook" };
  my_perl = perl_alloc();
  perl_construct( my_perl );     
  perl_exit_status = perl_parse(my_perl, cpp_functions_init, 
				sizeof(startup_code)/sizeof(startup_code[0]), 
				startup_code, NULL);

  // exit if we got compilation (parse) errors!
  if (perl_exit_status)
    die("Problem use-ing cpphook!  Check that perl file for compilation errors.");

  perl_run(my_perl);

  gjb_call_hooks_void(opts,HI_STARTUP);

  p = argv[0] + strlen (argv[0]);
  while (p != argv[0] && p[-1] != '/') --p;
  progname = p;

  init_parse_file (&parse_in);
  parse_in.data = opts;

  init_parse_options (opts);

  /* FIXGJB: the argument handling needs work -- localize, or generalize! */
  argi += cppmain_handle_options (&parse_in, argc - argi, argv + argi);

  argi += cpp_handle_options (&parse_in, argc - argi , argv + argi);
  if (argi < argc)
    fatal ("Invalid option `%s'", argv[argi]);
  parse_in.show_column = 1;

  i = push_parse_file (&parse_in, opts->in_fname);
  if (i != SUCCESS_EXIT_CODE)
    return i;

  /* Now that we know the input file is valid, open the output.  */

  if (!opts->out_fname || !strcmp (opts->out_fname, ""))
    opts->out_fname = "stdout";
  else if (! freopen (opts->out_fname, "w", stdout))
    cpp_pfatal_with_name (&parse_in, opts->out_fname);

  if (!fShouldParse)
    {
    fprintf(stderr,"Option --noparse given, just running cpp w/o grammar!\n");
    for (;;)
      {
      enum cpp_token kind;
      kind = cpp_get_token (&parse_in);
      if (! opts->no_output)
	{
	fwrite (parse_in.token_buffer, 1, CPP_WRITTEN (&parse_in), stdout);
	}
      gjb_call_hooks_szl(opts,HI_CPP_OUT,parse_in.token_buffer,CPP_WRITTEN(&parse_in));
      gjb_call_hooks_sz_szl(opts,HI_TOKEN,SzFromToken(kind),parse_in.token_buffer,
			    CPP_WRITTEN(&parse_in));
      if (kind == CPP_EOF)
	break;
      parse_in.limit = parse_in.token_buffer;
      }
    }
  else
    {
    if (yydebug)
      fprintf(stderr,"Calling yyparse()...\n");
    yyparse();
    if (yydebug)
      fprintf(stderr,"Returned from yyparse()!\n");
    }

  cpp_finish (&parse_in);

  /* Perl shutdown code */
  perl_destruct(my_perl);
  perl_free(my_perl);

  if (parse_in.errors)
    {
    return_exit_code = FATAL_EXIT_CODE;
    }

  gjb_call_hooks_i(opts,HI_EXIT,return_exit_code);
  exit (return_exit_code);
}
