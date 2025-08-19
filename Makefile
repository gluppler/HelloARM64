# Root Makefile for HelloARM64

file ?= examples/hello_world.s

all: build

build:
	@./tools/build.sh $(file)

bare_build:
	@./tools/build.sh $(file) --bare

debug:
	@./tools/build.sh $(file) --debug

bare_debug:
	@./tools/build.sh $(file) --bare --debug

run:
	@bin/$(basename $(notdir $(file)))

clean:
	@./tools/clean.sh
