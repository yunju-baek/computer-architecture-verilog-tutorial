#!/bin/sh
# 도구 버전과 실행 환경을 기록한다.
# 사용법: env_report.sh <출력파일> <학번> <tutorial 경로>
# 사용자 이름과 경로는 해시로만 남긴다.
set -u
out="$1"
sid="$2"
tutorial="$3"

hash16() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | cut -c1-16
  else
    shasum -a 256 | cut -c1-16
  fi
}

first_line() {
  "$@" 2>&1 | head -1
}

{
  echo "STUDENT_ID=$sid"
  echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "OS=$(uname -srm)"
  echo "IVERILOG=$(first_line iverilog -V)"
  echo "VVP=$(first_line vvp -V)"
  echo "MAKE=$(first_line make --version)"
  echo "GIT=$(first_line git --version)"
  if command -v gtkwave >/dev/null 2>&1; then
    echo "GTKWAVE=installed"
  else
    echo "GTKWAVE=optional-absent"
  fi
  echo "TUTORIAL_COMMIT=$(git -C "$tutorial" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  echo "USER_HASH=$(printf '%s' "$(whoami)@$(hostname)" | hash16)"
  echo "PWD_HASH=$(pwd | hash16)"
} > "$out"
