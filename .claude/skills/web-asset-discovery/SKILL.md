---
name: web-asset-discovery
description: First recon step: discover an organization's internet-facing hostnames from passive sources (certificate logs, passive datasets, ASN/IP ranges, acquisitions, wildcards) without sending traffic. Produces the host LIST. Not for probing live services (web-recon) or finding paths (web-content-discovery).
---

# Web asset discovery (passive)

The first half of recon, split out because it is its own job: find the hosts. It
leans on third-party data (certificate transparency, passive DNS), so it sends
little or nothing to the target itself. Output feeds `web-recon` (surface inventory)
and `web-content-discovery`.

```bash
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
ROOT=acme.com          # an in-scope apex; repeat per apex
```

## 1. Passive sources → `recon/subdomains.txt`

```bash
subfinder -d "$ROOT" -all -recursive -silent -o "$ENG/recon/subfinder.txt"
amass enum -passive -d "$ROOT" -o "$ENG/recon/amass.txt"
curl -s "https://crt.sh/?q=%25.$ROOT&output=json" | jq -r '.[].name_value' \
  | sed 's/\*\.//g' | sort -u > "$ENG/recon/crtsh.txt"
# hostnames seen in historical datasets (names only, passive)
echo "$ROOT" | waybackurls 2>/dev/null | awk -F/ '{print $3}' | sort -u > "$ENG/recon/wb_hosts.txt"
cat "$ENG/recon/"{subfinder,amass,crtsh,wb_hosts}.txt 2>/dev/null | sort -u > "$ENG/recon/subdomains.txt"
wc -l "$ENG/recon/subdomains.txt"
```

## 2. Widen the net

- **ASN / IP ranges**: find the org's ASN and announced CIDRs; record ranges the
  policy authorizes (reverse-DNS them for more names).
- **Acquisitions / alternate brands**: the policy or open sources may name sibling
  domains (as Olympic Air sits under Aegean). Add their apexes and repeat §1.
- **Wildcards**: note apexes that resolve `*` — mark them so the inventory step does
  not treat every random label as a real host.

## 3. Hand off (scope first)

Every newly discovered host is resolved through `scope-gate` before anything active
touches it. In-scope hosts go to `web-recon` for the live surface inventory;
out-of-scope ones are recorded and dropped. Tick the ledger's `Hosts enumerated`
box once `subdomains.txt` is real.

## Example of good output

```
recon/subdomains.txt: 412 unique names across acme.com + olympicair.com
ASN AS2611 → 3 CIDRs recorded (policy-authorized). Wildcard on *.cdn.acme.com noted.
```
