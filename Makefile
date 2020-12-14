FILE=README
STYLEROOT=/Users/toni/Dropbox/_Tools/Stylesheets/Pandoc
SED=gsed

all: html pdf

marbles: marbles/slides.txt
	docker run -i -v `pwd`/marbles:/data rx-marbles
	mv marbles/*.png figures/

casts: $(FILE).Rmd
	# Extract code blocks and create casts for them
	awk -f scripts/create_casts.awk $(FILE).Rmd
	# Strip local paths
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work| <...>/work|g' casts/*.cast
	# base64 encode
	scripts/encode.sh

md: $(FILE).Rmd
	# Use viash component from viash_docs
	knit $(FILE).Rmd
	# Strip local paths
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work|<...>/work|g' $(FILE).md

html: $(FILE).md
	pandoc $(FILE).md -o $(FILE).html -t html5 -s --self-contained --toc --highlight-style espresso

pdf: $(FILE).md
	# pandoc $(FILE).md -o $(FILE).pdf --template $(ROOT)/mytemplate.tex --variable ebook $(OPT_PDF)
	pandoc $(FILE).md -o $(FILE).pdf -d $(STYLEROOT)/DI2/di.yaml
	@echo "$(shell date) ========> done"
