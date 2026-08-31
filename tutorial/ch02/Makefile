IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch02 ex01 numbers ==='
	@$(IVERILOG) $(IVFLAGS) -s ex01_numbers -o $(BUILD)/ex01.vvp ex01_numbers.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch02 ex02 xz ==='
	@$(IVERILOG) $(IVFLAGS) -s ex02_xz -o $(BUILD)/ex02.vvp ex02_xz.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch02 ex03 wire/reg ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_wire_reg.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch02 ex04 select ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_select.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo '=== ch02 ex05 concat ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex05 -o $(BUILD)/ex05.vvp ex05_concat.v tb_ex05.v
	@$(VVP) $(BUILD)/ex05.vvp
	@echo '=== ch02 ex06 parameter ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex06 -o $(BUILD)/ex06.vvp ex06_param.v tb_ex06.v
	@$(VVP) $(BUILD)/ex06.vvp
	@echo 'PASS ch02'

clean:
	@rm -rf $(BUILD)

# 아래 예제는 오류와 경고를 직접 보기 위한 것이다.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01 (a) -g2001: reg를 assign으로 구동, 오류가 정상 ==='
	-@$(IVERILOG) -g2001 -Wall -s bad01_reg_assign -o $(BUILD)/bad01a.vvp bad01_reg_assign.v
	@echo '=== bad01 (b) -g2012: 같은 파일이 통과한다 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_reg_assign -o $(BUILD)/bad01b.vvp bad01_reg_assign.v
	@echo 'compiled'
	@echo '=== bad02: 미선언 식별자, 경고와 폭 손실이 정상 ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad02_implicit_wire -o $(BUILD)/bad02.vvp bad02_implicit_wire.v && $(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: 폭 잘림 경고가 정상 ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad03_truncation -o $(BUILD)/bad03.vvp bad03_truncation.v && $(VVP) $(BUILD)/bad03.vvp
	@echo '=== bad04: 구동원 2개, 오류가 정상 ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad04_double_driver -o $(BUILD)/bad04.vvp bad04_double_driver.v
