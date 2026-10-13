# AI Governance adoption audit — 2026-10-13

## Decision
Partial adoption. Safe to submit as a Draft candidate; not qualified for full-adoption or gameplay acceptance.
Owner authorization in this turn covers the README-only main bootstrap and two stacked Draft PRs. It does not approve merge/release, domain classification, or gameplay Gates.

## Observed coverage
- Pinned submodule: b74bbde22727391dadfdc017cb1bad9c20169ad6; framework lock matches checkout. Local tracking comparison is not remote freshness proof.
- Repo instructions, baseline, domain contract, plan and memory files exist.
- Installed local pre-commit/pre-push hooks validate. Installation is per checkout. API writes do not invoke local Git hooks.
- Readiness passes with zero validators: readiness does not imply domain or gameplay coverage.
- Fresh maturity assessment: partial; validator_surface=false; runtime_capable=not_checked; memory_workflow_surface=not_checked.
- Prior memory workflow authority guard passes; this only means the inspected workflow has no blocking authority finding.
- Runtime smoke ok=true, pre_task_ok=true, session_start_ok=true, post_task_ok=null, post_task_cases=[].
- Smoke warnings: assumption-check evidence missing; no token telemetry. No end-to-end task enforcement claim.
- No independent review or Owner acceptance exists.
- GDScript is absent from canonical language enumeration. Python only describes tooling; it cannot cover GDScript gameplay.
- Proposed domain/risk classification remains unapproved.
- CI governance-drift checks file drift only, uses main base/path filters, and does not enforce runtime, memory guard, or game validators. A stacked DM-00 PR targeting governance branch is outside that governance workflow filter.
- No branch protection/required-check enforcement was configured or verified.
- DM-00 Linux checks cover empty scene import/startup only. Windows is pending hosted evidence. No G1/G2/G3 evidence.

## Findings and decision impact
1. BLOCKING full adoption: validators empty and GDScript routing unresolved. Exposed; blocks full adoption/gameplay governance qualification, does not block Draft submission.
2. WARNING runtime coverage: smoke omits post-task and platform lifecycle execution is unproven. Carried forward with explicit claim ceiling.
3. WARNING enforcement: local hooks and drift-only CI cannot establish non-bypassable delivery checks; stacked PR filter gap observed. Carry forward until runtime/memory/validator integration and hosted checks are reviewed.
4. WARNING authority: domain/risk proposal and acceptance not approved. Owner authorization to deliver is not an attestation to these classifications.

## Smallest next implementation
Before DM-01: decide supported GDScript routing through framework's existing extension process; bind the native project checker as an actual validator with missing-engine and bad-scene negative cases; cover the relevant PR bases and run existing runtime/memory checks in CI. Verify on Windows, then seek review of the exact candidate. Do not expand the framework with speculative rules.

## Delivery provenance
Remote candidates are snapshot commits with the authorized README bootstrap ancestry. Prior local implementation and evidence commits remain historical references: governance f88756e; DM-00 6d6b4e0. Historical evidence is not relabeled as remote-head evidence.
No gameplay code, merge, deployment or publication in this delivery.

## Hosted evidence and correction
Governance PR #1 drift run 38380413033 passed. DM-00 PR #2 run 38380577054: Ubuntu native checks passed; Windows failed during governance submodule checkout with Filename too long, before engine execution. Historical JSON evidence was uploaded by the old wildcard artifact path even on Windows checkout failure; this is not Windows evidence.
Correction in DM-00: configure core.longpaths before Windows checkout; write native result to RUNNER_TEMP and upload only that exact file. Verification is the same hosted checkout/native matrix; no gameplay or governance-policy change. Local current-remote-head native check b80a178 passed; memory authority and drift checks also passed. Windows correction not verified until next hosted run.
