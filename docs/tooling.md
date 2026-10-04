# Tooling

The harness assumes a standard recon/testing toolset on `PATH`. Skills check for
what they need and tell you to install anything missing — they do not pin you to a
specific installer. If your team maintains a bootstrap repo, set `RECON_INSTALL` in
`config.sh` to its clone+install URL and run it once.

## Check what's present

```bash
which subfinder amass dnsx httpx nuclei katana ffuf gau waybackurls \
      wafw00f gowitness jq curl go python3 2>/dev/null
```

## Install what's missing

- Go tools: `GOPATH=$HOME/go go install <package>@latest && sudo cp ~/go/bin/<tool> /usr/local/bin/`
- Python tools: `pipx install <tool>` (or `pip3 install --break-system-packages <tool>`)
- Apt tools: `sudo apt-get install -y <tool>`

## Suite by purpose (install on demand, not all up front)

- **Host/asset discovery:** `subfinder`, `amass`, `dnsx`, `puredns`, `massdns`, `chaos-client`, `github-subdomains`
- **Live + fingerprint:** `httpx`, `wafw00f`, `gowitness`
- **Content/endpoint discovery:** `katana`, `gau`, `waybackurls`, `feroxbuster`, `dirsearch`, `ffuf`, `arjun`, `paramspider`, `gf`, `unfurl`, `qsreplace`
- **Script analysis:** `linkfinder`, `getjs`, `subjs`
- **Per-technique helpers** (install when the surface appears): consult the skill
  for the technique; it names what it needs.
- **Mobile (when in scope):** `apktool`, `jadx`, `frida`, `objection`

## Hygiene

- Prefer official repos, PyPI, Go modules, apt. Don't install from untrusted sources.
- Log installs in the engagement's `02_strategy.md` under a "Tooling" note so a run
  is reproducible.
