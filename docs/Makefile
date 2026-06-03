# Makefile for Sphinx documentation

SPHINXBUILD   = sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

help:
	@echo "Usage:"
	@echo "  make html   - Build the HTML documentation"
	@echo "  make clean  - Remove built documentation"

html:
	$(SPHINXBUILD) -b html "$(SOURCEDIR)" "$(BUILDDIR)/html"
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

clean:
	rm -rf "$(BUILDDIR)"
