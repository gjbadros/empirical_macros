#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$
# Requirements:
#   filter-for-file-prefix   --- used for demuxing the textprops output

use pcp3;
use em_constants;
use checkargs;
use File::Basename;

my $fDebug = 1;

my %already_included;

my %func_calls = ();
my %typedefs = ();

my $prefix = "source";
my $expanding = 0;

sub Exit { }

sub do_function {
  my ($szName,$fStatic) = @_;
  if (scalar (keys %func_calls) > 0) {
    print "Function: $szName", $fStatic?" (static) ":"", " calls ";
    print join(", ",sort keys %func_calls), "\n";
  }
}

sub do_func_call {
  my ($szName) = @_;
  print "CallFunction: $szName\n" if $fDebug;
  if ($expanding == 0) {
    $func_calls{$szName} = 1;
    print "\n";
  } 
}

sub do_typedef {
  my ($name) = @_;
  print "Typedef: $name\n" if $fDebug;
  $typedefs{$name} = 1;
}


sub do_func_spec {
  print "Func_spec\n" if $fDebug;
  %func_calls = ();
}

sub expand_macro {
  my ($s_start,$s_end,$mname,$expansion,$length,$raw_call,
      $has_escapes,$cbuffersDeep,@rest) = @_;
  print "Expanding $mname...\n";
  $expanding++;
}

sub macro_cleanup {
  my ($s_start, $s_end, $mname, $cnested, @nests) = @_;
  print "Done expanding $mname.\n";
  warn "Macro_cleanup out of synch" if (--$expanding < 0);
}



AddHook("EXIT",\&Exit);
AddHook("FUNCTION",\&do_function);
AddHook("FUNC_CALL",\&do_func_call);
AddHook("FUNC_SPEC",\&do_func_spec);
AddHook("TYPEDEF",\&do_typedef);
AddHook("EXPAND_MACRO",\&expand_macro);
AddHook("MACRO_CLEANUP",\&macro_cleanup);

1;
__END__
