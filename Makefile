SHELL = /bin/bash
BENCHPROGS ?= "pandoc -fmarkdown_strict+autolink_bare_uris+fenced_code_blocks+intraword_underscores"
SOURCES=bin/main.hs Cheapskate.hs Cheapskate/Parse.hs Cheapskate/Types.hs Cheapskate/Inlines.hs Cheapskate/Util.hs Cheapskate/Html.hs Cheapskate/ParserCombinators.hs

.PHONY: build
build: $(SOURCES)
	cabal configure --user && cabal build

.PHONY: prof
prof:
	cabal configure --enable-library-profiling --enable-executable-profiling --user && cabal build ; \
	  echo "To profile:  cabal run +RTS -pa -V0.0002 -RTS"

.PHONY: test
test:
	make -C tests --quiet clean all

.PHONY: fuzztest
fuzztest:
	cat /dev/urandom | head -c 100000 | iconv -f latin1 -t utf-8 | time cabal run >/dev/null ; \
	cat /dev/urandom | head -c 1000000 | iconv -f latin1 -t utf-8 | time cabal run >/dev/null ; \
	cat /dev/urandom | head -c 10000000 | iconv -f latin1 -t utf-8 | time cabal run >/dev/null

.PHONY: bench
bench:
	for prog in "cabal run" $(BENCHPROGS); do \
	   echo; \
	   echo "Benchmarking $$prog"; \
	     time for i in tests/*/*.markdown; do \
	       cat $$i | $$prog >/dev/null ; \
	       done ; \
	done

.PHONY: linecount
linecount:
	@echo "Non-comment, non-blank lines:" ; \
	grep '^[^-]' Cheapskate.hs Cheapskate/*.hs | wc -l

.PHONY: clean
clean:
	cabal clean && make -C tests clean
