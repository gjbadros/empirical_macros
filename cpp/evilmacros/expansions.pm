#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output

use pcp3;
my %macro_name;

sub Startup {
  # Parse debugging (bison's yydebug variable) is on by default,
  # so turn it off
  pcp3::ResetParseDebugging();
  open(VARS,">vars.listing") || die "Cannot open vars.listing: $!";
  open(TYPES,">types.listing") || die "Cannot open types.listing: $!";
  open(EXPAND,">expansions.listing") || die "Cannot open expansions.listing: $!";
  print STDERR "STARTUP...\n";
  $| = 1; # Turn on autoflush
}

sub Exit {
  my ($retval) = @_;
}

sub add_use {
  my ($mname,$fname, $expansion, $s_start, $s_end, $cbb) = @_;
  print EXPAND "$fname: $mname, $s_start, $s_end, $cbb\n";
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
  my $cch_output = pcp3::CchOutput();
  my $cch_offset = pcp3::CchOffset();
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
  my $fname = pcp3::Fname();
  print CPP "pre_do_undef of $mname [$s_start,$s_end]\n";
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
  my $offset  = pcp3::CchOffset();
  my $cbb = pcp3::CbuffersBack();
  my $cbytesOutput = pcp3::CchOutput();
  my $fname = pcp3::Fname();
  my $old = select;
  select CPP;
  my $state_stack = join(",",pcp3::ParseStateStack());
  print "macro_cleanup $mname; [$s_start - $s_end] source $offset, $cbb; output $cbytesOutput\n";
  print " : nests = ", join("->",@nests), "\n";
  print " : MEH = ", join("<-",pcp3::MacroExpansionHistory()),"\n";
  if ($cbb == 1) {
    $top_level_full_expansion =~ s%\n%\\n\\%g;
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'final-exp \"$mname -> $top_level_full_expansion\")\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'stack \"$state_stack\")\n";
    $top_level_full_expansion = "";
    $top_level_mname = "";
  }
  select $old;
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
  }
  select CPP;

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
  if ($s_start >= 0) {
    if ($has_escapes == 0) {
      # top level expansion
      $top_level_mname = $mname;
      print TPSOURCE "#$fname:(put-face-property-if-none $s_start $s_end \'italic)\n";
      print TPSOURCE "#$fname:(put-mouse-face-property-if-none $s_start $s_end \'highlight)\n";
    }
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'exp \"$mname => $expansion\")\n";
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
  print CPP "do_include $file_as_given [$s_start:$s_end] -> ", simplify_path_name($file_as_resolved),";  $flags\n";
#  print "Was working on: ", pcp3::Fname(), "\n";
}

sub do_if {
  my ($s_start,$s_end,$conditional, $skipped, $value) = @_;
  print CPP "do_if on $conditional evals to $value ";
  print CPP ", skipping $skipped" if $skipped ne "";
  print CPP "\n";
  pcp3::YYPushStackState();
  @state_stack = pcp3::ParseStateStack();
  print CPP ": Stack: @state_stack\n";
  if ($value == 0 && $conditional ne "0") {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,"If",$conditional);
  }
  push @got_c_token, 0;
}

sub do_elif {
  my ($s_start,$s_end,$already_did_clause, $conditional, $skipped, $value) = @_;
  print CPP "do_elif on $conditional ($skipped) evals to $value; $already_did_clause\n";
  if ($value == 0 && $conditional ne "0") {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped);
  }
}

sub handle_unincluded_block {
 # return; # FIXGJB: do not handle these for now
  my ($s_branch_start,$s_branch_end,$skipped,$kind,$conditional) = @_;
  my $fname = pcp3::Fname();
  print TPSOURCE "#$fname:(put-face-property-if-none $s_branch_start $s_branch_end \'font-lock-reference-face)\n";
  print TPSOURCE "#$fname:(add-text-property $s_branch_start $s_branch_end \'doc \"Skipped due to $kind $conditional\")\n";
  # FIXGJB: probably better to keep a #include list in perl, and only remove
  # #include-s that we've already done, or something like that;  really
  # need separate symbol tables and hash tables for the different configuration
  # (versioning) structures, but that's quite a bit harder!!
  my $old_skipped = $skipped;
  $skipped =~ s/^\s*\#\s*include .*$//mg;
  if ($skipped ne $old_skipped) {
    print TRACE "Removed some #include-s from speculative branch\n";
  }
  print TRACE "Pushing skipped branch : [[ $skipped ]]\n";
  print TRACE ": ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  pcp3::YYPushStackState();
  pcp3::EnterScope();
  pcp3::PushHashTab();
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
  print CPP "POP_PERL_BUFFER, $cbb buffers back\n";
  print TRACE ": ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
  if (!pcp3::YYFCompareTopStackState()) {
    print TRACE ": NOT Identical!\n";
  }
  pcp3::ExitScope();
  pcp3::PopHashTab();
  pcp3::YYPopAndRestoreStackState();
  print TRACE ": After ParseStateStack: ", join(",",pcp3::ParseStateStack()), "\n";
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
  if ($fSkipping) {
    print TPSOURCE "#$fname:(put-face-property-if-none $s_start_branch $s_end \'font-lock-reference-face)\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"Skipped due to else of $orig_conditional\")\n";
  }
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
  if ($controlled_c_source) {
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"Controls C source inclusion\")\n";
  }
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


sub do_function {
  my ($szName,$fStatic) = @_;
  print "Function: $szName", $fStatic?" (static)":"", "\n";
}

sub do_func_call {
  my ($szName) = @_;
  print "CallFunction: $szName\n";
}

sub do_typedef {
  my ($name) = @_;
  my $offset  = pcp3::CchOffset();
  my $fname = pcp3::Fname();
  print TYPES "Typedef: $fname, $name, $offset\n";
}

sub do_vardecl {
  my ($name) = @_;
  my $offset  = pcp3::CchOffset();
  my $fname = pcp3::Fname();
  print VARS "Vardecl: $fname, $name, $offset\n";
  $vars{$name}++;
}


# Add the hooks, now

AddHook("STARTUP",\&Startup);
#AddHook("STARTUP",\&Startup2);
#AddHook("DO_DEFINE",\&do_define);
#AddHook("HANDLE_DIRECTIVE",\&handle_directive);
#AddHook("CREATE_PREDEF",\&create_predef);
#AddHook("CREATE_DEF",\&create_def);
#AddHook("DO_UNDEF",\&do_undef);
#AddHook("PRE_DO_UNDEF",\&pre_do_undef);
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
#AddHook("DO_INCLUDE",\&do_include);
#AddHook("DO_IF",\&do_if);
#AddHook("DO_ELIF",\&do_elif);
#AddHook("DO_XIFDEF",\&do_xifdef);
#AddHook("DO_IFDEF",\&do_ifdef);
#AddHook("DO_IFNDEF",\&do_ifndef);
#AddHook("DO_ELSE",\&do_else);
#AddHook("DO_ENDIF",\&do_endif);
#AddHook("ADD_IMPORT",\&add_import);
#AddHook("INCLUDE_FILE",\&include_file);
#AddHook("DONE_INCLUDE_FILE",\&done_include_file);
#AddHook("EXIT",\&Exit);
#AddHook("TOKEN",\&Got_token);
#AddHook("TOKEN",\&Got_token2);
#AddHook("FUNCTION",\&do_function);
#AddHook("FUNC_CALL",\&do_func_call);
#AddHook("ANNOTATE",\&annotate);
#AddHook("POP_BUFFER",\&pop_buffer);
AddHook("TYPEDEF",\&do_typedef);
AddHook("VARDECL",\&do_vardecl);
#AddHook("POP_PERL_BUFFER",\&pop_perl_buffer);


1;
__END__
