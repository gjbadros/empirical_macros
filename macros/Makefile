# $Id$
# Makefile

PERL_MODULES := $(wildcard *.pm)
PERL_SCRIPTS := $(wildcard *.pl)
PERL_SCRIPTS += evilmacros
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

TAGS:	$(PERL_SCRIPTS) $(PERL_MODULES)
	perletags $(PERL_SCRIPTS) $(PERL_MODULES)

tags:	TAGS

%.man: %.pm
	pod2man $< >$@

%.html: %.pm
	pod2html $< >$@

%.man: %.pl
	pod2man $< >$@

%.html: %.pl
	pod2html $< >$@

%.man: %
	pod2man $< >$@

%.html: %
	pod2html $< >$@

showvars:
	echo $(PERL_MODULES)
	echo $(PERL_SCRIPTS)
	echo $(PERL_MODULE_MAN)
	echo $(PERL_MODULE_HTML)

.PHONY: all module_man check showvars tags
