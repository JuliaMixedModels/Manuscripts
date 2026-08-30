DOCNAME := BlockedCholeskyMM
TEMPS := jss.bst jss.cls jsslogo.jpg $(DOCNAME).tex ms.tex arxiv.sty orcidlink.sty
OUTFILES :=  $(TEMPS) $(DOCNAME).pdf $(DOCNAME)+arxiv.tex $(DOCNAME)+arxiv.pdf $(DOCNAME)+jss.tex $(DOCNAME)+jss.pdf

.PHONY: rbench render-arxiv precompile

.DEFAULT_GOAL := render

precompile:
	julia --startup-file=no --project=. -e'using Pkg; Pkg.precompile()'

preview: precompile
	quarto preview $(DOCNAME).qmd

render: precompile
	quarto render $(DOCNAME).qmd --to jds-pdf

render-arxiv: precompile
	sed -i'.bak' -e '/city:/d' $(DOCNAME).qmd
	quarto render $(DOCNAME).qmd --to arxiv-pdf+arxiv
	mv $(DOCNAME).qmd.bak $(DOCNAME).qmd

clean:
	./latex-clean.sh && rm -fv $(OUTFILES)

clean-temps:
	./latex-clean.sh && rm -fv $(TEMPS)

clean-arxiv:
	./latex-clean.sh && rm -fv ms.tex arxiv.sty orcidlink.sty

clean-replication:
	rm -rfv replication

rbench:
	R --quiet --no-restore --file=scripts/benchmark.R > scripts/benchmarkoutput.txt

submit-arxiv: rbench render-arxiv
	./arxiver.sh
