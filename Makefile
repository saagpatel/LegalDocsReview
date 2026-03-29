.PHONY: build test lint clean check run

build:
	cargo build --release

check:
	cargo check

test:
	cargo test

lint:
	cargo clippy -- -D warnings

run:
	cargo run

clean:
	cargo clean
