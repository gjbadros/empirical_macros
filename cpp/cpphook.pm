#!/uns/bin/perl
@EXPORT = qw( PrintUID );

use hook_index_constants;

sub PrintUID { 
  print "UID is $<\n"; 
}

sub AddHook {
  my ($index,$fnref) = @_;
  @Hooks[$index] = $fnref;
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
AddHook($DO_DEFINE,\&do_define);
AddHook($HANDLE_DIRECTIVE,\&handle_directive);

1;
