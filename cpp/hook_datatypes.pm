#!/uns/bin/perl
@bitmap_masks = (1,2,4,8,16,32,64,128,256,512,1024,2048);

(
$PREDEFINED,
$RESTARGS,
) = @bitmap_masks;

(
$STRINGIFY,
$RAW_BEFORE,
$RAW_AFTER,
$REST_ARGS,
) = @bitmap_masks;


sub make_printable {
  my ($str) = @_;
  $str =~ s/([\000-\037])/sprintf("\\%03o",ord($1))/ge;
  return $str;
}

# FIXGJB: Should this return undef instead of 0 for false?
sub is_set {
  my ($flag, $bitmask) = @_;
  return ($flag & $bitmask)? 1 : 0;
}
