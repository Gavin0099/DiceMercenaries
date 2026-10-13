# DiceMercenaries PLAN

> **最後更新**: 2026-10-13
> **Owner**: Gavin0099
> **Freshness**: Sprint (7d)

## Current Phase
DM-02 fixed-module destruction and repo-specific image/motion skills authorized by Owner. Governance remains partial; human gameplay acceptance pending.

## Active Sprint
- GOV-00: pinned submodule, baseline, repo instructions, installed local hooks, runtime smoke and reviewer evidence.
- DM-00: independent Godot 4.7.2 project, empty main scene, headless test entry, Windows CI.
- DM-01: fixed greybox battlefield, movement, manual ballistic aiming, swept projectile collision, bounded knockback/wall damage, Windows development playtest.
- DM-02: thin wall/platform/bridge break cases, shallow/deep fall outcomes, collision removal, repo character-art/combat-motion skills.
- DOC-01: candidate Godot source-verification knowledge base; DM-02 stacks on its Draft PR #4.
- Each slice has its own branch and Draft PR. No merge, deploy or release.

## Backlog
DM-03 onward follow docs/GAME_PLAN.md §12 and G1/G2/G3. No later slice is authorized by the current request.

## Decision Log
- Owner supplied v0.1 spec and authorized governance-first implementation on 2026-10-13.
- Existing repository is public and empty. Visibility unchanged.
- Earlier main initialization was rejected. Owner explicitly authorized README-only main initialization and two stacked Draft PRs on 2026-10-13; bootstrap commit 84db6639ce3e08783f10c94c1284021d74fe5683. No merge/release authorization.
- Proposed domain: offline single-player game; proposed risk: medium, escalate core rules/save integrity to L2. Not human-approved classification.
- Owner explicitly requested the next slice despite partial governance on 2026-10-13. This permits DM-01, not full-governance claims or merge/release.
- Scope conflict resolved for this candidate: GAME_PLAN §12 assigns terrain destruction to DM-02; keep DM-01 terrain fixed despite later illustrative examples.
- Owner requested DM-02 and adaptation of latest TacticalGo image/animation skills on 2026-10-13. This is continuation authorization, not human gameplay acceptance or permission to modify TacticalGo.

## Known Risks
- Governance completion cannot be self-declared; final authority is Owner/reviewer.
- GDScript is absent from framework language enum; no framework rule modified. Python describes tooling only.
- DM-00 Windows/Linux hosted native checks passed at c90de451 (run 38380875572); this does not prove DM-01 or human gameplay acceptance.
- No gameplay gate has passed.
