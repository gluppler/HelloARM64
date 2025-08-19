# Makefile (root)
file ?= examples/hello_world/sys_macos_hello.s
target ?= macos

.PHONY: build bare debug

build:
	@./tools/build.sh $(file) --target=$(target)

bare:
	@./tools/build.sh $(file) --target=$(target) --bare

debug:
	@./tools/build.sh $(file) --target=$(target) --debug
