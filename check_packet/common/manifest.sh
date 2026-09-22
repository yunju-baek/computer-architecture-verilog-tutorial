#!/bin/sh
# 제출물 파일의 SHA-256 목록을 만든다.
# 사용법: manifest.sh <학번> <출력파일> <파일...>
# 교수자 검사기가 이 목록으로 제출 후 변경 여부를 확인한다.
set -u
sid="$1"
out="$2"
shift 2

sum256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

{
  echo "STUDENT_ID=$sid"
  echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  for f in "$@"; do
    if [ -f "$f" ]; then
      echo "$(sum256 "$f")  $f"
    fi
  done
} > "$out"
