#!/uns/bin/perl -w
use pcp3;
AddHook("TYPEDEF",\&Typedef);
AddHook("EXIT",\&Exit);

sub Typedef {
  my ($name) = @_;
  push @typedefs, $name;
  $num_typedefs{pcp3::Fname()}++;
}

sub Exit {
  my ($return_value) = @_;
  print "Typedefs:\n", join("\n",sort @typedefs), "\n\n";
  print "Number per file:\n";
  foreach my $fname (sort keys %num_typedefs) {
    print $fname, " had ", $num_typedefs{$fname}, " typedefs\n";
  }
}
