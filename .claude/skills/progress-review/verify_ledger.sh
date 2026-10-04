#!/usr/bin/env bash
# Audit a progress ledger against disk.
# Usage: verify_ledger.sh /abs/path/to/00_ledger.md
# Prints one line per checklist item: COMPLETE | SUSPECT | OUTSTANDING
set -u

LEDGER="${1:?usage: verify_ledger.sh <ledger.md>}"
MIN_BYTES="${MIN_BYTES:-16}"   # artifact smaller than this is treated as a stub
ENG_DIR="$(dirname "$LEDGER")"

[ -f "$LEDGER" ] || { echo "ERROR: ledger not found: $LEDGER" >&2; exit 2; }

complete=0; suspect=0; outstanding=0

# Resolve a ledger path token (may be relative like `.../recon/x.txt`) against the
# engagement dir. Leading `.../` or `.../` style is normalized to the ledger's dir.
resolve() {
  local p="$1"
  p="${p#\`}"; p="${p%\`}"                 # strip backticks
  case "$p" in
    /*) printf '%s' "$p" ;;                # already absolute
    .../*) printf '%s/%s' "$ENG_DIR" "${p#.../}" ;;
    */*) printf '%s/%s' "$ENG_DIR" "$p" ;;
    *)   printf '%s/%s' "$ENG_DIR" "$p" ;;
  esac
}

while IFS= read -r line; do
  case "$line" in
    "- [ ]"*)
      echo "OUTSTANDING  ${line#- [ ] }"
      outstanding=$((outstanding+1))
      ;;
    "- [x]"*|"- [X]"*)
      # Prefer the last backtick-quoted path on the line (robust to trailing notes
      # like "(KB section)"); else fall back to whatever follows the last → / ->.
      if printf '%s' "$line" | grep -q '`'; then
        art="$(printf '%s' "$line" | sed 's/.*`\([^`]*\)`[^`]*$/\1/')"
      else
        art="${line##*→}"
        [ "$art" = "$line" ] && art="${line##*-> }"
      fi
      art="$(echo "$art" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      if [ -z "$art" ] || [ "$art" = "$line" ]; then
        echo "COMPLETE     (no artifact path declared) ${line#- [x] }"
        complete=$((complete+1)); continue
      fi
      f="$(resolve "$art")"
      if [ ! -e "$f" ]; then
        echo "SUSPECT      missing: $f"
        suspect=$((suspect+1))
      else
        sz=$(wc -c < "$f" 2>/dev/null || echo 0)
        if [ "$sz" -lt "$MIN_BYTES" ]; then
          echo "SUSPECT      stub (${sz}B): $f"
          suspect=$((suspect+1))
        else
          echo "COMPLETE     ${sz}B: $f"
          complete=$((complete+1))
        fi
      fi
      ;;
  esac
done < "$LEDGER"

echo "----"
echo "SUMMARY complete=$complete suspect=$suspect outstanding=$outstanding"
[ "$suspect" -eq 0 ] && [ "$outstanding" -eq 0 ] && exit 0 || exit 1
