#!/usr/bin/env bash
# bl4ckai tool installer. Mirrors the operator's base-agent patterns:
#   go install <pkg>@latest && sudo cp ~/go/bin/<bin> /usr/local/bin/
#   pipx install <tool>        (falls back to pip3 --break-system-packages)
#   sudo apt-get install -y <pkg>
# Usage:
#   install.sh core|web-full|review|fuzzing|all          install a set
#   install.sh <tool> [<tool> ...]                        install named tools
#   install.sh --check <set|tool ...>                     verify only, no install
# Honors $RECON_INSTALL (team bootstrap repo) and logs to $ENG/02_strategy.md.
set -uo pipefail

GOBIN_DIR="$HOME/go/bin"
DEST=/usr/local/bin
FAILED=(); INSTALLED=()

say(){ printf '  %s\n' "$*"; }
have(){ command -v "$1" >/dev/null 2>&1; }

# ---- go package + binary name map ------------------------------------------
go_pkg(){ case "$1" in
  subfinder)   echo github.com/projectdiscovery/subfinder/v2/cmd/subfinder;;
  httpx)       echo github.com/projectdiscovery/httpx/cmd/httpx;;
  dnsx)        echo github.com/projectdiscovery/dnsx/cmd/dnsx;;
  naabu)       echo github.com/projectdiscovery/naabu/v2/cmd/naabu;;
  katana)      echo github.com/projectdiscovery/katana/cmd/katana;;
  nuclei)      echo github.com/projectdiscovery/nuclei/v3/cmd/nuclei;;
  gau)         echo github.com/lc/gau/v2/cmd/gau;;
  waybackurls) echo github.com/tomnomnom/waybackurls;;
  assetfinder) echo github.com/tomnomnom/assetfinder;;
  qsreplace)   echo github.com/tomnomnom/qsreplace;;
  unfurl)      echo github.com/tomnomnom/unfurl;;
  gf)          echo github.com/tomnomnom/gf;;
  hakrawler)   echo github.com/hakluke/hakrawler;;
  dalfox)      echo github.com/hahwul/dalfox/v2;;
  gowitness)   echo github.com/sensepost/gowitness;;
  ffuf)        echo github.com/ffuf/ffuf/v2;;
  gitleaks)    echo github.com/gitleaks/gitleaks/v8;;
  osv-scanner) echo github.com/google/osv-scanner/cmd/osv-scanner;;
  govulncheck) echo golang.org/x/vuln/cmd/govulncheck;;
  gosec)       echo github.com/securego/gosec/v2/cmd/gosec;;
  staticcheck) echo honnef.co/go/tools/cmd/staticcheck;;
  *) echo "";; esac; }

apt_pkg(){ case "$1" in                    # tools best taken from apt
  amass) echo amass;; nmap) echo nmap;; whatweb) echo whatweb;;
  nikto) echo nikto;; sqlmap) echo sqlmap;; ripgrep|rg) echo ripgrep;;
  cloc) echo cloc;; jq) echo jq;; unzip) echo unzip;; *) echo "";; esac; }

pipx_pkg(){ case "$1" in                   # python tools
  wafw00f) echo wafw00f;; arjun) echo arjun;; semgrep) echo semgrep;;
  trufflehog) echo "";;  # trufflehog is go/binary, handled elsewhere
  *) echo "";; esac; }

# ---- sets ------------------------------------------------------------------
set_tools(){ case "$1" in
  core)     echo "go:subfinder go:httpx go:dnsx go:katana go:gau go:waybackurls go:nuclei go:ffuf pipx:wafw00f apt:nmap";;
  web-full) echo "$(set_tools core) go:naabu go:assetfinder go:qsreplace go:unfurl go:gf go:hakrawler go:dalfox go:gowitness pipx:arjun apt:whatweb apt:nikto apt:sqlmap";;
  review)   echo "pipx:semgrep go:gitleaks go:osv-scanner go:govulncheck go:gosec go:staticcheck apt:ripgrep apt:cloc";;
  fuzzing)  echo "apt:afl++ apt:honggfuzz apt:radare2";;
  all)      echo "$(set_tools web-full) $(set_tools review)";;
  *) echo "";; esac; }

# expand an arg (set name or bare tool) into "method:tool" specs
expand(){ local a="$1" s; s="$(set_tools "$a")"
  if [ -n "$s" ]; then echo "$s"; return; fi
  if [ -n "$(go_pkg "$a")" ]; then echo "go:$a";
  elif [ -n "$(apt_pkg "$a")" ]; then echo "apt:$a";
  elif [ -n "$(pipx_pkg "$a")" ]; then echo "pipx:$a";
  else echo "go:$a"; fi      # default guess: go
}

# ---- prerequisites ---------------------------------------------------------
ensure_base(){
  say "apt: base packages (git curl unzip jq build-essential python3-pip pipx libpcap-dev)"
  sudo apt-get update -qq || true
  sudo apt-get install -y -qq git curl wget unzip jq build-essential \
       python3-pip pipx ca-certificates libpcap-dev >/dev/null 2>&1 || true
  pipx ensurepath >/dev/null 2>&1 || true
}
ensure_go(){
  local need=0
  if ! have go; then need=1; else
    local v; v="$(go version | grep -oE 'go[0-9]+\.[0-9]+' | tr -d 'go')"
    awk -v v="$v" 'BEGIN{split(v,a,"."); if(a[1]<1||(a[1]==1&&a[2]<21)) exit 0; exit 1}' && need=1
  fi
  if [ "$need" = 1 ]; then
    say "go: installing a recent toolchain from go.dev (apt version absent/too old)"
    local GV=1.23.4 T=/tmp/go.tgz
    curl -fsSL "https://go.dev/dl/go${GV}.linux-amd64.tar.gz" -o "$T" \
      && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$T"
    export PATH="/usr/local/go/bin:$PATH"
    grep -q '/usr/local/go/bin' "$HOME/.profile" 2>/dev/null \
      || echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' >> "$HOME/.profile"
  fi
  export PATH="/usr/local/go/bin:$GOBIN_DIR:$PATH"
}

# ---- installers ------------------------------------------------------------
do_go(){ local t="$1" pkg; pkg="$(go_pkg "$t")"; [ -z "$pkg" ] && pkg="$t"
  say "go install $pkg@latest"
  if GOFLAGS=-buildvcs=false go install "${pkg}@latest" >/tmp/go_${t}.log 2>&1; then
    local bin="$GOBIN_DIR/$(basename "$pkg")"
    [ "$(basename "$pkg")" = "$t" ] || bin="$GOBIN_DIR/$t"
    [ -f "$GOBIN_DIR/$t" ] && bin="$GOBIN_DIR/$t"
    sudo cp "$bin" "$DEST/" 2>/dev/null && INSTALLED+=("$t") || { FAILED+=("$t(cp)"); }
  else FAILED+=("$t(build)"); say "   build failed — see /tmp/go_${t}.log"; fi
}
do_apt(){ local t="$1" p; p="$(apt_pkg "$t")"; [ -z "$p" ] && p="$t"
  say "apt-get install -y $p"
  if sudo apt-get install -y -qq "$p" >/tmp/apt_${t}.log 2>&1; then INSTALLED+=("$t"); else FAILED+=("$t(apt)"); fi
}
do_pipx(){ local t="$1" p; p="$(pipx_pkg "$t")"; [ -z "$p" ] && p="$t"
  say "pipx install $p"
  if pipx install "$p" >/tmp/pipx_${t}.log 2>&1; then INSTALLED+=("$t")
  elif pip3 install --break-system-packages -q "$p" >>/tmp/pipx_${t}.log 2>&1; then INSTALLED+=("$t")
  else FAILED+=("$t(pipx)"); fi
}
do_interceptor(){                 # signed-in browser + traffic layer (see browser-interactor skill)
  local H="$HOME/tools/Interceptor" log=/tmp/interceptor_build.log
  say "interceptor: clone + build + register MCP (browser extension is an operator step)"
  command -v bun >/dev/null 2>&1 || { say "  installing bun"; curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1; export PATH="$HOME/.bun/bin:$PATH"; }
  [ -d "$H/.git" ] || git clone --depth 1 https://github.com/Hacker-Valley-Media/Interceptor "$H" >>"$log" 2>&1
  if ( cd "$H" && bun install --frozen-lockfile && bun run build ) >>"$log" 2>&1; then
    local BIN="$H/dist/interceptor"
    "$BIN" skills adopt --into claude >>"$log" 2>&1 || true
    command -v claude >/dev/null 2>&1 && { claude mcp add --scope user interceptor -- "$BIN" mcp serve >>"$log" 2>&1 || "$BIN" mcp install >>"$log" 2>&1 || true; }
    INSTALLED+=("interceptor")
    say "  built: $BIN — add INTERCEPTOR_BIN=$BIN to config.sh"
    say "  OPERATOR: load the browser extension where your signed-in browser is, then 'interceptor status'"
  else FAILED+=("interceptor(build)"); say "  build failed — see $log"; fi
}

# ---- check -----------------------------------------------------------------
check(){ local ok=0 miss=0 t
  for spec in "$@"; do t="${spec#*:}"
    if have "$t"; then printf "  %-12s OK %s\n" "$t" "$(command -v "$t")"; ok=$((ok+1))
    else printf "  %-12s MISSING\n" "$t"; miss=$((miss+1)); fi
  done
  echo "SUMMARY ok=$ok missing=$miss"
}

# ---- main ------------------------------------------------------------------
[ $# -eq 0 ] && { echo "usage: install.sh core|web-full|review|fuzzing|all | <tool...> | --check <...>"; exit 2; }

MODE=install; [ "$1" = "--check" ] && { MODE=check; shift; }

# expand args to specs (interceptor is special: clone+build+register, not a pkg)
SPECS=(); WANT_INTERCEPTOR=0
for a in "$@"; do
  [ "$a" = interceptor ] && { WANT_INTERCEPTOR=1; continue; }
  for s in $(expand "$a"); do SPECS+=("$s"); done
done
# de-dup (guard empty under set -u)
[ ${#SPECS[@]} -gt 0 ] && readarray -t SPECS < <(printf '%s\n' "${SPECS[@]}" | awk '!seen[$0]++')

if [ "$MODE" = check ]; then
  [ ${#SPECS[@]} -gt 0 ] && check "${SPECS[@]}"
  [ "$WANT_INTERCEPTOR" = 1 ] && { b="${INTERCEPTOR_BIN:-$HOME/tools/Interceptor/dist/interceptor}"; [ -x "$b" ] && printf "  %-12s OK %s\n" interceptor "$b" || printf "  %-12s MISSING\n" interceptor; }
  exit 0
fi

echo "== bl4ckai tool-setup : installing ${#SPECS[@]} programs${WANT_INTERCEPTOR:+ + interceptor} =="
# optional team bootstrap
if [ -n "${RECON_INSTALL:-}" ]; then
  say "RECON_INSTALL set → clone + run team bootstrap"
  git clone --depth 1 "$RECON_INSTALL" "$HOME/recontools" 2>/dev/null || true
  [ -f "$HOME/recontools/install.sh" ] && sudo bash "$HOME/recontools/install.sh" || true
fi
ensure_base
if [ ${#SPECS[@]} -gt 0 ] && printf '%s\n' "${SPECS[@]}" | grep -q '^go:'; then ensure_go; fi

for spec in ${SPECS[@]+"${SPECS[@]}"}; do
  case "$spec" in
    go:*)   have "${spec#go:}"   || do_go   "${spec#go:}";;
    apt:*)  have "${spec#apt:}"  || do_apt  "${spec#apt:}";;
    pipx:*) have "${spec#pipx:}" || do_pipx "${spec#pipx:}";;
  esac
done
[ "$WANT_INTERCEPTOR" = 1 ] && do_interceptor

echo "== installed: ${INSTALLED[*]:-none} =="
[ ${#FAILED[@]} -gt 0 ] && echo "== FAILED: ${FAILED[*]} =="

# log to engagement strategy note if ENG is set
if [ -n "${ENG:-}" ] && [ -d "$ENG" ]; then
  { echo; echo "## Tooling ($(date +%F\ %T))";
    echo "Installed: ${INSTALLED[*]:-none}"; [ ${#FAILED[@]} -gt 0 ] && echo "Failed: ${FAILED[*]}";
  } >> "$ENG/02_strategy.md"
fi
exit 0
