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
use Boolean;

sub AddHook {
  my ($indexname,$fnref) = @_;
  if (!defined($$indexname)) {
    die "Cannot find hook named $indexname";
  }
  push @{$Hooks[$$indexname]}, $fnref;
# Below line would still work, but uses the less general, 
# single hook interface  --10/02/97 gjb
#  $Hooks[$$indexname] = $fnref;
}


my %macro_name;


# List of empirically identified "Ok" states for the parsers stack in order
# to insert a declaration
my @state_stacks_decl_allowable = ( [],
				    [0],
				    [0,26] );

# From The C++ Programming Language, 3rd Edition, p. 817
my @new_cpp_keywords = 
  qw(
     and and_eq asm bitand bitor bool catch class compl const_cast
     delete dynamic_cast explicit false friend inline mutable namespace 
     new not not_eq operator or or_eq private protected public reinterpret_cast
     static_cast template this throw true try typeid typename using virtual wchar_t
     xor xor_eq );
			

sub FIsDeclAllowable {
  my @state_stack;
  if (@_) {
    @state_stack = @_;
  } else {
    @state_stack = cpp::ParseStateStack();
  }
  foreach my $stackref (@state_stacks_decl_allowable) {
    # String interpolation of an array works for comparing them
    # iff the elements are all numeric [otherwise might work if you change $"
    return TRUE if "@$stackref" eq "@state_stack";
  }
  return FALSE;
}

# For testing of more general multiple hook mechanism
sub Startup2 {
  print STDERR "Startup2\n";
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
  open(MACEXP_STACKS,">macro_expand_stacks") || die "Could not open output file: $!";
  open(CPPOUT,">cppout") || die "Could not open output file: $!";
#  select CHOUT;
  select STDERR;
  $| = 1; # Turn on autoflush
}

sub Exit {
  my ($retval) = @_;
  select(STDERR); dump_uses();
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


sub add_use {
  my ($mname,$fname, $expansion, $s_start, $s_end, $cbb) = @_;
  push @{$macro_uses{$mname}}, [$fname, $s_start, $s_end, $expansion, $cbb];
  print STDERR "add_use for $mname ($cbb), now at ", $#{$macro_uses{$mname}} + 1, "\n";
}


sub dump_uses {
  foreach my $mname (sort keys %macro_name) {
    $cUses = scalar(@{$macro_uses{$mname}}) || 0;
    print "$mname has $cUses uses\n";
    my $expansion = undef;
    my $all_same_expansions = TRUE;
    for (my $i = 0; $i < $cUses; $i++ ) {
      my $aref = $macro_uses{$mname}[$i];
      my ($fname,$s_start,$s_end,$expn) = @$aref;
      print "$i : $fname:[$s_start:$s_end] -> $expn\n";
      if (defined($expansion) && $expansion ne $expn) {
	$all_same_expansions = FALSE;
      } elsif (!defined($expansion)) {
	$expansion = $expn;
      }
    }
    # Note that undef-s are not an insurmountable problem,
    # they could be handled by using a new, non-conflicting name
    # and removing the undef-s
    if ($all_same_expansions == FALSE) {
      annotate_definition('xform',"Expansions vary, not a constant",$mname,
			  cpp::InFname(),undef,undef);
    } elsif ($cUses > 0) {
      annotate_definition('expsumm',"Expansions all go to $expansion",$mname,
			  cpp::InFname(),undef,undef);
      if (scalar(@$macro_name{$mname}) > 1) {
	annotate_definition_message('text','xform',"Multiple definitions!",$mname);
      } elsif ($expansion =~ m/^(0x)?\d+$/) {
	my $new_var = $mname;
	$new_var =~ tr/[A-Z]/[a-z]/;
	#FIXGJB: must avoid name conflicts here
	annotate_definition_message('text','subst',"enum {$new_var = $expansion};",$mname);
	annotate_definition_message('text','substexpn',"$new_var /* $expansion */",$mname);
      }
    } else {
      annotate_definition('expsumm',"No uses",$mname,
			  cpp::InFname(),undef,undef);
    }
  }
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
  print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'def \"$mname defined [$s_start:$s_end]\")\n";
  push @{$macro_name{$mname}{defs}}, [ $fname, $s_start,$s_end ];
  @{$macro_name{$mname}{currdef}} = ( $fname, $s_start,$s_end );
  if (!FIsDeclAllowable()) {
    annotate_definition('xform',"Parse stack may not be appropriate for a declaration",$mname,$fname,$s_start,$s_end);
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
  my $cch_output = cpp::CchOutput();
  my $cch_offset = cpp::CchOffset();
  print MAPPING "'($cch_offset . $cch_output)\n";
  if ($top_level_mname ne "") {
    $top_level_full_expansion .= $sz;
  }

  print CPPOUT "$sz\n";
  print CPPOUT "|"; # just print separator
}

sub cpp_error {
  my ($file,$line,$col,$msg) = @_;
  print CPP "cpp_error: $file:$line:$col, $msg\n";
}

sub do_undef {
  my ($s_start,$s_end,$mname, $cDeletes) = @_;
  print CPP "do_undef of $mname [$s_start,$s_end] ($cDeletes deleted)\n";
}

sub pre_do_undef {
  my ($s_start,$s_end,$mname) = @_;
  my $fname = cpp::Fname();
  print CPP "pre_do_undef of $mname [$s_start,$s_end]\n";
  annotate_definition_with_undef($mname,$fname,$s_start,$s_end);
}

sub delete_def {
  my ($keyword, $fExists) = @_;
  print CPP "delete_def $keyword, $fExists\n";
}

sub pop_buffer {
  my ($cbb) = @_;
  print "POP_BUFFER, $cbb buffers back\n";
}


sub macro_cleanup {
  my ($s_start, $s_end, $mname, $cnested, @nests) = @_;
  my $offset  = cpp::CchOffset();
  my $cbb = cpp::CbuffersBack();
  my $cbytesOutput = cpp::CchOutput();
  my $fname = cpp::Fname();
  my $old = select;
  select CPP;
  my $state_stack = join(",",cpp::ParseStateStack());
  print "macro_cleanup $mname; [$s_start - $s_end] source $offset, $cbb; output $cbytesOutput\n";
  print " : nests = ", join("->",@nests), "\n";
  print " : MEH = ", join("<-",cpp::MacroExpansionHistory()),"\n";
  if ($cbb == 1) {
    $top_level_full_expansion =~ s%\n%\\n\\%g;
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'final-exp \"$mname final expansion: $top_level_full_expansion\")\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'stack \"$state_stack\")\n";
    $top_level_full_expansion = "";
    $top_level_mname = "";
  }
  select $old;
}

# FIXGJB: Obsoleted, methinks --10/08/97 gjb
sub macro_arg_exp  {
  my ($mname,$raw,$number) = @_;
  print STDERR "macro_arg_exp $mname of $raw (arg $number)\n";
}

sub annotate_definition_message {
  my ($kind,$prop, $message, $mname) = @_;
  my ($fnamedef, $s_start, $s_end) = @{$macro_name{$mname}{currdef}};
  if (!defined($fnamedef)) {
    print STDERR "annotate_definition_message: could not find $mname\n";
  } else {
    print TPSOURCE "#$fnamedef:(add-$kind-property $s_start $s_end \'$prop \"$message\")\n";
  }
}

sub annotate_definition {
  my ($prop, $message, $mname, $fname, $s, $e) = @_;
  my ($fnamedef, $s_start, $s_end) = @{$macro_name{$mname}{currdef}};
  my $kind = "text";
  $kind = "list" if ($prop eq "use");
  if (!defined($s) && !defined($e)) {
    annotate_definition_message($kind,$prop,"$message at $fname",$mname);
  } else {
    annotate_definition_message($kind,$prop,"$message at $fname:$s,$e",$mname);
  }
}


sub annotate_definition_with_use {
  my $cbb = pop @_;
  my $expansion = splice(@_,2,1);
  if ($cbb == 0) {
    # Use appearing in the source code
    annotate_definition('use',"$expansion",@_);
  } else {
    annotate_definition('expuse',"$expansion [$cbb]",@_);
  }
}

sub annotate_definition_with_ifdef_use {
  my ($mname,$fname,$expansion,$s_start,$s_end,$cbb) = @_;
  annotate_definition_message("text",'ifdefuse',"$expansion [$cbb] at $fname:$s_start,$s_end",$mname);
  annotate_definition_message("text",'xform',"Used in a ccd! Do not convert!",$mname);
}

sub annotate_definition_with_undef {
  annotate_definition('xform',"Undef-fed",@_);
}

sub expand_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,@rest) 
    = @_;
  my $cnested = shift @rest;
  my @nests = splice(@rest,0,$cnested);
  my ($cargs,@args) = @rest;
  my $cBytesOutput = cpp::CchOutput();
  my $start = $cBytesOutput + 1 + $exp_offset - ($cbb > 0? $length - 1:0);
  my $end = $start + $length;
  my $call_length = length("$mname$raw_call");
  my $fname = cpp::Fname();
  my $old = select;
  annotate_definition_with_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
  add_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
  select CPP;

  print "\nexpand_macro $mname = ", cpp::ExpansionLookup($mname), ", source offset: $s_start - $s_end, $cbuffersDeep [$has_escapes]; ", 
      cpp::FExpandingMacros(), " in $fname\n";
  print " : expansion of $mname => $expansion (length $length:offset $start - $end [$cBytesOutput + $exp_offset + 1])\n";
#  print " : argof = ", cpp::ArgOf(), "\n"; FIXGJB obsoleted
  print " : nests = ", join("->",@nests), "\n";
  print " : MEH = ", join("<-",cpp::MacroExpansionHistory()),"\n";
  chomp $raw_call;
  print " : was \"$mname$raw_call\" with $cargs args, length = ", $call_length, "\n";
  my $state_stack = join(",",cpp::ParseStateStack());
  print MACEXP_STACKS "$mname: $state_stack\n";
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
  }
  select $old;
}

sub ifdef_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,@rest) = @_;
  my $start = cpp::CchOutput()+1;
  my $end = $start + $length - 3; # Subtract off for the @ @, and it's an inclusive range
  print CPP "ifdef_macro $mname => $expansion [$s_start:$s_end] (offset $start - $end)\n";
  my $fname = cpp::Fname();
  annotate_definition_with_ifdef_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
}


sub ifdef_lookup_macro {
  my ($mname,$fDefined) = @_;
  print STDERR "ifdef_lookup_macro $mname is ", $fDefined?"":"not ", "defined\n";
  my $fname = cpp::Fname();
  annotate_definition_with_ifdef_use($mname,$fname,$fDefined?"\@DEFINED\@":"\@NOT_DEFINED\@",
				    cpp::CchOffset()-length($mname),cpp::CchOffset);
}

sub special_symbol {
  my ($symbol,$enum_node_type) = @_;
  print CPP "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

# FIX: this lines wrong is wrong
sub comment {
  my ($s_start, $s_end, $comment,$how_term,$lines) = @_;
  print "\n-----------------\n";
  print "COMMENT ($lines lines in @{[cpp::Fname()]} [$s_start:$s_end) ending w/ $how_term: $comment\n";
  print "-----------------\n";
}

sub string_constant {
  my ($s_start, $s_end, $string, $lines) = @_;
  print "String_constant ($lines lines) [$s_start:$s_end]: \"$string\"\n";
}

sub do_include {
  my ($s_start,$s_end,$file_as_given, $file_as_resolved, $flags) = @_;
  print CPP "do_include $file_as_given [$s_start:$s_end] -> ", simplify_path_name($file_as_resolved),";  $flags\n";
#  print "Was working on: ", cpp::Fname(), "\n";
}

sub do_if {
  my ($s_start,$s_end,$conditional, $skipped, $value) = @_;
  print CPP "do_if on $conditional evals to $value ";
  print CPP ", skipping $skipped" if $skipped ne "";
  print CPP "\n";
  cpp::YYPushStackState();
  @state_stack = cpp::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
}

sub do_elif {
  my ($s_start,$s_end,$already_did_clause, $conditional, $skipped, $value) = @_;
  print CPP "do_elif on $conditional ($skipped) evals to $value; $already_did_clause\n";
}

sub do_xifdef {
  my ($s_start,$s_end,$kind,$conditional,$trailing_garbage,$skipped,$fSkipping,$s_branch_start) = @_;
  my $fname = cpp::Fname();
  my $s_branch_end = cpp::CchOffset() + 1;
  print CPP "do_xifdef ($kind) on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  print CPP ": @[$s_start - $s_end]\n";
  if ($fSkipping) {
    print STDERR "#$fname:(put-face-property-if-none $s_branch_start $s_branch_end \'font-lock-reference-face)\n";
    print TPSOURCE "#$fname:(put-face-property-if-none $s_branch_start $s_branch_end \'font-lock-reference-face)\n";
    print TPSOURCE "#$fname:(add-text-property $s_branch_start $s_branch_end \'doc \"Skipped due to $kind $conditional\")\n";
  }
}

sub do_ifdef {
  my ($s_start,$s_end,$conditional, $trailing_garbage, $skipped, $fSkipping) = @_;
  print CPP "do_ifdef on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  cpp::YYPushStackState();
  @state_stack = cpp::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
}

sub do_ifndef {
  my ($s_start,$s_end,$conditional, $trailing_garbage, $skipped, $fSkipping) = @_;
  print CPP "do_ifndef on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  cpp::YYPushStackState();
  @state_stack = cpp::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
}

sub do_else {
  my ($s_start,$s_end, 
      $orig_conditional, $trailing_garbage, $skipped, $fSkipping, $s_start_branch) = @_;
  my $s_end_branch = cpp::CchOffset() + 1;
  print CPP "do_else (orig conditional was $orig_conditional) [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  @state_stack = cpp::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  my $fname = cpp::Fname();
  if ($fSkipping) {
    print TPSOURCE "#$fname:(put-face-property-if-none $s_start_branch $s_end \'font-lock-reference-face)\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"Skipped due to else of $orig_conditional\")\n";
  }
}

sub do_endif {
  my ($s_start,$s_end,$orig_conditional, $trailing_garbage) = @_;
  chomp($trailing_garbage);
  print CPP "do_endif (orig conditional was $orig_conditional) [$trailing_garbage]\n";
  @state_stack = cpp::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  my $fEqual = cpp::YYFCompareTopStackState();
  if (!$fEqual) {
    print CPP ": STATE_STACK altered by #ifdef/#endif block\n";
  }
  cpp::YYPopAndDiscardStackState();
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

sub Got_token2 {
  my ($token,$mname,$argno,$raw,@history) = @_;
  print STDERR "Got TOKEN2, $token\n";
}

# Token's come a lot, so redirect this output somewhere else
sub Got_token {
  my ($token,$raw,$mname,$argno,@history) = @_;
  my @nests = cpp::MacroExpansionHistory();
  my $fname = cpp::Fname();

#  $argof = cpp::ArgOf(); FIXGJB: obsoleted, use $argno instead
  print  TOKEN "TOKEN: $raw;", substr($token,4),", FExpandingMacros = ",cpp::FExpandingMacros(),
   ", CchOffset = $fname:", cpp::CchOffset(), "; CchOutput = ", cpp::CchOutput(),"\n";
  print TOKEN ": Nests: ",join("<-",@nests),"\n";
  print TOKEN ": History: ",join("<-",@history),"\n";
  print TOKEN ": From $mname\n";
  print TOKEN ": Argno = $argno\n";
  if ($raw =~ m/^[\w\$]+$/) {
    print TOKEN ": ", cpp::FLookupSymbol($raw)? "Found symbol" : "Not found", "\n";
  }

  my $end = cpp::CchOutput()+1;
  my $start = $end-length($raw);
  @history = @nests; # FIXGJB: this is a hack, since stuff not getting passed
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

#FIXGJB Obsoleted
#sub annotate {
#  my ($szBefore,$cdeepBefore,$szAfter,$cdeepAfter, $pad) = @_;
#  print "ANNOTATE: $szBefore\[$cdeepBefore\]; $szAfter\[$cdeepAfter\] : $pad\n";
#}

sub do_function {
  my ($szName,$fStatic) = @_;
  print "Function: $szName", $fStatic?" (static)":"", "\n";
}

sub do_func_call {
  my ($szName) = @_;
  print "CallFunction: $szName\n";
}

# Add the hooks, now

AddHook("STARTUP",\&Startup);
#AddHook("STARTUP",\&Startup2);
AddHook("DO_DEFINE",\&do_define);
AddHook("HANDLE_DIRECTIVE",\&handle_directive);
AddHook("CREATE_PREDEF",\&create_predef);
AddHook("CREATE_DEF",\&create_def);
AddHook("DO_UNDEF",\&do_undef);
AddHook("PRE_DO_UNDEF",\&pre_do_undef);
AddHook("DELETE_DEF",\&delete_def);
AddHook("CPP_ERROR",\&cpp_error);
AddHook("CPP_OUT",\&cpp_out);
AddHook("EXPAND_MACRO",\&expand_macro);
AddHook("MACARG_EXP",\&macro_arg_exp);
AddHook("MACRO_CLEANUP",\&macro_cleanup);
AddHook("IFDEF_MACRO",\&ifdef_macro);
AddHook("IFDEF_LOOKUP_MACRO",\&ifdef_lookup_macro);
AddHook("SPECIAL_SYMBOL",\&special_symbol);
AddHook("COMMENT",\&comment);
AddHook("STRING_CONSTANT",\&string_constant);
AddHook("DO_INCLUDE",\&do_include);
AddHook("DO_IF",\&do_if);
AddHook("DO_ELIF",\&do_elif);
AddHook("DO_XIFDEF",\&do_xifdef);
AddHook("DO_IFDEF",\&do_ifdef);
AddHook("DO_IFNDEF",\&do_ifndef);
AddHook("DO_ELSE",\&do_else);
AddHook("DO_ENDIF",\&do_endif);
AddHook("ADD_IMPORT",\&add_import);
AddHook("INCLUDE_FILE",\&include_file);
AddHook("DONE_INCLUDE_FILE",\&done_include_file);
AddHook("EXIT",\&Exit);
AddHook("TOKEN",\&Got_token);
#AddHook("TOKEN",\&Got_token2);
AddHook("FUNCTION",\&do_function);
AddHook("FUNC_CALL",\&do_func_call);
AddHook("ANNOTATE",\&annotate);
AddHook("POP_BUFFER",\&pop_buffer);


1;
__END__
