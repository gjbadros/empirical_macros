#!/uns/bin/perl -n
# Runs on cpplib.h as stdin,
BEGIN
  { print <<'END_HEADER'
#This file is generated automatically from cpplib.h -- DO NOT EDIT!
(
END_HEADER
 ; $cItems = 0; $f = 0;
}

if (/^enum node_type \{/) {
  $f = 1;
  next;
}
next unless $f == 1;

exit if (/\};/);

if (/^ *(\w+)\s*=\s*(\d+)/ && !defined($start_index)) {
  $start_index = $2;
  if ($start_index < 0) {
    warn "Got start_index = $start_index, negative\n";
  } else {
    my $i = 0;
    while ($i++ < $start_index) {
      push @list, 'BAD';
    }
  }
}

if (/^ *(\w+)/) {
  print "\$", $1, ",\n";
  push @list,$1;
  $cItems++;
}

END { print ") = ($start_index..",$start_index+$cItems+1,");\n";
      print "\@node_type_name = (", join (',',@list), ");\n1;\n__EOF__"; }


