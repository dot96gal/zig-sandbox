.PHONY: run-hello-world
run-hello-world:
	zig run ./hello-world/main.zig

.PHONY: test-sample
test-sample:
	zig test ./test-sample/main.zig
