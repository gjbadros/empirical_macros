#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$

use pcp3; use em_constants;

my $fDebug = 0;
my %func_calls = ();

AddHook("FUNCTION",\&do_function);
AddHook("FUNC_CALL",\&do_func_call);
AddHook("FUNC_SPEC",\&do_func_spec);

sub do_function { my ($szName,$fStatic) = @_;
  if (scalar (keys %func_calls) > 0) {
    print "$szName", $fStatic?" (static)":"", " calls ", 
          join(", ",sort keys %func_calls), "\n";
  }
}

sub do_func_call { $func_calls{$_[0]} = 1; }

sub do_func_spec { %func_calls = (); }

1;
