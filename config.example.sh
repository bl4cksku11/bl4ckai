# bl4ckai harness configuration — EXAMPLE.
# Copy to config.sh (which is gitignored) and edit for your machine:
#     cp config.example.sh config.sh
# Then set BL4CKAI_HOME once in your shell or your Claude Code project settings:
#     export BL4CKAI_HOME=/absolute/path/to/this/repo
# Every skill sources this file via "$BL4CKAI_HOME/config.sh". Nothing here is
# committed with real values, so no personal paths or handles land in the repo.

# --- Required ---------------------------------------------------------------
# Repo root. If you exported it in your shell, this keeps it; otherwise set it.
: "${BL4CKAI_HOME:=$HOME/bl4ckai}"
export BL4CKAI_HOME

# Where per-engagement output is written (A-Z/<target>/ underneath).
# Keep it OUTSIDE the repo if you don't want engagement data near the code.
export ENGAGEMENTS_ROOT="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}"

# --- Optional (leave empty if you don't have one) ---------------------------
# A personal reference library of notes (e.g. a PayloadsAllTheThings-style tree
# with a Web/<topic>/README.md layout). If empty, skills fall back to the method
# written in each skill plus public references. Never commit private notes here.
export KB_ROOT="${KB_ROOT:-}"

# A personal notes vault to mirror finished write-ups into. Empty = no mirror.
export VAULT_ROOT="${VAULT_ROOT:-}"

# Identity used in write-ups and self-duplicate checks. Empty = those steps skip.
export OPERATOR_HANDLE="${OPERATOR_HANDLE:-}"
# Space-separated profile URLs checked during self-dedup, e.g.
#   "https://hackerone.com/<handle> https://bugcrowd.com/h/<handle>"
export PLATFORM_PROFILES="${PLATFORM_PROFILES:-}"

# Optional: a recon-tool bootstrap repo your team maintains (clone+install URL).
# Empty = skills just check for tools and tell you to install any that are missing.
export RECON_INSTALL="${RECON_INSTALL:-}"

# --- Interceptor (model-driven signed-in browser + traffic inspection) -------
# The agent's Burp-equivalent: open pages in your logged-in browser, read/submit
# forms, inspect the page's own requests/responses, record PoCs. Set up where your
# authenticated browser lives (see the browser-interactor skill).
export INTERCEPTOR_BIN="${INTERCEPTOR_BIN:-}"               # path to the interceptor binary; empty = not installed
export INTERCEPTOR_MCP_ALLOW="${INTERCEPTOR_MCP_ALLOW:-}"   # empty = read+mutate only (safe). add destructive/raw to opt in
export INTERCEPTOR_MCP_FENCE="${INTERCEPTOR_MCP_FENCE:-on}" # wrap captured page/network content as untrusted data
export RESEARCH_HEADER="${RESEARCH_HEADER:-}"               # program header added to live traffic, e.g. "X-HackerOne-Research: <handle>"

# --- Web interaction backend (pick one; both are optional) -------------------
# How authenticated web interaction + live traffic inspection is driven:
#   burp        = Burp Suite Pro + its MCP server (see burp-driver skill)
#   interceptor = model-driven signed-in browser (see browser-interactor skill)
#   auto        = prefer burp if its MCP is reachable, else interceptor
export WEB_BACKEND="${WEB_BACKEND:-auto}"
export BURP_MCP_URL="${BURP_MCP_URL:-http://127.0.0.1:9876/sse}"   # Burp MCP server (BApp: "MCP Server")

# --- Pacing & scope (safety) -------------------------------------------------
export MAX_RPS="${MAX_RPS:-5}"        # cap requests/sec for active jobs; programs often set rate rules
export MAX_CONCURRENCY="${MAX_CONCURRENCY:-10}"
# Scope is captured per engagement in $ENG/scope.txt (patterns: plain=in-scope, '-'=out).
