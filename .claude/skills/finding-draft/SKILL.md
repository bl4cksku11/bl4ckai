---
name: finding-draft
description: Turn a confirmed, non-duplicate result into a complete write-up. The agent writes the whole draft from the recorded notes and evidence, saves it in the engagement folder, and mirrors it to the operator's notes vault. Leaves it for the operator to validate; never submits.
---

# Finding draft

The agent writes the full report. This is agent work, not operator work — the
operator reviews and validates afterward. Runs after `dedup-check` returns NOVEL or
VARIANT. The draft stays `status: draft` and is never submitted or sent to the
program by this skill.

## Set up paths

```bash
TARGET=acme
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
SLUG=idor-orders-cross-account
TYPE=bbp                 # bbp (pays) or vdp — from 00_program_brief.md
PROGRAM=acme
VAULT="${VAULT_ROOT:+$VAULT_ROOT/$TYPE/$PROGRAM}"   # empty if no vault configured
```

## 1. Gather the source material

If `impact-escalation` produced `<slug>_impact.md`, use it for the Impact and
Severity sections — it already found the demonstrated ceiling and any chain. Score
Severity explicitly with a CVSS 3.1 vector that matches what the evidence shows
(not what is imaginable). Evidence is referenced by full path per CONVENTIONS §14.


Pull everything the draft must be built from — do not re-test, use what is recorded:

```bash
cat "$ENG/checks/"*/*"$SLUG"* 2>/dev/null   # the technique note(s) for this finding
cat "$ENG/reports/${SLUG}_dedup.md"          # the dedup verdict
ls  "$ENG/evidence/"                          # evidence files to reference by full path
cat "$ENG/00_program_brief.md"                # scope, excluded classes, reward tier
```

## 2. Write the draft from the template

Fill `$BL4CKAI_HOME/templates/finding.template.md` into
`$ENG/reports/$SLUG.md`. Rules that make a draft land:

- **Summary**: what, where, and the concrete effect in two or three sentences.
- **Steps to reproduce**: exact and minimal — the smallest sequence that works,
  copied from the recorded proof, with the real endpoint and the real request.
- **Proof of concept**: the actual request/response pair or smallest script, and a
  full-path reference to the evidence file under `$ENG/evidence/`.
- **Impact**: the concrete business effect for THIS program, not a generic
  description of the class. Tie it to what the affected data or action is worth.
- **Severity**: score what was proved, with a CVSS 3.1 vector. An honest Medium
  beats an inflated High that arrives with the operator's name on it.
- **Remediation**: specific and actionable for the observed stack.
- **Chain potential**: link related findings in this engagement with `[[slug]]`.
- Respect the brief: if the program excludes this class or marks the asset out of
  scope, say so at the top and flag for the operator rather than quietly drafting.

Set the frontmatter: `program`, `platform`, `type`, `severity`, `class` (plain
name), `endpoint`, `status: draft`, `date_found`, `tags`.

## 3. Mirror to the operator's vault

Only the finished finding goes to the vault — not notes, not recon.

```bash
if [ -n "$VAULT" ]; then
  mkdir -p "$VAULT"; cp "$ENG/reports/$SLUG.md" "$VAULT/$SLUG.md"
  echo "mirrored to $VAULT/$SLUG.md"
else
  echo "No vault configured (VAULT_ROOT); skipping mirror."
fi
```

## 4. Tick and present for validation

Tick the `Report draft written by agent` and `Vault mirror written` lines for this
finding in `$ENG/00_ledger.md`. Then show the operator a short summary: the title,
severity, one-line impact, and the two full paths (engagement + vault). Say plainly
that it is a draft awaiting their validation and that nothing has been or will be
submitted by the agent. The operator validates and submits; when they do, they (or
a later step at their request) update `status`.

## Example of good output — summary line back to the operator

```
Draft ready for validation:
  "Cross-account order access via sequential id on /api/orders/{id}" — High (CVSS 7.5)
  Impact: any authenticated user reads any other user's order incl. address + card last4.
  Draft:  $BL4CKAI_HOME/engagements/A/acme/reports/idor-orders-cross-account.md
  Vault:  $VAULT_ROOT/bbp/acme/idor-orders-cross-account.md   (or "no vault configured")
  Status: draft — awaiting your validation. Nothing submitted.
```
