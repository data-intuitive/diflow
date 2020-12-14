FILE=../README
STYLEROOT=/Users/toni/Dropbox/_Tools/Stylesheets/Pandoc
SED=gsed

slides: $(FILE).Rmd
	awk -f ../scripts/convert_to_slides.awk ../README.Rmd > slides.Rmd
	$(SED) -i 's|scripts/extract_steps.awk|../scripts/extract_steps.awk|' slides.Rmd
	$(SED) -i 's|main.nf|../main.nf|' slides.Rmd
	knit slides.Rmd
	$(SED) -i 's|/\(.*\)/work|<...>/work|' slides.md
	pandoc front.md slides.md back.md -o slides.html -t revealjs -s --self-contained -V revealjs-url=reveal.js --css $(STYLEROOT)/revealjs/dark.css --highlight-style custom_zenburn.theme --slide-level 2
	sed -i bkp 's|asciinema-player|asciinema-player poster="npt:0:01"|' slides.html
