# $Id$
# Makefile for post-processing of evilmacros output files
# (Using the macros-* scripts)

PKG_DIR := /tmp/mernst/packages

# FIX: These files should be generated from the directory
# names under PKG_DIR

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
		tbl-how_used_ni

RAW_TABLES := raw-directives-hist

LATEX_TABLES :=	tbl-categories.tex

CVT_LATEX_TABLES :=	$(patsubst %,%.tex,$(TEXT_TABLES))

all:	$(LATEX_TABLES) $(CVT_LATEX_TABLES) $(RAW_TABLES)

clean:
	rm -f $(LATEX_TABLES) $(CVT_LATEX_TABLES) $(RAW_TABLES)

showvars:
	echo $(TEXT_TABLES)
	echo $(RAW_TABLES)
	echo $(LATEX_TABLES)
	echo $(CVT_LATEX_TABLES)

text_tables:	$(TEXT_TABLES)

$(CVT_LATEX_TABLES): %.tex: %
	latexify $< >$@

tbl-package_sizes: $(STAT)
	macros-make-package-sizes-tbl-from-stat $^ >$@

tbl-def_frequency: $(MAC)
	macros-make-def-frequency-tbl-from-mac $^ >$@

tbl-how_used_ni: $(MAC)
	macros-make-how-used-ni-tbl-from-mac $^ >$@

tbl-categories.tex: $(STAT)
	macros-make-categories-tbl-from-stat-pct $^ >$@

raw-directives-hist: $(STAT)
	macros-make-directives-raw-hist-from-stats $^ >$@

data:
	macros-make-data $(PKG_DIR)

.PHONY: all clean showvars text_tables data
