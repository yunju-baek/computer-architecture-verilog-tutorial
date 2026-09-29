#!/bin/sh
# Generate SHA-256 manifest of deliverable files.
# Usage: manifest.sh <student_id> <output_file> <files...>
# The instructor verification suite verifies post-submission integrity using this manifest.
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
