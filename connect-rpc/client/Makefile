.PHONY: build
build:
	zig build --summary all

.PHONY: build-run
build-run:
	zig build run --summary all

.PHONY: build-test
build-test:
	zig build test --summary all

.PHONY: gen-proto
gen-proto:
	zig build gen-proto --summary all

.PHONY: fetch-deps
fetch-deps:
	zig fetch --save "git+https://github.com/Arwalk/zig-protobuf#v3.0.0"
