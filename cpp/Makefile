# $Id$
# By Greg J. Badros, Aug 25, 1997

#Ends up doing something like this
#gcc -c  -Dbool=char -DHAS_BOOL -I/usr/local/include -O    -DVERSION=\"0.01\" -DXS_VERSION=\"0.01\" -fpic -I/uns/lib/perl5.004/arch/CORE  cpp.c

CCCP=cccp
BISON = bison
CC=gcc

CFLAGS=-DYYDEBUG

GCC_CFLAGS=$(INTERNAL_CFLAGS) $(X_CFLAGS) $(T_CFLAGS) $(CFLAGS) -I./include
# This is the variable actually used when we compile.
ALL_CFLAGS = $(INTERNAL_CFLAGS) $(X_CFLAGS) $(T_CFLAGS) $(CFLAGS) $(XCFLAGS) -g -Wall

# Use yyparse()!
ALL_CFLAGS += -DGJB_PARSE -DCTGRAMMAR
ALL_CFLAGS += -DUSE_CPP -DSHOW_TYPES -DCT_DEBUG

# Directory where sources are, from where we are.
srcdir = .
PERLARCHDIR = /uns/lib//perl5.004/arch

INCLUDES = -I$(srcdir) -I$(srcdir)/config -I$(PERLARCHDIR)/CORE


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


# Output of "perl -M"ExtUtils::Embed" -e ccopts -e ldopts" running on uni --gjb
PERLLIBS = -rdynamic  -L/usr/local/lib /uns/lib/perl5.004/arch/auto/DynaLoader/DynaLoader.a -L/uns/lib/perl5.004/arch/CORE -lperl -lgdbm -ldb -lm -lc

## Other vars for configuring backcalls.{xs,c} to build properly
## (Credit Ken Fox [kfox@ford.com])
PERL=/uns/bin/perl
PERL-EMBED = -MExtUtils::Embed
PERL-EXTUTILS-DIR := $(shell $(PERL) -e 'use Config; print "$$Config{privlibexp}/ExtUtils";')
PERL-XSUBPP := $(PERL) $(PERL-EXTUTILS-DIR)/xsubpp -typemap $(PERL-EXTUTILS-DIR)/typemap
PERL-INCS := $(shell $(PERL) $(PERL-EMBED) -e ccopts)
STANDARD-INCS += $(PERL-INCS)
PERL-LINKAGE := $(shell $(PERL) $(PERL-EMBED) -e ldopts)
STANDARD-LINKAGE += $(PERL-LINKAGE)
C++-FLAGS := $(STANDARD-INCS) ...

GRAMMAR_OBJECTS := ansi-c.tab.o ansi-c-lex.o

CT_GRAMMAR_OBJECTS := lexer.o gram.tab.o ct-heap.o ct-nmetab.o ct-prnttree.o ct-symtab.o ct-token.o ct-tree.o ct-tree_stk.o

NON_GRAMMAR_OBJECTS =pcpp.o cpplib.o cpphook.o cpphash.o cppalloc.o cpperror.o cppexp.o \
  version.o backcalls.o bison-stack.o

OBJECTS = $(NON_GRAMMAR_OBJECTS) $(GRAMMAR_OBJECTS)

SD_OBJECTS = scan-decls.o cpplib.o cpphash.o cppalloc.o cpperror.o cppexp.o version.o backcalls.o cpphook.o

all: pcp3 paper/backcalls.tex paper/pcp3-hooks.tex

# Making the preprocessor/parser
# PCP^3 == Perl-enhanced C PreProcessor and Parser
# Used to be called pcppct (Perl-enhanced C Preprocesor and Parser using CTree)
pcp3: $(NON_GRAMMAR_OBJECTS) $(CT_GRAMMAR_OBJECTS) hook_index_constants.pm
	rm -f $@
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ $(filter-out hook_index_constants.pm,$^) $(LIBS) $(PERLLIBS)

pcpp.o: cpphook.h

# This target is obsolete -- 
pcpp: $(OBJECTS) cpphook.h
	rm -f $@
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS) $(PERLLIBS)

cppmain: $(OBJECTS)
	rm -f $@
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) $(PERLLIBS)


scandecls: $(SD_OBJECTS)
	rm -f $@
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) $(PERLLIBS)

tags:
	etags cppmain.[ch] cpplib.[ch] cpphash.[ch] cppalloc.[ch] cpperror.[ch] cppexp.[ch] version.c pcp.h tm.h bison_stack.[ch]

clean:
	rm -f *.o cppmain pcpp pcppct cpphook_names.h hook_index_constants.pm gram.tab.* lexer.c

cpp: $(CCCP)
	-rm -f cpp$(exeext)
	ln $(CCCP)$(exeext) cpp$(exeext) > /dev/null 2>&1 \
	 || cp $(CCCP)$(exeext) cpp$(exeext)
cccp: cccp.o cexp.o version.o
	$(CC) $(ALL_CFLAGS) $(LDFLAGS) -o $@ cccp.o cexp.o \
	  version.o $(LIBS)
cexp.o: $(srcdir)/cexp.c $(CONFIG_H) cpphook.h
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) -c $(srcdir)/cexp.c
$(srcdir)/cexp.c: $(srcdir)/cexp.y
	cd $(srcdir); $(BISON) -o cexp.c cexp.y

# Always use -I$(srcdir)/config when compiling.
.c.o:
	$(CC) -c $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) $<

cppmain.o: cppmain.c cpphook.h

cccp.o: cccp.c $(CONFIG_H) pcp.h version.c config.status cpphook.h
# The reason we use $(libdir)/g++-include rather than using libsubdir
# is for compatibility with the current version of libg++.
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
	  -DGCC_INCLUDE_DIR=\"$(libsubdir)/include\" \
	  -DGPLUSPLUS_INCLUDE_DIR=\"$(gxx_include_dir)\" \
	  -DLOCAL_INCLUDE_DIR=\"$(includedir)\" \
	  -DCROSS_INCLUDE_DIR=\"$(libsubdir)/sys-include\" \
	  -DTOOL_INCLUDE_DIR=\"$(tooldir)/include\" \
	  -c `echo $(srcdir)/cccp.c | sed 's,^\./,,'`

cpplib.o: cpplib.c $(CONFIG_H) cpplib.h cpphash.h config.status cpphook.h cpphook.h
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
	  -DGCC_INCLUDE_DIR=\"$(libsubdir)/include\" \
	  -DGPLUSPLUS_INCLUDE_DIR=\"$(gxx_include_dir)\" \
	  -DLOCAL_INCLUDE_DIR=\"$(includedir)\" \
	  -DCROSS_INCLUDE_DIR=\"$(libsubdir)/sys-include\" \
	  -DTOOL_INCLUDE_DIR=\"$(tooldir)/include\" \
	  -c `echo $(srcdir)/cpplib.c | sed 's,^\./,,'`

cpperror.o: cpperror.c $(CONFIG_H) cpplib.h cpphook.h

cppexp.o: cppexp.c $(CONFIG_H) cpplib.h cpphook.h

cpphash.o: cpphash.c cpplib.h cpphash.h cpphook.h

cppalloc.o: cppalloc.c $(CONFIG_H) cpphook.h

cpphook.o: cpphook_names.h cpphook.h

# Could use "-typemap typemap" w/ typemap file "typemap"
backcalls.c: backcalls.xs cpphook.h
	$(PERL-XSUBPP) $< > $@

backcalls.o: backcalls.c cppmain.h

hook_index_constants.pm: cpphook.h
	(awk <$< '\
BEGIN { print "#This file is automatically generated by make --- DO NOT EDIT!\n("; } \
END { print ") = (0..1000);\n\n1;\n__END__" } \
/^typedef enum hook_index_constants/ { f = 1; next } \
/^} HOOK_INDEX;/ { exit } \
f == 1 && $$0 ~ /^[ \t]*HI_/ { gsub("^ +HI_",""); print "\$$"$$0 }') > $@

enum_node_type.pm: cpplib.h
	./build-enum_node_type.pl <$< >$@

cpphook_names.h: cpphook.h
	(awk <$< '\
BEGIN { print "//\$$Id\$$\n// This file is automatically generated by make --- DO NOT EDIT!\nchar *hook_names[] = {"; } \
END { print "};\n" } \
/^typedef enum hook_index_constants/ { f = 1; next } \
/^} HOOK_INDEX;/ { exit } \
f == 1 { gsub("^ +HI_",""); gsub(",",""); print "\""$$0"\"," }') > $@

## ANSI C grammar included w/ CTree but *not* used by it
ansi-c-lex.c: ansi-c.l
	flex -o$@ $^

ansi-c.tab.c ansi-c.tab.h: ansi-c.y
	$(BISON) -d $^

bison-stack.o: bison-stack.c bison-stack.h lexer.h

## The C Grammar used by CTree 0.05
lexer.c: lexer.l
	flex -Pct_yy -o$@ $^

lexer.o: lexer.c cpphook.h

gram.tab.o: gram.tab.c cpphook.h

gram.tab.c gram.tab.h: gram.y
	$(BISON) -v -pct_yy -d $^

gram.h: gram.tab.h
	cp $< $@

grammar: $(GRAMMAR_OBJECTS) grammar.o
	gcc -g -o grammar $^ -lfl

.PHONY: tags clean

%.d: %.c
	$(SHELL) -ec '$(CC) -MM $(CPPFLAGS) $(INCLUDES) $< \
		| sed '\''s/$*\\.o[ :]*/& $@/g'\'' > $@'

paper/backcalls.tex: backcalls.xs
	extract-latex-comments <$< >$@

paper/pcp3-hooks.tex: cpphook.h
	extract-latex-comments <$< >$@

SOURCES = $(wildcard *.c)
include $(SOURCES:.c=.d)
