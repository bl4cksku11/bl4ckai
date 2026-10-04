---
name: job-runner
description: Run a long step in the background with its status kept in a file the operator can read at any time — whether it is still working, finished, failed, or has gone quiet — so there is never a blind wait. Use it for installs, scans, crawls, and fuzzing.
---

# Job runner

Any step that takes more than a few seconds runs through this, so the operator
always has an answer to "is it still going, is it stuck, or is it done?" without
the agent having to narrate it. Status lives in files under the engagement folder;
read them whenever you want.

Never block the session on a process you cannot see, and never track a job by
matching a process name (the pattern matches the watcher itself and hangs forever —
this runner tracks a PID file plus the output log's last-write time instead).

## Set up paths

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"      # required
JOB="$BL4CKAI_HOME/.claude/skills/job-runner/job.sh"
```

## Start a job (returns immediately)

```bash
bash "$JOB" run <slug> "<human label>" "<the full shell command>"
```

## Check status — the whole point

```bash
bash "$JOB" status            # one line per job
bash "$JOB" status <slug>     # detail: label, cmd, log path
```

Each job reports one of:
- `RUNNING 2m10s` — alive and producing output.
- `RUNNING 9m00s  ⚠ no output for 3m00s — may be stalled` — alive but quiet past
  the `STALL` threshold (default 120s). This is the signal to investigate.
- `CRASHED (pid gone, no exit recorded)` — the process died without finishing.
- `DONE in 2m40s (exit 0)` / `FAILED in 0m08s (exit 1)` — finished, with code.

Report the status line to the operator verbatim when they ask, and proactively
after starting a job and when it ends. "Still running, 4m, last line: …" is a
real answer; silence is not.

## Follow or block

```bash
bash "$JOB" watch <slug>      # tail -f the output (for the operator)
bash "$JOB" wait  <slug>      # block until it ends (only inside a script)
```

## After it ends

Read the exit code and the tail of `"$ENG/.jobs/<slug>/output.log"`. On a non-zero
exit, surface the failing lines — do not tick the step's ledger box. A job that
`CRASHED` or `FAILED` means the step did not complete; re-run it.

## Example of good output — `status`

```
install-core       DONE in 2m41s (exit 0)
    last: == installed: subfinder httpx dnsx katana gau waybackurls nuclei ffuf wafw00f nmap ==
recon-httpx        RUNNING 1m05s
    last: https://www.aegeanair.com [200] [Aegean Airlines] [cloudflare]
```
