#!/uns/bin/perl -wna
# use macros-make-categories-tbl-from-stat.pl *.stat

BEGIN {
  use English;
  use strict;
  use em_constants;
  use Carp;
  use vars qw($ORS $OFS $FORMAT);
  
  my $getopts_option_letters = 'htp';
  sub usage () {
    die "@_\nUsage: $0 [-$getopts_option_letters] <*.stat files>
-t  to use tab delimiters, not latex output format
-p  to give the numbers as percentages
-h  to display this help
";
  }
  
  use vars qw ($opt_h $opt_t $opt_p %column_name_to_colno $fInitializedHeadings $nolatex $usepct $totLine $fFoundLine);
  


  $nolatex = 0;
  $usepct = 0;
  $totLine = 0;
  $fFoundLine = 0;
  $fInitializedHeadings = 0;
  %column_name_to_colno = ();
  $ORS = "\n";

  use Getopt::Std;
  getopts($getopts_option_letters);
  
  if ($opt_h) { usage(); }
  if ($opt_t) { $nolatex = 1; }
  if ($opt_p) { $usepct = 1; }
  
#   my $foo = "catFUNCTION_NAME";
#   no strict;
#   print $$foo, "\n";
#   exit 0;

#  print $categoryname[19], "\n";
#  exit 0;
  
  if ($usepct) { 
    $FORMAT="%2.3f";
#DBG    print STDERR "Using percents\n";
  }
  if ($nolatex) { 
    $OFS="\t"; 
  } else {
    $OFS = " & ";
    $ORS="\\\\\\hline\n";
    print "\\begin{tabular}{|l|c|c|c|c|c|c|c|c|}\\hline\n"; 
  }
  print " ",       "Null",   " ",        " ",          " ",         "Syntactic","Type",   " ",        "Not",    " ",     "Failed";
  print "Package", "Define", "Constant", "Expression", "Statement", "macros",   "Related","Recursive","C Code", "Other", "classification";

  my ($cNull, $cLit, $cExp, $cStm, $cSyntax, $cType, 
      $cRecursive, $cNonC, $cOther, $cFail, @rest) = 0 x 40;
  my ($sNull, $sLit, $sExp, $sStm, $sSyntax, $sType, 
      $sRecursive, $sNonC, $sOther, $sFail, @rest2) = 0 x 40;
  
}



if (/^CATEGORIES_NI:/) {
  $fFoundLine = 1;
  $cNull = sum_meta_category(@mcat_NULL); $sNull += $cNull;
  $cLit = sum_meta_category(@mcat_LITERAL); $sLit += $cLit;
  $cExp = sum_meta_category(@mcat_NONLITERAL_EXPRESSION); $sExp += $cExp; 
  $cStm = sum_meta_category(@mcat_STATEMENT); $sStm += $cStm; 
  $cSyntax = sum_meta_category(@mcat_SYNTAX); $sSyntax += $cSyntax; 
  $cType = sum_meta_category(@mcat_TYPE); $sType += $cType; 
  $cRecursive = sum_meta_category(@mcat_RECURSIVE); $sRecursive += $cRecursive; 
  $cNonC = sum_meta_category(@mcat_NON_C_CODE); $sNonC += $cNonC;
  $cOther = sum_meta_category(@mcat_OTHER); $sOther += $cOther;
  $cFail = sum_meta_category(@mcat_FAILURE); $sFail += $cFail;
  $totLine = $cNull + $cLit + $cExp + $cStm + $cSyntax + 
    $cType + $cRecursive + $cNonC + $cFail + $cOther;

  my $filename = $ARGV;
  $filename =~ s/\..*$//;

  print $filename, map {sprintf $FORMAT, $_ } pct($cNull), pct($cLit), pct($cExp), pct($cStm), pct($cSyntax),
    pct($cType), pct($cRecursive), pct($cNonC), pct($cOther), pct($cFail);

  $totLine = 0;
} elsif ($fInitializedHeadings == 0 && /^\#CATEGORIES_NI\#:/ ) {
  # Need to know which columns the @mcat_XXXX-s go with
  # since the @mcat_XXXX-s can give me indices into @categoryname,
  # and the categoryname-s are what the column headings are,
  # I just need to create a backmapping from the categoryname to the column
  # it's in
  my $i = 0;
  foreach my $column_name (@F) {
    $column_name_to_colno{$column_name} = $i;
#DBG    print STDERR "$column_name in $i\n";
    $i++;
  }
  $fInitializedHeadings = 1;
}

END {
  if (!$nolatex) { print "\\hline\n" }; 
  if ($fFoundLine) {
    $totLine = $sNull + $sLit + $sExp + $sStm + $sSyntax + $sType + $sRecursive + 
      $sNonC + $sFail + $sOther;
    print "Total", map {sprintf $FORMAT, $_ } ( pct($sNull), pct($sLit), pct($sExp), pct($sStm), pct($sSyntax), pct($sType), 
      pct($sRecursive), pct($sNonC), pct($sOther), pct($sFail) );
    print "Total-raw", map {sprintf "%2.0f", $_} ($sNull, $sLit, $sExp, $sStm, $sSyntax, $sType, 
      $sRecursive, $sNonC, $sOther, $sFail );
  }
  $ORS=""; 
  if (!$nolatex) {print "\\end{tabular}\n"; } 
}

########### Utility subroutines

# pct2(x) returns a percentage (not a fraction) which corresponds to arg1/arg2.
sub pct2 ($$) {
  my ($x,$w) = @_;
  if ($w <= 0) {
    if ($x > 0) {
      croak "pct2: Bad divisor: $x / $w";
      return 0;
    }
    $w = 1;
  }
  if ($x < 0 || $x > $w) {
    croak "pct2: Percentage out of range: $x / $w\n";
  }
  return (100*$x/$w);
}

# pct(x) returns a percentage using totline as the divisor
sub pct ($) {
  my ($x) = @_;
  return pct2($x,$totLine);
}

sub sum_meta_category {
  die if !$fInitializedHeadings;
  my $sum = 0;
  foreach my $catname (@_) {
    my $catindex;
    { no strict; $catindex = ${$catname}; }
    my $colname = $categoryname[$catindex];
    my $colno = $column_name_to_colno{$colname};
#DBG    print STDERR "Catname $catname -> catindex $catindex -> colname $colname -> colno $colno\n";
    $sum += $F[$colno];
  }
#DBG  print STDERR "Summed to $sum\n";
  return $sum;
}
