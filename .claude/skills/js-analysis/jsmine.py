#!/usr/bin/env python3
# Extract endpoints and likely secrets from already-fetched JavaScript files.
# Usage: jsmine.py <out_dir> <file.js> [file.js ...]
# Writes <out_dir>/js_endpoints_parsed.txt and <out_dir>/js_secrets.txt
import sys, os, re

out_dir = sys.argv[1]; files = sys.argv[2:]
os.makedirs(out_dir, exist_ok=True)

# endpoint-ish strings inside quotes: absolute URLs, rooted paths, api routes
EP = re.compile(r"""["'`]((?:https?:)?//[\w.-]+(?:/[\w./?=&%:+~-]*)?|/[\w./?=&%:+~-]{2,}|(?:/?api|/?v\d|/?rest|/?graphql)[\w./?=&%:+~-]*)["'`]""")
# likely secrets (name, pattern)
SECRETS = [
 ("aws_access_key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
 ("google_api_key", re.compile(r"\bAIza[0-9A-Za-z_\-]{35}\b")),
 ("slack_token",    re.compile(r"\bxox[baprs]-[0-9A-Za-z-]{10,}\b")),
 ("stripe_live",    re.compile(r"\bsk_live_[0-9A-Za-z]{10,}\b")),
 ("github_token",   re.compile(r"\bgh[pousr]_[0-9A-Za-z]{30,}\b")),
 ("private_key",    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----")),
 ("jwt",            re.compile(r"\beyJ[\w-]{10,}\.[\w-]{10,}\.[\w-]{10,}\b")),
 ("generic_secret", re.compile(r"""(?i)\b(api[_-]?key|secret|token|passwd|password|authorization|bearer)\b["'`]?\s*[:=]\s*["'`]([^"'`\s]{8,})["'`]""")),
 ("firebase",       re.compile(r"\b[\w-]+\.firebaseio\.com\b")),
]

endpoints=set(); secrets=[]
for f in files:
    try: txt=open(f, errors="ignore").read()
    except Exception: continue
    base=os.path.basename(f)
    for m in EP.finditer(txt):
        e=m.group(1)
        if len(e)>3 and not e.endswith((".png",".jpg",".svg",".css",".woff",".gif",".ico")):
            endpoints.add(e)
    for name,rx in SECRETS:
        for m in rx.finditer(txt):
            val=m.group(0)[:80]
            secrets.append((name, base, val))

with open(os.path.join(out_dir,"js_endpoints_parsed.txt"),"w") as fo:
    fo.write("\n".join(sorted(endpoints))+"\n")
with open(os.path.join(out_dir,"js_secrets.txt"),"w") as fo:
    seen=set()
    for name,base,val in secrets:
        k=(name,val)
        if k in seen: continue
        seen.add(k); fo.write(f"{name}\t{base}\t{val}\n")
print(f"endpoints: {len(endpoints)}  secret-candidates: {len(set((n,v) for n,_,v in secrets))}")
