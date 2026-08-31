.PHONY: help setup-check tutorial test errors waves webbook webbook-check clean package-check

help:
	@echo 'make setup-check   # Icarus Verilog 도구 확인'
	@echo 'make test          # Verilog 자습서 전체 실행'
	@echo 'make errors        # 의도적 결함 예제 실행'
	@echo 'make waves         # ch10 통합 VCD 생성'
	@echo 'make webbook       # 정적 웹북 생성'
	@echo 'make webbook-check # 웹북 구조와 링크 검증'
	@echo 'make clean         # 생성물 정리'
	@echo 'make package-check # 공개 패키지 검증'

setup-check:
	$(MAKE) --no-print-directory -C tutorial setup-check

tutorial test:
	$(MAKE) --no-print-directory -C tutorial test

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
	@test "$$(find publish/webbook -name index.html | wc -l | tr -d ' ')" = 12
	@echo 'PASS webbook package'

clean:
	$(MAKE) --no-print-directory -C tutorial clean
	$(RM) -r publish/webbook tools/__pycache__

package-check:
	@test -f README.md
	@test -f VERSION
	@test -f release_manifest.json
	@test -f assignments/README.md
	@test -d tutorial
	@test -z "$$(find assignments -mindepth 1 -maxdepth 1 -type d -print -quit)"
	@$(MAKE) --no-print-directory test
	@$(MAKE) --no-print-directory webbook-check
	@echo 'PASS public tutorial and webbook package'
