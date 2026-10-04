#!/usr/bin/env python3
# Paste-and-go engagement intake. Give it the WHOLE program dump (policy text +
# scope table) and it fills the mechanical parts automatically:
#   - scope.txt        (in-scope apex wildcards + apex, from the hostnames found)
#   - recon/subdomains.txt  (every explicit host found → seeds recon)
#   - 00_program_dump.txt   (the raw paste, kept as the source of truth)
#   - 00_program_brief.md   (scaffold: header + embedded policy + rule hints to confirm)
#   - 00_ledger.md, _queue.json  (from templates)
# Prose rules (header to send, rate rule, exclusions) are HINTED but the operator/
# agent confirms them — regex must not invent an authorization boundary.
#
# Usage:  python3 intake.py <slug> <dumpfile> [--program "Name"] [--platform hackerone] [--type vdp|bbp]
import os, re, sys, argparse

ap = argparse.ArgumentParser()
ap.add_argument("slug"); ap.add_argument("dumpfile")
ap.add_argument("--program", default=""); ap.add_argument("--platform", default="hackerone")
ap.add_argument("--type", default="vdp", choices=["vdp","bbp"])
a = ap.parse_args()

HOME = os.environ.get("BL4CKAI_HOME") or sys.exit("export BL4CKAI_HOME first")
EROOT = os.environ.get("ENGAGEMENTS_ROOT") or os.path.join(HOME, "engagements")
slug = a.slug.lower(); letter = slug[0].upper()
ENG = os.path.join(EROOT, letter, slug)
for d in ("recon","checks","reports","evidence"): os.makedirs(os.path.join(ENG,d), exist_ok=True)

dump = open(a.dumpfile, errors="ignore").read()
open(os.path.join(ENG,"00_program_dump.txt"),"w").write(dump)

# --- hostnames ---
# platform / infra / common domains that appear in policies but are NOT the target
DENY = {"hackerone.com","bugcrowd.com","github.com","githubusercontent.com","gitlab.com",
        "example.com","example.net","example.org","google.com","gmail.com","beehiiv.com",
        "docs.hackerone.com","chromewebstore.google.com","mozilla.org","w3.org","portswigger.net"}
MULTI_TLD = ("co.uk","com.au","co.jp","com.br","co.nz","org.uk","ac.uk","com.mx","co.in")
host_rx = re.compile(r"\b((?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,})\b", re.I)

def apex(h):
    p = h.split(".")
    for m in MULTI_TLD:
        if h.endswith("."+m): return ".".join(p[-3:])
    return ".".join(p[-2:])

hosts=set()
for m in host_rx.finditer(dump):
    h=m.group(1).lower().lstrip(".")
    if h.startswith("*."): h=h[2:]
    if "." not in h: continue
    if apex(h) in DENY or h in DENY: continue
    if re.search(r"\.(png|jpg|svg|css|js|md|json|pdf)$", h): continue
    hosts.add(h)

apexes = sorted({apex(h) for h in hosts})
scope_lines = ["# in-scope — auto-derived from the dump; REVIEW before use.",
               "# plain = in-scope, leading '-' = out-of-scope (deny wins). Add exclusions below."]
for ax in apexes: scope_lines += [f"*.{ax}", ax]
open(os.path.join(ENG,"scope.txt"),"w").write("\n".join(scope_lines)+"\n")
open(os.path.join(ENG,"recon","subdomains.txt"),"w").write("\n".join(sorted(hosts))+"\n")

# --- brief scaffold with rule hints (confirm, don't trust) ---
def hint(pats):
    out=[]
    for ln in dump.splitlines():
        s=ln.strip()
        if s and any(re.search(p, s, re.I) for p in pats) and len(s)<200: out.append("  - "+s)
    return "\n".join(dict.fromkeys(out)) or "  (none auto-detected — read the dump)"
brief=f"""# {a.program or slug} — brief
Platform: {a.platform}   Type: {a.type}
Hosts found: {len(hosts)} across {len(apexes)} apex domain(s). Scope: see scope.txt.

## Required header / identity (CONFIRM — set RESEARCH_HEADER to match)
{hint([r'header', r'X-[A-Za-z-]+-Research', r'alias', r'research'])}

## Rate / pacing rules (CONFIRM — set MAX_RPS accordingly)
{hint([r'rate', r'requests per', r'throttl', r'automat'])}

## Prohibited / hard rules (CONFIRM against the dump)
{hint([r'do not', r'prohibit', r'not permitted', r'strictly', r'must not', r'no DoS', r'denial of service', r'social engineering'])}

## Excluded / out-of-scope classes (CONFIRM — add '-' lines to scope.txt)
{hint([r'out of scope', r'exclud', r'informational', r'not applicable'])}

## Full policy (pasted — source of truth)
See `00_program_dump.txt`. The hints above are extracted lines, not a substitute for reading it.
"""
open(os.path.join(ENG,"00_program_brief.md"),"w").write(brief)

# --- ledger + queue from templates ---
import datetime
tpl=lambda n: open(os.path.join(HOME,"templates",n)).read()
led=tpl("ledger.template.md")
for k,v in {"{{TARGET}}":slug,"{{PROGRAM}}":a.program or slug,"{{PLATFORM}}":a.platform,
            "{{bbp|vdp}}":a.type,"{{A-Z}}":letter,"{{DATE}}":datetime.date.today().isoformat()}.items():
    led=led.replace(k,v)
open(os.path.join(ENG,"00_ledger.md"),"w").write(led)
q=tpl("queue.template.json").replace("{{TARGET}}",slug).replace("{{PROGRAM}}",a.program or slug)
open(os.path.join(ENG,"_queue.json"),"w").write(q)

print(f"engagement: {ENG}")
print(f"  hosts: {len(hosts)} → recon/subdomains.txt   apexes: {len(apexes)} → scope.txt")
print(f"  brief + dump + ledger + queue written")
print("NEXT (human-in-the-loop):")
print("  1. REVIEW scope.txt — confirm the apexes, add any '-' exclusions from the dump.")
print("  2. Confirm the brief's header/rate/prohibited hints against 00_program_dump.txt;")
print("     set RESEARCH_HEADER + MAX_RPS in config.sh to match.")
