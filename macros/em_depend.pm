#!/uns/bin/perl -w

package em_depend;
require 5.003;			# uses prototypes
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
  save_dependence_state
	     );
use strict;			# must follow uses of @ISA, @EXPORTER
use checkargs;
use em_constants;

###########################################################################


sub save_dependence_state ( $% )
{ my ($file, %namevalhash) = check_args_at_least(1, @_);
  open(DEPSTATE, ">$file") or die "Can't open $file: $!";
  select(DEPSTATE);
  print "\# -*- Perl -*-\n";
  for my $varname (sort keys %namevalhash)
    { my %hash = %{$namevalhash{$varname}};
      dump_dependenton($varname, %hash); }
  close(DEPSTATE);
}



sub dump_dependenton ( $% )
{ my ($hash_name, %hash) = check_args_at_least(1, @_);
  print "$hash_name = (";
  my @keys = keys %hash;
  if (scalar(@keys) > 0)
    { my $first = $true;
      for my $key (sort @keys)
	{ if ($first)
	    { $first = $false; }
	  else
	    { print ","; }
	  print "\n  ";
	  # This test works, but when reading the file via "do", we get
	  # warnings because the unquoted strings may be ambiguous.
	  # ($key =~ /^[_a-zA-Z][_a-zA-Z0-9]*$/)
	  if ($key =~ /^\d+$/)
	    { print $key; }
	  else
	    { print "'$key'"; }
	  print " => ";
	  dump_hashset(2, %{$hash{$key}});
	}
      print "\n";
    }
  print ");\n";
}

# Prints from "{" to "}", but no leading or trailing newline.  $indent is
# the indentation of the hash itself; its elements are 2 spaces further
# indented.
sub dump_hashset ( $% )
{ my ($indent, %hash) = check_args_at_least(1, @_);
  print "{";
  my @keys = keys %hash;
  if (scalar(@keys) > 0)
    { my $first = $true;
      for my $key (sort @keys)	# sort to make output comparisons easier
	{ if ($first)
	    { $first = $false; }
	  else
	    { print ","; }
	  if ($hash{$key} ne '1')
	    { die "hashset val $hash{$key} should have been '1'"; }
	  print "\n" . " " x $indent . "  ";
	  # This test works, but when reading the file via "do", we get
	  # warnings because the unquoted strings may be ambiguous.
	  # ($key =~ /^[_a-zA-Z][_a-zA-Z0-9]*$/)
	  if ($key =~ /^\d+$/)
	    { print $key; }
	  else
	    { print "'$key'"; }
	  # If we don't want consistency with Data::Dumper, use a real number
	  # print " => '1'";
	  print " => 1";
	}
      print "\n" . " " x $indent; }
  print "}";
}
