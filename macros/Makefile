# $Id$
# Makefile

PERL_MODULES := $(wildcard *.pm)
PERL_SCRIPTS := $(wildcard *.pl)
PERL_MODULE_MAN := $(patsubst %.pm,%.man,$(PERL_MODULES))
PERL_MODULE_HTML := $(patsubst %.pm,%.html,$(PERL_MODULES))

all: module_man check

module_man: $(PERL_MODULE_MAN)

module_html: $(PERL_MODULE_HTML)

check: $(PERL_MODULES) $(PERL_SCRIPTS)
	for i in $^; do perl -c $$i; done

.checked: $(PERL_MODULES) $(PERL_SCRIPTS)
	for i in $?; do perl -c $$i; done
	touch .checked

%.man: %.pm
	pod2man $< >$@

%.html: %.pm
	pod2html $< >$@

showvars:
	echo $(PERL_MODULES)
	echo $(PERL_SCRIPTS)
	echo $(PERL_MODULE_MAN)
	echo $(PERL_MODULE_HTML)

.PHONY: all module_man check showvars
