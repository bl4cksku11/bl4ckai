---
program: {{PROGRAM}}
platform: hackerone | bugcrowd
type: vdp | bbp
severity: critical | high | medium | low
class: {{plain-name}}
endpoint: {{affected URL}}
status: draft | submitted | triaged | accepted | rejected | duplicate
date_found: {{DATE}}
tags: [bugbounty, {{PROGRAM}}, {{class}}]
---

# {{Finding title}}

## Summary
Two to three sentences: what, where, and the concrete effect.

## Steps to Reproduce
1. ...
2. ...

## Proof of Concept
Minimal, exact reproduction. Request/response pair or the smallest script.

## Impact
Concrete business impact, not a generic class description.

## Severity
{Critical | High | Medium | Low} — CVSS 3.1: {vector}

## Remediation
Specific and actionable.

## Chain potential
Does this combine with another finding? Link it: [[other-finding]]

## References
CWE, OWASP, related prior disclosures.
