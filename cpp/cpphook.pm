#!/uns/bin/perl
#$Id$

use hook_index_constants;

sub AddHook {
  my ($index,$fnref) = @_;
  @Hooks[$index] = $fnref;
}

sub PrintUID { 
  print "UID is $<\n"; 
}

sub Startup {
  open(CHOUT,">chout.listing") || die "Could not open output file: $!";
  select CHOUT;
}

sub do_define {
  my ($body) = @_;
  print "In do_define w/ body = $body\n";
}

sub handle_directive {
  my ($body) = @_;
  print "In handle_directive for $body\n";
}


# Add the hooks, now
AddHook($STARTUP,\&Startup);
AddHook($DO_DEFINE,\&do_define);
AddHook($HANDLE_DIRECTIVE,\&handle_directive);

1;
