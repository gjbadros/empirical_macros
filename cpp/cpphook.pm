#!/uns/bin/perl -w
#$Id$
use English;
#use strict;

use hook_index_constants;
use hook_datatypes;
use enum_node_type;
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

sub create_def {
  my ($name, $expn, $nargs, $simp_expn, $file, $line, 
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  print "Create def for \"$name\": \"$expn\"\n";
  print "nargs = ", $nargs, "\n";
  print "simp_expn = \"", $simp_expn, "\"", "\n";
  @argnames = reverse split (/, /,$backward_argnames_string);
  print "argnames = ", join(', ', @argnames), "\n";
  print "file = ", $file, "\n";
  print "line = ", $line, "\n";
  print "predefined = ", is_set($def_flags,$PREDEFINED), "\n";
  print "restargs = ", is_set($def_flags,$RESTARGS), "\n";
  while ($#currpat >= 2) {
    print "$argnames[$currpat[0]], $currpat[1], $currpat[2]\n";
    splice(@currpat,0,3);
  }
}

sub create_predef {
  my ($name, $expn, $nargs, $simp_expn, $file, $line, 
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  print "PREDEF for \"$name\": \"$expn\"\n";
  print "nargs = ", $nargs, "\n";
  print "simp_expn = \"", $simp_expn, "\"", "\n";
  @argnames = reverse split (/, /,$backward_argnames_string);
  print "argnames = ", join(', ', @argnames), "\n";
  print "file = ", $file, "\n";
  print "line = ", $line, "\n";
  print "predefined = ", is_set($def_flags,$PREDEFINED), "\n";
  print "restargs = ", is_set($def_flags,$RESTARGS), "\n";
  while ($#currpat >= 2) {
    print "$argnames[$currpat[0]], $currpat[1], $currpat[2]\n";
    splice(@currpat,0,3);
  }
}

sub cpp_error {
  my ($file,$line,$col,$msg) = @_;
  print "cpp_error: $file:$line:$col, $msg\n";
}

sub do_undef {
  my ($keyword) = @_;
  print "do_undef of $keyword\n";
}

sub delete_def {
  my ($keyword, $fExists) = @_;
  print "delete_def $keyword, $fExists\n";
}

sub expand_macro {
  my ($mname,$expansion) = @_;
  print "expand_macro $mname => $expansion\n";
}

sub special_symbol {
  my ($symbol,$enum_node_type) = @_;
  print "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

sub comment {
  my ($comment,$how_term,$lines) = @_;
  print "\n-----------------\n";
  print "COMMENT ($lines lines) ending w/ $how_term: $comment\n";
  print "-----------------\n";
}

# Add the hooks, now
AddHook($STARTUP,\&Startup);
AddHook($DO_DEFINE,\&do_define);
AddHook($HANDLE_DIRECTIVE,\&handle_directive);
AddHook($CREATE_PREDEF,\&create_predef);
AddHook($CREATE_DEF,\&create_def);
AddHook($DELETE_DEF,\&delete_def);
AddHook($DO_UNDEF,\&do_undef);
AddHook($CPP_ERROR,\&cpp_error);
AddHook($EXPAND_MACRO,\&expand_macro);
AddHook($SPECIAL_SYMBOL,\&special_symbol);
AddHook($COMMENT,\&comment);


1;
__END__
