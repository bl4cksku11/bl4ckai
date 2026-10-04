#!/usr/bin/env bash
# Skill linter — catch network egress that bypasses the enforced wrapper, in REVIEW
# (not runtime). Run in CI / before publishing.
#   ERROR: a naked curl/wget/python-requests to (presumably) the target, not via
#          req.sh. Target traffic must go through the wrapper (scope + rate + header).
#   WARN:  a bulk tool (httpx/nuclei/katana/ffuf) invoked without a rate flag.
# Third-party passive services (CT logs, wayback, OOB) are exempt — they are not the
# target. Exit non-zero if any ERROR remains.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
SKILLS="$ROOT/.claude/skills"
# hosts that are NOT the target (passive/third-party/OOB) — naked fetch is fine
ALLOW='crt\.sh|web\.archive\.org|archive\.org|oast\.|interact\.sh|interactsh|bun\.sh|go\.dev|githubusercontent|chromewebstore'
err=0; warn=0

while IFS= read -r hit; do
  f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"; line="${rest#*:}"
  base="$(basename "$(dirname "$f")")"
  # exempt: the wrapper itself, references to it, allowlisted third-party, comments about it
  case "$f" in */scope-gate/req.sh|*/scope-gate/scope_check.sh|*/scripts/*) continue;; esac
  # skip false positives: apt package lists, descriptive say/echo strings, which-probes
  printf '%s' "$line" | grep -qE 'apt(-get)? install|(^|[[:space:]])(say|echo)[[:space:]]"|^[[:space:]]*#?[[:space:]]*which ' && continue
  printf '%s' "$line" | grep -qE 'req\.sh|\$REQ|scope_check|'"$ALLOW" && continue
  echo "ERROR  $base ($f:$ln): naked network call — route target traffic via req.sh"
  echo "         > $(printf '%s' "$line" | sed 's/^[[:space:]]*//' | cut -c1-90)"
  err=$((err+1))
done < <(grep -rnE '(^|[^a-zA-Z.])(curl|wget)[[:space:]]|requests\.(get|post|put|delete)\(' "$SKILLS" --include=*.md --include=*.sh 2>/dev/null)

while IFS= read -r hit; do
  f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"; line="${rest#*:}"
  base="$(basename "$(dirname "$f")")"
  printf '%s' "$line" | grep -qE '^[[:space:]]*#?[[:space:]]*which ' && continue
  # accept if a rate flag appears within +/-5 lines (multi-line commands)
  if sed -n "$((ln>8?ln-8:1)),$((ln+8))p" "$f" | grep -qE '\-rl |\-rate|\-rate-limit|\-\-rate'; then continue; fi
  echo "WARN   $base ($f:$ln): bulk tool with no rate flag nearby (-rl/-rate)"
  warn=$((warn+1))
done < <(grep -rnE '(^|[^a-zA-Z])(httpx|nuclei|katana|ffuf)[[:space:]]' "$SKILLS" --include=*.md --include=*.sh 2>/dev/null)

echo "----"; echo "lint: $err error(s), $warn warning(s)"
[ "$err" -eq 0 ]
