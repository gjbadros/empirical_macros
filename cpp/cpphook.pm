#!/uns/bin/perl -w -I/tmp/gjb/cpp/xs/cpp/blib/arch -I/tmp/gjb/cpp/xs/cpp/blib/lib -I/tmp/gjb/cpp
#$Id$
use English;
#use strict;

use hook_index_constants;
use hook_datatypes;
use enum_node_type;
use em_util;
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
  open(TOKEN,">token.listing") || die "Could not open output file: $!";
#  select CHOUT;
  $| = 1; # Turn on autoflush
}

sub Exit {
  my ($retval) = @_;
  close(CHOUT); # Not really necessary of course
  close(TOKEN); # Not really necessary of course
  print "Exiting with status $retval\n";
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
  print "file = ", simplify_path_name($file), "\n";
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

sub cpp_out {
  my ($sz) = @_;
#  print "$sz\n";
  print "|"; # just print separator
}

sub cpp_error {
  my ($file,$line,$col,$msg) = @_;
  print "cpp_error: $file:$line:$col, $msg\n";
}

sub do_undef {
  my ($keyword, $cDeletes) = @_;
  print "do_undef of $keyword ($cDeletes deleted)\n";
}

sub delete_def {
  my ($keyword, $fExists) = @_;
  print "delete_def $keyword, $fExists\n";
}

sub expand_macro {
  my ($mname,$expansion) = @_;
  print "Lookup = ", cpp::lookup($mname), "\n";
  print "expand_macro $mname => $expansion\n";
}

sub special_symbol {
  my ($symbol,$enum_node_type) = @_;
  print "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

sub comment {
  my ($comment,$how_term,$lines) = @_;
  print "\n-----------------\n";
  print "COMMENT ($lines lines in @{[cpp::fname()]}) ending w/ $how_term: $comment\n";
  print "-----------------\n";
}

sub string_constant {
  my ($string,$lines) = @_;
  print "String_constant ($lines lines): \"$string\"\n";
}

sub do_include {
  my ($keyword, $file, $flags) = @_;
  print "do_include $keyword -> ", simplify_path_name($file),";  $flags\n";
#  print "Was working on: ", cpp::fname(), "\n";
}

sub do_if {
  my ($conditional, $skipped, $value) = @_;
  print "do_if on $conditional evals to $value ";
  print ", skipping $skipped" if $skipped ne "";
  print "\n";
}

sub do_elif {
  my ($conditional, $skipped, $value) = @_;
  print "do_elif_eval on $conditional ($skipped) evals to $value\n";
}
sub do_xifdef {
  my ($kind,$conditional, $trailing_garbage, $skipped, $value) = @_;
  print "do_xifdef ($kind) on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_ifdef {
  my ($conditional, $trailing_garbage, $skipped, $value) = @_;
  print "do_ifdef on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_ifndef {
  my ($kind,$conditional, $trailing_garbage, $skipped, $value) = @_;
  print "do_ifndef on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_else {
  my ($orig_conditional, $trailing_garbage, $skipped) = @_;
  print "do_else (orig conditional was $orig_conditional) [$trailing_garbage] skipped $skipped\n";
}

sub do_endif {
  my ($orig_conditional, $trailing_garbage) = @_;
  print "do_endif (orig conditional was $orig_conditional) [$trailing_garbage]\n";
}

sub add_import {
  my ($filename, $f) = @_;
  print "do_import on $filename, $f\n"
}

sub include_file {
  my ($filename, $fSystemInclude) = @_;
  print "include_file $filename, $fSystemInclude\n";
}

sub done_include_file {
  my ($filename, $fSystemInclude) = @_;
  # NOTE: $fSystemInclude is always undef due to a bug
  print "done_include_file $filename, $fSystemInclude\n";
}

# Token's come a lot, so redirect this output somewhere else
sub Got_token {
  my ($token,$sz) = @_;
  print TOKEN substr($token,4),"\n";
}

# Add the hooks, now

#AddHook($STARTUP,\&Startup);
#AddHook($DO_DEFINE,\&do_define);
#AddHook($HANDLE_DIRECTIVE,\&handle_directive);
#AddHook($CREATE_PREDEF,\&create_predef);
#AddHook($CREATE_DEF,\&create_def);
#AddHook($DO_UNDEF,\&do_undef);
#AddHook($DELETE_DEF,\&delete_def);
#AddHook($CPP_ERROR,\&cpp_error);
AddHook($CPP_OUT,\&cpp_out);
#AddHook($EXPAND_MACRO,\&expand_macro);
#AddHook($SPECIAL_SYMBOL,\&special_symbol);
#AddHook($COMMENT,\&comment);
#AddHook($STRING_CONSTANT,\&string_constant);
#AddHook($DO_INCLUDE,\&do_include);
#AddHook($DO_IF,\&do_if);
#AddHook($DO_ELIF,\&do_elif);
#AddHook($DO_XIFDEF,\&do_xifdef);
#AddHook($DO_IFDEF,\&do_ifdef);
#AddHook($DO_IFNDEF,\&do_ifndef);
#AddHook($DO_ELSE,\&do_else);
#AddHook($DO_ENDIF,\&do_endif);
#AddHook($ADD_IMPORT,\&add_import);
#AddHook($INCLUDE_FILE,\&include_file);
#AddHook($DONE_INCLUDE_FILE,\&done_include_file);
#AddHook($EXIT,\&Exit);
#AddHook($TOKEN,\&Got_token);


1;
__END__
