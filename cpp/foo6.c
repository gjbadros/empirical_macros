# if foo
#  if arch_sizeof_float == arch_sizeof_int
#    define is_fge1(f) (sizeof(f) == sizeof(float) ? (_f_as_int(f)) >= IEEE_f1 : (f) >= 1.0)
#  else
#  endif

#endif
