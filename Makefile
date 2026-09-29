.PHONY: help setup-check tutorial test tutorial-en test-en errors waves webbook webbook-check check-packet-verify check-packet-en-verify clean package-check

help:
	@echo 'make setup-check   # Icarus Verilog 도구 확인'
	@echo 'make test          # Verilog 자습서 전체 실행 (한국어)'
	@echo 'make test-en       # Verilog 자습서 전체 실행 (영어)'
	@echo 'make errors        # 의도적 결함 예제 실행'
	@echo 'make waves         # ch10 통합 VCD 생성'
	@echo 'make webbook       # 정적 웹북 생성 (한국어 및 영어)'
	@echo 'make webbook-check # 웹북 구조와 링크 검증'
	@echo 'make clean         # 생성물 정리'
	@echo 'make package-check # 공개 패키지 검증'
	@echo 'make check-packet-verify # 점검 과제 probe 컴파일 확인'
	@echo 'make check-packet-en-verify # 점검 과제 영어판 probe 컴파일 확인'

setup-check:
	$(MAKE) --no-print-directory -C tutorial setup-check

tutorial test:
	$(MAKE) --no-print-directory -C tutorial test

tutorial-en test-en:
	$(MAKE) --no-print-directory -C tutorial_en test

errors:
	$(MAKE) --no-print-directory -C tutorial errors

waves:
	$(MAKE) --no-print-directory -C tutorial waves

webbook:
	python3 tools/build_webbook.py

webbook-check:
	python3 -m py_compile tools/build_webbook.py
	python3 tools/build_webbook.py --check
	@test -f publish/webbook/index.html
	@test -f publish/webbook/search-index.json
	@test -f publish/webbook/en/index.html
	@test -f publish/webbook/en/search-index.json
	@test "$$(find publish/webbook -name index.html | wc -l | tr -d ' ')" = 24
	@echo 'PASS webbook package'

check-packet-verify:
	@for c in 1 2; do \
	  for p in check_packet/check$$c/probes/*.v; do \
	    n=$$(basename $$p .v); ch=$${n#probe_}; \
	    duts=$$(sed -n "s/^DUT_$$ch *:= *//p" check_packet/check$$c/Makefile | sed 's#$$(TUTORIAL)#tutorial#g'); \
	    iverilog -g2012 -Wall -I check_packet/common -I check_packet/check$$c -s $$n -o /dev/null $$duts $$p || exit 1; \
	  done; \
	done
	@echo 'PASS check_packet probes compile'

check-packet-en-verify:
	@for c in 1 2; do \
	  for p in check_packet_en/check$$c/probes/*.v; do \
	    n=$$(basename $$p .v); ch=$${n#probe_}; \
	    duts=$$(sed -n "s/^DUT_$$ch *:= *//p" check_packet_en/check$$c/Makefile | sed 's#$$(TUTORIAL)#tutorial_en#g'); \
	    iverilog -g2012 -Wall -I check_packet_en/common -I check_packet_en/check$$c -s $$n -o /dev/null $$duts $$p || exit 1; \
	  done; \
	done
	@echo 'PASS check_packet_en probes compile'

clean:
	$(MAKE) --no-print-directory -C tutorial clean
	$(MAKE) --no-print-directory -C tutorial_en clean
	$(RM) -r publish/webbook tools/__pycache__

package-check:
	@test -f README.md
	@test -f VERSION
	@test -f release_manifest.json
	@test -f assignments/README.md
	@test -d tutorial
	@test -d tutorial_en
	@test -d check_packet
	@test -d check_packet_en
	@test -z "$$(find assignments -mindepth 1 -maxdepth 1 -type d -print -quit)"
	@$(MAKE) --no-print-directory test
	@$(MAKE) --no-print-directory test-en
	@$(MAKE) --no-print-directory webbook-check
	@$(MAKE) --no-print-directory check-packet-verify
	@$(MAKE) --no-print-directory check-packet-en-verify
	@echo 'PASS public tutorial and webbook package'
