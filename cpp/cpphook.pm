#!/uns/bin/perl -w
#$Id$
use English;
#use strict;

use hook_index_constants;
use hook_datatypes;
use vars qw( *CHOUT @Hooks );

sub AddHook {
  my ($index,$fnref) = @_;
  $Hooks[$index] = $fnref;
}

sub PrintUID { 
  print "UID is $<\n"; 
}

sub Startup {
  open(CHOUT,">chout.listing") || die "Could not open output file: $!";
#  select CHOUT;
}

sub do_define {
  my ($body) = @_;
  print "In do_define w/ body = $body\n";
}

sub handle_directive {
  my ($body) = @_;
  print "In handle_directive for $body\n";
}

sub make_printable {
  my ($str) = @_;
  $str =~ s/([\000-\037])/sprintf("\\%03o",ord($1))/ge;
  return $str;
}

sub create_def {
  my ($name, $expn, $nargs, $simp_expn, $file, $line, $argnames, $refargnames, 
      $f_predef, $f_restargs, @currpat) = @_;
  print "Create def for \"$name\": \"$expn\"\n";
  print "nargs = ", $nargs, "\n";
  print "simp_expn = \"", $simp_expn, "\"", "\n";
#  @argnames = reverse split (/, /,$argnames);
  @argnames = @$refargnames;
  print "argnames = ", join(', ', @argnames), "\n";
  print "file = ", $file, "\n";
  print "line = ", $line, "\n";
  print "predefined = ", $f_predef, "\n";
  print "rest_args = ", $f_restargs, "\n";
  while ($#currpat >= 5) {
    print join(', ',@currpat[(0..3)]), ", $argnames[$currpat[4]], $currpat[5]\n";
    splice(@currpat,0,6);
  }
}


# Add the hooks, now
AddHook($STARTUP,\&Startup);
AddHook($DO_DEFINE,\&do_define);
AddHook($HANDLE_DIRECTIVE,\&handle_directive);
AddHook($CREATE_DEF,\&create_def);


1;
__END__
