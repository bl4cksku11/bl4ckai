---
name: disclosure-intake
description: At setup, collect the program's already-published reports and the operator's own past submissions into a local corpus, so later duplicate checks compare against real prior art instead of running blind.
---

# Disclosure intake

`dedup-check` is only as good as what it can compare against. This gathers the prior
art once, at setup, so the duplicate judgment has something real to work with: the
program's public disclosures and the operator's own history.

## Set up paths

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
CORP="$ENG/prior_art"; mkdir -p "$CORP"
```

## 1. The program's public disclosures

If the program discloses reports (HackerOne Hacktivity, a public changelog, a CVE
list), collect the disclosed items for THIS program: title, class, affected area,
date, and the link. Pull them through the configured web backend
(`burp-driver`/`browser-interactor`) or the platform's API if the operator has
access; carry the program header on any live request. Save to
`$CORP/program_disclosures.md`, one row per item.

## 2. The operator's own history

From `PLATFORM_PROFILES` (if set) and the operator's vault (`VAULT_ROOT`), collect
what the operator has already reported on this program (and closely similar reports
on other programs that could be re-filed). Save to `$CORP/operator_history.md`.
Skip silently if neither is configured.

## 3. Index for fast matching

Write `$CORP/index.txt`: one line per prior item as
`class | area/endpoint | title | link`, lowercased — the cheap thing `dedup-check`
greps against before a candidate is drafted.

## Hand-off

`dedup-check` reads `$CORP/index.txt` first (self-dup + program history) and only
then falls back to live profile lookups. Keep this corpus; refresh it if the
engagement runs long or the program newly discloses a batch.

## Example of good output — `prior_art/index.txt`

```
idor | /api/invoices/{id} | IDOR on invoices exposes PII | h1/reports/123
open-redirect | /login?next | Open redirect in login return | h1/reports/456
info-leak | /debug | Stack trace on error discloses paths | changelog#2024-11
```
