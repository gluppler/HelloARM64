# Makefile for ARM64 Assembly (Apple Silicon)

file ?= examples/hello_world.s
bin_dir = bin

build:
	@./tools/build.sh $(file)

debug:
	@./tools/build.sh $(file) --debug

bare_build:
	@./tools/build.sh $(file) --bare

bare_debug:
	@./tools/build.sh $(file) --bare --debug

run:
	@./tools/run.sh $(basename $(notdir $(file)))

clean:
	@./tools/clean.sh

.PHONY: build debug bare_build bare_debug run clean
