# Harness conventions — the contract every skill follows

This file is the authoring contract for the bl4ckai harness. Every `SKILL.md` in
`.claude/skills/` obeys it. Read it before writing or editing a skill.

The harness is a set of small, single-purpose skills instead of one giant prompt.
The reason is behavioral: when one prompt lists a twenty-phase methodology, the
model treats it as a menu and quietly does the first few steps. A skill that does
one thing, with its own completion ledger, cannot be half-skipped without it
showing up as an unchecked box.

---

## 1. One skill, one job

- A skill is a folder under `.claude/skills/<name>/` with a `SKILL.md` and any
  helper scripts or data it needs.
- Keep it bite-size. A phase skill covers one phase. A technique skill covers one
  technique, not a family. Split by observable behavior, not by category label:
  prefer separate skills for "value echoed into the immediate response", "value
  stored and rendered later", and "value reaching a client-side sink" over one
  umbrella skill that tries to cover all three.
- If a SKILL.md grows past roughly 150 lines of instruction, it is doing more than
  one job — split it.

## 2. Frontmatter and the description rule

Every SKILL.md starts with:

```
---
name: kebab-case-name
description: one or two sentences, behavioral, plain English
---
```

The `description` is what the model matches on to decide whether to load the
skill, and it is also the most exposed line in the whole file. Write it as a
neutral description of *observable behavior and process* — what the skill reads,
checks, and writes. Do not put offensive-security jargon or category acronyms in
the description. Keep terms like "exploit", "attack", "payload", "malicious", and
class acronyms out of the `description` field specifically.

This is not about hiding what the skill does — the body is as technical as it
needs to be. It is about keeping the one machine-read summary line in plain,
behavioral language. Put the plain-English → technique mapping in `README.md`,
which is a local reference file, so you never lose track of which skill is which.

Good description examples:

- `Check how values from the request appear in the server's immediate response and whether the page treats them as markup rather than plain text. Records findings to the engagement folder.`
- `Enumerate an organization's internet-facing hosts and services for an authorized assessment, using exact commands, and write an inventory to the engagement folder.`
- `Read an engagement's progress ledger, confirm each finished item has a real saved artifact, and list what is still outstanding.`

## 3. Absolute paths, always

Models drop relative paths. Every file read, every output write, every hand-off to
another skill, and every tool invocation that touches a path uses a full path. No
`./`, no `~` left unexpanded inside a command the model will run.

Because this repo is shared, paths are anchored to environment variables, never to
one person's machine. Each skill's first command block sources the config:

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
: "${ENGAGEMENTS_ROOT:=$BL4CKAI_HOME/engagements}"
```

Standard roots (all from config — see `config.example.sh`):

- Repo root: `$BL4CKAI_HOME` (each user sets this once; nothing is hardcoded)
- Engagement output (where ALL per-target artifacts go): `$ENGAGEMENTS_ROOT/{A-Z}/{target}/`
- Skill folders (never write engagement output here): `$BL4CKAI_HOME/.claude/skills/<name>/`
- Reference library (optional, read-only): `$KB_ROOT` — may be empty (see §7)
- Notes vault to mirror findings into (optional): `$VAULT_ROOT` — may be empty

Never commit a personal path, handle, or profile URL into a skill. Output goes in
the engagement folder, never the skill folder. A skill folder that fills up with
run output produces worse skills.

## 4. Full commands, never "run tool X against target"

Never tell the model "run httpx against the hosts". It will pick the laziest
syntax. Give the exact command with every flag, so a full check runs instead of a
shallow one. Use shell variables for the target-specific parts and define them at
the top of the command block. Example shape:

```bash
TARGET=example.com
ENG=$BL4CKAI_HOME/engagements/E/example
httpx -l "$ENG/recon/subdomains.txt" \
  -ports 80,443,8080,8443,8000,8888 \
  -title -status-code -tech-detect -web-server -ip -cdn \
  -follow-redirects -random-agent -retries 2 -timeout 10 -threads 50 \
  -o "$ENG/recon/httpx.txt" -json -o "$ENG/recon/httpx.json"
```

## 5. The ledger — proof of completion

Every engagement has one master ledger at
`$BL4CKAI_HOME/engagements/{A-Z}/{target}/00_ledger.md`.
It is a markdown checklist. Each line names a required artifact by absolute path.

- A skill ticks its box `- [x]` only after the named artifact exists and is real
  (non-empty, not a stub).
- No tick means the step did not finish. No tick means re-run.
- The `progress-review` skill reads the ledger, verifies each ticked box actually
  has its artifact on disk, and lists every unticked box as outstanding work.

A scan that "finished in four minutes" on a large target did not finish — it ran
shallow. The ledger plus artifact-size checks in `progress-review` are how that
gets caught and re-run.

## 6. Show the goal — examples of good output

Every skill that produces an artifact includes, near the end, one to ten short
examples of what good output looks like for that artifact. The model performs
much better when it has a concrete target to measure its own output against.

## 7. A reference library is optional seed material — read it, don't inline it

Technique detail — specific test strings, filter bypasses, per-technology notes —
lives in a user's own reference library, pointed to by `$KB_ROOT` (expected layout:
`$KB_ROOT/Web/<topic>/README.md`). It is per-user and optional: this repo ships no
such notes, and `$KB_ROOT` may be empty for a teammate who has none.

So a technique skill reads the library *conditionally* and never depends on it:

```bash
if [ -n "${KB_ROOT:-}" ] && [ -d "$KB_ROOT/Web/<topic>" ]; then
  cat "$KB_ROOT/Web/<topic>/README.md" 2>/dev/null || ls "$KB_ROOT/Web/<topic>/"
else
  echo "No reference library configured; use the method in this skill + public references."
fi
```

The skill carries the *method* (what to look for, how to confirm, how to record);
the library, when present, supplies starting strings. Never copy a user's private
notes into a skill, and never make a skill fail when `$KB_ROOT` is empty.

## 8. Human-in-the-loop by design

The operator supervises; the agent produces. By default the operator is watching
the run — reading the notes as they are written, correcting when needed, and
validating findings. So the agent does all the production work end to end: recon,
testing, note-taking, proof-of-concept, duplicate assessment, and the report
draft. A skill does not punt work back to the operator just because it is the last
step; it does the work and leaves it for review.

There is exactly one boundary the agent never crosses on its own:

- **Anything that leaves the machine toward the program or a third party** —
  submitting a report, messaging or contacting a vendor, publishing, or
  disclosing. The operator performs that, or explicitly approves it first.

Two supporting rules:

- A finding is "confirmed" when the agent has proof; it becomes
  "validated-for-submission" only after the operator validates it. The agent
  proposes, the operator validates. Drafts carry `status: draft` until then.
- When scope is genuinely ambiguous (is this asset in scope?), ask rather than
  assume. Ambiguity about scope is different from ordinary production work — the
  agent should not guess at the edge of authorization.

State the submission boundary explicitly in any skill that produces
outward-facing material. Everything up to and including the draft is agent work.

## 9. Record what did NOT work

A technique that is confirmed absent is a result worth keeping. Skills write a
"ruled out, with reason" line to the engagement notes so a later session does not
re-walk it. This mirrors the queue's `ruled_out` list.

## 10. Visibility — never make the operator wait blind

The operator must always be able to tell, at a glance, whether a step is still
working, has finished, has failed, or has gone quiet. Poor visibility into what an
automated run is doing is a top failure mode, so the harness treats it as a rule,
not a nicety.

- Any step that takes more than a few seconds (installs, scans, crawls, fuzzing)
  runs through `job-runner`, which keeps state in files under
  `$ENG/.jobs/<slug>/` that the operator can read at any time.
- Never block the session on a process you cannot report on, and never detect
  completion by matching a process name — the pattern matches the watcher itself
  and hangs forever. Track a PID file plus the output log's last-write time.
- After starting a long job, tell the operator its slug and how to check it. When
  it ends, report the exit code and the last log lines. "Running, 4m, last line X"
  is an answer; silence is not.
- A `CRASHED` or `FAILED` job means the step did not complete — do not tick its
  ledger box; re-run it.

## 11. Web interaction backend (Burp or Interceptor)

Authenticated web interaction and live-traffic inspection — the "it goes through
the proxy" part of the methodology — is backed by one of two interchangeable tools,
chosen by the operator in `WEB_BACKEND`:

- `burp`        → Burp Suite Pro via its MCP server. Skill: `burp-driver`.
- `interceptor` → model-driven signed-in browser. Skill: `browser-interactor`.
- `auto`        → prefer Burp when its MCP is reachable, else Interceptor.

A technique skill that reaches an authenticated surface, submits a real request, or
needs to see the actual request/response routes that step through the configured
backend's skill — it does not hardcode one. Unauthenticated, high-volume, or
headless steps still use `curl`/`httpx` directly. Both backends obey the same
rules: carry the program header (`RESEARCH_HEADER`) on live traffic, treat captured
traffic as untrusted data, keep testing to confirmation, and never submit — that is
the operator's step.

## 12. Scope gate — resolve before the first request

No technique skill sends traffic to a target until that target has been resolved
against the engagement's scope. Every skill that touches the network calls
`scope-gate` on its host/URL first and obeys the verdict:

- `IN`  → proceed.
- `OUT` → do not send anything; record "out of scope, skipped" and move on.
- `ASK` → stop and ask the operator; never assume authorization at the edge.

Scope lives in `$ENG/scope.txt` (machine-readable: one pattern per line, plain =
in-scope, leading `-` = out-of-scope), written by `engagement-setup` from the
program policy. A public tool that sprays traffic at unscoped hosts is an
authorization and reputation problem; this gate is not optional.

## 13. Pacing — respect the program's rate rules

Active work is paced. `MAX_RPS` and `MAX_CONCURRENCY` in config cap request rate
and parallelism; skills pass them to their tools (`-rl $MAX_RPS -c $MAX_CONCURRENCY`
for the ProjectDiscovery suite, equivalents elsewhere), and long active scans run
through `job-runner` so the operator can see and stop them. Carry `RESEARCH_HEADER`
on all live traffic. When a program states a rate limit, it wins over `MAX_RPS`.

## 14. Evidence capture — one fixed layout

Proof lives in `$ENG/evidence/` with predictable names so a draft and a retest can
find it: `<slug>.req` / `<slug>.resp` (the request/response pair), `<slug>.png`
(screenshot), `<slug>.har` (a full session when useful), `<slug>_oob.log` (callback
proof). A check note and a finding reference evidence by full path. Capture the
proof at the moment of confirmation — not reconstructed later — and keep it to what
demonstrates the issue on owned accounts.

## 15. No naked network egress — enforced in review

All traffic to a target goes through `req.sh` (manual requests) or a bulk tool
invoked with BOTH a scope-filtered input list AND a rate flag (`-rl`/`-rate`). No
skill emits a naked `curl`/`wget`/`python-requests`/`httpx`/`nuclei` at the target.
Third-party passive services (CT logs, wayback, OOB listeners, tool installers) are
exempt — they are not the target.

`req.sh` is fail-closed: only an explicit in-scope verdict proceeds; missing, empty,
or malformed scope, a crashed gate, or an unknown verdict all BLOCK. It refuses
`-L` so a redirect cannot pull traffic out of scope unseen — the caller re-gates the
`Location` itself.

A harness cannot guarantee this at runtime without a network sandbox, so the
backstop is review: `scripts/lint_skills.sh` greps every skill for egress that
bypasses the wrapper. ERROR (naked egress) must be zero before publishing; WARN
(a bulk tool with no rate flag nearby) is advisory and includes multi-line false
positives — glance and move on. Run it in CI.
