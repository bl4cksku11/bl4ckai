---
name: engagement-setup
description: Set up a new assessment from a program's pasted policy and scope. The operator pastes the program information into the chat; you (the agent) read it and fill the whole workspace — scope file, brief, host seed, ledger, task queue — then stop for the operator to confirm scope and the required header. Run this first.
---

# Engagement setup

You are the intake agent. The operator pastes a program's information into the chat
(policy text + the scope/asset table, or a policy URL) and you do the whole setup
from it — there is no script for the operator to run. Read the pasted text, apply
judgment, write every artifact, and stop at the two confirmations. Nothing here
touches the target over the network.

## What the operator gives you

A pasted dump: the program policy and the scope/asset list. Sometimes just a URL —
if so, fetch it. If scope is genuinely missing, ask; never invent it.

## What you produce (do all of this from the paste)

Set the paths first:

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
TARGET=<slug>                     # short lowercase name you choose for the program
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
export ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
mkdir -p "$ENG"/{recon,checks,reports,evidence}
```

1. **Save the raw paste** verbatim to `$ENG/00_program_dump.txt` — it is the source
   of truth you and later skills re-read.

2. **`scope.txt`** — read the scope table and write the authorization boundary, with
   judgment a regex cannot apply:
   - Every in-scope hostname → derive the apex and write `*.apex` + `apex`. List
     unusual exact hosts too.
   - **Filter out** the platform and infra domains that appear in policies but are
     not the target (hackerone.com, bugcrowd.com, github.com, the researcher's own
     profile URL, doc links).
   - **"Ineligible" on HackerOne means NO BOUNTY, not out of scope** — do NOT exclude
     those hosts. Only add a `-` deny line for assets the policy actually excludes
     (marketing sites, third-party, explicitly out-of-scope).
   - Plain line = in-scope, leading `-` = out-of-scope (deny wins).

3. **`recon/subdomains.txt`** — every explicit in-scope host from the table, one per
   line. This seeds recon so nothing is lost.

4. **`00_program_brief.md`** — the rules that govern every later step, extracted and
   stated plainly:
   - Required request header (e.g. `X-HackerOne-Research: <handle>`) and account/alias rule.
   - Rate / pacing rule if stated.
   - Hard prohibitions (no DoS, no data access/exfiltration, no social engineering, …).
   - Excluded finding classes (self-XSS, missing headers, SPF, clickjacking non-sensitive, …).
   - `bbp` vs `vdp` from the reward language; any program-named "areas of focus".

5. **`00_ledger.md` and `_queue.json`** from the templates:

```bash
sed -e "s/{{TARGET}}/$TARGET/g" -e "s/{{PROGRAM}}/<Program Name>/g" -e "s/{{PLATFORM}}/<platform>/g" \
    -e "s/{{bbp|vdp}}/<type>/g" -e "s#{{A-Z}}#$LETTER#g" -e "s/{{DATE}}/$(date +%F)/g" \
    "$BL4CKAI_HOME/templates/ledger.template.md" > "$ENG/00_ledger.md"
sed -e "s/{{TARGET}}/$TARGET/g" -e "s/{{PROGRAM}}/<Program Name>/g" \
    "$BL4CKAI_HOME/templates/queue.template.json" > "$ENG/_queue.json"
```

Then tick the `## Setup` boxes in the ledger (all four artifacts now exist).

## Optional accelerator for a huge scope table

If the pasted table has dozens of hosts, you MAY save the dump and run
`intake.py <slug> <dumpfile>` to bulk-extract hosts and scaffold the files — but
it is a blunt regex tool: **verify and correct its `scope.txt` and brief yourself**
(it cannot tell "Ineligible" from out-of-scope, or a real exclusion from a mention).
You own the result, not the script.

## Stop here — the two confirmations (human-in-the-loop)

Do not proceed to recon on your own. Show the operator:
- the `scope.txt` you wrote (the authorization boundary), and
- the header and rate rule you read from the policy.

Ask them to confirm scope and to set `RESEARCH_HEADER` + `MAX_RPS` in `config.sh` to
match. Only after they confirm does anything touch the target.

## Example — what you report back after setup

```
Set up acme (hackerone, bbp) at $ENG
  scope.txt: *.acme.com, acme.com, *.acme.io, acme.io  (dropped hackerone.com; no exclusions found)
  recon seed: 63 hosts → recon/subdomains.txt
  brief: header "X-HackerOne-Research: <handle>" required; no DoS/social-eng; excludes self-XSS, missing headers
  ledger + queue initialized; Setup boxes ticked.
CONFIRM before recon: (1) scope.txt looks right? (2) set RESEARCH_HEADER + MAX_RPS to match?
```
