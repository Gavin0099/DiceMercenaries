# DiceMercenaries PLAN

> **最後更新**: 2026-10-14
> **Owner**: Gavin0099
> **Freshness**: Sprint (7d)

## Current Phase
Governance onboarding candidate, followed by DM-00. Owner acceptance pending.

## Active Sprint
- S3 delivery: Draft PR #8 stacks on DM-00. Framework pin 2a09d542, explicit
  native validator and pre/post-task acceptance; Windows interface tests and
  four native failure replays passed locally. Author review found no blocking
  finding; independent review and Owner acceptance pending.
- S4 CI: implementation 6cfd76d9 updates only two workflows, covering all
  PR bases with Windows/Linux native acceptance and current-diff memory checks.
  Local workflow/drift/memory checks passed; hosted latest-head checks pending.
  Separate stacked Draft authorized. No consumer merge.
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
- S3 native evidence is local. S4 hosted Windows/Linux and memory checks remain
  a separate delivery gate; green checks do not establish branch protection.
- No gameplay gate has passed.
