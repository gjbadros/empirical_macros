#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output

use pcp3;
use em_constants;
use checkargs;
use File::Basename;

my %already_included;

my $prefix = "source";

sub Startup { my ($source_file) = @_;
  $prefix = basename($source_file,".c") if ($source_file !~ /@/);
  open(EXPAND,">$prefix.exps") || die "Cannot open $prefix.exps: $!";
  $| = 1; # Turn on autoflush
}

sub Exit { system("touch $prefix.o"); }

sub add_use { my ($mname,$fname, $expansion, $s_start, $s_end, $cbb) = @_;
  print EXPAND "$fname: $mname, $s_start, $s_end\n" if ($cbb <= 1);
}

sub expand_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,
      $raw_call,$has_escapes,$cbuffersDeep,@rest) = @_;
  my $fname = pcp3::Fname();
  add_use($mname,$fname,$expansion,$s_start,$s_end,$cbuffersDeep) if (scalar (@MEH) == 0);
}

sub do_include {
  my ($s_start,$s_end,$file_as_given, $file_as_resolved, $flags) = @_;
  return $false if (exists $already_included{$file_as_resolved});
  my $fname = $file_as_resolved;
  print EXPAND "$fname: FILE_IS_BEING_INCLUDED_GJB_MDE, -1, -1\n" if ($fname !~ /^@/);
  $already_included{$file_as_resolved} = $true;
  return $true;
}

sub do_if {
  my ($s_start,$s_end,$conditional, $skipped, $value, $s_branch_start) = @_;
  my $s_branch_end = pcp3::CchOffset() + 1;
  pcp3::YYPushStackState();
  if ($value == 0 && $conditional ne "0") {
     handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,"If",$conditional);
  }
}

sub do_elif {
  my ($s_start,$s_end,$already_did_clause, $conditional, $skipped, $value, $s_branch_start) = @_;
  my $s_branch_end = pcp3::CchOffset() + 1;
  if ($value == 0 && $conditional ne "0") {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped);
  }
}

sub handle_unincluded_block {
  my ($s_branch_start,$s_branch_end,$skipped,$kind,$conditional) = @_;
  $skipped =~ s/^\s*\#\s*include .*$//mg;
  pcp3::YYPushStackState();
  pcp3::EnterScope();
  pcp3::PushBuffer($skipped,$s_branch_start);
}

sub do_xifdef {
  my ($s_start,$s_end,$kind,$conditional,$trailing_garbage,$skipped,$fSkipping,$s_branch_start) = @_;
  my $s_branch_end = pcp3::CchOffset() + 1;
  pcp3::YYPushStackState();
  if ($fSkipping) {
    handle_unincluded_block($s_branch_start,$s_branch_end,$skipped,$kind,$conditional);
  }
}

sub pop_perl_buffer { my ($cbb) = @_;
  pcp3::ExitScope();
  pcp3::YYPopAndRestoreStackState();
  pcp3::YYSetState(0);
  pcp3::YYSetNode(0);
}

sub do_endif { my ($s_start,$s_end,$orig_conditional, $trailing_garbage) = @_;
  pcp3::YYPopAndDiscardStackState();
}

AddHook("STARTUP",\&Startup);
AddHook("EXPAND_MACRO",\&expand_macro);
AddHook("DO_INCLUDE",\&do_include);
AddHook("DO_IF",\&do_if);
AddHook("DO_ELIF",\&do_elif);
AddHook("DO_XIFDEF",\&do_xifdef);
AddHook("DO_ENDIF",\&do_endif);
AddHook("EXIT",\&Exit);
AddHook("POP_PERL_BUFFER",\&pop_perl_buffer);

1;
__END__
