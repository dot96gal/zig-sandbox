.PHONY: build
build:
	zig build --summary all

.PHONY: run
run:
	DYLD_LIBRARY_PATH=./build ./zig-out/bin/call-go

.PHONY: build-run
build-run:
	DYLD_LIBRARY_PATH=./build zig build run --summary all

.PHONY: build-test
build-test:
	DYLD_LIBRARY_PATH=./build zig build test --summary all

.PHONY: build-go-c-shared
build-go-c-shared:
	go build -o ./build/libcalc.so -buildmode=c-shared ./src-go/calc.go


