#!/uns/bin/perl -wpi.bak

###
### Eliminate comments (except at end of line)
###

s/^%.*\n//;			# compresses out the newline, too
s/([^\\])%(?!$).*$/$1/;


###
### Figure references
###

# Here is a list of figures, labels, and related files (if any)
# 1	fig:packages	tbl-package-sizes.tex
# 2	fig:directives-breakdown	fig/directives-breakdown.eps
# 3	fig:categorization	fig/def-categories.eps
# 4	fig:subset-properties	tbl-subset-properties.tex
# 5	fig:macro-lint	tbl-lint.tex
# 6	fig:freq-sum-cat	tbl-summarize-frequency.tex
# 7	fig:category-lub
# 8	fig:subset-categories	tbl-subset-categories.tex
# 9	fig:use-per-line	fig/uses-per-line.eps
# 10	fig:freq-use-cat	fig/cat-use-frequency.eps
# 11	fig:where-used	tbl-where-used.tex
# 12	fig:ccd-categories	fig/ccd-categories.eps
# 13	fig:dep-byline	fig/dep-byline.eps
# 14	fig:dep-bymacro	fig/exp-dep-bymacro.eps	fig/incl-dep-bymacro.eps

s/fig:packages/fig:1/;
s/fig:directives-breakdown/fig:2/;
s/fig:categorization/fig:3/;
s/fig:subset-properties/fig:4/;
s/fig:macro-lint/fig:5/;
s/fig:freq-sum-cat/fig:6/;
s/fig:category-lub/fig:7/;
s/fig:subset-categories/fig:8/;
s/fig:use-per-line/fig:9/;
s/fig:freq-use-cat/fig:10/;
s/fig:where-used/fig:11/;
s/fig:ccd-categories/fig:12/;
s/fig:dep-byline/fig:13/;
s/fig:dep-bymacro/fig:14/;

s/tbl-package-sizes.tex/fig1.tex/;
s/fig\/directives-breakdown.eps/fig2.eps/;
s/fig\/def-categories.eps/fig3.eps/;
s/tbl-subset-properties.tex/fig4.tex/;
s/tbl-lint.tex/fig5.tex/;
s/tbl-summarize-frequency.tex/fig6.tex/;
s/tbl-subset-categories.tex/fig8.tex/;
s/fig\/uses-per-line.eps/fig9.eps/;
s/fig\/cat-use-frequency.eps/fig10.eps/;
s/tbl-where-used.tex/fig11.tex/;
s/fig\/ccd-categories.eps/fig12.eps/;
s/fig\/dep-byline.eps/fig13.eps/;
s/fig\/exp-dep-bymacro.eps/fig14a.eps/;
s/fig\/incl-dep-bymacro.eps/fig14b.eps/;

s/fig\/ernst-photo.eps/ernst-photo.eps/;
s/fig\/badros-photo.eps/badros-photo.eps/;
s/fig\/notkin-photo.eps/notkin-photo.eps/;
