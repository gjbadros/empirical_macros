#!/uns/bin/perl -wna
# use macros-make-categories-tbl-from-stat.pl *.stat

BEGIN {
  use English;
  use strict;
  use em_constants;
  use em_util;
  use Carp;
  use vars qw($ORS $OFS $FORMAT);
  $FORMAT="%2.3f";
  my $getopts_option_letters = 'htpb';
  my $usage_msg = "Usage: $0 [-$getopts_option_letters] <*.stat files>
-t  to use tab delimiters, not latex output format
-p  to give the numbers as percentages
-b  to also give breakdown of metacategory elements
-h  to display this help
";

  use vars qw ($opt_h $opt_t $opt_p $opt_b %column_name_to_colno $fInitializedHeadings $nolatex $usepct $totLine $fFoundLine);

  $nolatex = 0;
  $usepct = 0;
  $totLine = 0;
  $fFoundLine = 0;
  $fInitializedHeadings = 0;
  %column_name_to_colno = ();
  $ORS = "\n";

  use Getopt::Std;
  getopts($getopts_option_letters);

  if ($opt_h) { die $usage_msg; }
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
  print " ",       "Null",   " ",        " ",          " ",        "",         "Type",   "Not",    " ",     "Unknown",	"Failed";
  print "Package", "define", "Constant", "Expression", "Statement", "Syntactic","related","C code", "Other", "symbol",	"classification";

  my ($cNull, $cConst, $cExp, $cStm, $cSyntax, $cType,
      $cNonC, $cSymbol, $cFail, @rest) = 0 x 40;
  my ($sNull, $sConst, $sExp, $sStm, $sSyntax, $sType,
      $sNonC, $sSymbol, $sFail, @rest2) = 0 x 40;

  my @nonmeta_sums = ();
}



if (/^CATEGORIES_NI:/) {
  $fFoundLine = 1;
  for my $colno (1..$#F)
    { $nonmeta_sums[$colno] += $F[$colno]; }

  $cNull = sum_meta_category(@mcat_NULL); $sNull += $cNull;
  $cConst = sum_meta_category(@mcat_CONSTANT); $sConst += $cConst;
  $cExp = sum_meta_category(@mcat_NONCONSTANT_EXPRESSION); $sExp += $cExp;
  $cStm = sum_meta_category(@mcat_STATEMENT); $sStm += $cStm;
  $cSyntax = sum_meta_category(@mcat_SYNTAX); $sSyntax += $cSyntax;
  $cType = sum_meta_category(@mcat_TYPE); $sType += $cType;
  $cNonC = sum_meta_category(@mcat_NON_C_CODE); $sNonC += $cNonC;
  $cSymbol = sum_meta_category(@mcat_SYMBOL); $sSymbol += $cSymbol;
  $cSymUknown = sum_meta_category(@mcat_SYMBOL_UNKNOWN); $sSymUnknown += $cSymUknown;
  $cFail = sum_meta_category(@mcat_FAILURE); $sFail += $cFail;
  $totLine = $cNull + $cConst + $cExp + $cStm + $cSyntax +
    $cType + $cNonC + $cSymUknown + $cFail + $cSymbol;

  my $filename = $ARGV;
  $filename =~ s/\..*$//;

  print $filename, map {sprintf $FORMAT, $_ } pct($cNull), pct($cConst), pct($cExp), pct($cStm), pct($cSyntax),
    pct($cType), pct($cNonC), pct($cSymbol), pct($cSymUknown), pct($cFail);

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
    $totLine = $sNull + $sConst + $sExp + $sStm + $sSyntax + $sType +
      $sNonC + $sFail + $sSymbol + $sSymUnknown;
    print "Total", map {sprintf $FORMAT, $_ } ( pct($sNull), pct($sConst), pct($sExp), pct($sStm), pct($sSyntax), pct($sType),
      pct($sNonC), pct($sSymbol), pct($sSymUnknown), pct($sFail) );
    print "Total-raw", map {sprintf "%2.0f", $_} ($sNull, $sConst, $sExp, $sStm, $sSyntax, $sType,
      $sNonC, $sSymbol, $sSymUnknown, $sFail );
  }
  $ORS="";
  if (!$nolatex) {print "\\end{tabular}\n"; }


  if ($opt_b) {
    @F = @nonmeta_sums;
    $cNull = sum_meta_category(@mcat_NULL);
    if ($sNull != $cNull) { die "sNull $sNull, cNull $cNull"; }
    $cConst = sum_meta_category(@mcat_CONSTANT);
    if ($sConst != $cConst) { die "sConst $sConst, $cConst cConst"; }
    $cExp = sum_meta_category(@mcat_NONCONSTANT_EXPRESSION);
    if ($sExp != $cExp) { die "sExp $sExp, cExp $cExp"; }
    $cStm = sum_meta_category(@mcat_STATEMENT);
    if ($sStm != $cStm) { die "sStm $sStm, cStm $cStm"; }
    $cSyntax = sum_meta_category(@mcat_SYNTAX);
    if ($sSyntax != $cSyntax) { die "sSyntax $sSyntax, cSyntax $cSyntax"; }
    $cType = sum_meta_category(@mcat_TYPE);
    if ($sType != $cType) { die "sType $sType, cType $cType"; }
    $cNonC = sum_meta_category(@mcat_NON_C_CODE);
    if ($sNonC != $cNonC) { die "sNonC $sNonC, cNonC $cNonC"; }
    $cSymbol = sum_meta_category(@mcat_SYMBOL);
    if ($sSymbol != $cSymbol) { die "sSymbol $sSymbol, cSymbol $cSymbol"; }
    $cSymUknown = sum_meta_category(@mcat_SYMBOL_UNKNOWN);
    if ($sSymUnknown != $cSymUknown) { die "sSymUnknown $sSymUnknown, cSymUknown $cSymUknown"; }
    $cFail = sum_meta_category(@mcat_FAILURE);
    if ($sFail != $cFail) { die "sFail $sFail, cFail $cFail"; }
    $totLine = $cNull + $cConst + $cExp + $cStm + $cSyntax +
      $cType + $cNonC + $cSymUknown + $cFail + $cSymbol;

    breakdown_meta_category("mcat_NULL", $sNull, @mcat_NULL);
    breakdown_meta_category("mcat_CONSTANT", $sConst, @mcat_CONSTANT);
    breakdown_meta_category("mcat_NONCONSTANT_EXPRESSION", $sExp, @mcat_NONCONSTANT_EXPRESSION);
    breakdown_meta_category("mcat_STATEMENT", $sStm, @mcat_STATEMENT);
    breakdown_meta_category("mcat_SYNTAX", $sSyntax, @mcat_SYNTAX);
    breakdown_meta_category("mcat_TYPE", $sType, @mcat_TYPE);
    breakdown_meta_category("mcat_NON_C_CODE", $sNonC, @mcat_NON_C_CODE);
    breakdown_meta_category("mcat_SYMBOL", $sSymbol, @mcat_SYMBOL);
    breakdown_meta_category("mcat_SYMBOL_UNKNOWN", $sSymUnknown, @mcat_SYMBOL_UNKNOWN);
    breakdown_meta_category("mcat_FAILURE", $sFail, @mcat_FAILURE);
  }
}

########### Utility subroutines

# pct(x) returns a percentage using totline as the divisor
sub pct ( $ ) {
  my ($x) = @_;
  return percent2($x,$totLine);
}

sub sum_meta_category {
  die if !$fInitializedHeadings;
  my $sum = 0;
  foreach my $catname (@_) {
    my $catindex;
    { no strict; $catindex = $ {$catname}; }
    my $colname = $categoryname[$catindex];
    my $colno = $column_name_to_colno{$colname};
#DBG    print STDERR "Catname $catname -> catindex $catindex -> colname $colname -> colno $colno\n";
    $sum += $F[$colno];
  }
#DBG  print STDERR "Summed to $sum\n";
  return $sum;
}

sub breakdown_meta_category {
  my ($mcat_name, $mcat_total, @catnames) = @_;
  die if !$fInitializedHeadings;
  print STDERR "$mcat_name: $mcat_total\n";
  my $sum = 0;
  foreach my $catname (@catnames) {
    my $catindex;
    { no strict; $catindex = $ {$catname}; }
    my $colname = $categoryname[$catindex];
    my $colno = $column_name_to_colno{$colname};
 #DBG    print STDERR "Catname $catname -> catindex $catindex -> colname $colname -> colno $colno\n";
    $sum += $F[$colno];
    print STDERR "  " . two_significant_digits(percent2($F[$colno], $mcat_total)) . "%  $colname ($F[$colno])\n";
  }
  #DBG  print STDERR "Summed to $sum\n";
  if ($sum != $mcat_total)
    { die "sum $sum, mcat_total $mcat_total"; }
}
