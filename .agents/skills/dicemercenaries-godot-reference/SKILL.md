---
name: dicemercenaries-godot-reference
description: Research and validate Godot 4.7.2 APIs, GDQuest/KidsCanCode examples, and community fixes for DiceMercenaries slices before using them. Evidence-first; use for combat terrain, D20, animation, map, assets or native CI research.
---

# Godot 4.7.2 Reference Skill (candidate)

This is a **research/verification skill**, not an AI Governance adoption certificate, gameplay approval, or permission to expand scope.

Read [docs/GODOT_TECH_REFERENCE.md](../../../docs/GODOT_TECH_REFERENCE.md) first. The authoritative gameplay contracts remain docs/GAME_PLAN.md, docs/DECISIONS.md and PLAN.md.

Use [the resource hub](../../../docs/GODOT_RESOURCES.md) to select official APIs and learning material for the current slice, [troubleshooting](../../../docs/godot/TROUBLESHOOTING.md) for failure paths, and [the research template](../../../docs/godot/RESEARCH_TEMPLATE.md) to retain adoption evidence. Priorities are canonical in PLAN.md; docs/DEVELOPMENT_PRIORITIES.md explains the ordering. A resource or priority entry does not authorize a new gameplay slice.

## Procedure

1. Identify the specific authorized DM-XX slice, blocker, owned layer and existing tests. Do not introduce game features based solely on tutorials.
2. Confirm the exact Godot 4.7.2 API in official stable docs/Class Reference; check any differences between example engine versions and pinned engine. Do not copy 3.x or older 4.x examples without validation.
3. Consult GDQuest for architecture/teaching, KidsCanCode 4.x recipes for minimal examples; inspect source revision and **code vs art/audio licenses separately**. Discord and Forums are hypotheses only until reproduced.
4. Propose the smallest adapter: pure Domain owns decisions; Combat integrates physics; Presentation owns animation/UI; Infrastructure owns logging/seeds/tests. Godot physics is not bit-exact deterministic.
5. Establish at least one negative test and run Windows/Linux native checks in Godot 4.7.2; capture engine version, repo SHA, test result and screenshots/recording where necessary.
6. Report with precise status: researched, candidate, validated, or rejected. Keep human playtest, Owner gates and actual governance compliance distinct.
7. If blocked, ask a Godot community question using a minimal sanitized .tscn/.gd repro, expected/actual behavior, OS, exact engine version, logs and documentation checked. Re-verify any response locally.

## Targeted heuristics

- DM-02: prefer small destructible StaticBody2D modules; CollisionShape2D.set_deferred("disabled", true) and a next-physics-step check; no infinite recursive damage or unrestricted geometry cutting.
- DM-03: separate run_seed and RNG streams for map, rewards, D20 and enemy choices; raw_roll/effective_roll/natural20 separate; never derive natural 20 from modifiers.
- DM-04/05: AnimationPlayer first; AnimationTree only when transition complexity justifies it; animation completion is never the sole authority for gameplay events.
- Roguelite: test valid connected DAG route templates before introducing procedural generation frameworks; keep mutable run state out of shared Resource definitions.
- Visuals: TacticalGo's character-style skill supplies provenance and QA methodology, **not** transferable identities, tabletop board views, approvals, or finished side-view animations.
- Commercial assets: GDQuest starter Roguelite identifies code MIT but game art CC BY-NC-SA; do not import noncommercial assets into Steam deliverables.

## Required research record

Source URL/date; upstream version/commit; specific API; target DM-XX; program and asset licenses; 4.7.2 compatibility check; project commit and native evidence; failures; remaining questions; adoption status.

## Hard boundaries

No automatic merge, release, production asset imports, governance framework modifications, Owner approval claims or unrelated repo writes. GitHub API writes bypass local Git hooks and do not count as full governance evidence. All behavior changes require a separately authorized slice.
