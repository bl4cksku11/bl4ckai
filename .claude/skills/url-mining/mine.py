#!/usr/bin/env python3
# Offline URL/endpoint miner. Reads already-collected recon (no new traffic):
# katana.txt + historical_urls.txt. Emits parameter names, API endpoints,
# interesting paths, and per-surface endpoint lists into the engagement recon dir.
import sys, os, re
from urllib.parse import urlsplit, parse_qsl

ENG = sys.argv[1]
RECON = os.path.join(ENG, "recon")
SRC = [os.path.join(RECON, f) for f in ("katana.txt", "historical_urls.txt")]
PRIORITY = ["ops360.aegeanair.com","ssp.aegeanair.com","servicedesk.aegeanair.com",
            "mytravel.aegeanair.com","transfers.aegeanair.com"]
INTERESTING = re.compile(r"(/api/|/v\d+/|/rest/|graphql|/admin|/internal|token|/auth|oauth|sso|"
                         r"saml|upload|redirect|/debug|/config|backup|/export|swagger|openapi|"
                         r"actuator|/soap|\.wsdl|\.json(\?|$)|\.xml(\?|$)|/user|/account|/booking|/pnr)", re.I)

urls=set()
for p in SRC:
    if not os.path.exists(p): continue
    with open(p, errors="ignore") as fh:
        for ln in fh:
            u=ln.strip()
            if u.startswith("http"): urls.add(u)
print(f"unique URLs mined: {len(urls)}")

params={}; api=set(); interesting=set(); per_host={h:set() for h in PRIORITY}
for u in urls:
    try: s=urlsplit(u)
    except Exception: continue
    host=s.netloc.split(":")[0]
    for k,_ in parse_qsl(s.query):
        params[k]=params.get(k,0)+1
    base=f"{s.scheme}://{s.netloc}{s.path}"
    if re.search(r"/api/|/v\d+/|/rest/|graphql", s.path, re.I): api.add(base)
    if INTERESTING.search(u): interesting.add(base)
    if host in per_host: per_host[host].add(base + (("?"+s.query) if s.query else ""))

def dump(name, lines):
    p=os.path.join(RECON,name)
    with open(p,"w") as f: f.write("\n".join(sorted(lines))+"\n")
    return len(lines)

np=dump("params.txt", [f"{v:>6}  {k}" for k,v in sorted(params.items(), key=lambda x:-x[1])])
na=dump("endpoints_api.txt", api)
ni=dump("interesting_paths.txt", interesting)
os.makedirs(os.path.join(ENG,"checks"), exist_ok=True)
host_counts={}
for h,eps in per_host.items():
    d=os.path.join(ENG,"checks",h); os.makedirs(d, exist_ok=True)
    host_counts[h]=dump(os.path.join("..","checks",h,"endpoints.txt") if False else f"../checks/{h}/endpoints.txt", eps) if False else len(eps)
    with open(os.path.join(d,"endpoints.txt"),"w") as f: f.write("\n".join(sorted(eps))+"\n")

# summary note
with open(os.path.join(RECON,"url_mining.md"),"w") as f:
    f.write("# URL/endpoint mining (offline, no new traffic)\n\n")
    f.write(f"- unique URLs: {len(urls)}\n- distinct parameters: {np}\n")
    f.write(f"- API endpoints: {na}\n- interesting paths: {ni}\n\n")
    f.write("## Top 25 parameters (name × count)\n```\n")
    for k,v in sorted(params.items(), key=lambda x:-x[1])[:25]: f.write(f"{v:>6}  {k}\n")
    f.write("```\n\n## Priority-surface endpoint counts\n")
    for h in PRIORITY: f.write(f"- {h}: {host_counts[h]} endpoints → checks/{h}/endpoints.txt\n")
print("params:",np,"api:",na,"interesting:",ni)
for h in PRIORITY: print(f"  {h}: {host_counts[h]} endpoints")
