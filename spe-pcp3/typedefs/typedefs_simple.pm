#!/uns/bin/perl -w -I/scratch/gjb/cpp/xs/cpp/blib/arch -I/scratch/gjb/cpp/xs/cpp/blib/lib -I/scratch/gjb/cpp -I/homes/gws/gjb/macros
#$Id$

use pcp3;

my $fDebug = 0; my %typedefs = ();

AddHook("TYPEDEF",sub { $typedefs{$_[0]} = 1; });
AddHook("EXIT",sub { print join(", ", (sort keys %typedefs)); });

1;
