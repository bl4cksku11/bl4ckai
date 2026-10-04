#!/usr/bin/env bash
# Provision/track the test identities an access-control check needs (account A,
# account B, anon, admin…). Credentials are secrets: they live ONLY under the
# gitignored engagement dir, never committed. File-based store avoids JSON escaping.
#
#   identity.sh set  <name> <role> <auth header line>   store/replace an identity
#   identity.sh get  <name>                             print its auth header line
#   identity.sh hdr  <name>                             print `-H '<auth>'` for curl/tools
#   identity.sh list                                    names + roles + age (no secrets)
#   identity.sh del  <name>
#
# <auth header line> is exactly what goes on the wire, e.g.
#   "Cookie: session=abc123"   or   "Authorization: Bearer eyJ..."
set -uo pipefail
: "${ENG:?export ENG=\$ENGAGEMENTS_ROOT/<A-Z>/<target> first}"
DIR="$ENG/identities"; mkdir -p "$DIR"; chmod 700 "$DIR" 2>/dev/null || true

cmd="${1:-}"; shift || true
case "$cmd" in
  set)
    name="${1:?name}"; role="${2:?role}"; shift 2; auth="$*"
    [ -z "$auth" ] && { echo "need an auth header line"; exit 2; }
    d="$DIR/$name"; mkdir -p "$d"
    printf '%s' "$role" > "$d/role"
    printf '%s' "$auth" > "$d/auth"; chmod 600 "$d/auth" 2>/dev/null || true
    date +%s > "$d/added"
    echo "stored identity '$name' (role=$role)"
    ;;
  get) d="$DIR/${1:?name}"; [ -f "$d/auth" ] && cat "$d/auth" || { echo "no such identity: $1" >&2; exit 1; } ;;
  hdr) d="$DIR/${1:?name}"; [ -f "$d/auth" ] && printf -- "-H '%s'" "$(cat "$d/auth")" || { echo "no such identity: $1" >&2; exit 1; } ;;
  list)
    [ -d "$DIR" ] || { echo "(no identities)"; exit 0; }
    now=$(date +%s)
    for d in "$DIR"/*/; do [ -d "$d" ] || continue
      n=$(basename "$d"); r=$(cat "$d/role" 2>/dev/null); a=$(cat "$d/added" 2>/dev/null || echo "$now")
      age=$(( (now - a) / 60 )); printf "  %-10s role=%-8s age=%dm\n" "$n" "$r" "$age"; done
    ;;
  del) rm -rf "$DIR/${1:?name}" && echo "removed $1" ;;
  *) echo "usage: identity.sh set|get|hdr|list|del … (see header)"; exit 2 ;;
esac
