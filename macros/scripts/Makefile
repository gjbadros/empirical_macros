# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

#NOTE: You may need to cp this Makefile into the directory and
# make some changes (e.g. to the first several settings).  If so
# be sure to point COMMON_DIR to your scripts directory!

# Typical usage:
#   make data_analyze
#   # remove/rename .dstate to suppress dependence processing for a package
#   make data_reports
#   make
#   make copy


USER_PREFIX = /homes/gws/gjb/macros

# Directories
PKG_DIR := /scratch/gjb/packages
# Use only packages that start with these chars 
PKG_PREFIX :=   
# DO NOT USE "" for a null var, since that becomes a space
# Leave MUNGED_DIR blank or set to "munged/"
MUNGED_DIR := munged/
ANALYZE_OUTPUT_DIR := $(shell pwd)
COMMON_DIR := $(shell dirname `ls -l Makefile | awk '{print $$NF}'`)
#COMMON_DIR := /homes/gws/mernst/research/notkin/macros/scripts
#COMMON_DIR := /homes/gws/gjb/macros/scripts

# "=", not ":=", so that these are re-expanded every time (and setting
# USER_PREFIX in Makefile.user has an effect).
FAST_DIR = $(USER_PREFIX)/fast
PAPER_DIR = $(USER_PREFIX)/papers
# PAPER_FIG_DIR = $(USER_PREFIX)/papers/fig
PAPER_FIG_DIR = $(USER_PREFIX)/papers
PAPER_CPPP_DIR = $(USER_PREFIX)/papers/cppp
PAPER_ORIG_DIR = $(USER_PREFIX)/papers/orig

EXTRA_ANALYZE_FLAGS := -v
EXTRA_REPORTS_FLAGS := -v
#EXTRA_ANALYZE_FLAGS := -v -g14 -F$(FAST_DIR)

# not -DPROTO  because that is a macro that takes arguments
# other possibilities:
#   LIBC KR_headers STDARGS?  VARARGS?  I_STDARGS?  I_VARARGS?
#   NeedFunctionPrototypes has_prototypes HaveProtos PROTOTYPE FUNCPROTO
#   NO_PROTO HAVE_PROTOS USE_PROTOS HAVE_PROTOTYPES USE_PROTOTYPES
CPPP_FLAGS := -DHAS_BOOL -DHAVE_STDC -DNULL=0 -DSTANDARD_C -DSTDC -DSTDC_HEADERS -D__STDC__ -D__cplusplus -D__cplusplus__ -Dc_plusplus -Dcplusplus -D_POSIX_SOURCE -D_POSIX_C_SOURCE=2 -D__USE_POSIX -D__USE_POSIX2

include Makefile.$(USER)

SCRIPTS := em_analyze em_reports em_constants.pm em_depend.pm em_util.pm cline.pm paren.pm
SCRIPTSPATH := $(addprefix $(USER_PREFIX)/,$(SCRIPTS))
SCRIPTSFAST := $(addprefix $(FAST_DIR)/,$(SCRIPTS))

PKG_DIRS_NOMUNGE := $(shell zsh -c "setopt extendedglob; echo $(PKG_DIR)/$(PKG_PREFIX)*~*\~(/:t)")
PKG_DIRS := $(addsuffix /$(MUNGED_DIR),$(PKG_DIRS_NOMUNGE))

# Should make this use PKG_DIRS_NOMUNGE, not recompute from scratch.
PKGS := $(shell zsh -c "setopt extendedglob; echo $(PKG_DIR)/$(PKG_PREFIX)*~*\~(/:t) | sed -e 's/-[^ ]*//g' | uniq")

STATE := $(addsuffix .state,$(PKGS))
DSTATE := $(addsuffix .dstate,$(PKGS))
ESTATE := $(addsuffix .estate,$(PKGS))
STAT := $(addsuffix .stat,$(PKGS))
CATG := $(addsuffix .catg,$(PKGS))
ERR  := $(addsuffix .err,$(PKGS))
EVIL := $(addsuffix .evil,$(PKGS))
FNLN := $(addsuffix .fnln,$(PKGS))
FUNC := $(addsuffix .func,$(PKGS))
LINT := $(addsuffix .lint,$(PKGS))
PROP := $(addsuffix .prop,$(PKGS))
MAC  := $(addsuffix .mac,$(PKGS))
HMAC  := $(addsuffix .hmac,$(PKGS))
CCD  := $(addsuffix .ccd,$(PKGS))
DEPEND  := $(addsuffix .depend,$(PKGS))
SDEPEND  := $(addsuffix .sdepend,$(PKGS))
SDEPEND_BY_MACRO  := $(addsuffix .bymacro,$(SDEPEND))
# freq{use,def,ddf}_cum is created by em_reports
USECUM  := $(addsuffix .frequse_cum,$(PKGS))
DEFCUM  := $(addsuffix .freqdef_cum,$(PKGS))
DDFCUM  := $(addsuffix .freqddf_cum,$(PKGS))
NUMARG  := $(addsuffix .numarg,$(PKGS))
CATUSECUM  := cat-*.frequse_cum
CATDEFCUM  := cat-*.freqdef_cum
CATDDFCUM  := cat-*.freqddf_cum

PERR := $(addsuffix .perr,$(PKGS))

TEXT_TABLES :=	tbl-package-sizes \
		tbl-package-sizes-with-uses \
		tbl-def-frequency \
		tbl-ddf-frequency \
		tbl-use-frequency \
		tbl-cat-def-frequency \
		tbl-cat-ddf-frequency \
		tbl-cat-use-frequency \
		tbl-where-used \
		tbl-ccd-categories \
		tbl-properties-subset \
		tbl-properties-percents \
		tbl-inclusion-dependences-by-line \
		tbl-expansion-dependences-by-line \
		tbl-any-dependences-by-line \
		tbl-inclusion-dependences-by-macro \
		tbl-expansion-dependences-by-macro \
		tbl-any-dependences-by-macro \
		tbl-def-categories \
		tbl-directives-breakdown \
		tbl-lint \
		tbl-dep-byline \
		tbl-cat-numargs

RAW_TABLES := tbl-directives-hist tbl-subset-categories

LATEX_TABLES := tbl-package-sizes.tex \
		tbl-subset-categories.tex \
		tbl-subset-properties.tex \
		tbl-where-used.tex \
		tbl-lint.tex

ALL_TABLES := $(TEXT_TABLES) $(RAW_TABLES) $(LATEX_TABLES)

PAPER_TABLES :=  $(TEXT_TABLES) $(LATEX_TABLES)

# Do data_analyze first, as data_reports may core dump
all:	data_analyze $(PAPER_TABLES)

clean:
	rm -f $(ALL_TABLES)
	rm -fr made-catdefuse

# Use this with extreme caution!
totally_clean: clean clean_reports
	# These are the files exempted by macros-clean-reports, except Makefiles
	rm -f $(STATE) $(DSTATE) $(ESTATE) $(ERR) $(EVIL) $(OUT) $(PERR)

foo: $(DEFCUM)
	average-cums.pl $(DEFCUM)

# To make static executables:
#   Unpack all the tar files from /scratch/mernst/archive into /scratch/mernst/pack-static
#   setenv CC "gcc -Dstatic="
#   For each package:
#     Configure:
#       * For Mosaic, bash
#          (Do nothing)
#       * For RasMol, fvwm, ghostview, xfig
#          xmkmf -a
#       * For bc, bison, cvs, emacs, flex, gcc, genscript, gzip, m4, rcs, zephyr, zsh
#          ./configure
#       * For gawk
#          ./configure linux
#       * For gnuchess
#          cd src; ./configure
#       * For gnuplot
#          cp makefile.unx Makefile
#          make CC="gcc -Dstatic=" linux
#       * For gs
#          ln -s unix-gcc.mak makefile   # might already be done
#       * For perl
#          rm -f config.sh; Configure -d
#          Where "pcp3" appears in /scratch/gjb/packages/perl-5.003/, use "gcc -Dstatic="
#       * For plan
#          cd src
#          Edit Makefile:
#           * add "-I/homes/gws/gjb/include" to LINUX_C
#           * For "linux:" target, use MYCC="gcc -Dstatic="
#          make CC="gcc -Dstatic=" linux
#       * For remind
#          cp -p /scratch/gjb/packages/remind-03.00.16/Makefile .
#       * For workman
#          cp -p Makefile.linux Makefile
#     make CC="gcc -Dstatic="
#     make CC="gcc -Dstatic=" -k
#     # Sometimes (eg, Mosaic) it seems I want:  make 'CC="gcc -Dstatic="'
#     Get symbols; ignore any errors, including "Is a directory" and "File format not recognized"
#       rm -f symbols.gjbmde; find . -name "*.o" -o -perm +u+x | xargs nm | cleanup-nm-output > symbols.gjbmde
#   Copy the symbols.gjbmde files into the main munged directories and
#     rerun "make data_analyze", etc.


###########################################################################
### Data
###

data_analyze: $(STATE)

data_reports: $(STAT)

clean_reports:
	macros-clean-reports

# Could also depend on $(PKG_DIR)/$(ANALYZE_OUTPUT_DIR)*/c-files-listing
%.state: #[REMOVE THIS # TO DEPEND ON SCRIPTS] $(COMMON_DIR)/../em_analyze
	em_make_state_file $(PKG_DIR) $(ANALYZE_OUTPUT_DIR) $@ $(EXTRA_ANALYZE_FLAGS) || echo $(basename $@) >> $(ANALYZE_OUTPUT_DIR)/failures
	stringify-state-file $(basename $@).*state
	@ -chgrp macros $(basename $@).*
	@ -chmod g+rw $(basename $@).*

%.stat: %.state #[REMOVE THIS # TO DEPEND ON SCRIPTS] $(COMMON_DIR)/../em_reports
	em_reports -s $< -t $(EXTRA_REPORTS_FLAGS) -d $(ANALYZE_OUTPUT_DIR):$(basename $@)
	@ -chgrp macros $(basename $@).*
	@ -chmod g+rw $(basename $@).*


###########################################################################
### Text tables
###

text_tables:	$(TEXT_TABLES)

tbl-package-sizes: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@

tbl-package-sizes-with-uses: tbl-package-sizes made-catdefuse
	macros-make-tbl-package-sizes-with-uses $^ > $@

# To add commas, do this in Emacs:
# (query-replace-regexp "\\([0-9]\\)\\([0-9][0-9][0-9]\\)\\([^0-9]\\)" "\\1,\\2\\3" nil)
tbl-package-sizes.tex: tbl-package-sizes package_num_files
	(echo "Package	Version	Physical lines	NCNB lines	Files	Description"; join -t'	' $(COMMON_DIR)/package_versions tbl-package-sizes | join -t'	' - package_num_files | join -t'	' - $(COMMON_DIR)/package_descriptions ) | latexify > $@

tbl-def-frequency: $(DEFCUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-ddf-frequency: $(DDFCUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-use-frequency: $(USECUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-cat-def-frequency: made-catdefuse
	macros-make-tbl-frequsedef-from-cum $(CATDEFCUM) > $@

tbl-cat-ddf-frequency: made-catdefuse
	macros-make-tbl-frequsedef-from-cum $(CATDDFCUM) > $@

tbl-cat-use-frequency: made-catdefuse
	macros-make-tbl-frequsedef-from-cum $(CATUSECUM) > $@

tbl-where-used: $(HMAC)
	macros-make-how-used-ni-tbl-from-hmac.pl $^ > $@

tbl-where-used.tex: tbl-where-used
	latexify $<  >$@

tbl-ccd-categories: $(CCD)
	( head -1 $< && grep -v '^#' $^ | sed -e 's/:/	/' -e 's/.ccd//' ) > $@

# this file is just a note that we have the cat-* files around, now
made-catdefuse:	$(DEFCUM) $(DDFCUM) $(USECUM)
	rm -f *.*-* cat-* # careful w/ what this deletes!
	macros-extract-defuse-categories $^
	date > made-catdefuse

###########################################################################
### Raw tables
###

raw: $(RAW_TABLES)

tbl-directives-hist: $(STAT)
	macros-make-directives-raw-hist-from-stats $^ > $@

tbl-directives-breakdown: tbl-directives-hist
	macros-bake-raw-directives-hist $^ > $@


###########################################################################
### LaTeX tables
###

tbl-def-categories.tex: $(STAT)
	macros-make-categories-tbl-from-stat.pl $^ > $@

tbl-def-categories: $(STAT)
	macros-make-categories-tbl-from-stat.pl -t -p $^ > $@

tbl-subset-categories: $(MAC)
	macros-make-subset-metacateg-from-mac -m $^ | sort | uniq -c -w12 | sort -nr > $@

tbl-subset-categories.tex: tbl-subset-categories
	cat $< | latexify-meta-mark-table `sum-column 1 <$<` > $@
#	head -50 $< | latexify-meta-mark-table `sum-column 1 <$<` > $@
# the head -50 chooses how many lines to include in the latex table

tbl-subset-properties.tex: tbl-properties-percents tbl-properties-subset
	macros-make-subset-prop-tbl > $@

tbl-lint.tex: tbl-lint
	macros-make-lint-table < $< > $@

tbl-lint:	$(LINT)
	lint-summarize $^ > $@

# tbl-lint-warnings: $(LINT)
# 	combine-histogram -p'\) ' -s '^Total.*: (.*)' $^ > $@

tbl-properties-subset: $(PROP)
	combine-histogram -s'#.*histogram: total defs = (.*)' -e '^#' $^ > $@

tbl-properties-percents: $(PROP)
	combine-histogram -p'\)' -s'#.*percentages: total defs = (.*)' -e '^#' $^ > $@

# Be sure to not count lines in c-files-listing that start with #.
# Also, be sure that either the c-files-listing links are updated to point
# to the current files, or that both gjb and mernst are cvs-updated after
# changes get made to a c-files-listing files.
# Fixed up /scratch/gjb/packages using
# for i in */munged/c-files-listing; ln -s $i ${i%%-*}-c-files-listing

package_num_files:
	cd $(PKG_DIR); \
	(for i in *c-files-listing; do echo -n $${i%%-*} && grep -v '^\#' < $$i | wc -l; done ) | awk '{print $$1 "\t" $$2; sum += $$2} END {print "zzz<total>\t" sum}' > $(ANALYZE_OUTPUT_DIR)/$@


tbl-inclusion-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Inclusion $^ > $@

tbl-any-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Any `only-non-empty-files $^` > $@

tbl-expansion-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Expansion `only-non-empty-files $^` > $@

tbl-dep-byline: tbl-inclusion-dependences-by-line tbl-expansion-dependences-by-line tbl-any-dependences-by-line
	macros-make-dep-byline $^ > $@

%.numarg: %.catg
	macros-make-numarg-from-catg $< >$@

# %.sdepend is just the tail of %.depend
%.sdepend: %.depend
	awk '/======================================================================/,/^  thislinewontmatchanything  $$/' < $< > $@

%.sdepend.bymacro: %.sdepend
	macros-simplify-dependences-by-macro $<

%.hmac: %.mac
	macros-how-used-ni-from-mac $< > $@

tbl-inclusion-dependences-by-macro: $(SDEPEND_BY_MACRO)
	macros-make-dependences-by-macro 4 `only-non-empty-files $^` > $@ # column 4 has inclusion dependences

tbl-expansion-dependences-by-macro: $(SDEPEND_BY_MACRO)
	macros-make-dependences-by-macro 5 `only-non-empty-files $^` > $@ # column 5 has expansion dependences

tbl-any-dependences-by-macro: $(SDEPEND_BY_MACRO)
	macros-make-dependences-by-macro 6 `only-non-empty-files $^` > $@ # column 6 has any dependences

sdepend: $(SDEPEND)

sdepend_bymacro: $(SDEPEND_BY_MACRO)

catnumargs: $(NUMARG)
	awk '{print $$1" "$$3}' $^ | demux-macro-categories-to-file

CATNUMARGS := catnumarg-not_c_code catnumarg-constant catnumarg-expression \
	 catnumarg-syntactic catnumarg-null_define catnumarg-other catnumarg-statement \
	 catnumarg-type_related catnumarg-failure catnumarg-unknown_symbol

$(CATNUMARGS): $(NUMARG)
	awk '{print $$1" "$$3}' $^ | demux-macro-categories-to-file

catnumarg-Mean:  $(CATNUMARGS)
	cat $^ | sort -n > $@

tbl-cat-numargs: catnumarg-Mean $(CATNUMARGS)
	@ -rm -f catnumarg-\#category 
	macros-make-tbl-cat-numargs $^ > tbl-cat-numargs

###########################################################################
### Etc.
###

showvars:
	@echo USER_PREFIX = $(USER_PREFIX)
	@echo PKG_DIR = $(PKG_DIR)
	@echo PKG_DIRS = $(PKG_DIRS)
	@echo PKG_DIRS_NOMUNGE = $(PKG_DIRS_NOMUNGE)
	@echo PKG_PREFIX = =$(PKG_PREFIX)=
	@echo PKGS = $(PKGS)
	@echo STAT = $(STAT)
	@echo TEXT_TABLES = $(TEXT_TABLES)
	@echo RAW_TABLES = $(RAW_TABLES)
	@echo LATEX_TABLES = $(LATEX_TABLES)
	@echo CVS_LATEX_TABLES = $(CVT_LATEX_TABLES)
	@echo ALL_TABLES = $(ALL_TABLES)
	@echo COMMON_DIR = $(COMMON_DIR)
	@echo SCRIPTS = $(SCRIPTS)
	@echo SCRIPTSPATH = $(SCRIPTSPATH)
	@echo EXTRA_ANALYZE_FLAGS = $(EXTRA_ANALYZE_FLAGS)
	@echo EXTRA_REPORTS_FLAGS = $(EXTRA_REPORTS_FLAGS)

copy: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp -p $(PAPER_TABLES) $(PAPER_FIG_DIR)

copycppp: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp -p $(PAPER_TABLES) $(PAPER_CPPP_DIR)

copyorig: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp -p $(PAPER_TABLES) $(PAPER_ORIG_DIR)

# Version of scripts which is faster but does less checking.
fast:	$(SCRIPTSPATH)
	for i in $(SCRIPTSPATH); do bn=$(FAST_DIR)/`basename $$i`; rm -f $$bn; remove_check_args $$i > $$bn; chmod +x $$bn; chmod -w $$bn; done
	@echo "Ensure $(FAST_DIR) is first on your path, and rehash if you changed it!"

## This target doesn't actually work; but it is something you can paste into
## a shell running csh to do the work.
# Run cpppfull on the includes and packages
cppp_packages:
	cd /scratch/mernst/include-cppp
	cppp $(CPPP_FLAGS) `find-c`
	cd /scratch/mernst/pack-cppp
	foreach PACK ($PKG_DIRS)
	  echo $PACK; cd $PACK; cppp $(CPPP_FLAGS) `grep -v '^#' c-files-listing`; cd /scratch/mernst/pack-cppp
	end

# This tells make not to remove *.state files created en route to making, e.g., a
# *.stat file
.PRECIOUS: %.state

.PHONY: all clean totally_clean showvars text_tables data_analyze data_reports raw copy fast sdepend sdepend_bymacro catnumargs
