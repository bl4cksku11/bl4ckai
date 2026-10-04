---
name: engagement-setup
description: Start a new assessment workspace from a program's policy page. Reads the program's scope and rules, creates the per-target folder tree, and initializes the progress ledger and task queue. Run this first.
---

# Engagement setup

First skill for any new authorized program. It turns a program policy into a
workspace: a folder tree, a brief, a ledger, and a seeded task queue. Nothing here
touches the target over the network.

## Inputs you need from the operator

- Program name and platform (hackerone | bugcrowd | other)
- Policy / scope URL
- Confirmation the program authorizes testing (it is in scope on the platform)

If the policy URL is missing, ask for it. Do not guess scope.

## Steps

### 1. Pick the engagement path

File alphabetically by the first letter of the target slug (a simple A–Z filing
convention that keeps large numbers of targets navigable).

```bash
TARGET=acme                 # lowercase slug, no spaces
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
echo "Engagement root: $ENG"
```

### 2. Create the folder tree

```bash
mkdir -p "$ENG"/{recon,checks,reports,evidence}
```

### 3. Read the policy and write the brief

Fetch the policy URL and extract, into `$ENG/00_program_brief.md`:

- Every in-scope asset (domains, subdomains, IP ranges, apps)
- Every out-of-scope asset
- Explicitly excluded finding classes
- Reward structure → decide `bbp` (pays) vs `vdp` (no pay)
- Any "areas of focus" the program names — note these, they are underexplored
- Disclosure and duplicate-handling rules

### 3b. Write the machine-readable scope file (required — `scope-gate` reads it)

Turn the scope into `$ENG/scope.txt`: one hostname pattern per line, plain =
in-scope, leading `-` = out-of-scope. Globs allowed. Every network-touching skill
checks a host against this before sending traffic (CONVENTIONS §12).

```bash
cat > "$ENG/scope.txt" <<'SCOPE'
# in-scope (allow)
*.acme.com
api.acme.io
# out-of-scope (deny — deny wins over allow)
-blog.acme.com
-*.marketing.acme.com
SCOPE
```

Only write patterns the policy actually authorizes. If scope is "open / all owned
assets", still list the known apexes here and leave genuinely-unknown hosts to
resolve as `ASK` at test time rather than blanket-allowing `*`.

### 4. List the knowledge base topics

So later skills know what reference material exists. Append to the brief:

```bash
if [ -n "${KB_ROOT:-}" ] && [ -d "$KB_ROOT" ]; then
  { echo; echo "## Reference library topics (KB_ROOT)"; ls "$KB_ROOT"; \
    [ -d "$KB_ROOT/Web" ] && ls "$KB_ROOT/Web"; } >> "$ENG/00_program_brief.md"
else
  echo "(No reference library configured; skills use their built-in method.)" \
    >> "$ENG/00_program_brief.md"
fi
```

### 5. Initialize the ledger

Copy the template and fill the header fields. Leave every box unchecked.

```bash
sed -e "s/{{TARGET}}/$TARGET/g" -e "s/{{DATE}}/$(date +%F)/g" \
  $BL4CKAI_HOME/templates/ledger.template.md \
  > "$ENG/00_ledger.md"
```

### 6. Initialize the task queue

```bash
sed -e "s/{{TARGET}}/$TARGET/g" \
  $BL4CKAI_HOME/templates/queue.template.json \
  > "$ENG/_queue.json"
```

Seed the queue with the first real tasks and their priority scores: run `web-recon`,
then build the strategy, then the per-surface checks the brief points to. Set each
task's `skill` field to the skill that performs it.

### 7. Tick the Setup boxes

Only after each artifact above exists, edit `$ENG/00_ledger.md` and change the four
`## Setup` boxes to `- [x]`. Then tell the operator the engagement is set up and
name the next skill to run (`web-recon`).

## Example of good output — `00_program_brief.md`

```markdown
# Program brief — acme (hackerone, bbp)

## In scope
- *.acme.com
- api.acme.io
- Acme Android app (com.acme.app)

## Out of scope
- blog.acme.com (marketing, third-party)
- Anything matching self-* class exclusions below

## Excluded classes
- Missing security headers, SPF/DMARC, rate limiting, self-directed only issues,
  clickjacking on non-sensitive pages

## Rewards
- critical 5000, high 2000, medium 600, low 150  → type: bbp

## Areas of focus (program-named — prioritize)
- The new billing workflow under /v2/billing
- Partner API token exchange

## Duplicate / disclosure
- First valid reporter. Coordinated disclosure after fix.

## KB topics available
Web/ ... (list)
```
