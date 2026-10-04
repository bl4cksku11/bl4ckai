#!/usr/bin/env bash
# Resolve a host or URL against the engagement scope. Exit 0=IN, 1=OUT, 2=ASK.
# Scope file ($ENG/scope.txt): one pattern per line; plain = in-scope (allow),
# leading '-' = out-of-scope (deny); '#' comments and blank lines ignored.
# Patterns are shell globs over the hostname (e.g. *.acme.com). Deny wins.
set -uo pipefail
: "${ENG:?export ENG=\$ENGAGEMENTS_ROOT/<A-Z>/<target> first}"
SCOPE="$ENG/scope.txt"
arg="${1:?usage: scope_check.sh <host-or-url>}"

# extract hostname from a URL or bare host
host="$arg"; host="${host#*://}"; host="${host%%/*}"; host="${host%%:*}"; host="${host%%\?*}"
host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"

if [ ! -f "$SCOPE" ]; then echo "ASK  $host  (no scope.txt — run engagement-setup)"; exit 2; fi

matches(){ case "$1" in $2) return 0;; *) return 1;; esac; }

deny=""; allow=""
while IFS= read -r line; do
  line="${line%%#*}"; line="$(printf '%s' "$line" | tr -d '[:space:]')"
  [ -z "$line" ] && continue
  case "$line" in
    -*) pat="${line#-}"; matches "$host" "$pat" && deny="$pat" ;;
     *) matches "$host" "$line" && allow="$line" ;;
  esac
done < "$SCOPE"

if [ -n "$deny" ];  then echo "OUT  $host  (matches -$deny)"; exit 1; fi
if [ -n "$allow" ]; then echo "IN   $host  (matches $allow)"; exit 0; fi
echo "ASK  $host  (no in-scope pattern matched — confirm with operator)"; exit 2
