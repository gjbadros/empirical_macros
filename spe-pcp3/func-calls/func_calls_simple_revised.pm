#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$

use pcp3;
my %func_calls = (); my $expanding = 0;

AddHook("FUNCTION",\&do_function);
AddHook("FUNC_SPEC", sub { %func_calls = (); });
AddHook("FUNC_CALL", sub { $func_calls{$_[0]} = 1 if !$expanding; } );
AddHook("EXPAND_MACRO", sub { $expanding++; $func_calls{$_[2]} = 1; });
AddHook("MACRO_CLEANUP", sub { --$expanding; };

sub do_function { my ($szName) = @_;
  if (scalar (keys %func_calls) > 0) {
    print "$szName calls ", join(", ",sort keys %func_calls), "\n";
  }
}

1;
