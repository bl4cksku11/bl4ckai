# bl4ckai — a skill-based harness for authorized security assessments

A modern harness for bug bounty, vulnerability research, and disclosure work.
Instead of one enormous prompt, the methodology is split into many small skills.
Each skill does one job, writes a completion box to a per-engagement ledger, and
reads technique detail from the operator's knowledge base rather than carrying it
inline. Human stays in the loop: nothing leaves the machine without the operator.

See `CONVENTIONS.md` for the authoring contract. Read it before adding a skill.

## Why small skills

A single prompt with a long methodology gets treated as a menu — the model does
the first few phases and declares victory. Small skills with per-skill ledgers
make a skipped step visible as an unchecked box, and `progress-review` re-queues
it. This is the core design bet.

## The loop

```
engagement-setup   → scope, folder tree, ledger, queue       (never touches target)
      ↓
web-recon          → host + surface inventory, strategy        (full commands)
      ↓
technique skills   → one observable behavior each, per surface  (read KB first)
      ↓          ↖──────── strategy-refresh re-prioritizes the queue every ~5 checks
on each confirmed result:
  dedup-check      → novel / variant / duplicate verdict
  finding-draft    → agent writes the full draft + vault mirror  (status: draft)
      ↓
progress-review    → verify every ledger box against disk, re-queue gaps
      ↓
operator           → watches throughout; validates findings; submits   (the only
                     step the agent never does on its own)
```

The agent does all production work — recon, testing, notes, PoC, dedup, and the
draft. The operator supervises by default (reads notes, corrects, validates) and
is the only one who sends anything to the program. See `CONVENTIONS.md` §8.

## Setup (per teammate)

Nothing is hardcoded to one machine — paths come from config.

1. Clone the repo, then point an env var at it (shell rc or Claude Code project
   settings): `export BL4CKAI_HOME=/path/to/this/repo`
2. `cp config.example.sh config.sh` and edit. `config.sh` is gitignored — it holds
   your machine's paths and your identity, and never gets committed.
   - `ENGAGEMENTS_ROOT` — where engagement output is written (default: `$BL4CKAI_HOME/engagements`)
   - `KB_ROOT` — optional personal reference library; empty is fine
   - `VAULT_ROOT` — optional notes vault to mirror findings into; empty is fine
   - `OPERATOR_HANDLE` / `PLATFORM_PROFILES` — optional, used in write-ups + dedup
3. Optional: pick a **web interaction backend** for authenticated testing +
   live-traffic inspection, via `WEB_BACKEND` in `config.sh`:
   - `burp` — **Burp Suite Pro** + its MCP server (BApp "MCP Server", SSE on
     `BURP_MCP_URL`). Register once: `claude mcp add --transport sse --scope user
     burpsuite "$BURP_MCP_URL"`. Connects when Burp is open. See `burp-driver`.
   - `interceptor` — model-driven signed-in browser. Install on the machine with
     your browser (`tool-setup` `interceptor` target), load its extension,
     `interceptor mcp install`, set `INTERCEPTOR_BIN`. See `browser-interactor`.
     Leave `INTERCEPTOR_MCP_FENCE=on` and `INTERCEPTOR_MCP_ALLOW` unset.
   Set `RESEARCH_HEADER` either way so live traffic carries the program header.

## Where things live

- Skills: `$BL4CKAI_HOME/.claude/skills/<name>/SKILL.md`
- Templates: `$BL4CKAI_HOME/templates/`
- Tooling notes: `$BL4CKAI_HOME/docs/tooling.md`
- Engagement output (filed A–Z by target): `$ENGAGEMENTS_ROOT/{A-Z}/{target}/`
- Reference library (optional, per-user): `$KB_ROOT`

`engagements/` and `config.sh` are gitignored so no target data or personal path is
ever committed.

## Skill index — plain name ↔ skill name

Skill `description` fields stay in neutral, behavioral language on purpose. This
table is the decoder ring; keep it current as skills are added.

### Built (vertical slice)
| Skill | Plain name / what it is |
|---|---|
| `engagement-setup` | Scope intake + workspace + ledger + queue |
| `web-recon` | Host/surface enumeration with full commands |
| `web-reflected-response` | Reflected script execution (reflected XSS) |
| `progress-review` | Completion gate — verify ledger vs disk, re-queue |

### Built — cross-domain / setup skills
| Skill | Plain name / what it is |
|---|---|
| `tool-setup` | Install + verify the CLI programs an engagement needs, logged (sets: core/web-full/review/fuzzing, plus `interceptor`) |
| `job-runner` | Run long steps in the background with status in a file the operator can read anytime (running/done/failed/stalled) |
| `browser-interactor` | Web backend A — drive the operator's signed-in browser + inspect its traffic via Interceptor (authenticated web + live requests) |
| `burp-driver` | Web backend B — drive Burp Suite Pro via its MCP (`mcp__burpsuite__*`): replay requests, proxy history, Intruder, Collaborator OOB. Pick via `WEB_BACKEND` |
| `url-mining` | Offline: turn bulk recon URLs into parameters, API endpoints, and per-host target lists (no new traffic) |

### Built — web technique skills (one behavior each)
Seeded into each engagement's ledger per surface via `templates/technique_menu.md`.

| Skill | Plain name |
|---|---|
| `web-stored-response` | Stored script execution (stored XSS) |
| `web-client-sink-trace` | Client-side sink execution (DOM XSS) |
| `web-markup-gadget-survey` | Markup/script gadget survey for sink chains |
| `web-object-reference-walk` | Object-reference access control (IDOR/BOLA) |
| `web-function-access-walk` | Function-level access control |
| `web-server-fetch-probe` | Server-initiated request behavior (SSRF) |
| `web-template-eval-check` | Server-side template evaluation (SSTI) |
| `web-db-query-influence` | Database query influence (SQL/NoSQL) |
| `web-os-command-influence` | OS command influence |
| `web-path-resolution-check` | Path resolution / traversal + file inclusion |
| `web-xml-entity-check` | XML entity processing (XXE) |
| `web-redirect-trust-check` | Redirect destination trust (open redirect) |
| `web-request-boundary-check` | Request boundary parsing (smuggling/desync) |
| `web-cross-origin-policy-check` | Cross-origin sharing policy |
| `web-token-handling-check` | Session token handling (JWT etc.) |
| `web-auth-flow-check` | Authentication flow (reset, OAuth/OIDC, SAML, MFA) |
| `web-logic-flow-walk` | Business-logic and workflow |
| `web-upload-handling-check` | File upload handling |
| `web-cache-behavior-check` | Cache behavior (deception/poisoning) |

### Built — other scope verticals (one behavior each, neutral descriptions)
Same pattern as web: bite-size, KB-optional, ledger-backed, confirm→dedup→draft.

**mobile** — `mobile-package-inspect` (unpack+manifest/permissions/components) · `mobile-secret-scan` · `mobile-traffic-inspect` (app↔server + cert) · `mobile-storage-check` (data at rest) · `mobile-component-reach` (exported components/deep links) · `mobile-auth-token-check`

**source** — `source-intake` (pin+map) · `source-dependency-audit` (advisories + reachability) · `source-input-trace` (source→sink by reading) · `source-auth-logic-review` · `source-secret-scan` (tree+history) · `source-crypto-review` · `source-query-construction-review`

**api** — `api-schema-map` · `api-object-reference-walk` (BOLA) · `api-function-access-walk` (BFLA) · `api-auth-token-check` · `api-mass-assignment-check` · `api-input-validation-check`

**cloud** — `cloud-storage-exposure` · `cloud-subdomain-takeover` (dangling DNS) · `cloud-identity-review` (over-broad roles) · `cloud-metadata-reach` · `cloud-exposed-service` · `cloud-secret-scan`

**ai** — `ai-input-handling-check` (prompt-injection surface) · `ai-output-trust-check` · `ai-data-exposure-check` · `ai-tool-access-check` · `ai-resource-abuse-check`

**contract** — `contract-intake` · `contract-access-control-review` · `contract-arithmetic-review` · `contract-external-call-order-review` (reentrancy) · `contract-oracle-review` (price manipulation) · `contract-upgrade-review` (proxy safety)

**hardware** — `hardware-firmware-extract` · `hardware-firmware-secret-scan` · `hardware-interface-survey` (UART/JTAG/debug) · `hardware-service-review` · `hardware-update-integrity-review`

### Built — shared workflow skills
| Skill | Job |
|---|---|
| `dedup-check` | Compare a confirmed result against the operator's history + program disclosures; verdict novel/variant/duplicate |
| `finding-draft` | Agent writes the full draft from notes+evidence, mirrors to the vault; leaves it `status: draft` for operator validation |
| `strategy-refresh` | The self-adjusting pass: record lessons, re-prioritize the queue, expand it from observation triggers |

## Running an engagement

1. Invoke `engagement-setup` with the program name + policy URL.
2. Invoke `web-recon`.
3. Work the queue — one technique skill per surface, each reading its KB file first.
4. Invoke `progress-review`; re-run anything it demotes or lists outstanding.
5. Operator reviews drafts and submits. The harness never submits.
