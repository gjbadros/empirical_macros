#!/uns/bin/perl -w
# Example of minimal functional pcp3 script
use pcp3;

AddHook("STARTUP",\&Startup);

sub Startup {
  print STDERR "I am running\n";
}
