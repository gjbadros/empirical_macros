# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

PKG_DIR := /tmp/mernst/packages

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
PERR := $(wildcard *.perr)

TEXT_TABLES :=	tbl-package_sizes \
		tbl-def_frequency \
		tbl-use_frequency \
		tbl-how_used_ni

# Maybe "baked" is actually a text table?
RAW_TABLES := raw-directives-hist baked-directives-hist \
		tbl-categories

LATEX_TABLES :=	tbl-categories.tex

CVT_LATEX_TABLES := $(patsubst %,%.tex,$(TEXT_TABLES))

ALL_TABLES := $(TEXT_TABLES) $(RAW_TABLES) $(LATEX_TABLES) $(CVT_LATEX_TABLES)

all:	$(ALL_TABLES)

clean:
	rm -f $(ALL_TABLES)

###########################################################################
### Data
###

data:
	macros-make-data $(PKG_DIR)

###########################################################################
### Text tables
###

text_tables:	$(TEXT_TABLES)

tbl-package_sizes: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@

tbl-def_frequency: $(MAC)
	macros-make-def-frequency-tbl-from-mac $^
	# -n12 arg to xargs for latex
	echo $(patsubst %.mac,%.freqdef,$^) | xargs paste /homes/gws/gjb/macros/freqdef.buckets >> $@

tbl-use_frequency: $(MAC)
	macros-make-use-frequency-tbl-from-mac $^
	# -n12 arg to xargs for latex
	echo $(patsubst %.mac,%.frequse,$^) | xargs paste /homes/gws/gjb/macros/frequse.buckets >> $@

tbl-how_used_ni: $(MAC)
	macros-make-how-used-ni-tbl-from-mac $^ > $@

###########################################################################
### Raw tables
###

raw: $(RAW_TABLES)

raw-directives-hist: $(STAT)
	macros-make-directives-raw-hist-from-stats $^ > $@

baked-directives-hist: raw-directives-hist
	macros-bake-raw-directives-hist $^ > $@

package_and_sizes-tbl.txt: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ > $@


###########################################################################
### LaTeX tables
###

tbl-categories.tex: $(STAT)
	macros-make-categories-tbl-from-stat $^ > $@

tbl-categories: $(STAT)
	macros-make-categories-tbl-from-stat -t -p $^ > $@

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

.PHONY: all clean showvars text_tables data raw
