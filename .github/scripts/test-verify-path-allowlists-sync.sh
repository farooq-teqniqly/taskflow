#!/bin/sh
# Regression tests for verify-path-allowlists-sync.sh.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

mk() { # $1 file, $2 push extra lines, $3 filter extra lines
	cat >"$1" <<EOF
on:
  push:
    paths:
      - "src/**"
      # comment inside the list

$2
  pull_request:
jobs:
  changes:
    steps:
      - with:
          filters: |
            code:
              - "src/**"
              # comment inside the list

$3
EOF
}

check() { # $1 name, $2 expected exit (0/1), $3 file
	rc=0
	sh "$here/verify-path-allowlists-sync.sh" "$3" >/dev/null 2>&1 || rc=$?
	if [ "$rc" -ne "$2" ]; then printf 'FAIL: %s (exit %s, want %s)\n' "$1" "$rc" "$2"; fail=1; else printf 'ok: %s\n' "$1"; fi
}

mk "$tmp/same.yaml" '      - "tests/**"' '              - "tests/**"'
check 'identical lists with interior comment/blank pass' 0 "$tmp/same.yaml"

mk "$tmp/drift.yaml" '      - "tests/**"' '              - "other/**"'
check 'entries differing after a comment/blank are caught' 1 "$tmp/drift.yaml"

[ "$fail" -eq 0 ]
