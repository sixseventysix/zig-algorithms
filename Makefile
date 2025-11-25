.PHONY: build run run-nobuild clean help

# Build the project
build:
	zig build

# Build and run a specific problem
run: build
	@if [ -z "$(PROB)" ]; then \
		echo "Error: PROB not specified. Usage: make run PROB=N"; \
		exit 1; \
	fi
	@if [ ! -f "inputs/problem$(PROB)_input.txt" ]; then \
		echo "Error: Input file not found: inputs/problem$(PROB)_input.txt"; \
		exit 1; \
	fi
	@echo "Running problem $(PROB) with input: inputs/problem$(PROB)_input.txt"
	@./zig-out/bin/zig_algorithms $(PROB) < inputs/problem$(PROB)_input.txt

# Run without building
run-nobuild:
	@if [ -z "$(PROB)" ]; then \
		echo "Error: PROB not specified. Usage: make run-nobuild PROB=N"; \
		exit 1; \
	fi
	@if [ ! -f "inputs/problem$(PROB)_input.txt" ]; then \
		echo "Error: Input file not found: inputs/problem$(PROB)_input.txt"; \
		exit 1; \
	fi
	@echo "Running problem $(PROB) with input: inputs/problem$(PROB)_input.txt"
	@./zig-out/bin/zig_algorithms $(PROB) < inputs/problem$(PROB)_input.txt

# Clean build artifacts
clean:
	rm -rf zig-out .zig-cache
