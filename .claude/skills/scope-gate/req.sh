#!/usr/bin/env bash
# Enforced outbound request wrapper for CLI/curl traffic. Every manual request a
# skill makes goes through this so three things are guaranteed, not remembered:
#   1) SCOPE   — the host is resolved through scope-gate; out-of-scope is refused.
#   2) HEADER  — RESEARCH_HEADER is injected if set and not already present.
#   3) RATE    — a global min-interval enforces MAX_RPS across all req.sh calls.
# It also logs every request. Usage mirrors curl:
#   req.sh https://api.acme.com/v3/orders/42
#   req.sh -X POST -d @body https://api.acme.com/v3/thing
# Exit: curl's exit on success; 3 = refused (out of scope); 2 = usage/ask.
set -uo pipefail
: "${ENG:?export ENG first}"
: "${BL4CKAI_HOME:?export BL4CKAI_HOME first}"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
MAX_RPS="${MAX_RPS:-5}"

# find the URL among the args (first token that looks like one)
url=""; for a in "$@"; do case "$a" in http://*|https://*) url="$a"; break;; esac; done
[ -z "$url" ] && { echo "req.sh: no URL in args" >&2; exit 2; }
host="${url#*://}"; host="${host%%/*}"; host="${host%%:*}"

# 0) FAIL-CLOSED: never follow redirects blindly — a 3xx to another host must be
# re-gated by the caller, not auto-fetched out of scope.
for a in "$@"; do case "$a" in -L|--location) echo "req.sh: refusing -L; gate the redirect Location yourself" >&2; exit 2;; esac; done

# 1) SCOPE — only an explicit IN (rc 0) proceeds. Missing/empty/malformed scope,
# a crashed gate, an unknown verdict → BLOCK. Default-deny.
verdict=$(bash "$GATE" "$host" 2>/dev/null); rc=$?
if [ "$rc" -ne 0 ]; then
  echo "BLOCKED (fail-closed): $host — ${verdict:-gate error} (rc=$rc)" >&2
  exit 3
fi

# 3) RATE — global min interval = 1/MAX_RPS, enforced via a timestamp lockfile
RL="$ENG/.rate"; mkdir -p "$RL"; lock="$RL/last"
min_ns=$(awk -v r="$MAX_RPS" 'BEGIN{printf "%d", (1.0/r)*1000000000}')
now=$(date +%s%N); last=$(cat "$lock" 2>/dev/null || echo 0)
wait_ns=$(( last + min_ns - now ))
[ "$wait_ns" -gt 0 ] && awk -v n="$wait_ns" 'BEGIN{ system("sleep " n/1000000000) }'
date +%s%N > "$lock"

# 2) HEADER — inject the program header unless the caller already set it
hdr_args=()
if [ -n "${RESEARCH_HEADER:-}" ] && ! printf '%s\0' "$@" | grep -qz "$RESEARCH_HEADER"; then
  hdr_args=(-H "$RESEARCH_HEADER")
fi

# log + send
printf '%s\t%s\n' "$(date +%FT%T)" "$url" >> "$ENG/evidence/requests.log"
exec curl -sS "${hdr_args[@]}" "$@"
