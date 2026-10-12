#!/bin/sh
#
# Fail if ci.yaml's `on.push.paths` allowlist and the `changes` job's `code` filter
# drift apart. The two lists are hand-duplicated (the trigger cannot share the
# filter's list), and drift silently skips or runs CI for the wrong pushes.
set -eu

workflow=${1:-.github/workflows/ci.yaml}

# Entries of a YAML list: the "- ..." lines under the line matching $1. Blank and
# comment lines inside the list are skipped; any other line ends it.
list_after() {
	awk -v start="$1" '
		found && /^[[:space:]]*-[[:space:]]/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); gsub(/"/, ""); print; next }
		found && /^[[:space:]]*(#.*)?$/ { next }
		found { exit }
		$0 ~ start { found = 1 }
	' "$workflow" | sort
}

push_paths=$(list_after '^    paths:[[:space:]]*$')
code_filter=$(list_after '^[[:space:]]+code:[[:space:]]*$')

if [ -z "$push_paths" ] || [ -z "$code_filter" ]; then
	printf 'could not parse one of the path lists in %s\n' "$workflow" >&2
	exit 1
fi

if [ "$push_paths" != "$code_filter" ]; then
	printf 'on.push.paths and the changes job code filter are out of sync in %s\n' "$workflow" >&2
	printf '%s\n' "$push_paths" >"${TMPDIR:-/tmp}/push_paths.$$"
	printf '%s\n' "$code_filter" >"${TMPDIR:-/tmp}/code_filter.$$"
	diff "${TMPDIR:-/tmp}/push_paths.$$" "${TMPDIR:-/tmp}/code_filter.$$" >&2 || true
	rm -f "${TMPDIR:-/tmp}/push_paths.$$" "${TMPDIR:-/tmp}/code_filter.$$"
	exit 1
fi

printf 'path allowlists in sync (%s entries)\n' "$(printf '%s\n' "$push_paths" | wc -l | tr -d ' ')"
