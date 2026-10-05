IVERILOG ?= iverilog
VVP ?= vvp
RTL ?= rtl

.PHONY: setup-check test test-alu test-pc test-regfile test-decode student-test evidence clean help

setup-check:
	@command -v $(IVERILOG) >/dev/null && command -v $(VVP) >/dev/null
	@echo READY

test: setup-check test-alu test-pc test-regfile test-decode student-test
	@echo PASS HW02

test-alu:
	@mkdir -p build evidence
	@$(IVERILOG) -g2012 -Wall -s tb_alu -o build/alu.vvp $(RTL)/alu.v tests/tb_alu.v
	@$(VVP) build/alu.vvp

test-pc:
	@mkdir -p build evidence
	@$(IVERILOG) -g2012 -Wall -s tb_pc_counter -o build/pc.vvp $(RTL)/pc_counter.v tests/tb_pc_counter.v
	@$(VVP) build/pc.vvp

test-regfile:
	@mkdir -p build evidence
	@$(IVERILOG) -g2012 -Wall -s tb_regfile -o build/regfile.vvp $(RTL)/regfile.v tests/tb_regfile.v
	@$(VVP) build/regfile.vvp

test-decode:
	@mkdir -p build evidence
	@$(IVERILOG) -g2012 -Wall -s tb_decode -o build/decode.vvp $(RTL)/rv32i_immgen.v $(RTL)/rv32i_decode.v tests/tb_decode.v
	@$(VVP) build/decode.vvp

student-test:
	@mkdir -p build evidence
	@$(IVERILOG) -g2012 -Wall -s tb_student_blocks -o build/student_blocks.vvp \
		$(RTL)/pc_counter.v $(RTL)/regfile.v $(RTL)/rv32i_immgen.v $(RTL)/rv32i_decode.v tests/tb_student_blocks.v
	@$(VVP) build/student_blocks.vvp

evidence: test
	@cp build/alu.vcd evidence/alu.vcd
	@cp build/pc.vcd evidence/pc.vcd
	@cp build/regfile.vcd evidence/regfile.vcd
	@cp build/decode.vcd evidence/decode.vcd
	@cp build/student_blocks.vcd evidence/student_blocks.vcd
	@echo PASS HW02 evidence

clean:
	@rm -rf build evidence

help:
	@echo 'make setup-check | test | test-alu | test-pc | test-regfile | test-decode | student-test | evidence | clean'
