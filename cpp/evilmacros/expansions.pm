#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output

use pcp3;
use em_constants;
use checkargs;
use File::Basename;

my $prefix;
my %macro_name;
my %macro_name_to_def_in_filename;
my %typedefs;
my %functions;
my %already_included;

my $fParsingMacro = $false;
my %vars_declared_in_macro = ();
my $state_before_parse_body = 0;
my $node_before_parse_body = 0;
my $current_macro_name;
#my $fDebugParse = $true;
my $fDebugParse = $false;

my $macro_nestings_deep = 0;

sub handle_directive {
  my ($directive) = @_;
#  print STDERR "In handle_directive for $directive\n";
  if ($directive =~ m/^line/) {
    print STDERR "Ignoring #line directive\n";
    return 0;
  }
  return 1;
}


sub Got_token {
  my ($token,$mname,$argno,$raw,@history) = @_;
  print CPP "Got TOKEN2, $token\n";
}


sub Startup {
  my ($source_file) = @_;

  print STDERR "Source file is: $source_file\n";

  # Parse debugging (bison's yydebug variable) is on by default,
  # so turn it off
  if ($fDebugParse) {
    pcp3::SetParseDebugging();
  }
  $prefix = "source";
  if ($source_file !~ /@/) {
    $prefix = basename($source_file,".c");
  }

#  open(CPP,">$prefix.cPp") || die "Cannot open $prefix.cpp: $!";
  open(VARS,">$prefix.vars") || die "Cannot open $prefix.vars: $!";
  open(TYPES,">$prefix.types") || die "Cannot open $prefix.types: $!";
  open(EXPAND,">$prefix.exps") || die "Cannot open $prefix.exps: $!";
  #EXPNEG will hold expansions with bogus offsets, so denote-expansions
  # does not unnecessarily complain -- they are innocuous in my recent
  # experience --12/13/98 gjb
  open(EXPNEG,">$prefix.exps-neg") || die "Cannot open $prefix.exps-neg: $!";
  open(CMDLNDEFS,">$prefix.defgjbmde") || die "Cannot open $prefix.defgjbmde: $!";
#  open(EXP_CL,">$prefix.expcl") || die "Cannot open $prefix.expcl: $!";
#  open(TOKEN,">$prefix.tokens") || die "Could not open $prefix.tokens: $!";
  open(FUNCTIONS,">$prefix.funcs") || die "Cannot open $prefix.funcs: $!";
  print STDERR "STARTUP...\n";
  $| = 1; # Turn on autoflush

}



sub Exit {
  my ($retval) = @_;
  print STDERR "Exit -- touching ${prefix}.o\n";
  output_functions_listing();
  system("touch $prefix.o");
}

sub add_use {
  my ($mname,$fname, $expansion, $s_start, $s_end, $cbb) = @_;
  # test16.c tickles this bug
  if ($cbb <= 1) {
    if ($s_start < 0 || $s_end < 0 || $s_start > $s_end) {
      # bad, but probably not a severe problem
      print EXPNEG "$fname: $mname, $s_start, $s_end\n";
    } else {
      print EXPAND "$fname: $mname, $s_start, $s_end\n";
    }
  }
}

sub output_functions_listing {
  foreach my $funcname (sort keys %functions) {
    print FUNCTIONS $funcname, "\n";
  }
}



#from em_analyze
# Note that "words" include literal numbers, etc.
sub words_in ( $ )
{
  my ($text) = check_args(1, @_);
  # \W+ is probably more efficient than \b for the split criterion.
  # Without this, we can get an empty first component.
  $text =~ s/^\W+//;
  # \W+ in place of char class is wrong:  $ may appear in identifier.
  return split(/[^a-zA-Z0-9_\$]+/,$text);
}

sub underscores_stripped ( $ )
{
  my ($text) = @_;
  if ($text =~ /^__(.*)__$/o) {
    $text = $1;
  }
}

sub HistogramNumericFromList ( @ ) {
  my %histogram = ();
  foreach my $item (@_) {
    local $WARNING = 0;
    $histogram{$item}++;
  }
  return %histogram;
}


sub uniquify_array ( @ )
{
  return () if (scalar(@_) == 0);
  my %histogram = HistogramNumericFromList(@_);
  return keys %histogram;
}


#from em_analyze
# NOTE: I added the check against reserved words here! --04/01/98 gjb
sub identifiers_in ( $ )
{
  my ($text) = check_args(1, @_);
  return grep { $_ =~ /$identifier_re/o &&
		$_ !~ /$reserved_word_re/o &&
		$_ !~ /__(extension|attribute)__/o && 
		underscores_stripped($_) !~ /${reserved_word_re}/o } words_in($text);
}


sub FMacroDefined {
  my ($mname) = @_;
  return exists $macro_name_to_def_in_filename{$mname};
}


sub create_def {
  my ($s_start, $s_end, $mname, $expn, $nargs, $simp_expn, $file, $line,
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  my $fname = pcp3::Fname();

  if ($simp_expn =~ /__attribute__/) {
    print STDERR "removing\n";
    $simp_expn =~ s/__attribute__\s+\(\(.*?\)\)//g;
  }

  $macro_name_to_def_in_filename{$mname} = $fname;
  $current_macro_name = $mname;

}

sub do_undef {
  my ($s_start,$s_end,$mname, $cDeletes) = @_;
#  print STDERR "DO UNDEF\n";
}


sub create_predef {
  my ($mname, $expn, $nargs, $simp_expn, $file, $line, 
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  $macro_name_to_def_in_filename{$mname} = "__PREDEF__";
}

sub pre_do_undef {
  my ($s_start,$s_end,$mname) = @_;
  my $fname = pcp3::Fname();
  print CPP "pre_do_undef of $mname [$s_start,$s_end]\n";
  my $retval = 0; # by default, do not do the undef
  if ($macro_nestings_deep == 0) {
    $retval = 1;
  } else {
#    print STDERR "Ignoring UNDEF\n";
  }
  return $retval;
}

sub delete_def {
  my ($keyword, $fExists) = @_;
  print CPP "delete_def $keyword, $fExists\n";
}

sub pop_buffer {
  my ($cbb) = @_;
  print "POP_BUFFER, $cbb buffers back\n";
}


sub expand_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,@rest) 
    = @_;
  my $cnested = shift @rest;
  my @nests = splice(@rest,0,$cnested);
  my ($cargs,@args) = @rest;
  my $cBytesOutput = pcp3::CchOutput();
  my $start = $cBytesOutput + 1 + $exp_offset - ($cbb > 0? $length - 1:0);
  my $end = $start + $length;
  my $call_length = length("$mname$raw_call");
  my $fname = pcp3::Fname();
  my $old = select;
  my @MEH = pcp3::MacroExpansionHistory();
  if (scalar (@MEH) == 0) {
    add_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
  } else {
    print CPP "EXPANSION HERE of $mname; ", pcp3::SumCchExpansionOffset(), "\n";
  }
  select CPP;

  if ($s_start >= 0) {
    if ($has_escapes == 0) {
      # top level expansion
      $top_level_mname = $mname;
    }
  }

  print "\nexpand_macro $mname = ", pcp3::ExpansionLookup($mname), ", source offset: $s_start - $s_end, $cbuffersDeep [$has_escapes]; ", 
      pcp3::FExpandingMacros(), " in $fname\n";
  print " : expansion of $mname => $expansion (length $length:offset $start - $end [$cBytesOutput + $exp_offset + 1])\n";
#  print " : argof = ", pcp3::ArgOf(), "\n"; FIXGJB obsoleted
  print " : nests = ", join("->",@nests), "\n";
  print " : MEH = ", join("<-",@MEH),"\n";
  chomp $raw_call;
  print " : was \"$mname$raw_call\" with $cargs args, length = ", $call_length, "\n";
  print ": ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  my $state_stack = join(",",pcp3::ParseStateStack());
  print MACEXP_STACKS "$mname: $state_stack\n";
  my $iarg = 0;
# Return values here that look like "@-BAZ" are escape macros (they've been expanded)
  while ($#args > 0) {
    print " :$iarg: ", join(",",splice(@args,0,6)), "\n";
    my $uses = shift @args;
    print " :$iarg used $uses times: ", join(";",splice(@args,0,2*$uses)), "\n";
    $iarg++;
  }
  select $old;
}

sub ifdef_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,@rest) = @_;
  my $start = pcp3::CchOutput()+1;
  my $end = $start + $length - 3; # Subtract off for the @ @, and it's an inclusive range
  print CPP "ifdef_macro $mname => $expansion [$s_start:$s_end] (offset $start - $end)\n";
  my $fname = pcp3::Fname();
}


sub ifdef_lookup_macro {
  my ($mname,$fDefined) = @_;
  print TRACE "ifdef_lookup_macro $mname is ", $fDefined?"":"not ", "defined\n";
  my $fname = pcp3::Fname();
}

sub special_symbol {
  my ($symbol,$enum_node_type) = @_;
  print "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

# FIX: this lines wrong is wrong
sub comment {
  my ($s_start, $s_end, $comment,$how_term,$lines) = @_;
  print "\n-----------------\n";
  print "COMMENT ($lines lines in @{[pcp3::Fname()]} [$s_start:$s_end) ending w/ $how_term: $comment\n";
  print "-----------------\n";
}

sub string_constant {
  my ($s_start, $s_end, $string, $lines) = @_;
  print "String_constant ($lines lines) [$s_start:$s_end]: \"$string\"\n";
}

sub do_include {
  my ($s_start,$s_end,$file_as_given, $file_as_resolved, $flags) = @_;
#  print STDERR "do_include $file_as_given [$s_start:$s_end] -> ", simplify_path_name($file_as_resolved),";  $flags\n";
#  print "Was working on: ", pcp3::Fname(), "\n";
  my $retval = $true;
  if (exists $already_included{$file_as_resolved}) {
    return $false;
  }
  # Mark the file as included in the expansions list
  my $fname = $file_as_resolved;
  if ($fname !~ /^@/) { #ignore @NOTFOUND@ or @REDUNDANT_INCLUDE@ values
    print EXPAND "$fname: FILE_IS_BEING_INCLUDED_GJB_MDE, -1, -1\n";
  }
  $already_included{$file_as_resolved} = $true;
  return $retval;
}

sub do_if {
  my ($s_start,$s_end,$conditional, $skipped, $value, $s_branch_start) = @_;
  print CPP "do_if on $conditional evals to $value ";
  print CPP ", skipping $skipped" if $skipped ne "";
  print CPP "\n";
  my $s_branch_end = pcp3::CchOffset() + 1;
  pcp3::YYPushStackState();
  @state_stack = pcp3::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  print STDERR "Value: $value, conditional: $conditional\n";
  my $fTriviallyFalse = cpp_trivially_false_condition($conditional);
  if ($value == 0 && !$fTriviallyFalse) {
     handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,"If",$conditional);
  } elsif ($fTriviallyFalse) {
    print STDERR "Skipped comment-like conditional: $conditional\n";
  }
  push @got_c_token, 0;
}

sub do_elif {
  my ($s_start,$s_end,$already_did_clause, $conditional, $skipped, $value, $s_branch_start) = @_;
  my $s_branch_end = pcp3::CchOffset() + 1;
  print CPP "do_elif on $conditional ($skipped) evals to $value; $already_did_clause\n";
  if ($value == 0 && $conditional ne "0") {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped);
  }
}

sub handle_unincluded_block {
 # return; # FIXGJB: do not handle these for now
  my ($s_branch_start,$s_branch_end,$skipped,$kind,$conditional) = @_;
  my $fname = pcp3::Fname();
  # FIXGJB: probably better to keep a #include list in perl, and only remove
  # #include-s that we've already done, or something like that;  really
  # need separate symbol tables and hash tables for the different configuration
  # (versioning) structures, but that's quite a bit harder!!
  my $old_skipped = $skipped;
  # be careful not to change the size of the text that we push back -- just
  # turn the include into a comment
  $skipped =~ s/^(\s*\#\s*)include (.*)$/\/\*$1inc $2\*\//mg;
  if ($skipped ne $old_skipped) {
    print CPP "Removed some #include-s from speculative branch\n";
  }
  print CPP "Pushing skipped branch : [[ $skipped ]]\n";
  print CPP ": ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  pcp3::YYPushStackState();
  pcp3::EnterScope();
#  pcp3::PushHashTab();
  $macro_nestings_deep++;
#  print STDERR "s_branch_start = $s_branch_start\n";
  pcp3::PushBuffer($skipped,$s_branch_start);
}

sub do_xifdef {
  my ($s_start,$s_end,$kind,$conditional,$trailing_garbage,$skipped,$fSkipping,$s_branch_start) = @_;
  my $fname = pcp3::Fname();
  my $s_branch_end = pcp3::CchOffset() + 1;
  print CPP "do_xifdef ($kind) on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  print CPP ": @[$s_start - $s_end]\n";
  # This copy is for seeing if parse state changes at endif
  pcp3::YYPushStackState();
  if ($fSkipping) {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,$kind,$conditional);
  }
  push @got_c_token, 0;
}

sub do_ifdef {
  my ($s_start,$s_end,$conditional, $trailing_garbage, $skipped, $fSkipping) = @_;
  print CPP "do_ifdef on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
}

sub do_ifndef {
  my ($s_start,$s_end,$conditional, $trailing_garbage, $skipped, $fSkipping) = @_;
  print CPP "do_ifndef on $conditional [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
}

sub pop_perl_buffer {
  my ($cbb) = @_;
#  print "POP_PERL_BUFFER, $cbb buffers back\n";
#  print ": ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  if (!pcp3::YYFCompareTopStackState()) {
    print TRACE ": NOT Identical!\n";
  }
  pcp3::ExitScope();
#  pcp3::PopHashTab();   #don't do this -- will restore the macro hash table before this definition that we parsed got added
  $macro_nestings_deep--;
  pcp3::YYPopAndRestoreStackState();
  pcp3::YYSetState($state_before_parse_body);
  pcp3::YYSetNode($node_before_parse_body);
#  print STDERR "nbpb: $node_before_parse_body\n";
  $fParsingMacro = $false;
#  print STDERR ": After ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  $current_macro_name = "";
}


sub do_else {
  my ($s_start,$s_end, 
      $orig_conditional, $trailing_garbage, $skipped, $fSkipping, $s_start_branch) = @_;
  my $s_end_branch = pcp3::CchOffset() + 1;
  print CPP "do_else (orig conditional was $orig_conditional) [$trailing_garbage] ($skipped), ",
  !$fSkipping?"Not ":"", "skipped\n";
  @state_stack = pcp3::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  my $fname = pcp3::Fname();
}

sub do_endif {
  my ($s_start,$s_end,$orig_conditional, $trailing_garbage) = @_;
  chomp($trailing_garbage);
  print CPP "do_endif (orig conditional was $orig_conditional) [$trailing_garbage]\n";
  @state_stack = pcp3::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  my $fEqual = pcp3::YYFCompareTopStackState();
  if (!$fEqual) {
    # probably no big deal, but it does mean that the #ifdef does control
    # inclusion of C code (though it could control seeing C code w/o
    # altering the state stack
    print CPP ": STATE_STACK altered by #ifdef/#endif block\n";
  }
  pcp3::YYPopAndDiscardStackState();
  my $controlled_c_source = pop @got_c_token;
  my $fname = pcp3::Fname();
}


sub include_file {
  my ($filename, $fSystemInclude) = @_;
  print "include_file $filename, $fSystemInclude\n";
#  pcp3::YYPushStackState();
}

sub done_include_file {
  my ($filename, $fSystemInclude) = @_;
  # NOTE: $fSystemInclude is always undef due to a bug
  print "done_include_file $filename, $fSystemInclude\n";
#  pcp3::YYPopAndRestoreStackState();
}

# This only gets called for functions actually defined, not those
# just declared with a prototype
sub do_function {
  my ($szName,$fStatic) = @_;
#  print "Function: $szName", $fStatic?" (static)":"", "\n";
  $functions{$szName} = $true;
}

sub do_func_proto {
  my ($szName,$fStatic) = @_;
#  print "FuncProto: $szName", $fStatic?" (static)":"", "\n";
  $functions{$szName} = $true;
}

# sub macro_body_declares_var {
#   my ($body,$var) = @_;
#   return (($body =~ /(\.|->|\bstruct|\bunion)\s*$var\b/) ||
# 	  ($body =~ /\b\Q$var\E\s*(\*\s*)+\)/) ||
# 	  ($body =~ /\b\Q$var\E\s*\(/));
# }


sub do_func_call {
  my ($szName) = @_;
  print "CallFunction: $szName\n";
}


sub macro_cleanup {
  my ($s_start, $s_end, $mname, $cnested, @nests) = @_;
  my $offset  = pcp3::CchOffset();
  my $cbb = pcp3::CbuffersBack();
  my $cbytesOutput = pcp3::CchOutput();
  my $fname = pcp3::Fname();
  my $old = select;
  select CPP;
  my $state_stack = join(",",pcp3::ParseStateStack());
  print EXP_CL "macro_cleanup $mname; [$s_start - $s_end] source $offset, $cbb; output $cbytesOutput\n";
  print EXP_CL " : nests = ", join("->",@nests), "\n";
  print EXP_CL " : MEH = ", join("<-",pcp3::MacroExpansionHistory()),"\n";
  if ($cbb == 1) {
    print EXP_CL "#$fname:(add-text-property $s_start $s_end \'final-exp \"$mname\")\n";
    $top_level_full_expansion = "";
    $top_level_mname = "";
  }
  select $old;
}

# This will get called with some of the built-in definitions, too.
# in particular, I see:
#
# define __ELF__ 1
# define unix 1
# define i386 1
# define linux 1
#
# as the first 4 lines of all *.defgjbmde files
# --12/13/98 gjb

sub cmd_line_def {
  my ($def) = @_;
  print CMDLNDEFS "#define $def\n";
}

# From mde's paren.pm
# Takes a simplified line as its argument; returns a string containing the
# unbalanced parens (empty string if all parens are balanced).
# Perhaps this should also check for braces (and complain or err if any are
# found before parens balance).
sub paren_change ( $ )
{ my ($line) = check_args(1, @_);
  if ($debug_paren) { print "paren_change <= $line\n"; }
  my $result_num = 0;
  my $result_chars = "";
  while ($line =~ /[\(\)]/g)
    { $result_chars .= $MATCH;
      if ($MATCH eq "\(")
	{ $result_num++; }
      elsif ($MATCH eq "\)")
	{ $result_num--; }
      else
	{ die("What match? $MATCH"); } }
  return ($result_num == 0) ? $false : $result_chars;
}

# Not sure whether it would be faster and just as effective to merely check
# for a set of common trivially false conditions, like this used to do.
sub cpp_trivially_false_condition ( $ )
{ my ($cond) = @_;
  if (($cond eq "0") || ($cond =~ /^0\s*&&/))
    { return $true; }
  elsif ($cond =~ /^\(\s*(.*)\s*\)$/)
    { return cpp_trivially_false_condition($1); }
  elsif ($cond =~ /^!\s*1$/)
    { return $true; }
  elsif ($cond =~ /^!\((.*)\)$/)
    { my $negated = $1;
      if (paren_change($negated))
	{ return $false; }
      else
	{ return cpp_trivially_true_condition(negate_cpp_if_condition($cond)); } }
  else
    { return $false; }
}


# Just like the above, with 0 and 1 reversed
sub cpp_trivially_true_condition( $ )
{ my ($cond) = @_;
  if (($cond eq "1") || ($cond =~ /^1\s*\|\|/))
    { return $true; }
  elsif ($cond =~ /^\(\s*(.*)\s*\)$/)
    { return cpp_trivially_true_condition($1); }
  elsif ($cond =~ /^!\s*0$/)
    { return $true; }
  elsif ($cond =~ /^!\((.*)\)$/)
    { my $negated = $1;
      if (paren_change($negated))
	{ return $false; }
      else
	{ return cpp_trivially_false_condition(negate_cpp_if_condition($cond)); } }
  else
    { return $false; }
}



# Add the hooks, now

AddHook("STARTUP",\&Startup);
#AddHook("STARTUP",\&Startup2);
#AddHook("DO_DEFINE",\&do_define);
AddHook("HANDLE_DIRECTIVE",\&handle_directive);
AddHook("CREATE_PREDEF",\&create_predef);
AddHook("CREATE_DEF",\&create_def);
AddHook("DO_UNDEF",\&do_undef);
AddHook("PRE_DO_UNDEF",\&pre_do_undef);
#AddHook("DELETE_DEF",\&delete_def);
#AddHook("CPP_ERROR",\&cpp_error);
#AddHook("CPP_OUT",\&cpp_out);
AddHook("EXPAND_MACRO",\&expand_macro);
#AddHook("MACARG_EXP",\&macro_arg_exp);
#AddHook("MACRO_CLEANUP",\&macro_cleanup);
#AddHook("IFDEF_MACRO",\&ifdef_macro);
#AddHook("IFDEF_LOOKUP_MACRO",\&ifdef_lookup_macro);
#AddHook("SPECIAL_SYMBOL",\&special_symbol);
#AddHook("COMMENT",\&comment);
#AddHook("STRING_CONSTANT",\&string_constant);
AddHook("DO_INCLUDE",\&do_include);
AddHook("DO_IF",\&do_if);
AddHook("DO_ELIF",\&do_elif);
AddHook("DO_XIFDEF",\&do_xifdef);
AddHook("DO_IFDEF",\&do_ifdef);
AddHook("DO_IFNDEF",\&do_ifndef);
AddHook("DO_ELSE",\&do_else);
AddHook("DO_ENDIF",\&do_endif);
#AddHook("ADD_IMPORT",\&add_import);
#AddHook("INCLUDE_FILE",\&include_file);
#AddHook("DONE_INCLUDE_FILE",\&done_include_file);
AddHook("EXIT",\&Exit);
#AddHook("TOKEN",\&Got_token);
#AddHook("TOKEN",\&Got_token2);
#AddHook("FUNCTION",\&do_function);
#AddHook("FUNC_PROTO",\&do_func_proto);
#AddHook("FUNC_CALL",\&do_func_call);
#AddHook("ANNOTATE",\&annotate);
#AddHook("POP_BUFFER",\&pop_buffer);
#AddHook("TYPEDEF",\&do_typedef);
#AddHook("VARDECL",\&do_vardecl);
AddHook("POP_PERL_BUFFER",\&pop_perl_buffer);
AddHook("CMD_LINE_DEF",\&cmd_line_def);


1;
__END__
