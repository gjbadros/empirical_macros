#!/uns/bin/perl -w
package em_util;
require 5.003;			# uses prototypes
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( is_number type_name count_macro_args formals_array actuals_array
	      percent2 two_significant_digits
	      sum_array make_cum_array sum_parallel_hashes add_newline
	      simplify_path_name print_lint_summary);

use checkargs;
use em_constants;
use paren;

use strict;
use Carp;
use English;

# Common functions to em_reports and em_analyze
# For determining whether a Perl variable has numeric type.
# This is incredibly disgusting; do something about it.
sub is_number ( $ )
{
  my ($arg) = check_args(1, @_);
  return ($arg =~ /^\d+$/);
}

sub type_name ( $ )
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
sub count_macro_args ( $ ) {
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

# Given a macro argument declaration, return an array of formal names.
sub formals_array ( $ )
{ my ($args) = check_args(1, @_);
  $args =~ s/^\s*\(\s*//;
  $args =~ s/\s*\)\s*$//;
  return split(/\s*,\s*/,$args);
}

# Like formals_array, but works for arbitrary expressions
sub actuals_array ( $ )
{ my ($args) = check_args(1, @_);
  # print "actuals_array <= $args\n";
  if (!($args =~ s/^\s*\(\s*(.*)\)\s*$/$1/))
    { croak "argument to args_array not enclosed in parentheses: $args"; }
  # print "actuals_array (2) <= $args\n";
  if ($args =~ /^\s*$/)
    { return (); }
  my $remaining = $args;
  my @results = ();
  my $this_arg = "";
  while ($remaining =~ /[,\(\{]/)
    { my $pre = $PREMATCH;
      $remaining = $POSTMATCH;
      # print "actuals_array $pre<<$MATCH>>$remaining\n";
      # print "results size = ", scalar(@results), ", this_arg = $this_arg\n";
      if (!defined($remaining))
	{ croak "remaining undefined"; }
      if ($MATCH eq ",")
	{ push(@results, $this_arg . $pre);
	  $this_arg = ""; }
      elsif (($MATCH eq "\(") || ($MATCH eq "\{"))
	{ $this_arg .= $pre . $MATCH;
	  my $close_index = find_close_delimiter($MATCH, $remaining);
	  if ($close_index eq $false)
	    { mdie("No match for $MATCH found in $remaining"); }
	  $this_arg .= substr($remaining, 0, $close_index+1);
	  $remaining = substr($remaining, $close_index+1);
	  if (!defined($remaining))
	    { croak "remaining undefined (2)"; } }
      else
	{ croak "what match? '$MATCH'"; } }
  push(@results, $this_arg . $remaining);
  return @results;
}


# percent2(x) returns a percentage (not a fraction) which corresponds to arg1/arg2.
sub percent2 ( $$ ) {
  my ($x,$w) = check_args(2, @_);
  if ($w <= 0) {
    croak("percent2: Bad divisor: $x / $w");
    return 0;
  }
  if ($x < 0 || $x > $w) {
    print STDERR "percent2: Percentage out of range: $x / $w\n";
  }
  return (100*$x/$w);
}


# Not currently appropriate for values above 100.
sub two_significant_digits ( $ )
{ my ($x) = check_args(1, @_);
  my $result = sprintf "%6.02g", $x;
  $result =~ s/^\s+//;
  # If only one significant digit, fix.
  $result =~ s/^(\d)$/$1.0/;
  $result =~ s/^(0\.0*\d)$/${1}0/;
  return $result;
}

# sum_array sums all its inputs, typically the elements of an array.
# Pass in a slice of the array in order to sum that part.
sub sum_array ( @ ) {
  my (@args) = @_;
  my $sum = 0;
  { foreach my $elt (@args)
      { $sum += $elt if defined $elt; } }
  return $sum;
}

# make_cum_array returns an array that is the running total of the
# elements in the array passed in.
# e.g.     1, 3, 2,  1,  6,  2
# returns  1, 4, 6,  7, 13, 15
sub make_cum_array ( @ ) { # returns @cum_array
  my (@args) = @_;
  my @cum_array = ();
  my $sum = 0;
  foreach my $elt (@args) {
    $sum += $elt if defined $elt;
    push @cum_array, $sum;
  }
  return @cum_array;
}


# Sum corresponding elements of an array (or array slice)
# into the destination reference provided
sub sum_parallel_hashes { # returns void; output in $_[0]
  my ($dest_hashref,@array_of_hash_refs) = check_args_at_least(1,@_);
  no strict 'refs';  #FIX: Must I do this?
  foreach my $hashref (@array_of_hash_refs) {
    foreach my $key (keys %{$hashref}) {
      if (!defined($dest_hashref->{$key})) {
	# print STDERR "UNDEF: $key\n";
	$dest_hashref->{$key} = 0;
      }
      $dest_hashref->{$key} += $hashref->{$key};
    }
  }
  return;
}



# Add newline to end of string; return string unchanged if it already has one.
sub add_newline ( $ )
{ my ($string) = check_args(1, @_);
  if ($string =~ m/\n$/)
    { return $string; }
  else
    { return $string . "\n"; }
}


# Simplify a directory path by canonicalizing to not contain
# any ".." or "." components
# e.g.  simplify_path_name("./bink/baz/foo/../foo2/../../bar") is
#       "./bink/bar"
sub simplify_path_name ( $ ) {
  my ($path) = @_;
  my $result = $path;
  while (($result =~ s%/[^/\n]*/\.\./%/%) && $result ne $path) {
    $path = $result;
  }
  while (($result =~ s%//%/%g) && $result ne $path) {
    $path = $result;
  }
  return $result;
}


###########################################################################
### Lint output
###

# Not the right place for this, but I want to share it between em_reports
# and lint-summarize.

sub print_lint_summary ( $$$$$$$$$$$$$;$ )
{
  my ($different_arity, $null_body, $newline_body, $unparen_body,
      $swallow_semi, $free_var, $formal_name, $formal_mult_use,
      $formal_adjacent_use, $formal_unparen_use, $formal_modified,
      $macros, $defs, $packages)
    = check_args_range(13, 14, @_);

  print "\n\n";
  print "Excluding libraries, $macros macros defined $defs times"
    , (defined($packages) ? " in $packages packages" : ""), "\n";
  print "$different_arity\t("
    . sprintf("%2.4f",percent2($different_arity,$macros))
      . "%) inconsistent arity\n";
  print "$null_body\t("
    . sprintf("%2.4f",percent2($null_body,$defs))
      . "%) null body with args\n";
  print "$newline_body\t("
    . sprintf("%2.4f",percent2($newline_body,$defs))
      . "%) contains newline\n";
  print "$unparen_body\t("
    . sprintf("%2.4f",percent2($unparen_body,$defs))
      . "%) unparenthesized body\n";
  print "$swallow_semi\t("
    . sprintf("%2.4f",percent2($swallow_semi,$defs))
      . "%) doesn't swallow semicolon\n";
  print "$free_var\t("
    . sprintf("%2.4f",percent2($free_var,$defs))
      . "%) free variables\n";
  print "$formal_name\t("
    . sprintf("%2.4f",percent2($formal_name,$defs))
      . "%) bad formal name\n";
  print "$formal_mult_use\t("
    . sprintf("%2.4f",percent2($formal_mult_use,$defs))
      . "%) multiple formal uses\n";
  print "$formal_adjacent_use\t("
    . sprintf("%2.4f",percent2($formal_adjacent_use,$defs))
      . "%) adjacent formal uses\n";
  print "$formal_unparen_use\t("
    . sprintf("%2.4f",percent2($formal_unparen_use,$defs))
      . "%) unparenthesized formal uses\n";
  print "$formal_modified\t("
    . sprintf("%2.4f",percent2($formal_modified,$defs))
      . "%) side-effected formal\n";
}


1; #Successful import
__END__
