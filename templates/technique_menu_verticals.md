# Technique menu — non-web verticals

Canonical ledger labels + output files for the mobile/source/api/cloud/ai/contract/
hardware skills, so a seeded `00_ledger.md` line matches exactly what the skill ticks.
Each vertical works per **scope unit** (shown per group); the vertical's intake skill
or `strategy-refresh` seeds one block per in-scope unit into the ledger:

```
### <scope unit>
- [ ] <label> → `.../checks/<scope unit>/<file>`
```

## mobile  (scope unit: `<app>` — package / bundle id of the in-scope app)

| Skill | Ledger label | Output file |
|---|---|---|
| mobile-package-inspect | Mobile package inspection | checks/<app>/package_inspect.md |
| mobile-secret-scan | Mobile package secret scan | checks/<app>/secret_scan.md |
| mobile-traffic-inspect | Mobile traffic inspection | checks/<app>/traffic_inspect.md |
| mobile-storage-check | Mobile local-storage check | checks/<app>/storage_check.md |
| mobile-component-reach | Mobile component reachability | checks/<app>/component_reach.md |
| mobile-auth-token-check | Mobile session handling | checks/<app>/auth_token.md |

## source  (scope unit: `<repo>` — repo or module name under src/)

| Skill | Ledger label | Output file |
|---|---|---|
| source-intake | Source intake | checks/<repo>/intake.md |
| source-dependency-audit | Dependency audit | checks/<repo>/dependency_audit.md |
| source-input-trace | Input-to-sink trace | checks/<repo>/input_trace.md |
| source-auth-logic-review | Authorization logic review | checks/<repo>/auth_logic.md |
| source-secret-scan | Repository secret scan | checks/<repo>/secret_scan.md |
| source-crypto-review | Cryptography usage review | checks/<repo>/crypto_review.md |
| source-query-construction-review | Query construction review | checks/<repo>/query_construction.md |

## api  (scope unit: `<service>` — API host or service name)

| Skill | Ledger label | Output file |
|---|---|---|
| api-schema-map | API surface map | checks/<service>/schema_map.md |
| api-object-reference-walk | API object-reference walk | checks/<service>/object_reference.md |
| api-function-access-walk | API function-access walk | checks/<service>/function_access.md |
| api-auth-token-check | API token handling | checks/<service>/auth_token.md |
| api-mass-assignment-check | Mass-assignment check | checks/<service>/mass_assignment.md |
| api-input-validation-check | API input-validation check | checks/<service>/input_validation.md |

## cloud  (scope unit: `<asset>` — in-scope cloud account/project/asset label)

| Skill | Ledger label | Output file |
|---|---|---|
| cloud-storage-exposure | Cloud storage exposure | checks/<asset>/storage_exposure.md |
| cloud-subdomain-takeover | Dangling-DNS takeover check | checks/<asset>/subdomain_takeover.md |
| cloud-identity-review | Cloud identity review | checks/<asset>/identity_review.md |
| cloud-metadata-reach | Metadata reachability | checks/<asset>/metadata_reach.md |
| cloud-exposed-service | Exposed-service check | checks/<asset>/exposed_service.md |
| cloud-secret-scan | Cloud secret scan | checks/<asset>/secret_scan.md |

## ai  (scope unit: `<feature>` — the model-backed feature under test)

| Skill | Ledger label | Output file |
|---|---|---|
| ai-input-handling-check | Model input-handling check | checks/<feature>/input_handling.md |
| ai-output-trust-check | Model output-trust check | checks/<feature>/output_trust.md |
| ai-data-exposure-check | Model data-exposure check | checks/<feature>/data_exposure.md |
| ai-tool-access-check | Model tool-access check | checks/<feature>/tool_access.md |
| ai-resource-abuse-check | Model resource-abuse check | checks/<feature>/resource_abuse.md |

## contract  (scope unit: `<contract>` — contract name or address in scope)

| Skill | Ledger label | Output file |
|---|---|---|
| contract-intake | Contract intake | checks/<contract>/intake.md |
| contract-access-control-review | Contract access-control review | checks/<contract>/access_control.md |
| contract-arithmetic-review | Contract arithmetic review | checks/<contract>/arithmetic.md |
| contract-external-call-order-review | External-call ordering review | checks/<contract>/call_order.md |
| contract-oracle-review | Contract price-source review | checks/<contract>/oracle_review.md |
| contract-upgrade-review | Upgrade/proxy review | checks/<contract>/upgrade_review.md |

## hardware  (scope unit: `<device>` — device / firmware image label)

| Skill | Ledger label | Output file |
|---|---|---|
| hardware-firmware-extract | Firmware extraction | checks/<device>/firmware_extract.md |
| hardware-firmware-secret-scan | Firmware secret scan | checks/<device>/secret_scan.md |
| hardware-interface-survey | Debug-interface survey | checks/<device>/interface_survey.md |
| hardware-service-review | Device service review | checks/<device>/service_review.md |
| hardware-update-integrity-review | Update-integrity review | checks/<device>/update_integrity.md |

