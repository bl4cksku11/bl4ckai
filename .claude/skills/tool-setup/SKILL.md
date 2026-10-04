---
name: tool-setup
description: Install and verify the command-line programs an engagement needs on a fresh machine, logging what was installed and its version. Run it at the start of a project and whenever a step reports a missing program.
---

# Tool setup

Prepares a machine for an engagement. It installs a curated set of command-line
programs, copies them where every shell can find them, and records versions so a
run is reproducible. Idempotent — re-running only fills gaps.

## When to run

- First time on a new machine (install the `core` set).
- Any time a skill's command reports a program is missing (install that one).

## Set up paths

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
```

## Install

The installer lives beside this skill and takes either a set name or explicit
programs. It handles apt packages, Go programs, and Python programs, then copies Go
binaries into `/usr/local/bin` so they are on `PATH` for every shell.

```bash
# the standard set for a web engagement (safe to re-run)
bash "$BL4CKAI_HOME/.claude/skills/tool-setup/install.sh" core

# the fuller set (adds crawlers, fuzzers, JS/secret helpers, screenshotters)
bash "$BL4CKAI_HOME/.claude/skills/tool-setup/install.sh" full

# just one or a few, by name
bash "$BL4CKAI_HOME/.claude/skills/tool-setup/install.sh" subfinder httpx dnsx
```

If `RECON_INSTALL` is set in config to a team bootstrap repo, the installer clones
and runs it first, then fills any remaining gaps.

## Verify

```bash
bash "$BL4CKAI_HOME/.claude/skills/tool-setup/install.sh" --check core
```

It prints one line per program: `OK <path> (<version>)` or `MISSING`. Nothing is
"done" until the programs a task needs all show `OK`.

## Log

The installer appends what it installed, with versions and timestamp, to the active
engagement's `02_strategy.md` under a `## Tooling` note when `ENG` is exported, so
the environment behind a finding is recorded. Set `ENG` first if you want that:

```bash
export ENG="$ENGAGEMENTS_ROOT/A/aegean"
```

## Notes

- Prefers official sources: apt, PyPI via pipx, and Go modules. Do not add
  untrusted sources.
- Go programs install to `$HOME/go/bin` then copy to `/usr/local/bin` (needs sudo).
- If an install fails, the installer keeps going and reports the failure at the end
  rather than aborting the whole set.

## Example of good output — `--check core`

```
go          OK /usr/local/go/bin/go (go1.23.4)
subfinder   OK /usr/local/bin/subfinder (v2.6.6)
httpx       OK /usr/local/bin/httpx (v1.6.9)
dnsx        OK /usr/local/bin/dnsx (v1.2.1)
katana      OK /usr/local/bin/katana (v1.1.0)
gau         OK /usr/local/bin/gau (v2.2.4)
waybackurls OK /usr/local/bin/waybackurls
nuclei      OK /usr/local/bin/nuclei (v3.3.7)
ffuf        OK /usr/local/bin/ffuf (v2.1.0)
wafw00f     OK /home/op/.local/bin/wafw00f (2.2.0)
SUMMARY ok=10 missing=0
```

## Web interaction backends (not plain CLI installs)

Authenticated web testing uses one of two backends, chosen by `WEB_BACKEND`:

- **Burp Suite Pro** (`WEB_BACKEND=burp`): operator installs Burp + the "MCP Server"
  BApp; register it once with
  `claude mcp add --transport sse --scope user burpsuite "$BURP_MCP_URL"`.
  Connects when Burp is running. See the `burp-driver` skill.
- **Interceptor** (`WEB_BACKEND=interceptor`): run `install.sh interceptor` (clones,
  builds with Bun, registers its MCP, adopts skills). Operator loads the browser
  extension. See the `browser-interactor` skill.
