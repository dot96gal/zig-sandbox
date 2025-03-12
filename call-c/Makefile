.PHONY: build
build:
	zig build --summary all

.PHONY: build-run
build-run:
	zig build run --summary all

.PHONY: build-test
build-test:
	zig build test --summary all

.PHONY: build-c
build-c:
	gcc src-c/calc.c src-c/main.c -o ./build/main-c

.PHONY: build-zig
build-zig:
	zig cc src-c/calc.c src-c/main.c -o ./build/main-zig

