#!/uns/bin/perl -w
package em_util;
require 5.002;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( is_number type_name count_macro_args );


use checkargs;
use em_constants;

# Common functions to em_reports and em_analyze
# For determining whether a Perl variable has numeric type.
# This is incredibly disgusting; do something about it.
sub is_number ($)
{
  my ($arg) = check_args(1, @_);
  return ($arg =~ /^\d+$/);
}

sub type_name ($)
{
  my ($type) = check_args(1, @_);
  if (is_number($type))
    { return $type_name_array[$type]; }
  else
    { return $type; }
}

# Return the number of arguments, given a macro argument
# declaration.  Just counts number of commas, and adds 1,
# or zero if we were passed "".
sub count_macro_args ($) {
  my ($arg_decl) = check_args(1, @_);
  my $retval;

  if ($arg_decl eq "") {
    $retval = 0;
  } else {
    # count the number of commas, by substituting commas for themselves
    # (tr returns the number of deletions or substitutions)
    $retval = ($arg_decl =~ tr/,/,/d) + 1;
  }
  #print STDERR "count_macro_args: $retval for $arg_decl\n";
  return $retval;
}

1; #Successful import
__END__
