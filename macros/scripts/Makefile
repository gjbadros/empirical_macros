# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

# Directories on uni
PKG_DIR := /tmp/mernst/packages
ANALYZE_OUTPUT_DIR := /tmp/gjb/splitdata
COMMON_DIR := $(shell dirname $$(which em_analyze))

PAPER_DIR := /homes/gws/gjb/macros/papers

# FIX: These files should be generated from the directory names under PKG_DIR

# "make data" makes these files.
# other targets operate on these files.
STAT := $(wildcard *.stat)
CATG := $(wildcard *.catg)
ERR  := $(wildcard *.err)
EVIL := $(wildcard *.evil)
FNLN := $(wildcard *.fnln)
FUNC := $(wildcard *.func)
MAC  := $(wildcard *.mac)
USECUM  := $(wildcard *.frequse_cum)
DEFCUM  := $(wildcard *.freqdef_cum)
PERR := $(wildcard *.perr)

TEXT_TABLES :=	tbl-package-sizes \
		tbl-def-frequency \
		tbl-use-frequency \
		tbl-where-used

RAW_TABLES := raw-directives-hist tbl-directives-breakdown \
		tbl-def-categories tbl-subset-categories

LATEX_TABLES :=	tbl-def-categories.tex tbl-subset-categories.tex

CVT_LATEX_TABLES := $(patsubst %,%.tex,$(TEXT_TABLES))

ALL_TABLES := $(TEXT_TABLES) $(RAW_TABLES) $(LATEX_TABLES) $(CVT_LATEX_TABLES)

PAPER_TABLES :=  \
	tbl-def-frequency \
	tbl-use-frequency \
	tbl-directives-breakdown \
	tbl-where-used \
	tbl-def-categories \
	tbl-subset-categories.tex


all:	$(ALL_TABLES)

clean:
	rm -f $(ALL_TABLES)

###########################################################################
### Data
###

data_analyze:
	pushd $(ANALYZE_OUTPUT_DIR); \
	macros-make-data-analyze $(PKG_DIR); \
	popd

data_reports:
	macros-make-data-reports $(ANALYZE_OUTPUT_DIR)


###########################################################################
### Text tables
###

text_tables:	$(TEXT_TABLES)

tbl-package-sizes: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@

tbl-def-frequency: $(DEFCUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-use-frequency: $(USECUM)
	macros-make-tbl-frequsedef-from-cum $^ > $@

tbl-where-used: $(MAC)
	macros-make-how-used-ni-tbl-from-mac $^ > $@

###########################################################################
### Raw tables
###

raw: $(RAW_TABLES)

raw-directives-hist: $(STAT)
	macros-make-directives-raw-hist-from-stats $^ > $@

tbl-directives-breakdown: raw-directives-hist
	macros-bake-raw-directives-hist $^ > $@

package_and_sizes-tbl.txt: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@


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

$(CVT_LATEX_TABLES): %.tex: %
	latexify $< > $@

###########################################################################
### Etc.
###

showvars:
	echo $(TEXT_TABLES)
	echo $(RAW_TABLES)
	echo $(LATEX_TABLES)
	echo $(CVT_LATEX_TABLES)
	echo $(ALL_TABLES)
	echo $(COMMON_DIR)


copy:
	perl -pi.bak -e 's/<total>/Total/g' $(PAPER_TABLES)
	cp $(PAPER_TABLES) $(PAPER_DIR)	

.PHONY: all clean showvars text_tables data raw copy
