#!/uns/bin/perl -w
use English;
use em_util;
my %ctype;
my $total = 0;
foreach my $filename (@ARGV) {
  open (IN,"<$filename") || die "Can not open $filename: $!";
  while (<IN>) {
    next if $_ =~ m/^\w*$/;
    my ($count, $type) = split(" ",$_);
    $type =~ s/\s*Redef\s*//;
    if ($type eq "") {
      $type = "NoUses";
    }
      
    if (!defined($ctype{$type})) {
      $ctype{$type} = 0;
    }
    $ctype{$type} += $count;
    $total += $count;
  }
  close (IN);
}

my %keyheading = 
  (
   Code => "Code",
   CodeMacro => "Code, macro",
   Cond => "Cond.",
   MacroCond => "Cond., macro",
   Macro => "Macro",
   CodeCond => "Code, cond.",
   CodeMacroCond => "Code, cond., macro",
   NoUses => "No uses"
  );
	       

$OFS = "\t";
foreach my $key (qw(Code CodeMacro Cond MacroCond Macro CodeCond CodeMacroCond NoUses) ) {
  print $keyheading{$key},# $ctype{$key},
  sprintf("%s%%",two_significant_digits($ctype{$key}/$total*100)),"\n";
}
print "Total",$total,"(100%)" ."\n";

