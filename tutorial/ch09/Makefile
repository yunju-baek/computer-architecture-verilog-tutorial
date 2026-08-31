IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch09 ex01 합성 가능 구조 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_synthesizable.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch09 ex02 대조 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_compare.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo 'PASS ch09'

clean:
	@rm -rf $(BUILD)

# 아래 예제는 합성 대상 코드에서 피할 구조를 직접 보기 위한 것이다.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: 설계 코드의 지연문 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_delay -o $(BUILD)/bad01.vvp bad01_delay.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: 반복 횟수가 달라지는 while ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_while -o $(BUILD)/bad02.vvp bad02_while.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: 나눗셈과 나머지 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_division -o $(BUILD)/bad03.vvp bad03_division.v
	@$(VVP) $(BUILD)/bad03.vvp
