#!/uns/bin/perl

package checkargs;
require 5.000;
require Exporter;
@ISA = (Exporter);
@EXPORT = qw(check_args check_args_range check_args_at_least);
use strict;

=head1 NAME

checkargs -- Provide rudimentary argument checking for perl5 functions

=head1 SYNOPSIS

  check_args(cArgsExpected, szFunctionName, caller, @_)
  check_args_range(cArgsMin, cArgsMax, szFunctionName, caller, @_)
  check_args_at_least(cArgsMin, szFunctionName, caller, @_)
where "caller" and "@_" should be supplied literally.

As the first line of user-written subroutine foo, do one of the following:

  my ($arg1, $arg2) = check_args(2, "foo", caller, @_);
  my ($arg1, @rest) = check_args_range(1, 4, "foo", caller, @_);
  my ($arg1, @rest) = check_args_at_least(1, "foo", caller, @_);
  my @args = check_args_at_least(0, "foo", caller, @_);

These functions may also be called for side effect (put a call to one
of the functions near the beginning of the subroutine), but using the
argument checkers to set the argument list is the recommended usage.

The number of arguments and their definedness are checked.

=head1 DESCRIPTION

I<check_args> and I<check_args_range> simply report if it received the wrong
number of arguments to a function.  They will die with a message
listing a brief description of the situation.

=head1 AUTHOR

Michael D. Ernst <F<mernst@cs.washington.edu>>

=cut

# A sample call:   check_args(2, "parse_declarator", caller, @_);
# The last two arguments should always be "caller" and "@_";
# Maybe have this return the arglist, so it can be merged in with the my line???

sub check_args
{
  my ($num_formals, $function_name, $package, $filename, $line, @args) = @_;
  if (@_ < 5) { die "check_args needs at least 5 args, got: @_\n"; }
  if ((!wantarray) && ($num_formals != 0))
    { ($package, $filename, $line) = caller;
      die "check_args called in scalar context by $function_name at $filename line $line: @args\n"; }
  my $num_actuals = @args;
  if ($num_actuals != $num_formals)
    { die "function $function_name expected $num_formals argument",
      ($num_formals == 1) ? "" : "s",
      ", got $num_actuals at $filename line $line",
      ($num_actuals == 0) ? "" : ": @args", "\n"; }
  my $index;
  for $index (0..$#args)
    { if (!defined($args[$index]))
	{ die "function $function_name undefined argument ", $index+1, " at $filename line $line: @args\n"; } }
  return @args;
}

sub check_args_range
{
  my ($min_formals, $max_formals, $function_name, $package, $filename, $line, @args) = @_;
  if (@_ < 6) { die "check_args_range needs at least 6 args, got: @_\n"; }
  if ((!wantarray) && ($max_formals != 0) && ($min_formals !=0) )
    { ($package, $filename, $line) = caller;
      die "check_args_range called in scalar context at $filename line $line: @args\n"; }
  my $num_actuals = @args;
  if (($num_actuals < $min_formals) || ($num_actuals > $max_formals))
    { die "function $function_name expected $min_formals-$max_formals arguments, got $num_actuals at $filename line $line",
      ($num_actuals == 0) ? "" : ": @args", "\n"; }
  my $index;
  for $index (0..$#args)
    { if (!defined($args[$index]))
	{ die "function $function_name undefined argument ", $index+1, " at $filename line $line: @args\n"; } }
  return @args;
}

sub check_args_at_least
{
  my ($min_formals, $function_name, $package, $filename, $line, @args) = @_;
  # Don't do this, because we want every sub to start with a call to check_args*
  # if ($min_formals == 0)
  #   { die "Isn't it pointless to check for at least zero args to $function_name?\n"; }
  if (@_ < 6) { die "check_args_at_least needs at least 6 args, got: @_\n"; }
  if ((!wantarray) && ($min_formals != 0))
    { ($package, $filename, $line) = caller;
      die "check_args_at_least called in scalar context at $filename line $line: @args\n";
    }
  my $num_actuals = @args;
  if ($num_actuals < $min_formals)
    { die "function $function_name expected at least $min_formals argument",
      ($min_formals == 1) ? "" : "s",
      ", got $num_actuals at $filename line $line",
      ($num_actuals == 0) ? "" : ": @args", "\n"; }
  my $index;
  for $index (0..$#args)
    { if (!defined($args[$index]))
	{ die "function $function_name undefined argument ", $index+1, " at $filename line $line: @args\n"; } }
  return @args;
}

1;				# successful import
__END__
