# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

#NOTE: You may need to cp this Makefile into the directory and
# make some changes (e.g. to the first several settings).  If so
# be sure to point COMMON_DIR to your scripts directory!

# Directories
PKG_DIR := /tmp/gjb/packages
ANALYZE_OUTPUT_DIR := /tmp/gjb/data
COMMON_DIR := $(shell dirname $$(ls -l Makefile | awk '{print $$NF}'))
#COMMON_DIR := /homes/gws/mernst/research/notkin/macros/scripts
#COMMON_DIR := /homes/gws/gjb/macros/scripts

EXTRA_ANALYZE_FLAGS := ""
#EXTRA_ANALYZE_FLAGS := -g14

PAPER_DIR := /homes/gws/gjb/macros/papers

# FIX: These files should be generated from the directory names under PKG_DIR

PKGS := $(shell zsh -c "echo $(PKG_DIR)/*(/:t) | sed -e 's/-[^ ]*//g'")
# "make data" makes these files.
# other targets operate on these files.
STATE := $(addsuffix .state,$(PKGS))
STAT := $(addsuffix .stat,$(PKGS))
CATG := $(addsuffix .catg,$(PKGS))
ERR  := $(addsuffix .err,$(PKGS))
EVIL := $(addsuffix .evil,$(PKGS))
FNLN := $(addsuffix .fnln,$(PKGS))
FUNC := $(addsuffix .func,$(PKGS))
MAC  := $(addsuffix .mac,$(PKGS))
CCD  := $(addsuffix .ccd,$(PKGS))
USECUM  := $(addsuffix .frequse_cum,$(PKGS))
DEFCUM  := $(addsuffix .freqdef_cum,$(PKGS))
CATUSECUM  := cat-*.frequse_cum
CATDEFCUM  := cat-*.freqdef_cum

PERR := $(addsuffix .perr,$(PKGS))

TEXT_TABLES :=	tbl-package-sizes \
		tbl-def-frequency \
		tbl-use-frequency \
		tbl-cat-def-frequency \
		tbl-cat-use-frequency \
		tbl-where-used \
		tbl-ccd-categories

RAW_TABLES := raw-directives-hist tbl-directives-breakdown \
		tbl-def-categories tbl-subset-categories

LATEX_TABLES :=	tbl-def-categories.tex tbl-subset-categories.tex

ALL_TABLES := $(TEXT_TABLES) $(RAW_TABLES) $(LATEX_TABLES) $(CVT_LATEX_TABLES)

PAPER_TABLES :=  \
	tbl-def-frequency \
	tbl-use-frequency \
	tbl-cat-def-frequency \
	tbl-cat-use-frequency \
	tbl-directives-breakdown \
	tbl-where-used \
	tbl-def-categories \
	tbl-ccd-categories \
	tbl-subset-categories.tex


all:	$(ALL_TABLES)

clean:
	rm -f $(ALL_TABLES)
	rm -fr made-catdefuse

###########################################################################
### Data
###

data_analyze:
	pushd $(ANALYZE_OUTPUT_DIR); \
	macros-make-data-analyze $(PKG_DIR) $(EXTRA_ANALYZE_FLAGS); \
	popd

data_reports:
	macros-make-data-reports $(ANALYZE_OUTPUT_DIR)

clean_reports:
	macros-clean-reports

%.state:
	em_make_state_file $(PKG_DIR) $(ANALYZE_OUTPUT_DIR) $@ $(EXTRA_ANALYZE_FLAGS)

###########################################################################
### Text tables
###

text_tables:	$(TEXT_TABLES)

tbl-package-sizes: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@

tbl-package-sizes.tex: tbl-package-sizes
	(echo "Package	Version	Physical lines	NCNB lines	Description"; join -t'	' $(COMMON_DIR)/package_versions tbl-package-sizes | join -t'	' - $(COMMON_DIR)/package_descriptions ) | latexify > $@

tbl-def-frequency: $(DEFCUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-use-frequency: $(USECUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-cat-def-frequency: made-catdefuse
	macros-make-tbl-frequsedef-from-cum $(CATDEFCUM) > $@

tbl-cat-use-frequency: made-catdefuse
	macros-make-tbl-frequsedef-from-cum $(CATUSECUM) > $@

tbl-where-used: $(MAC)
	macros-make-how-used-ni-tbl-from-mac $^ > $@

tbl-ccd-categories: $(CCD)
	( head -1 $< && grep -v '^#' $^ | sed -e 's/:/	/' -e 's/.ccd//' ) > $@

# this file is just a note that we have the cat-* files around, now
made-catdefuse:	$(DEFCUM) $(USECUM)
	rm -f *.*-* cat-* # careful w/ what this deletes!
	macros-extract-defuse-categories $^
	date > made-catdefuse

###########################################################################
### Raw tables
###

raw: $(RAW_TABLES)

raw-directives-hist: $(STAT)
	macros-make-directives-raw-hist-from-stats $^ > $@

tbl-directives-breakdown: raw-directives-hist
	macros-bake-raw-directives-hist $^ > $@


###########################################################################
### LaTeX tables
###

tbl-def-categories.tex: $(STAT)
	macros-make-categories-tbl-from-stat $^ > $@

tbl-def-categories: $(STAT)
	macros-make-categories-tbl-from-stat -t -p $^ > $@

tbl-subset-categories: $(MAC)
	macros-make-subset-categorizations-from-mac $^ | sort | uniq -c | sort -nr >$@

tbl-subset-categories.tex: tbl-subset-categories
	latexify-mark-table `sum-column 1 <$^`  < $^ > $@

###########################################################################
### Etc.
###

showvars:
	echo $(PKGS)
	echo $(STAT)
	echo $(TEXT_TABLES)
	echo $(RAW_TABLES)
	echo $(LATEX_TABLES)
	echo $(CVT_LATEX_TABLES)
	echo $(ALL_TABLES)
	echo $(COMMON_DIR)


copy: $(PAPER_TABLES)
	perl -pi.bak -e 's/z*<total>/Total/g' $(PAPER_TABLES)
	cp $(PAPER_TABLES) $(PAPER_DIR)

.PHONY: all clean showvars text_tables data_analyze data_reports raw copy
