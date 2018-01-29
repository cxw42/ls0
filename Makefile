.PHONY: all

all: README.md

README.md: ls0 Makefile
	perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' $< > $@
	sed -i '1s/Name/ls0: a "ls" that separates results with a null terminator/' README.md

