#!/uns/bin/perl -w -I/tmp/gjb/cpp/xs/cpp/blib/arch -I/tmp/gjb/cpp/xs/cpp/blib/lib -I/tmp/gjb/cpp
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output
use English;
#use strict;

use hook_index_constants;
use hook_datatypes;
use enum_node_type;
use em_util;
use vars qw( *CHOUT @Hooks );

my %macro_name;

my @state_stacks_decl_allowable = ( [],
				    [0],
				    [0,26] );

my $TRUE = 1;
my $FALSE = 0;


sub FIsDeclAllowable {
  my @state_stack;
  if (@_) {
    @state_stack = @_;
  } else {
    @state_stack = cpp::ParseStateStack();
  }
  foreach my $stackref (@state_stacks_decl_allowable) {
    return $TRUE if "@$stackref" eq "@state_stack";
  }
  return $FALSE;
}


sub AddHook {
  my ($indexname,$fnref) = @_;
  if (!defined($$indexname)) {
    die "Cannot find hook named $indexname";
  }
  $Hooks[$$indexname] = $fnref;
}

sub Startup {
  # Parse debugging (bison's yydebug variable) is on by default,
  # so turn it off
  cpp::ResetParseDebugging();
  print STDERR "STARTUP...\n";
#  open(CPP,">cpp.listing") || die "Could not open output file: $!";
  *CPP = *STDERR;
  open(CHOUT,">chout.listing") || die "Could not open output file: $!";
#  open(TOKEN,">token.listing") || die "Could not open output file: $!";
  *TOKEN = *STDERR;
  open(MAPPING,">mapping") || die "Could not open output file: $!";
  print MAPPING "(setq char-mapping (list\n";
  open(TP,">textprops.el") || die "Could not open output file: $!";
  open(TPSOURCE,">textprops-source.el") || die "Could not open output file: $!";
#  select CHOUT;
  select STDERR;
  $| = 1; # Turn on autoflush
}

sub Exit {
  my ($retval) = @_;
  close(TP);
  close(TPSOURCE);
  print MAPPING "))\n";
  close(MAPPING);
  close(CHOUT); # Not really necessary of course
  close(TOKEN); # Not really necessary of course
  print "Exiting with status $retval\n";
}

sub do_define {
  my ($s_start,$s_end,$name_args_body) = @_;
  my $fname = cpp::Fname();
  print CPP "In do_define w/ body = $name_args_body\n";
  print CPP ": $fname [$s_start,$s_end]\n";
  print STDERR ": ParseStateStack: ", join(",",cpp::ParseStateStack()), "\n";
}

sub handle_directive {
  my ($body) = @_;
  print CPP "In handle_directive for $body\n";
}

sub create_def {
  my ($s_start, $s_end, $mname, $expn, $nargs, $simp_expn, $file, $line,
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  my $old = select;
  my $fname = cpp::Fname();
  select CPP;
  print "Create def for \"$mname\": \"$expn\" [$s_start,$s_end]\n";
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
  print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"$mname defined\")\n";
  push @{$macro_name{$mname}{defs}}, [ $fname, $s_start,$s_end ];
  @{$macro_name{$mname}{currdef}} = ( $fname, $s_start,$s_end );
  if (!FIsDeclAllowable()) {
    annotate_definition("Parse stack may not be appropriate for a declaration",$mname,$s_start,$s_end);
    print STDERR ":**BETTER NOT CHANGE THIS TO A DECL!\n";
  }
  select $old;
}

sub create_predef {
  my ($name, $expn, $nargs, $simp_expn, $file, $line, 
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  my $old = select;
  select CPP;
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
  select $old;
}

sub cpp_out {
  my ($sz) = @_;
  my $cch_output = cpp::CbytesOutput();
  my $cch_offset = cpp::CchOffset();
  print MAPPING "'($cch_offset . $cch_output)\n";
  if ($top_level_mname ne "") {
    $top_level_full_expansion .= $sz;
  }

#  print "$sz\n";
#  print "|"; # just print separator
}

sub cpp_error {
  my ($file,$line,$col,$msg) = @_;
  print CPP "cpp_error: $file:$line:$col, $msg\n";
}

sub do_undef {
  my ($s_start,$s_end,$mname, $cDeletes) = @_;
  print CPP "do_undef of $mname [$s_start,$s_end] ($cDeletes deleted)\n";
  annotate_definition_with_undef($mname,$s_start,$s_end);
}
sub delete_def {
  my ($keyword, $fExists) = @_;
  print CPP "delete_def $keyword, $fExists\n";
}

sub macro_cleanup {
  my ($mname, $s_start, $s_end, $cnexted, @nests) = @_;
  my $offset  = cpp::CchOffset();
  my $cbb = cpp::CbuffersBack();
  my $cbytesOutput = cpp::CbytesOutput();
  my $fname = cpp::Fname();
  my $old = select;
  select CPP;
  print "macro_cleanup $mname; [$s_start - $s_end] source $offset, $cbb; output $cbytesOutput\n";
  print " : nests = ", join("->",@nests), "\n";
  if ($cbb == 1) {
    $top_level_full_expansion =~ s%\n%\\n\\%g;
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"$mname final expansion: $top_level_full_expansion\")\n";
    $top_level_full_expansion = "";
    $top_level_mname = "";
  }
  select $old;
}

sub macro_arg_exp  {
  my ($mname,$raw,$number) = @_;
  print "macro_arg_exp $mname of $raw (arg $number)\n";
}

sub annotate_definition {
  my ($message, $mname, $s, $e) = @_;
  my ($fnamedef, $s_start, $s_end) = @{$macro_name{$mname}{currdef}};
  my $fname = cpp::Fname();
  print STDERR "\"$mname\"\n";
  print TPSOURCE "#$fnamedef:(add-text-property $s_start $s_end \'doc \"$message at $fname:$s,$e\")\n";
}


sub annotate_definition_with_use {
  annotate_definition("Use",@_);
}

sub annotate_definition_with_undef {
  annotate_definition("Undef-fed",@_);
}

sub expand_macro {
  my ($mname,$expansion,$length,$raw_call,$s_start,$s_end,$has_escapes,$cbuffersDeep,@rest) 
    = @_;
  my $cnested = shift @rest;
  my @nests = splice(@rest,0,$cnested);
  my ($cargs,@args) = @rest;
  my ($exp_offset, $cbb) = cpp::SumCchExpansionOffset();
  my $cBytesOutput = cpp::CbytesOutput();
  my $start = $cBytesOutput + 1 + $exp_offset - ($cbb > 0? $length - 1:0);
  my $end = $start + $length;
  my $call_length = length("$mname$raw_call");
  my $cbuffersBack;
  my $fname = cpp::Fname();
  my $old = select;
  annotate_definition_with_use($mname,$s_start,$s_end);
  select CPP;

  print "\nexpand_macro $mname = ", cpp::ExpansionLookup($mname), ", source offset: $s_start - $s_end, $cbuffersDeep [$has_escapes]; ", 
      cpp::FExpandingMacros(), " in $fname\n";
  print " : expansion of $mname => $expansion (length $length:offset $start - $end [$cBytesOutput + $exp_offset + 1])\n";
  print " : argof = ", cpp::ArgOf(), "\n";
  print " : nests = ", join("->",@nests), "\n";
  print " : MEH = ", join("<-",cpp::MacroExpansionHistory()),"\n";
  chomp $raw_call;
  print " : was \"$mname$raw_call\" with $cargs args, length = ", $call_length, "\n";
  my $iarg = 0;
# Return values here that look like "@-BAZ" are escape macros (they've been expanded)
  while ($#args > 0) {
    print " :$iarg: ", join(",",splice(@args,0,6)), "\n";
    my $uses = shift @args;
    print " :$iarg used $uses times: ", join(";",splice(@args,0,2*$uses)), "\n";
    $iarg++;
  }
  if ($s_start >= 0) {
    if ($has_escapes == 0) {
      # top level expansion
      $top_level_mname = $mname;
      print TPSOURCE "#$fname:(put-face-property-if-none $s_start $s_end \'italic)\n";
      print TPSOURCE "#$fname:(put-mouse-face-property-if-none $s_start $s_end \'highlight)\n";
    }
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"$mname expands to $expansion\")\n";
  }
  select $old;
}

sub ifdef_macro {
  my ($mname,$expansion,$length,$raw_call,$cargs) = @_;
  my $start = cpp::CbytesOutput()+1;
  my $end = $start + $length - 3; # Subtract off for the @ @, and it's an inclusive range
  print CPP "ifdef_macro $mname => $expansion (offset $start - $end)\n";
}

sub special_symbol {
  my ($symbol,$enum_node_type) = @_;
  print CPP "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

# FIX: this lines wrong is wrong
sub comment {
  my ($comment,$how_term,$lines) = @_;
  print "\n-----------------\n";
  print "COMMENT ($lines lines in @{[cpp::Fname()]}) ending w/ $how_term: $comment\n";
  print "-----------------\n";
}

sub string_constant {
  my ($string,$lines) = @_;
  print "String_constant ($lines lines): \"$string\"\n";
}

sub do_include {
  my ($keyword, $file, $flags) = @_;
  print CPP "do_include $keyword -> ", simplify_path_name($file),";  $flags\n";
#  print "Was working on: ", cpp::Fname(), "\n";
}

sub do_if {
  my ($conditional, $skipped, $value) = @_;
  print CPP "do_if on $conditional evals to $value ";
  print CPP ", skipping $skipped" if $skipped ne "";
  print CPP "\n";
}

sub do_elif {
  my ($conditional, $skipped, $value) = @_;
  print CPP "do_elif_eval on $conditional ($skipped) evals to $value\n";
}
sub do_xifdef {
  my ($kind,$conditional, $trailing_garbage, $skipped, $value) = @_;
  print CPP "do_xifdef ($kind) on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_ifdef {
  my ($conditional, $trailing_garbage, $skipped, $value) = @_;
  print CPP "do_ifdef on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_ifndef {
  my ($kind,$conditional, $trailing_garbage, $skipped, $value) = @_;
  print CPP "do_ifndef on $conditional [$trailing_garbage] ($skipped) evals to $value\n";
}

sub do_else {
  my ($orig_conditional, $trailing_garbage, $skipped) = @_;
  print CPP "do_else (orig conditional was $orig_conditional) [$trailing_garbage] skipped $skipped\n";
}

sub do_endif {
  my ($orig_conditional, $trailing_garbage) = @_;
  print CPP "do_endif (orig conditional was $orig_conditional) [$trailing_garbage]\n";
}

sub add_import {
  my ($filename, $f) = @_;
  print CPP "do_import on $filename, $f\n"
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
  my ($token,$mname,$argno,$raw,@history) = @_;
  my @nests = cpp::MacroExpansionHistory();
 $argof = cpp::ArgOf();
  print  TOKEN "TOKEN: $raw;", substr($token,4),", FExpandingMacros = ",cpp::FExpandingMacros(),
   ", CchOffset = ", cpp::CchOffset(), "; CbytesOutput = ", cpp::CbytesOutput(),"\n";
  print TOKEN ": Nests: ",join("<-",@nests),"\n";
  print TOKEN ": History: ",join("<-",@history),"\n";
  print TOKEN ": From $mname\n";
  print TOKEN ": ArgOf = $argof vs. Argno = $argno\n";

  my $end = cpp::CbytesOutput()+1;
  my $start = $end-length($raw);
  if ($#history >= 0) {
    print TP "#out:(put-face-property-if-none $start $end \'italic)\n";
    print TP "#out:(put-mouse-face-property-if-none $start $end \'highlight)\n";
    if ($argno < 0) {
      print TP "#out:(add-text-property $start $end \'doc \"Expansion from " , (join("<-",@history)),"\")\n";
    } elsif ($argno == 0) {
      print TP "#out:(add-text-property $start $end \'doc \"Expansion from body of " , (join("<-",@history)),"\")\n";
    } else {
      print TP "#out:(add-text-property $start $end \'doc \"Expansion from argument $argno of " , (join("<-",@history)),"\")\n";
    }
  }
}

sub annotate {
  my ($szBefore,$cdeepBefore,$szAfter,$cdeepAfter, $pad) = @_;
  print "ANNOTATE: $szBefore\[$cdeepBefore\]; $szAfter\[$cdeepAfter\] : $pad\n";
}

sub do_function {
  my ($szName) = @_;
  print "Function: $szName\n";
}

sub do_func_call {
  my ($szName) = @_;
  print "CallFunction: $szName\n";
}

# Add the hooks, now

AddHook("STARTUP",\&Startup);
AddHook("DO_DEFINE",\&do_define);
AddHook("HANDLE_DIRECTIVE",\&handle_directive);
AddHook("CREATE_PREDEF",\&create_predef);
AddHook("CREATE_DEF",\&create_def);
AddHook("DO_UNDEF",\&do_undef);
AddHook("DELETE_DEF",\&delete_def);
AddHook("CPP_ERROR",\&cpp_error);
AddHook("CPP_OUT",\&cpp_out);
AddHook("EXPAND_MACRO",\&expand_macro);
AddHook("MACARG_EXP",\&macro_arg_exp);
AddHook("MACRO_CLEANUP",\&macro_cleanup);
AddHook("IFDEF_MACRO",\&ifdef_macro);
AddHook("SPECIAL_SYMBOL",\&special_symbol);
AddHook("COMMENT",\&comment);
AddHook("STRING_CONSTANT",\&string_constant);
AddHook("DO_INCLUDE",\&do_include);
AddHook("DO_IF",\&do_if);
AddHook("DO_ELIF",\&do_elif);
AddHook("DO_XIFDEF",\&do_xifdef);
#AddHook("DO_IFDEF",\&do_ifdef);
#AddHook("DO_IFNDEF",\&do_ifndef);
AddHook("DO_ELSE",\&do_else);
AddHook("DO_ENDIF",\&do_endif);
AddHook("ADD_IMPORT",\&add_import);
AddHook("INCLUDE_FILE",\&include_file);
AddHook("DONE_INCLUDE_FILE",\&done_include_file);
AddHook("EXIT",\&Exit);
AddHook("TOKEN",\&Got_token);
AddHook("FUNCTION",\&do_function);
AddHook("FUNC_CALL",\&do_func_call);
AddHook("ANNOTATE",\&annotate);


1;
__END__
