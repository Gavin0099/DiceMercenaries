# DiceMercenaries PLAN

> **最後更新**: 2026-10-13
> **Owner**: Gavin0099
> **Freshness**: Sprint (7d)

## Current Phase
Governance onboarding candidate, followed by DM-00. Owner acceptance pending.

## Active Sprint
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
- GDScript is absent from framework language enum; no framework rule modified. Python describes tooling only.
- Windows runtime evidence pending until runner execution; Linux success is insufficient.
- No gameplay gate has passed.
