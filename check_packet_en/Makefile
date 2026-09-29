# Verilog Self-Study and Activity Reports Unified Package
# Run bulk verification and packaging for check1 and check2 from activity reports root.

.PHONY: help setup-check tutorial-check test package clean

help:
	@echo 'make setup-check    # Check tool prerequisites and environment'
	@echo 'make tutorial-check # Run tutorial test suite for CH01–CH10'
	@echo 'make test           # Verify predictions for check1 and check2'
	@echo 'make package        # Generate submission zip packages'
	@echo 'make clean          # Clean build and evidence artifacts'

setup-check:
	@$(MAKE) -C check1 setup-check
	@$(MAKE) -C check2 setup-check

tutorial-check:
	@$(MAKE) -C check1 tutorial-check
	@$(MAKE) -C check2 tutorial-check

test:
	@$(MAKE) -C check1 test
	@$(MAKE) -C check2 test
	@echo 'PASS activity reports check completed'

package:
	@$(MAKE) -C check1 package
	@$(MAKE) -C check2 package
	@echo 'PASS activity reports submission archives created'

clean:
	@$(MAKE) -C check1 clean
	@$(MAKE) -C check2 clean
	@rm -f verilog_check*.zip
