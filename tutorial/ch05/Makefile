IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch05 ex01 dff ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_dff.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch05 ex02 blocking vs nonblocking ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_blocking.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch05 ex03 control ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_control.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch05 ex04 reset ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_reset.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo 'PASS ch05'

clean:
	@rm -rf $(BUILD)

# 아래 예제는 순차 논리의 함정을 직접 보기 위한 것이다.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: 구동원 2개 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_two_always -o $(BUILD)/bad01.vvp bad01_two_always.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: 순차 블록의 블로킹 대입 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_blocking_seq -o $(BUILD)/bad02.vvp bad02_blocking_seq.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: 두 대입 혼용 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_mixed -o $(BUILD)/bad03.vvp bad03_mixed.v
	@$(VVP) $(BUILD)/bad03.vvp
