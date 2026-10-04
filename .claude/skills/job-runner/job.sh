#!/usr/bin/env bash
# bl4ckai job runner — run long steps with operator-visible status in a FILE.
# No process name-matching (that footgun self-matches); liveness is tracked by a
# PID file plus the output log's last-write time. The operator can read status any
# time without the agent narrating it.
#
# Usage:
#   job.sh run <slug> "<label>" "<shell command>"   # start, returns immediately
#   job.sh status [slug]                             # one line per job, or detail
#   job.sh watch  <slug>                             # follow its output
#   job.sh wait   <slug>                             # block until it ends (for scripts)
#
# Needs $ENG (engagement root). Jobs live under $ENG/.jobs/<slug>/.
set -uo pipefail
: "${ENG:?export ENG=\$ENGAGEMENTS_ROOT/<A-Z>/<target> first}"
STALL="${STALL:-120}"          # seconds without output before a RUNNING job is flagged
JROOT="$ENG/.jobs"

now(){ date +%s; }
human(){ local s=$1; printf '%dm%02ds' $((s/60)) $((s%60)); }
mtime(){ stat -c %Y "$1" 2>/dev/null || echo 0; }

cmd="${1:-}"; shift || true
case "$cmd" in
run)
  slug="$1"; label="$2"; command="$3"; d="$JROOT/$slug"; mkdir -p "$d"
  printf '%s' "$label"   > "$d/label"
  printf '%s' "$command" > "$d/cmd"
  now > "$d/start"; echo RUNNING > "$d/state"; : > "$d/output.log"; rm -f "$d/exit" "$d/end"
  ( bash -c "$command" >>"$d/output.log" 2>&1; code=$?
    echo "$code" > "$d/exit"; now > "$d/end"
    [ "$code" -eq 0 ] && echo DONE > "$d/state" || echo FAILED > "$d/state"
  ) & echo "$!" > "$d/pid"
  echo "started '$slug' (pid $(cat "$d/pid")) — $label"
  echo "status:  ENG=$ENG bash $0 status $slug"
  ;;
status)
  [ -d "$JROOT" ] || { echo "(no jobs yet)"; exit 0; }
  one(){ local d="$1" slug; slug="$(basename "$d")"
    local label state start pid; label="$(cat "$d/label" 2>/dev/null)"; state="$(cat "$d/state" 2>/dev/null)"
    start="$(cat "$d/start" 2>/dev/null || echo 0)"; pid="$(cat "$d/pid" 2>/dev/null || echo 0)"
    local disp note=""
    if [ "$state" = RUNNING ]; then
      if kill -0 "$pid" 2>/dev/null; then
        local idle=$(( $(now) - $(mtime "$d/output.log") ))
        disp="RUNNING $(human $(( $(now) - start )))"
        [ "$idle" -ge "$STALL" ] && note="  ⚠ no output for $(human $idle) — may be stalled"
      else
        disp="CRASHED (pid gone, no exit recorded)"; note="  ⚠ died without finishing"
      fi
    else
      local end exit dur; end="$(cat "$d/end" 2>/dev/null || now)"; exit="$(cat "$d/exit" 2>/dev/null)"
      dur=$(( end - start )); disp="$state in $(human $dur) (exit $exit)"
    fi
    printf '%-18s %s%s\n' "$slug" "$disp" "$note"
    printf '    last: %s\n' "$(tail -n1 "$d/output.log" 2>/dev/null | cut -c1-96)"
  }
  if [ -n "${1:-}" ]; then
    d="$JROOT/$1"; [ -d "$d" ] || { echo "no such job: $1"; exit 1; }
    one "$d"; echo "    label: $(cat "$d/label" 2>/dev/null)"; echo "    cmd:   $(cat "$d/cmd" 2>/dev/null)"
    echo "    log:   $d/output.log"
  else for d in "$JROOT"/*/; do [ -d "$d" ] && one "$d"; done; fi
  ;;
watch)
  d="$JROOT/$1"; [ -d "$d" ] || { echo "no such job: $1"; exit 1; }
  tail -f "$d/output.log"
  ;;
wait)
  d="$JROOT/$1"; [ -d "$d" ] || { echo "no such job: $1"; exit 1; }
  while [ "$(cat "$d/state" 2>/dev/null)" = RUNNING ] && kill -0 "$(cat "$d/pid" 2>/dev/null)" 2>/dev/null; do sleep 5; done
  echo "$(basename "$d"): $(cat "$d/state") (exit $(cat "$d/exit" 2>/dev/null))"
  ;;
*) echo "usage: job.sh run <slug> <label> <command> | status [slug] | watch <slug> | wait <slug>"; exit 2;;
esac
