FILES = emp-use-2.tex \
	tbl-package-sizes.tex tbl-subset-properties.tex \
	tbl-lint.tex \
	tbl-subset-categories.tex tbl-summarize-frequency.tex \
	tbl-where-used.tex

TAGS: $(FILES)
	etags $(FILES)

tags: TAGS

tse106066.tar: $(FILES)
	mkdir tse106066
	cp -p emp-use-2.ps tse106066/tse106066.ps
	cp -p tse-readme tse106066/README
	cp -p emp-use-2.tex tse106066/tse106066.tex
	../scripts/tse-fixup.pl tse106066/tse106066.tex
	rm -f tse106066/tse106066.tex.bak
	cp -p tbl-package-sizes.tex tse106066/fig1.tex
	cp -p fig/directives-breakdown.eps tse106066/fig2.eps
	cp -p fig/def-categories.eps tse106066/fig3.eps
	cp -p tbl-subset-properties.tex tse106066/fig4.tex
	cp -p tbl-lint.tex tse106066/fig5.tex
	cp -p tbl-summarize-frequency.tex tse106066/fig6.tex
	cp -p tbl-subset-categories.tex tse106066/fig8.tex
	cp -p fig/uses-per-line.eps tse106066/fig9.eps
	cp -p fig/cat-use-frequency.eps tse106066/fig10.eps
	cp -p tbl-where-used.tex tse106066/fig11.tex
	cp -p fig/ccd-categories.eps tse106066/fig12.eps
	cp -p fig/dep-byline.eps tse106066/fig13.eps
	cp -p fig/exp-dep-bymacro.eps tse106066/fig14a.eps
	cp -p fig/incl-dep-bymacro.eps tse106066/fig14b.eps
	cp -p fig/ernst-photo.eps fig/badros-photo.eps fig/notkin-photo.eps tse106066
	cp -p emp-use-2.bbl tse106066/tse106066.bbl
	tar cf tse106066.tar tse106066
	rm -rf tse106066
