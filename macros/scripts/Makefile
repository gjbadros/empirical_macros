# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

#NOTE: You may need to cp this Makefile into the directory and
# make some changes (e.g. to the first several settings).  If so
# be sure to point COMMON_DIR to your scripts directory!

USER_PREFIX = /homes/gws/gjb/macros

# Directories
PKG_DIR := /tmp/gjb/packages
# Use only packages that start with these chars 
PKG_PREFIX :=   
# DO NOT USE "" for a null var, since that becomes a space
ANALYZE_OUTPUT_DIR := $(shell pwd)
COMMON_DIR := $(shell dirname `ls -l Makefile | awk '{print $$NF}'`)
#COMMON_DIR := /homes/gws/mernst/research/notkin/macros/scripts
#COMMON_DIR := /homes/gws/gjb/macros/scripts

# "=", not ":=", so that these are re-expanded every time (and setting
# USER_PREFIX in Makefile.user has an effect).
FAST_DIR = $(USER_PREFIX)/fast
PAPER_DIR = $(USER_PREFIX)/papers
PAPER_CPPP_DIR = $(USER_PREFIX)/papers/cppp
PAPER_ORIG_DIR = $(USER_PREFIX)/papers/orig

EXTRA_ANALYZE_FLAGS := -v
EXTRA_REPORTS_FLAGS := -v
#EXTRA_ANALYZE_FLAGS := -v -g14 -F$(FAST_DIR)

include Makefile.user

SCRIPTS := em_analyze em_reports em_constants.pm em_depend.pm em_util.pm cline.pm paren.pm
SCRIPTSPATH := $(addprefix $(USER_PREFIX)/,$(SCRIPTS))
SCRIPTSFAST := $(addprefix $(FAST_DIR)/,$(SCRIPTS))

PKGS := $(shell zsh -c "setopt extendedglob; echo $(USER_PREFIX)/packages/$(PKG_PREFIX)*(.:t) | sed -e 's/-[^ ]*//g'")

STATE := $(addsuffix .state,$(PKGS))
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
USECUM  := $(addsuffix .frequse_cum,$(PKGS))
DEFCUM  := $(addsuffix .freqdef_cum,$(PKGS))
DDFCUM  := $(addsuffix .freqddf_cum,$(PKGS))
CATUSECUM  := cat-*.frequse_cum
CATDEFCUM  := cat-*.freqdef_cum
CATDDFCUM  := cat-*.freqdef_cum

PERR := $(addsuffix .perr,$(PKGS))

TEXT_TABLES :=	tbl-package-sizes \
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
		tbl-def-categories \
		tbl-directives-breakdown \
		tbl-lint

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

###########################################################################
### Data
###

data_analyze: $(STATE)

data_reports: $(STAT)

clean_reports:
	macros-clean-reports

# Could also depend on $(PKG_DIR)/$(ANALYZE_OUTPUT_DIR)*/c-files-listing
%.state: #[REMOVE THIS # TO DEPEND ON SCRIPTS] $(COMMON_DIR)/../em_analyze
	em_make_state_file $(PKG_DIR) $(ANALYZE_OUTPUT_DIR) $@ $(EXTRA_ANALYZE_FLAGS) || echo $< >> $(ANALYZE_OUTPUT_DIR)/failures
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
	macros-make-subset-metacateg-from-mac -m $^ | sort | uniq -c -w21 | sort -nr > $@

tbl-subset-categories.tex: tbl-subset-categories
	cat $< | latexify-meta-mark-table `sum-column 1 <$^` > $@
#	head -50 $< | latexify-meta-mark-table `sum-column 1 <$^` > $@
# the head -50 chooses how many lines to include in the latex table

tbl-subset-properties.tex: tbl-properties-percents tbl-properties-subset
	macros-make-subset-prop-tbl > $@

tbl-lint.tex: tbl-lint
	macros-make-lint-table < $^ > $@

tbl-lint:	$(LINT)
	lint-summarize < $^ > $@

# tbl-lint-warnings: $(LINT)
# 	combine-histogram -p'\) ' -s '^Total.*: (.*)' $^ > $@

tbl-properties-subset: $(PROP)
	combine-histogram -s'#.*histogram: total defs = (.*)' -e '^#' $^ > $@

tbl-properties-percents: $(PROP)
	combine-histogram -p'\)' -s'#.*percentages: total defs = (.*)' -e '^#' $^ > $@

package_num_files:
	cd $(USER_PREFIX)/packages; \
	wc -l *c-files-listing | awk -F- '{print $$1}' | awk '{print $$2 "\t" $$1}' > $(ANALYZE_OUTPUT_DIR)/$@


tbl-inclusion-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Inclusion $^ > $@

tbl-any-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Any `only-non-empty-files $^` > $@

tbl-expansion-dependences-by-line: $(SDEPEND)
	macros-make-dependences-by-line Expansion `only-non-empty-files $^` > $@

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

sdepend: $(SDEPEND)

sdepend_bymacro: $(SDEPEND_BY_MACRO)

###########################################################################
### Etc.
###

showvars:
	@echo USER_PREFIX = $(USER_PREFIX)
	@echo PKG_DIR = $(PKG_DIR)
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
	cp -p $(PAPER_TABLES) $(PAPER_DIR)

copycppp: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp -p $(PAPER_TABLES) $(PAPER_CPPP_DIR)

copyorig: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp -p $(PAPER_TABLES) $(PAPER_ORIG_DIR)

fast:	$(SCRIPTSPATH)
	for i in $(SCRIPTSPATH); do bn=$(FAST_DIR)/`basename $$i`; rm -f $$bn; remove_check_args $$i > $$bn; chmod +x $$bn; chmod -w $$bn; done
	@echo "Ensure $(FAST_DIR) is first on your path, and rehash if you changed it!"

# This tells make not to remove *.state files created en route to making, e.g., a
# *.stat file
.PRECIOUS: %.state

.PHONY: all clean showvars text_tables data_analyze data_reports raw copy fast sdepend sdepend_bymacro
