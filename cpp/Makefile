CCCP=cccp
BISON = bison
CC=gcc

# Directory where sources are, from where we are.
srcdir = .
INCLUDES = -I. -I$(srcdir) -I$(srcdir)/config

# Common prefix for installation directories.
# NOTE: This directory must exist when you start installation.
prefix = /usr
# Directory in which to put localized header files. On the systems with
# gcc as the native cc, `local_prefix' may not be `prefix' which is
# `/usr'.
# NOTE: local_prefix *should not* default from prefix.
local_prefix = /usr/local
# Directory in which to put host dependent programs and libraries
exec_prefix = $(prefix)
# Directory in which to put the executable for the command `gcc'
bindir = $(exec_prefix)/bin
# Directory in which to put the directories used by the compiler.
libdir = $(exec_prefix)/lib
# Directory in which the compiler finds executables, libraries, etc.
libsubdir = $(libdir)/gcc-lib/$(target)/$(version)
# Directory in which the compiler finds g++ includes.
gxx_include_dir = $(libdir)/g++-include
# Directory to search for site-specific includes.
includedir = $(local_prefix)/include
# assertdir is overridden in cross-make.
# (But this currently agrees with what is in cross-make.)
assertdir = $(tooldir)/include
# where the info files go
infodir = $(prefix)/info
# Extension (if any) to put in installed man-page filename.
manext = .1
objext = .o
exeext =

# Directory in which to put man pages.
mandir = $(prefix)/man/man1
# Directory in which to find other cross-compilation tools and headers.
# Used in install-cross.
tooldir = $(exec_prefix)/$(target)
# Dir for temp files.
tmpdir = /tmp

# Additional system libraries to link with.
CLIB=

# Change this to a null string if obstacks are installed in the
# system library.
OBSTACK=obstack.o

# Specify the rule for actually making libgcc.a,
LIBGCC = libgcc.a
# and the rule for installing it.
INSTALL_LIBGCC = install-libgcc

# Specify the rule for actually making libgcc1.a.
# The value may be empty; that means to do absolutely nothing
# with or for libgcc1.a.
LIBGCC1 = libgcc1.a

# Specify the rule for making libgcc1.a for a cross-compiler.
# The default rule assumes that libgcc1.a is supplied by the user.
CROSS_LIBGCC1 = libgcc1.cross

# Specify the rule for actually making libgcc2.a.
LIBGCC2 = libgcc2.a

# Options to use when compiling libgcc2.a.
# -g1 causes output of debug info only for file-scope entities.
# we use this here because that should be enough, and also
# so that -g1 will be tested.
LIBGCC2_CFLAGS = -O2 $(LIBGCC2_INCLUDES) $(GCC_CFLAGS) $(TARGET_LIBGCC2_CFLAGS) -g1

# Additional options to use when compiling libgcc2.a.
# Some targets override this to -Iinclude
LIBGCC2_INCLUDES =

# Additional target-dependent options for compiling libgcc2.a.
TARGET_LIBGCC2_CFLAGS = 

# Things which must be built before building libgcc2.a.
# Some targets override this to stmp-int-hdrs
LIBGCC2_DEPS =

# Enquire target (This is a variable so that a target can choose not to
# build it.)
ENQUIRE = enquire

# libgcc1-test target (must also be overridable for a target)
LIBGCC1_TEST = libgcc1-test

# List of extra executables that should be compiled for this target machine
# that are used for compiling from source code to object code.
# The rules for compiling them should be in the t-* file for the machine.
EXTRA_PASSES =

# Like EXTRA_PASSES, but these are used when linking.
EXTRA_PROGRAMS = 

# List of extra object files that should be compiled for this target machine.
# The rules for compiling them should be in the t-* file for the machine.
EXTRA_PARTS = crtbegin.o crtend.o

# List of extra object files that should be compiled and linked with
# compiler proper (cc1, cc1obj, cc1plus).
EXTRA_OBJS =

# List of extra object files that should be compiled and linked with
# the gcc driver.
EXTRA_GCC_OBJS =

# List of additional header files to install.
# Often this is edited directly by `configure'.
EXTRA_HEADERS =

# Set this to `ld' to enable use of collect2.
# USE_COLLECT2 =
# It is convenient for configure to add the assignment at the beginning,
# so don't override it here.

# List of extra C and assembler files to add to libgcc1.a.
# Assembler files should have names ending in `.asm'.
LIB1FUNCS_EXTRA = 

# List of extra C and assembler files to add to libgcc2.a.
# Assembler files should have names ending in `.asm'.
LIB2FUNCS_EXTRA = 

# Default float.h source to use for cross-compiler.
CROSS_FLOAT_H=float.h-cross

# Program to convert libraries.
LIBCONVERT = 

# Control whether header files are installed.
INSTALL_HEADERS=install-headers

# Options for tar when copying trees.  So HPUX can override it.
TAROUTOPTS = xpBf

# Select which version of fixincludes to use (I.E. regular versus SVR4)
# This value is overridden directly by configure.
FIXINCLUDES = Makefile.in

# Additional directories of header files to run fixincludes on.
# These should be directories searched automatically by default
# just as /usr/include is.
# *Do not* use this for directories that happen to contain 
# header files, but are not searched automatically by default.
# On most systems, this is empty.
OTHER_FIXINCLUDES_DIRS=

# List of things which should already be built whenever we try to use xgcc
# to compile anything (without linking).
GCC_PASSES=xgcc cc1 cpp $(EXTRA_PASSES)

# List of things which should already be built whenever we try to use xgcc
# to link anything.
GCC_PARTS=$(GCC_PASSES) $(LIBGCC) $(EXTRA_PROGRAMS) $(USE_COLLECT2) $(EXTRA_PARTS)

# Directory to link to, when using the target `maketest'.
DIR = ../gcc

# Guaranteed to not exist when not passing md through cpp.
# This value is overridden directly by configure.
MD_FILE = md-cpp-not-used

# Flags to use when cross-building GCC.
# Prefix to apply to names of object files when using them
# to run on the machine we are compiling on.
HOST_PREFIX=
# Prefix to apply to names of object files when compiling them
# to run on the machine we are compiling on.
# The default for this variable is chosen to keep these rules 
# out of the way of the other rules for compiling the same source files.
HOST_PREFIX_1=loser-
HOST_CC=$(CC)
HOST_CFLAGS=$(ALL_CFLAGS)
HOST_CLIB=$(CLIB)
HOST_LDFLAGS=$(LDFLAGS)
HOST_CPPFLAGS=$(ALL_CPPFLAGS)
HOST_ALLOCA=$(ALLOCA)
HOST_MALLOC=$(MALLOC)
HOST_OBSTACK=$(OBSTACK)

# Making the preprocessor
cpp: $(CCCP)
	-rm -f cpp$(exeext)
	ln $(CCCP)$(exeext) cpp$(exeext) > /dev/null 2>&1 \
	 || cp $(CCCP)$(exeext) cpp$(exeext)
cccp: cccp.o cexp.o version.o $(LIBDEPS)
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ cccp.o cexp.o \
	  version.o $(LIBS)
cexp.o: $(srcdir)/cexp.c $(CONFIG_H)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) -c $(srcdir)/cexp.c
$(srcdir)/cexp.c: $(srcdir)/cexp.y
	cd $(srcdir); $(BISON) -o cexp.c cexp.y

cccp.o: cccp.c $(CONFIG_H) pcp.h version.c config.status
# The reason we use $(libdir)/g++-include rather than using libsubdir
# is for compatibility with the current version of libg++.
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
	  -DGCC_INCLUDE_DIR=\"$(libsubdir)/include\" \
	  -DGPLUSPLUS_INCLUDE_DIR=\"$(gxx_include_dir)\" \
	  -DLOCAL_INCLUDE_DIR=\"$(includedir)\" \
	  -DCROSS_INCLUDE_DIR=\"$(libsubdir)/sys-include\" \
	  -DTOOL_INCLUDE_DIR=\"$(tooldir)/include\" \
	  -c `echo $(srcdir)/cccp.c | sed 's,^\./,,'`

cppmain: cppmain.o cpplib.o cpphash.o cppalloc.o cpperror.o cppexp.o \
  version.o $(LIBDEPS)
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ cppmain.o cpplib.o cpphash.o \
	  cppalloc.o cpperror.o cppexp.o version.o $(LIBS)

cpplib.o: cpplib.c $(CONFIG_H) cpplib.h cpphash.h config.status
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
	  -DGCC_INCLUDE_DIR=\"$(libsubdir)/include\" \
	  -DGPLUSPLUS_INCLUDE_DIR=\"$(gxx_include_dir)\" \
	  -DLOCAL_INCLUDE_DIR=\"$(includedir)\" \
	  -DCROSS_INCLUDE_DIR=\"$(libsubdir)/sys-include\" \
	  -DTOOL_INCLUDE_DIR=\"$(tooldir)/include\" \
	  -c `echo $(srcdir)/cpplib.c | sed 's,^\./,,'`

cpperror.o: cpperror.c $(CONFIG_H) cpplib.h

cppexp.o: cppexp.c $(CONFIG_H) cpplib.h

cpphash.o: cpphash.c cpplib.h cpphash.h

cppalloc.o: cppalloc.c $(CONFIG_H)