# DiceMercenaries PLAN

> **最後更新**: 2026-10-14
> **Owner**: Gavin0099
> **Freshness**: Sprint (7d)

## Current Phase
DM-00 skeleton engineering acceptance completed. DM-01-I1 integrates the existing physics lab candidate onto main a1068a8; Draft delivery and CI verification in progress. Governance remains partial; full play acceptance is not claimed.

## Active Sprint
- DM-01-I1: preserve game bytes from PR #3 head 92f4f418; retain main framework
  pin 2a09d542 and governance workflow; adapt native validation/failure fixtures
  for DM-01 and preserve DM-00 acceptance. Direct automatic checks and CI only.
  Owner explicitly skipped remaining DM-01-R1 GUI testing. No merge/release.
- S3/S4 were integrated with GOV-00 and DM-00 into main a1068a8. The current
  integration preserves that framework pin, native gate and memory CI. Earlier
  delivery records remain historical evidence, not current pending work.
- GOV-00: pinned submodule, baseline, repo instructions, installed local hooks, runtime smoke and reviewer evidence.
- DM-00: independent Godot 4.7.2 project, empty main scene, headless test entry, Windows CI.
- Each slice has its own branch and Draft PR. No merge, deploy or release.

## Backlog
DM-01 onward follow docs/GAME_PLAN.md §12 and G1/G2/G3. Do not start until preceding slice is accepted.

## Decision Log
- Owner supplied v0.1 spec and authorized governance-first implementation on 2026-10-13.
- Existing repository is public and empty. Visibility unchanged.
- Earlier main initialization was rejected. Owner explicitly authorized README-only main initialization and two stacked Draft PRs on 2026-10-13; bootstrap commit 84db6639ce3e08783f10c94c1284021d74fe5683. No merge/release authorization.
- Proposed domain: offline single-player game; proposed risk: medium, escalate core rules/save integrity to L2. Not human-approved classification.

## Known Risks
- Governance completion cannot be self-declared; final authority is Owner/reviewer.
- GDScript is available from the adopted framework checkout. The historical F-7 apply reported partial
  adoption; committing the pin alone does not prove complete adoption.
- Each new candidate must have its own Windows/Linux and memory CI evidence;
  green checks do not establish branch protection or human gameplay acceptance.
- No gameplay gate has passed.
