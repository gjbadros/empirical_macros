#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output

use pcp3;
my %macro_name;

# got_c_token array tracks whether we have gotten c tokens
# in this ifdef group
my @got_c_token;
my @s_start_ifdefs;
my @s_end_ifdefs;


sub Startup {
  open(MAPPING,">mapping") || die "Could not open output file: $!";
  print MAPPING "(setq char-mapping (list\n";
  open(TP,">textprops.el") || die "Could not open output file: $!";
  open(TPSOURCE,">textprops-source.el") || die "Could not open output file: $!";
  $| = 1; # Turn on autoflush
}

sub Exit {
  my ($retval) = @_;
  close(TP);
  close(TPSOURCE);
  print MAPPING "))\n";
  close(MAPPING);
}

sub do_define {
  my ($s_start,$s_end,$name_args_body) = @_;
  my $fname = pcp3::Fname();
  PutFaceProperty($fname,$s_start,$s_end,"font-lock-type-face");
}


sub add_use {
  my ($mname,$fname, $expansion, $s_start, $s_end, $cbb) = @_;
  push @{$macro_uses{$mname}}, [$fname, $s_start, $s_end, $expansion, $cbb];
  print TRACE "add_use for $mname ($cbb), now at ", $#{$macro_uses{$mname}} + 1, "\n";
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
    my $fname = pcp3::InFname();
    if ($all_same_expansions == FALSE) {
      annotate_definition_message($mname,'xform',
				  "Expansions vary, not a constant in $fname");
    } elsif ($cUses > 0) {
      annotate_definition_message($mname,'expsumm',
				  "Expansions all go to $expansion in $fname");
      if (scalar(@{$macro_name{$mname}{defs}}) > 1) {
	annotate_all_definitions_message($mname,'xform',"Multiple definitions!");
      } elsif ($expansion =~ m/^(0x)?\d+$/) {
	my $new_var = $mname;
	$new_var =~ tr/[A-Z]/[a-z]/;
	# Name conflict?
	if (exists $vars{$new_var}) {
	  # try falling back to no name change
	  if (exists $vars{$mname}) {
	    # Can't even leave the name alone
	    $new_var = "";
	  } else {
	    $new_var = $mname;
	  }
	} else {
	  # No conflict, so do a substitution, too
	  annotate_definition_message($mname,'substexpn',"$new_var");
	}
	if ($new_var ne "") {
	  #FIXGJB: do not always use enum!
	  annotate_definition_message($mname,'subst',"enum {$new_var = $expansion};");
	}
      }
    } else {
      annotate_definition_message($mname,'expsumm',"No uses in $fname");
    }
  }
}

sub create_def {
  my ($s_start, $s_end, $mname, $expn, $nargs, $simp_expn, $file, $line,
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  my $fname = pcp3::Fname();
  print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'def \"$mname defined [$s_start:$s_end]\")\n";
  push @{$macro_name{$mname}{defs}}, [ $fname, $s_start,$s_end ];
  @{$macro_name{$mname}{currdef}} = ( $fname, $s_start,$s_end );
}

sub create_predef {
  my ($name, $expn, $nargs, $simp_expn, $file, $line, 
      $backward_argnames_string, $def_flags,
      @currpat) = @_;
  my $old = select;
  select CPP;
  @argnames = reverse split (/, /,$backward_argnames_string);
}

sub cpp_out { my ($sz) = @_;
  my $cch_output = pcp3::CchOutput();
  my $cch_offset = pcp3::CchOffset();
  print MAPPING "'($cch_offset . $cch_output)\n";
  if ($top_level_mname ne "") {
    $top_level_full_expansion .= $sz;
  }
}


sub pre_do_undef { my ($s_start,$s_end,$mname) = @_;
  my $fname = pcp3::Fname();
  annotate_definition_with_undef($mname,$fname,$s_start,$s_end);
}

sub macro_cleanup {
  my ($s_start, $s_end, $mname, $cnested, @nests) = @_;
  my $offset  = pcp3::CchOffset();
  my $cbb = pcp3::CbuffersBack();
  my $cbytesOutput = pcp3::CchOutput();
  my $fname = pcp3::Fname();
  my $state_stack = join(",",pcp3::ParseStateStack());
  if ($cbb == 1) {
    $top_level_full_expansion =~ s%\n%\\n\\%g;
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'final-exp \"$mname -> $top_level_full_expansion\")\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'stack \"$state_stack\")\n";
    $top_level_full_expansion = "";
    $top_level_mname = "";
  }
}

sub annotate_definition_message { my ($mname, $prop, $message) = @_;
  my ($fnamedef, $s_start, $s_end) = @{$macro_name{$mname}{currdef}};
  if (defined($fnamedef)) {
    print TPSOURCE "#$fnamedef:(add-text-property $s_start $s_end \'$prop \"$message\")\n";
  }
}

sub annotate_all_definitions_message {
  my ($mname, $prop, $message) = @_;
  my @definitions = @{$macro_name{$mname}{defs}};
  foreach my $aref (@definitions) {
    my ($fnamedef, $s_start, $s_end) = @$aref;
    if (defined($fnamedef)) {
      print TPSOURCE "#$fnamedef:(add-text-property $s_start $s_end \'$prop \"$message\")\n";
    }
  }
}

sub annotate_definition_message_marker {
  my ($mname, $prop, $message, $fname, $s, $e) = @_;
  my ($fnamedef, $s_start, $s_end) = @{$macro_name{$mname}{currdef}};
  if (defined($fnamedef)) {
    print TPSOURCE "#$fnamedef:(add-list-marker-property $s_start $s_end \'$prop \"$message\" \"$fname\" $s $e)\n";
  }
}

sub annotate_definition_with_use {
  my ($mname, $expansion, $fname, $s, $e, $cbb) = @_;
  if ($cbb == 0) {
    # Use appearing in the source code
    annotate_definition_message_marker($mname,'use',$expansion,$fname,$s,$e);
  } else {
    annotate_definition_message($mname,'expuse',"$expansion [$cbb]");
  }
}

sub annotate_definition_with_ifdef_use {
  my ($mname,$fname,$expansion,$s_start,$s_end,$cbb) = @_;
  annotate_definition_message_marker($mname,'ifdefuse',"$expansion [$cbb]",$fname,$s_start,$s_end);
  annotate_definition_message($mname,'xform',"Used in a ccd! Do not convert!");
}

sub annotate_definition_with_undef {
  my ($mname,$fname,$s_start,$s_end) = @_;
  annotate_definition_message($mname,'xform',"Undef-fed");
  annotate_definition_message_marker($mname,'undef',"Undef-fed",$fname,$s_start,$s_end);
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
  my @MEH = pcp3::MacroExpansionHistory();
  if (scalar (@MEH) == 0) {
    annotate_definition_with_use($mname,$expansion,$fname,$s_start,$s_end,$cbuffersDeep);
    add_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
  }
  my $state_stack = join(",",pcp3::ParseStateStack());
  print MACEXP_STACKS "$mname: $state_stack\n";
  my $iarg = 0;
  if ($s_start >= 0) {
    if ($has_escapes == 0) {
      # top level expansion
      $top_level_mname = $mname;
      print TPSOURCE "#$fname:(put-face-property-if-none $s_start $s_end \'italic)\n";
      print TPSOURCE "#$fname:(put-mouse-face-property-if-none $s_start $s_end \'highlight)\n";
    }
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'exp \"$mname => $expansion\")\n";
  }
}

sub ifdef_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,$has_escapes,$cbuffersDeep,@rest) = @_;
  my $start = pcp3::CchOutput()+1;
  my $end = $start + $length - 3; # Subtract off for the @ @, and it's an inclusive range
  my $fname = pcp3::Fname();
  annotate_definition_with_ifdef_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep);
}


sub ifdef_lookup_macro { my ($mname,$fDefined) = @_;
  print TRACE "ifdef_lookup_macro $mname is ", $fDefined?"":"not ", "defined\n";
  my $fname = pcp3::Fname();
  annotate_definition_with_ifdef_use($mname,$fname,$fDefined?"\@DEFINED\@":"\@NOT_DEFINED\@",
				    pcp3::CchOffset()-length($mname),pcp3::CchOffset);
}

sub special_symbol { my ($symbol,$enum_node_type) = @_;
  print CPP "special_symbol $symbol => $node_type_name[$enum_node_type]\n";
}

sub do_if {
  my ($s_start,$s_end,$conditional, $skipped, $value) = @_;
  pcp3::YYPushStackState();
  @state_stack = pcp3::ParseStateStack();
  if ($value == 0 && $conditional ne "0") {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,"If",$conditional);
  }
  push @got_c_token, 0;
}

sub do_elif {
  my ($s_start,$s_end,$already_did_clause, $conditional, $skipped, $value) = @_;
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
  pcp3::YYPushStackState();
  pcp3::EnterScope();
  pcp3::PushHashTab();
  pcp3::PushBuffer($skipped,$s_branch_start);
}

sub do_xifdef {
  my ($s_start,$s_end,$kind,$conditional,$trailing_garbage,$skipped,$fSkipping,$s_branch_start) = @_;
  my $fname = pcp3::Fname();
  my $s_branch_end = pcp3::CchOffset() + 1;
  # This copy is for seeing if parse state changes at endif
  pcp3::YYPushStackState();
  if ($fSkipping) {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,$kind,$conditional);
  }
  push @got_c_token, 0;
}

sub pop_perl_buffer {
  my ($cbb) = @_;
  pcp3::ExitScope();
  pcp3::PopHashTab();
  pcp3::YYPopAndRestoreStackState();
}


sub do_else {
  my ($s_start,$s_end, 
      $orig_conditional, $trailing_garbage, $skipped, $fSkipping, $s_start_branch) = @_;
  my $s_end_branch = pcp3::CchOffset() + 1;
  my $fname = pcp3::Fname();
  if ($fSkipping) {
    print TPSOURCE "#$fname:(put-face-property-if-none $s_start_branch $s_end \'font-lock-reference-face)\n";
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"Skipped due to else of $orig_conditional\")\n";
  }
}

sub do_endif {
  my ($s_start,$s_end,$orig_conditional, $trailing_garbage) = @_;
  chomp($trailing_garbage);
  @state_stack = pcp3::ParseStateStack();
  my $fEqual = pcp3::YYFCompareTopStackState();
  pcp3::YYPopAndDiscardStackState();
  my $controlled_c_source = pop @got_c_token;
  my $fname = pcp3::Fname();
  if ($controlled_c_source) {
    print TPSOURCE "#$fname:(add-text-property $s_start $s_end \'doc \"Controls C source inclusion\")\n";
  }
}

# Token's come a lot, so redirect this output somewhere else
sub Got_token {
  my ($token,$raw,$mname,$argno,@history) = @_;
  my @nests = pcp3::MacroExpansionHistory();
  my $fname = pcp3::Fname();
  my $end = pcp3::CchOutput()+1;
  my $start = $end-length($raw);
#  @history = @nests;  FIXGJB: this is a hack, since stuff not getting passed
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

# Add the hooks, now

AddHook("STARTUP",\&Startup);
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
AddHook("TYPEDEF",\&do_typedef);
AddHook("VARDECL",\&do_vardecl);
AddHook("POP_PERL_BUFFER",\&pop_perl_buffer);


1;
__END__
