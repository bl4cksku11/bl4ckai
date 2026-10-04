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

# Record EVERY verdict (with the rule that fired) to a per-engagement decision log,
# then print and exit. On a real run this trail is how you catch an ASK that should
# have been IN (scope too narrow → lost surface) or an IN that should have been OUT
# (the expensive case). Every caller — req.sh or a direct call — goes through here.
decide(){ # <verdict-line> <exit-code>
  if [ -n "${ENG:-}" ]; then mkdir -p "$ENG/evidence" 2>/dev/null
    printf '%s\t%s\n' "$(date +%FT%T)" "$1" >> "$ENG/evidence/scope_decisions.log"; fi
  echo "$1"; exit "$2"
}

if [ ! -f "$SCOPE" ]; then decide "ASK  $host  (no scope.txt — run engagement-setup)" 2; fi

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

if [ -n "$deny" ];  then decide "OUT  $host  (matches -$deny)" 1; fi
if [ -n "$allow" ]; then decide "IN   $host  (matches $allow)" 0; fi
decide "ASK  $host  (no in-scope pattern matched — confirm with operator)" 2
