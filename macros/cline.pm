#!/uns/bin/perl

package cline;
require 5.000;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(get_spliced_cline get_spliced_cline_maybe_ungot get_fulltoken_cline
	     peek_fulltoken_cline
	     cline_simplify
	     cline_resetinvars cline_ungot_string cline_ungot_size cline_ungot_phys_lines
	     $cline_simplify_strings $debug_cline);
use checkargs;
use strict;
use Carp;
use English;

=head1 NAME

cline -- Read physical, logical, or full-token lines from C program files

=head1 SYNOPSIS

  get_spliced_cline(filehandle, opt_cpp_comment)
  get_spliced_cline_maybe_ungot(filehandle, opt_cpp_comment)
  get_fulltoken_cline(filehandle)
  peek_fulltoken_cline(filehandle, distance_fwd)
  cline_resetinvars()
  cline_ungot_string()
  cline_ungot_size()
  cline_ungot_phys_lines()
  cline_simplify(line)
  $cline_simplify_strings
  $debug_cline

=head1 DESCRIPTION

I<get_spliced_cline>, I<get_fulltoken_cline>, and I<peek_fulltoken_cline>
all return a five-element list of (raw_line, simplified_line,
num_phys_lines, num_ncnb_lines, warnings), where warnings is a reference to
an array of strings.  The optional argument to I<get_spliced_cline> causes
it not to track comments or strings.  This permits processing of
non-syntactic C code which is often found in CPP comments of the form "#if
0 ... #endif".

I<cline_resetinvars> is used for abandoning internal state changes made by
I<get_spliced_cline>, for example when end of file is unexpectedly
encountered.

=head1 AUTHOR

Michael D. Ernst <F<mernst@cs.washington.edu>>

=cut


###########################################################################
### To do
###
###

# Not sure whether I should export cline_updateinvars.  Maybe have a
# separate version for simplification; but when should simplification ever
# be necessary?


###########################################################################
### Variables
###

### Internal

my $true = (1 == 1);
my $false = (1 == 0);

# Copied from em_analyze
my $char_literal_contents_re = '(\\\\?.|\\\\[0-7]{3})';
my $non_escaped_double_quote_re = '(^|[^\\\\])(\\\\\\\\)*\"';

use vars qw($cline_incomment $cline_instring);
$cline_incomment = $false;		# in /* */ style comment
$cline_instring = $false;

sub cline_resetinvars ()
{
  check_args(0, @_);
  $cline_instring = $false;
  $cline_incomment = $false;
}

my @cline_ungot_raw_lines = ();
my @cline_ungot_simple_lines = ();
my @cline_ungot_phys_lines = ();
my @cline_ungot_ncnb_lines = ();
my @cline_ungot_warnings = ();	# a list of references to lists of strings

sub cline_check_ungot_sizes ()
{ check_args(0, @_);
  if ((@cline_ungot_raw_lines != @cline_ungot_simple_lines)
      || (@cline_ungot_raw_lines != @cline_ungot_phys_lines)
      || (@cline_ungot_raw_lines != @cline_ungot_ncnb_lines)
      || (@cline_ungot_raw_lines != @cline_ungot_warnings))
    { croak ("Unequal ungot_* sizes ",
	     scalar(@cline_ungot_raw_lines), " ",
	     scalar(@cline_ungot_simple_lines), " ",
	     scalar(@cline_ungot_phys_lines), " ",
	     scalar(@cline_ungot_phys_lines), " ",
	     scalar(@cline_ungot_warnings)); }
}

sub cline_ungot_string ()
{ check_args(0, @_);
  "ungot raw: ".  join("  >>", @cline_ungot_raw_lines)
    . "ungot simple: " . join("  >>", @cline_ungot_simple_lines);
}

sub cline_ungot_size ()
{ check_args(0, @_);
  cline_check_ungot_sizes();
  scalar(@cline_ungot_raw_lines);
}

sub cline_ungot_phys_lines ()
{ check_args(0, @_);
  my $result = 0;
  { foreach my $phys (@cline_ungot_phys_lines)
      { $result += $phys; } }
  return $result;
}


### Exported

# Don't declare with "my" because can be dynamically bound
use vars qw($cline_simplify_strings $debug_cline);

$debug_cline = $false;
# $debug_cline = $true;
# If $cline_simplify_strings is set, then character and string literals are
#   replaced by 'a' and "" respectively.  That lets us do a simple
#   syntactic check for parens, braces, commas, etc.
$cline_simplify_strings = $false;


###########################################################################
### Determination of whether in string, whether in comment
###

# cline_updateinvars is called on a *physical* line;
#   backslash line continuations have not been processed.

# Update the values of $cline_incomment and $cline_instring based on a new
# physical line.

# Returns: (simplified string, num_ncnb_lines, warnings)
#  * The simple result contains no comments, and its strings and character
#    constants are simplified if $cline_simplify_strings (which see) is true.
# I hope that always simplifying isn't terribly inefficient...
sub cline_updateinvars ($)
{
  my ($remaining) = check_args(1, @_);
  my $result = "";
  my $seen_ncnb = 0;		# not a boolean, but 0 or 1 (like a boolean)
  my $simple_char = "'~'";	# not 'a' because we'd identify it as a macro
  my $warnings = [];

  if ($debug_cline)
    { print "cline_updateinvars ($cline_simplify_strings): $remaining\n"; }

  if ($remaining =~ /\n./)
    { die "Call cline_updateinvars on a physical line, not one with embedded newline"; }

  while ($remaining)
    { if ($cline_incomment)
	{ if ($remaining =~ /\*\//)
	    { $remaining = $POSTMATCH;
	      $cline_incomment = $false; }
	  else
	    { goto UIV_RETURN; } }
      elsif ($cline_instring)
	{ $seen_ncnb = 1;
	  # print "in string, processing $remaining";
	  if ($remaining =~ m/$non_escaped_double_quote_re/o)
	    # Found a non-escaped double quote
	    { # print "non-escaped double quote: $result|$remaining|$PREMATCH|$MATCH|$POSTMATCH\n";
	      if ($cline_simplify_strings)
		{ $result .= "\""; }
	      else
		{ $result .= $PREMATCH . $MATCH; }
	      if ($debug_cline)
		{ print "post-nonescdquote: '$result' '$remaining'\n"; }
	      $remaining = $POSTMATCH;
	      $cline_instring = $false; }
	  else
	    { # print "$current_file:", current_line_no(), ": in string after line $_[0]";
	      if (!$cline_simplify_strings)
		{ if ($debug_cline)
		    { print "not simplifying; appending '$remaining'\n"; }
		  $result .= $remaining; }
	      goto UIV_RETURN; } }
      # If not instring, \" suffices instead of the more complicated
      # regexp that checks for leading backslashes.
      elsif ($remaining =~ m/\/[\*\/]|[\'\"]/)
	{ my $match = $MATCH;
	  my $postmatch = $POSTMATCH;
	  $result .= $PREMATCH;
	  if ($match eq "\'")
	    { if ($postmatch =~ m/^$char_literal_contents_re\'/o)
		{ if ($cline_simplify_strings)
		    { $result .= $simple_char; }
		  else
		    { $result .= "'" . $MATCH; }
		  $remaining = $POSTMATCH; }
	      else
                # No newline, since $_[0] has one.
		{ push(@{$warnings}, "illegal: bad character constant $match" . add_newline($postmatch) . "    in $_[0]");
		  if ($postmatch =~ /\'/)
		    { if ($cline_simplify_strings)
			{ $result .= $simple_char; }
		      else
			{ $result .= "'" . $MATCH; }
		      $remaining = $POSTMATCH; }
		  else
		    { $remaining = $postmatch; } } }
	  elsif ($match eq "\"")
	    { $result .= $match;
	      if ($debug_cline)
		{ print "Added double quotes to result: '$result'\n"; }
	      $remaining = $POSTMATCH;
	      $cline_instring = $true; }
	  elsif ($match eq "//")
	    { if ($PREMATCH !~ /^\s*$/)
		{ $seen_ncnb = 1; }
	      $result .= "\n";	# so we don't return an empty line, which
				# looks like failure or end of file
	      goto UIV_RETURN; }
	  elsif ($match eq "/*")
	    { $remaining = $POSTMATCH;
	      if ($PREMATCH !~ /^\s*$/)
		{ $seen_ncnb = 1; }
	      $cline_incomment = $true; }
	  else
	    { croak("cline_updateinvars: what match?  $match in $_[0]"); } }
      else
	{ if ($remaining !~ /^\s*$/)
	    { $seen_ncnb = 1; }
	  $result .= $remaining;
	  goto UIV_RETURN; }
    }

  UIV_RETURN:
  # Code that used to be here has been moved into callers.
  if ($debug_cline)
    { print "cline_updateinvars returning ($cline_instring, $cline_incomment, @{$warnings}) '$result'\n"; }

  # Second return value is either 0 or 1
  return ($result, $seen_ncnb, $warnings);
}


# Special-purpose variant of cline_updateinvars that removes comments,
# simplifies strings.
sub cline_simplify ($)
{
  my ($arg) = check_args(1, @_);

  local $cline_incomment = $false;
  local $cline_instring = $false;
  local $cline_simplify_strings = $true;

  my ($result, $seen_ncnb, $warnings) = cline_updateinvars($arg);
  return $result;
}


###########################################################################
### Copied from em_analyze
###

# This pretties things up but changes contents of line-spanning strings,
# so don't call it if ARG1 ends inside a string.
sub append_lines ($$)
{
  my ($arg1, $arg2) = check_args(2, @_);
  # "+" instead of "*" wouldn't introduce spaces where there were none before;
  # but we want to make sure the two lines don't just run together.
  # Exception to the above: if splicing, then running together may be OK.
  # At present, callers take care of that themselves.
  $arg1 =~ s/[ \t\n]*$/ /;
  $arg2 =~ s/^[ \t\n]*/ /;
  return ($arg1 . $arg2);
}

# Add newline to end of string; return string unchanged if it already has one.
sub add_newline ($)
{ my ($string) = check_args(1, @_);
  if ($string =~ m/\n$/)
    { return $string; }
  else
    { return $string . "\n"; }
}


###########################################################################
### Get spliced line
###

# Returns (raw_line, simplified_line, num_phys_lines, num_ncnb_lines, warnings)
#  * The raw result contains explicit backslash-newline combinations; callers
#    should remove them if desired.
#  * The simple result contains no comments, and its strings and character
#    constants have been simplified if $cline_simplify_strings (which see) is true.
# Always reads directly from input, never from ungotlines.
# Optional argument $cpp_comment is true if we are in a "CPP comment" -- that
#   is, in "#if 0", in the else part of "#if 1", or similar.  This prevents
#   cline_updateinvars from being called and causes ncnb lines to be zero.
sub get_spliced_cline ($;$)
{
  my ($filehandle, $cpp_comment) = check_args_range(1, 2, @_);
  if (!defined($cpp_comment))
    { $cpp_comment = $false; }

  my $raw_line = <$filehandle>;
  if (not ($raw_line))
    { return ($raw_line, $raw_line, 0, 0); }
  my $num_physical_lines = 1;
  my ($simple_line, $num_ncnb_lines, $warnings)
    = ($cpp_comment ? ($raw_line, 0, []) : cline_updateinvars($raw_line));

  if ($debug_cline)
    { print "initial simple: $simple_line\ninitial raw: $raw_line"; }
  while ($raw_line =~ m/\\$/)	# could test against either raw or simple here
    { # This line ends with a backslash (is continued on next line).
      # Remove backslash and possibly newline.
      # Could use $raw_line = $PREMATCH, but would need to use substr or
      #   do a match against $simple_line anyway.
      if (substr($raw_line, -1) eq "\\")
	{ push(@{$warnings}, "evil: file ends with backslash (no newline)\n");
	  # What is the point of this test?  I added $true to front.
	  if ($true || !($cline_incomment || ($cline_instring && $cline_simplify_strings)))
	    { if (substr($simple_line, -1) ne "\\")
		{ die "Didn't find backslash-nonewline where there must be one: '$simple_line'\n"; }
	      $simple_line = substr($simple_line, 0, length($simple_line)-1); }
	  elsif ((length($simple_line) >= 1) && (substr($simple_line, -1) eq "\\"))
	    { die "Found backslash-nonewline where there mustn't be one: '$simple_line'\n"; } }
      else
	{ if (substr($raw_line, -2) ne "\\\n")
	    { die "Didn't find backslash-newline where there must be one: '$raw_line'\n"; }
	  if ($cline_instring && $cline_simplify_strings && !($simple_line =~ /(^|\")$/))
	    { croak "In string and simplifying, so simple should be empty or end in double quote: <<$simple_line>>\n"; }
	  # If in a comment, or in a string and simplifying, then the
	  # trailing backslash has already been stripped from simple_line;
	  # don't remove even more characters!
	  if (!($cline_incomment || ($cline_instring && $cline_simplify_strings)))
	    {
	      if (substr($simple_line, -2) ne "\\\n")
		{ die "Didn't find backslash-nonewline where there must be one: '$simple_line'\n"; }
	      $simple_line = substr($simple_line, 0, length($simple_line)-2); }
	  elsif ((length($simple_line) >= 2) && (substr($simple_line, -1) eq "\\\n"))
	    { # The backslash-newline should already have been removed from $simple_line.
	      die "Found backslash-nonewline where there mustn't be one: '$simple_line'\n"; } }
      if ($debug_cline)
	{ print "simple_line less backslash = `$simple_line'\n"; }
      if ($simple_line =~ /\\\n/)
	{ die "Found backslashes that should have just been removed."; }
      my $next_raw_line = <$filehandle>;
      if (! $next_raw_line)
	# Already removed backslash and newline from result.
	{ push(@{$warnings}, "dangerous: file ends with continuation character:\n    $raw_line\n"); }
      else
	{ $num_physical_lines++;
	  my $old_instring = $cline_instring;
	  my ($next_simple_line, $next_ncnb_lines) =
	    ($cpp_comment ? ($next_raw_line, 0, []) : cline_updateinvars($next_raw_line));
	  $num_ncnb_lines += $next_ncnb_lines;
	  $raw_line = $raw_line . $next_raw_line;
	  if ($debug_cline)
	    { print "splicing '$simple_line' '$next_simple_line'\n"; }
	  if ($old_instring && $cline_simplify_strings)
	    { $simple_line .= $next_simple_line; }
	  else
	    { $simple_line = append_lines($simple_line, $next_simple_line); }
	  if ($next_raw_line =~ m/^\s*$/)
	    { # $next_raw_line is blank.  $raw_line has no newline.
	      push(@{$warnings}, "dangerous: blank line follows continuation character:\n    $raw_line\n"); }
	} }

  # Remove the filename in #include <foo.h>, which act like quotes.
  if ($cline_simplify_strings && ($simple_line =~ /^(\s*\#\s*include\s+<).*>\s*$/))
    { $simple_line = $1 . ">\n"; }

  # $raw_line and $simple_line end in newline
  if ($debug_cline)
    { print "get_spliced_cline returning with incomment $cline_incomment instring $cline_instring:\n >>$raw_line >>$simple_line\n"; }
  return ($raw_line, $simple_line, $num_physical_lines, $num_ncnb_lines, $warnings);
}


# Like get_spliced_cline, but tries the ungotlines cache first and never calls
# updateinvars.
# This is a bit of a hack.
sub get_spliced_cline_maybe_ungot ($;$)
{
  my ($filehandle, $cpp_comment) = check_args_range(1, 2, @_);
  if (!defined($cpp_comment))
    { $cpp_comment = $false; }

  if (@cline_ungot_raw_lines > 0)
    { # print "popping cline_ungot_raw_lines $cline_ungot_raw_lines[$#cline_ungot_raw_lines]  cline_ungot_simple_lines $cline_ungot_simple_lines[$#cline_ungot_simple_lines]"; # no newline: it ends with one
      # print "all ungot_raw_lines: <<", join(">><<", @cline_ungot_raw_lines), ">>\n";
      # print "all ungot_simple_lines: <<", join(">><<", @cline_ungot_simple_lines), ">>\n";
      return(shift(@cline_ungot_raw_lines),
	     shift(@cline_ungot_simple_lines),
	     shift(@cline_ungot_phys_lines),
	     shift(@cline_ungot_ncnb_lines),
	     shift(@cline_ungot_warnings));
    }
  else
    { return get_spliced_cline($filehandle, $cpp_comment); }
}


###########################################################################


# Read the next line from <$filehandle>, until no continuation char
#   and not in string or comment.  The result will never end in mid-token.
# Returns (raw_line, simplified_line, num_phys_lines, num_ncnb_lines, warnings)
#  * The raw result contains explicit backslash-newline combinations; callers
#    should remove them if desired.
#  * The simple result contains no comments, and its strings and character
#    constants have been simplified if $cline_simplify_strings (which see) is true.
#  * The string results end with newline.
# If calls to peek_fulltoken_line have been made, those strings are returned.
# To simplify an arbitrary string, use cline_simplify.
# 
# Constructing simplified values are a bit wasteful on the first pass, when we
# only care about macro definitions; special-case that?
sub get_fulltoken_cline ($;$)
{ my($filehandle,$peeking) = check_args_range(1, 2, @_);
  # If $peeking is set, get_fulltoken_cline doesn't use @cline_ungot_*
  if (!defined($peeking))
    { $peeking = $false; }

  if ($cline_instring || $cline_incomment)
    { croak("Bad instring $cline_instring or incomment $cline_incomment"); }

  # print "Called get_fulltoken_line ($cline_simplify_strings)\n";

  if ((@cline_ungot_raw_lines > 0) && !$peeking)
    { # print "popping cline_ungot_raw_lines $cline_ungot_raw_lines[$#cline_ungot_raw_lines]  cline_ungot_simple_lines $cline_ungot_simple_lines[$#cline_ungot_simple_lines]"; # no newline: it ends with one
      # print "all ungot_raw_lines: <<", join(">><<", @cline_ungot_raw_lines), ">>\n";
      # print "all ungot_simple_lines: <<", join(">><<", @cline_ungot_simple_lines), ">>\n";

      cline_check_ungot_sizes();

      return(shift(@cline_ungot_raw_lines),
	     shift(@cline_ungot_simple_lines),
	     shift(@cline_ungot_phys_lines),
	     shift(@cline_ungot_ncnb_lines),
	     shift(@cline_ungot_warnings));
    }
  else
    { my ($raw_result, $simple_result, $physical_lines, $physical_ncnb_lines, $warnings)
	= get_spliced_cline($filehandle);
      # don't check $simple_result, which might be simplified to "" (= false)
      if (not ($raw_result))
	{ return ($raw_result, $simple_result, $physical_lines, $physical_ncnb_lines, $warnings); }
      # This screws something up really badly.
      # if (not ($simple_result))
      #  { return $simple_result; }

      # perhaps check for $mdef_name and mention it in message if it's set
      while ($cline_incomment || $cline_instring)
	{
	  my $old_instring = $cline_instring;
	  my ($next_raw, $next_simple, $next_phys, $next_ncnb, $next_warnings) = get_spliced_cline($filehandle);
	  if ($next_raw)
	    # Strict ANSI C does not permit newlines in string constants;
	    # perhaps warn.  On the other hand, most compilers permit it.
	    { $raw_result = $raw_result . $next_raw;
	      if ($old_instring && $cline_simplify_strings)
		{ $simple_result .= $next_simple; }
	      else
		{ $simple_result = append_lines($simple_result, $next_simple); }
	      $physical_lines += $next_phys;
	      $physical_ncnb_lines += $next_ncnb;
	      push(@{$warnings}, @{$next_warnings}); }
	  elsif ($cline_incomment)
	    { push(@{$warnings}, "dangerous: file ends in comment:\n    $raw_result");
	      $cline_incomment = $false; }
	  elsif ($cline_instring)
	    { push(@{$warnings}, "dangerous: file ends in string:\n    $raw_result\n");
	      $cline_instring = $false; }
	  else
	    { croak "incomment $cline_incomment or instring $cline_instring must be set"; } }

      if ($debug_cline)
	{ print STDERR "get_fulltoken_line $physical_lines: >>$simple_result>>$raw_result"; }

      if (!defined($simple_result))
	{ $simple_result = " "; }
      elsif ($simple_result eq "")
	{ croak("empty get_fulltoken_line result"); }
      # print "get_fulltoken_line returning <<$simple_result>>\n";
      return ($raw_result, $simple_result, $physical_lines, $physical_ncnb_lines, $warnings);
    }
}


###########################################################################


# Returns (raw_line, simplified_line, num_phys_lines, num_ncnb_lines)
#  * The raw result contains explicit backslash-newline combinations; callers
#    should remove them if desired.
#  * The simple result contains no comments, and its strings and character
#    constants have been simplified if $cline_simplify_strings (which see) is true.
#  * The string results end in newline.
# The second argument is the number of lines ahead of the current one to peek:
# 1 gives the next line, 2 the line after that, etc.
sub peek_fulltoken_cline ($$)
{
  my ($filehandle, $arg) = check_args(2, @_);
  if ($arg < 1)
    { croak ("bad argument $arg to peek_fulltoken_cline", caller); }
  if ($debug_cline)
    { print "called peek_fulltoken_line($arg)\n";
      print "ungot raw: ", join("  >>", @cline_ungot_raw_lines);
      print "ungot simple: ", join("  >>", @cline_ungot_simple_lines); }

  cline_check_ungot_sizes();

  if ($arg <= @cline_ungot_raw_lines)
    { # We have previously peeked at the line in question
      # Was @cline_ungot_raw_lines-$arg; how did that work at all?
      my $index = $arg-1;
      return($cline_ungot_raw_lines[$index],
	     $cline_ungot_simple_lines[$index],
	     $cline_ungot_phys_lines[$index],
	     $cline_ungot_ncnb_lines[$index],
	     $cline_ungot_warnings[$index]); }
  else
    { if ($arg < (@cline_ungot_raw_lines + 1))
	{
	  # This should never happen:  why would one look two
	  # lines ahead before checking the next line?
	  croak("Why look far ahead when you haven't looked near?  $arg " . scalar(@cline_ungot_raw_lines));
	  # Old implementation.
	  # # Recursively fill up the arrays
	  # peek_fulltoken_line($arg-1);
	}
      if ($arg != (@cline_ungot_raw_lines + 1))
	{ die "arg $arg != cline_ungot_raw_lines+1 ", (@cline_ungot_raw_lines + 1); }

      # Do the real work.
      { # print "peeking about to call get_fulltoken_line\n";
	my ($raw, $simple, $phys, $ncnb, $warnings)
	  = get_fulltoken_cline($filehandle, $true);
	# print "peeking found $simple";
	push (@cline_ungot_raw_lines, $raw);
	push (@cline_ungot_simple_lines, $simple);
	push (@cline_ungot_phys_lines, $phys);
	push (@cline_ungot_ncnb_lines, $ncnb);
	push (@cline_ungot_warnings, $warnings);
	if ($debug_cline) { print "peek_fulltoken_line($arg) returning $simple"; }
	return($raw, $simple, $phys, $ncnb, $warnings); }
    }
}


1; #Successful import
__END__
