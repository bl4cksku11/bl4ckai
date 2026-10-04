---
name: web-os-command-influence
description: Check whether request values reach a system command the server runs and can change which command or arguments execute. Reads reference notes first and records observations to the engagement folder.
---

# OS command influence

Plain name: OS command influence. One technique, one skill. Run it against one host at a time,
from the surface list in `02_strategy.md`. Stay in scope. This skill tests and
records only — it never drafts, submits, or contacts the program. A confirmed
result is handed to the operator and the finding path.

## 1. Set up paths and read any configured reference notes first

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
: "${ENGAGEMENTS_ROOT:=$BL4CKAI_HOME/engagements}"
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="$ENGAGEMENTS_ROOT/$LETTER/$TARGET"
HOST=app.acme.com
OUT="$ENG/checks/$HOST"; mkdir -p "$OUT"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$HOST" || exit 0   # REQUIRED: OUT of scope → stop; ASK → confirm with operator
```

If a reference library is configured (`KB_ROOT`), read its notes for this technique
as a starting set, then adapt to what THIS target actually does. If not, rely on
the method in this skill plus public references. Send EVERY live request in
this skill through `$REQ` (it enforces scope + the program header + the rate
cap) — never raw curl; bulk tools get a scope-filtered input list and `-rl`.

```bash
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Command Injection" ] || [ -d "$KB_ROOT/Web/Argument Injection" ]); then
  cat "$KB_ROOT/Web/Command Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Command Injection"/ && cat "$KB_ROOT/Web/Command Injection"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Argument Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Argument Injection"/ && cat "$KB_ROOT/Web/Argument Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find features that shell out
File conversion, image/PDF processing, archive handling, ping/DNS/network tools,
backup/restore, anything that likely invokes a binary with user input in the
arguments.

## 3. Probe argument and command separation safely
Use out-of-band confirmation (a DNS/HTTP callback to a listener you own) rather
than reading local output, and benign separators from the KB. Also test argument
injection: leading `-`/`--` that adds a flag to an otherwise fixed command.

## 4. Confirm with an out-of-band signal only
A callback that fires proves influence without running anything damaging. Stop
there and hand to the operator; do not run further commands, read files, or
establish any persistence.

## 5. Record per feature
Feature, parameter, whether it was command vs argument influence, the OOB signal
observed, and the exact request.

## 6. Record → `checks/$HOST/os_command.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `os_command.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `OS command influence check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `os_command.md`

```markdown
### POST /convert {filename}  — CONFIRMED (OOB)
filename=x$(curl OOB).png triggered DNS+HTTP callback from the server IP → command
influence. Stopped at callback; handed to operator. Evidence: .../evidence/acme-cmd-oob.txt
```
