#!/uns/bin/perl -w
# $Id$ -*- perl -*-
# partial-expand.pl
# Greg Badros
# <gjb@cs.washington.edu>
# Seattle, WA  USA
# http://www.cs.washington.edu/homes/gjb

require 5.000;
#use strict;
#use Carp;

#require Exporter;
#@ISA = qw(Exporter);
#@EXPORT = qw();

# Perl uses $PERLLIB environment variable, by default
#BEGIN { if (defined $ENV{"PERLINC"})
#	  { unshift(@INC, split(/[ :]+/, $ENV{"PERLINC"})); } }

my $getopts_option_letters = 'h';
use vars qw($opt_h);

sub usage ( ) {
  die "@_
Usage: $0 [-$getopts_option_letters]
-h     Help. Display this usage information
ENTER USAGE INFO HERE
";
}

use Getopt::Std;
getopts($getopts_option_letters);
usage() if ($opt_h);

# Main routine




__END__

=head1 NAME

partial-expand.pl -- Evaluate #if(def) conditionals and output the version of code constrained by given #defined macros

=head1 SYNOPSIS

=head1 DESCRIPTION

I<Disclaimer: You choose to use this script at your own risk!>

=over 4

=item

=item

=back

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

=head1 AUTHOR

Greg Badros <F<<gjb@cs.washington.edu>>>

=cut
