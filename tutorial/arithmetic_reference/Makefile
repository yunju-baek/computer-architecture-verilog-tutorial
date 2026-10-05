PYTHON ?= python3
.PHONY: test demo clean
test:
	$(PYTHON) test_reference.py
demo:
	$(PYTHON) -c 'import json; from arithmetic import arithmetic_reference; print(json.dumps(arithmetic_reference(), indent=2))'
clean:
	rm -rf __pycache__
