IVERILOG ?= iverilog
VVP      ?= vvp

# Tutorial chapter list. Add new chapters here.
CHAPTERS := ch01 ch02 ch03 ch04 ch05 ch06 ch07 ch08 ch09 ch10

.PHONY: setup-check test chapters errors waves clean help

help:
	@echo 'make setup-check   # Verify development toolchain'
	@echo 'make test          # Run example suites across all chapters'
	@echo 'make chapters      # Equivalent to make test'
	@echo 'make errors        # Run intentional error and pitfall examples'
	@echo 'make waves         # Generate VCD waveforms for ch10 overview example'
	@echo 'make clean         # Remove build artifacts'

setup-check:
	@command -v $(IVERILOG) >/dev/null
	@command -v $(VVP) >/dev/null
	@echo READY

test: setup-check chapters
	@echo 'PASS tutorial all'

chapters:
	@for chapter in $(CHAPTERS); do \
	  $(MAKE) --no-print-directory -C $$chapter test || exit 1; \
	done

errors:
	@for chapter in $(CHAPTERS); do \
	  $(MAKE) --no-print-directory -C $$chapter errors 2>/dev/null || true; \
	done

waves:
	@$(MAKE) --no-print-directory -C ch10 waves

clean:
	@for chapter in $(CHAPTERS); do $(MAKE) --no-print-directory -C $$chapter clean; done
