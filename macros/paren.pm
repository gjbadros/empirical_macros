#!/uns/bin/perl -w
# cline -- Find balanced parentheses and braces
# Michael Ernst <mernst@cs.washington.edu>
# Time-stamp: <2000-07-23 16:39:41 mernst>

package paren;
require 5.003;			# uses prototypes
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(brace_change paren_change contains_mismatch find_close_delimiter);
use checkargs;
use strict;
use Carp;
use English;

=head1 NAME

paren -- Find balanced parentheses and braces

=head1 SYNOPSIS

  # Given a simplified line, return a string containing just the
  # unbalanced braces (empty string if all braces are balanced).
  brace_change (line)

  # Given a simplified line, return a string containing just the
  # unbalanced parens (empty string if all parens are balanced).
  paren_change (line)

  # Return a boolean indicating whether the argument string contains a
  # mismatching paren, brace, or bracket (close without open, or open without
  # close, or mismatched open and close).
  # Ignores strings, character constants, comments.
  contains_mismatch (line)

  # Return index of first close paren or brace not matching a preceding open,
  # or false (0) if no match is found.  Ignores strings, etc.
  # Optional third argument says where to start (right after the open, usually).
  find_close_delimiter (open_delim, line)
  find_close_delimiter (open_delim, line, startpos)


=head1 DESCRIPTION

Given an argument string, the functions in paren count the number of
unbalanced parentheses, braces, and other delimiters, or find the close
delimiter that matches a specified open delimiater.

This package is similar to Text::Balanced and Text::DelimMatch.  Those
packages do not count delimiters or find unmatched close delimiters.  This
package is less general than those, however, in that it deals only with
parentheses, braces, and brackets and does not specially handle quoted or
escaped text.  It was originally written for use on C code in which quoting
and escapes had already been eliminated.  The functionality of this package
should probably be merged into one of the other two packages (probably
Text::Balanced).

=head1 AUTHOR

Michael D. Ernst <F<mernst@cs.washington.edu>>

=cut


###########################################################################
### Constants
###

### Boolean
my $true = (1 == 1);
my $false = (1 == 0);

my $debug_paren = $false;
# $debug_paren = $true;


###########################################################################
### Counting change
###

# These should also check whether result_num ever becomes negative.

# Given a simplified line, return a string containing just the
# unbalanced braces (empty string if all braces are balanced).
sub brace_change ( $ )
{ my ($line) = check_args(1, @_);
  if ($debug_paren) { print "brace_change $line"; }
  my $result_num = 0;
  my $result_chars = "";
  while ($line =~ /[\{\}]/g)
    { $result_chars .= $MATCH;
      if ($MATCH eq "\{")
	{ $result_num++; }
      elsif ($MATCH eq "\}")
	{ $result_num--; }
      else
	{ die("What match? $MATCH"); } }
  return ($result_num == 0) ? $false : $result_chars;
}

# Given a simplified line, return a string containing just the
# unbalanced parens (empty string if all parens are balanced).
# Perhaps this should also check for braces (and complain or err if any are
# found before parens balance).
sub paren_change ( $ )
{ my ($line) = check_args(1, @_);
  if ($debug_paren) { print "paren_change <= $line\n"; }
  my $result_num = 0;
  my $result_chars = "";
  while ($line =~ /[\(\)]/g)
    { $result_chars .= $MATCH;
      if ($MATCH eq "\(")
	{ $result_num++; }
      elsif ($MATCH eq "\)")
	{ $result_num--; }
      else
	{ die("What match? $MATCH"); } }
  return ($result_num == 0) ? $false : $result_chars;
}


# Return a boolean indicating whether the argument string contains a
# mismatching paren, brace, or bracket (close without open, or open without
# close, or mismatched open and close).
# Ignores strings, character constants, comments.
# Largely lifted from old check_macro_body (which didn't ignore those, and
# did more to boot, but also tried to do too much).
sub contains_mismatch ( $ )
{ my ($body) = check_args(1, @_);
  if ($debug_paren) { print "contains_mismatch <= $body"; }

  my @nesting = ();

  # my $full_body = $body;

  while ($body =~ m/[\]\[(){}]/go) #'HACKCOLOR
    # Found paren, quote, cpp directive, or comment
    { my $match = $MATCH;
      if ($debug_paren) { print "contains_mismatch matched '$match'\n" }
      if ($match =~ /[\[\(\{]/)
        { push(@nesting,$match);
	  # print STDERR "FRONTMATCH\n";
	}
      else # ($match =~ /[\]\)\}]/)
	{ if (scalar(@nesting) == 0)
	    { return $true; }
	  else
	    { my $popped = pop(@nesting);
	      if ((($match eq "\]") && ($popped ne "\["))
		  || (($match eq "\)") && ($popped ne "\("))
		  || (($match eq "\}") && ($popped ne "\{")))
		{ return $true; } } } }
  if (scalar(@nesting) != 0)
    { return $true; }

  return $false;
}


###########################################################################
### Finding close delimiter
###

## I could perhaps better implement this recursively than as a loop.


# Return index of first close paren or brace not matching a preceding open,
# or $false (0) if no match is found.  Ignores strings, etc.
# Optional third argument says where to start (right after the open, usually).
sub find_close_delimiter ($$;$)
{ my ($open, $exp, $pos) = check_args_range(2, 3, @_);
  if (($open ne "\(") && ($open ne "\{"))
    { croak "first arg to find_close_delimiter should be '(' or '{', not '$open'"; }

  my $remaining;
  if (!defined($pos))
    { $pos = 0;
      $remaining = $exp; }
  else
    { $remaining = substr($exp,$pos); }
  if ($debug_paren) { print "find_close_delimiter '$open' from $pos: $exp\n"; }
  my @opens = ($open);

  while ($remaining =~ /[(){}]/g)
    { if ($debug_paren)
	{ print "match '$MATCH' at ", length($exp) - length($POSTMATCH) - 1, "\n"; }
      if (($MATCH eq "\(") || ($MATCH eq "\{"))
	{ push(@opens, $MATCH); }
      elsif ((($MATCH eq "\)") && ($opens[$#opens] ne "\("))
	     || (($MATCH eq "\}") && ($opens[$#opens] ne "\{")))
	{ carp "Delimiter mismatch: '$MATCH' at ",
	    length($exp) - length($POSTMATCH) - 1,
	    " matched $opens[$#opens] in: $exp\n";
	  return $false; }
      elsif ((($MATCH eq "\)") && ($opens[$#opens] eq "\("))
	     || (($MATCH eq "\}") && ($opens[$#opens] eq "\{")))
	{ pop(@opens);
	  if (scalar(@opens) == 0)
	    { return length($exp) - length($POSTMATCH) - 1; } }
      else
	{ die "Huh? '$MATCH' <<@opens>> '$opens[$#opens]' '$POSTMATCH':\n  $exp"; }
    }
  return $false;
}

# # Return index of first close paren which doesn't match a preceding open paren,
# # or $false if no match is found.  Ignores strings, braces, etc.
# # Optional second argument says where to start (right after the open, usually).
# sub find_close_paren ($;$)
# { my ($exp, $pos) = check_args_range(1, 2, @_);
#   if (!defined($pos))
#     { $pos = 0; }
#   if ($debug_paren) { print "find_close_paren: $exp\n"; }
#   my $opens = 1;
#   my $brace_pos;			# undefined if no brace found
#   { my $open_pos = index($exp, "\{", $pos);
#     my $close_pos = index($exp, "\}", $pos);
#     $brace_pos = ($open_pos == -1) ? $close_pos
#       : ($close_pos == -1) ? $open_pos
# 	# min($open_pos, $close_pos)
# 	: ($open_pos < $close_pos) ? $open_pos : $close_pos;
#     if ($brace_pos == -1)
#       { undef($brace_pos); } }
# 
#   while ($opens > 0)
#     { my $next_open = index($exp, "\(", $pos);
#       my $next_close = index($exp, "\)", $pos);
#       if ($debug_paren)
# 	{ print "next_open $next_open next_close $next_close\n"; }
#       if (($next_close != -1)
# 	  && (($next_open == -1) || ($next_close < $next_open)))
# 	{ if (defined($brace_pos) && ($next_close > $brace_pos))
# 	    { # croak "Found brace before matching paren in $exp";
# 	      carp "Found brace before matching paren in $exp\n";
# 	      return $false; }
# 	  $opens--;
# 	  $pos = $next_close+1; }
#       elsif (($next_open != -1)
# 	     && (($next_close == -1) || ($next_open < $next_close)))
# 	{ if (defined($brace_pos) && ($next_open > $brace_pos))
# 	    { # croak "Found brace before matching paren in $exp";
# 	      carp "Found brace before matching paren in $exp\n";
# 	      return $false; }
# 	  $opens++;
# 	  $pos = $next_open+1;
# 	  if ($debug_paren)
# 	    { print "open paren at $next_open, opens = $opens, pos = $pos\n"; }
# 	}
#       else
# 	# Didn't find an open or close parenthesis.
# 	{ if (!(($next_open == -1) && ($next_close == -1)))
# 	    { die "bad values for next_open $next_open and next_close $next_close"; }
# 	  return $false; }
#     }
#   if ($debug_paren)
#     { print "find_close_paren(\"$exp\") => ", $pos-1, "\n"; }
#   return $pos - 1;
# }
# 
# # Return index of first close brace which doesn't match a preceding open brace
# # in the argument string.  Ignores strings, parens, etc.
# # Optional second argument says where to start (right after the open, usually).
# sub find_close_brace ($;$)
# { my ($exp, $pos_init) = check_args_range(1, 2, @_);
#   if (!defined($pos_init))
#     { $pos_init = 0; }
#   if ($debug_paren) { print "find_close_brace: $exp\n"; }
#   my $opens = 1;
#   my $pos = $pos_init;
# 
#   while ($opens > 0)
#     { my $next_open = index($exp, "\{", $pos);
#       my $next_close = index($exp, "\}", $pos);
#       if ($debug_paren)
# 	{ print "next_open $next_open next_close $next_close\n"; }
#       if (($next_close != -1)
# 	  && (($next_open == -1) || ($next_close < $next_open)))
# 	{ $opens--;
# 	  $pos = $next_close+1; }
#       elsif (($next_open != -1)
# 	     && (($next_close == -1) || ($next_open < $next_close)))
# 	{ $opens++;
# 	  $pos = $next_open+1;
# 	  if ($debug_paren)
# 	    { print "open brace at $next_open, opens = $opens, pos = $pos\n"; }
# 	}
#       else
# 	{ if (!(($next_open == -1) && ($next_close == -1)))
# 	    { die "bad values for next_open $next_open and next_close $next_close"; }
# 	  return $false; }
#     }
#   return $pos - 1;
# }

1; #Successful import
__END__
