PYTHON ?= python3
CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -Werror -O0

.PHONY: setup-check test test-c test-assembly student-test evidence ra-experiment clean help

setup-check:
	@$(PYTHON) -c 'import sys; assert sys.version_info >= (3,11); print("READY python=" + sys.version.split()[0])'

build/test_c: programs/state_contract.c tests/test_c.c
	@mkdir -p build
	@$(CC) $(CFLAGS) programs/state_contract.c tests/test_c.c -o $@

test-c: build/test_c
	@./build/test_c

test-assembly:
	@PYTHONPATH=. $(PYTHON) -m unittest tests/test_public_state.py -v

student-test:
	@PYTHONPATH=. $(PYTHON) -m unittest tests/test_student_cases.py -v

test: setup-check test-assembly student-test

evidence: test
	@mkdir -p evidence
	@PYTHONPATH=. $(PYTHON) scripts/make_evidence.py

ra-experiment: test-assembly
	@PYTHONPATH=. $(PYTHON) scripts/ra_experiment.py $(if $(RESTORE_LINE),--restore-line $(RESTORE_LINE),)

clean:
	@rm -rf build evidence __pycache__ programs/__pycache__ scripts/__pycache__ tests/__pycache__ tools/__pycache__

help:
	@echo 'make setup-check | test | test-c | test-assembly | student-test | evidence | ra-experiment | clean'
