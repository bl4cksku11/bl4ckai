# Technique menu — canonical ledger labels + output files

`web-recon` seeds per-surface ledger lines from this table so each line's
wording matches exactly what the technique skill ticks. One line per technique,
per in-scope host, written into the host block of `00_ledger.md`:

```
- [ ] <label> → `.../checks/<host>/<file>`
```

| Skill | Ledger label | Output file |
|---|---|---|
| web-reflected-response | Immediate-response reflection check | checks/<host>/reflected_response.md |
| web-reflected-response | Immediate-response reflection check | checks/<host>/reflected_response.md |
| web-stored-response | Stored-and-rendered check | checks/<host>/stored_render.md |
| web-client-sink-trace | Client-side sink trace | checks/<host>/client_sink.md |
| web-markup-gadget-survey | Markup/script gadget survey | checks/<host>/gadget_survey.md |
| web-object-reference-walk | Object-reference access control walk | checks/<host>/object_reference.md |
| web-function-access-walk | Function-level access control walk | checks/<host>/function_access.md |
| web-server-fetch-probe | Server-initiated request probe | checks/<host>/server_fetch.md |
| web-template-eval-check | Server-side template evaluation check | checks/<host>/template_eval.md |
| web-db-query-influence | Database query influence check | checks/<host>/db_query.md |
| web-os-command-influence | OS command influence check | checks/<host>/os_command.md |
| web-path-resolution-check | Path resolution check | checks/<host>/path_resolution.md |
| web-xml-entity-check | XML entity processing check | checks/<host>/xml_entity.md |
| web-redirect-trust-check | Redirect destination trust check | checks/<host>/redirect_trust.md |
| web-request-boundary-check | Request boundary parsing check | checks/<host>/request_boundary.md |
| web-cross-origin-policy-check | Cross-origin sharing policy check | checks/<host>/cross_origin.md |
| web-token-handling-check | Session token handling check | checks/<host>/token_handling.md |
| web-auth-flow-check | Authentication flow walk | checks/<host>/auth_flow.md |
| web-logic-flow-walk | Business-logic and workflow walk | checks/<host>/logic_flow.md |
| web-upload-handling-check | File upload handling check | checks/<host>/upload_handling.md |
| web-cache-behavior-check | Cache behavior check | checks/<host>/cache_behavior.md |
