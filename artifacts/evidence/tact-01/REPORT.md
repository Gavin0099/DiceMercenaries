# TACT-01 candidate evidence

2026-10-13, Windows, official Godot 4.7.2.stable.official.ed1daf0bf.

Scope: warrior movement/skills, locked enemy sweeps, actual bridge/wall collisions, fixed roll comparison; resource consolidation and priority planning from preceding authorized task are included. No full random D20/fate, maps/saves, merge/release or human acceptance.

Local native-check.json retains tested pre-commit HEAD, dirty file inventory and game/test source hashes. It must not be read as proof that unchanged HEAD alone contains the candidate. Results: 81 DM-01/02 regression assertions, 30 tactical rule assertions, 28 tactical scene assertions; import/startup successful.

capture-log.txt is native Windows scripted replay at 1280x720/60fps, not human input. Ready, shield preview/contact, response, bridge before/after and reduced-motion screenshots retained. Same bridge inputs in normal/reduced mode produced equal HP/module/turn outcomes. Native AVI is local under build/tact01.avi and will also be a CI artifact; not committed due size.

windows-package.json records a freshly extracted development package import/startup. The package is official editor engine in game mode, not release export. Local distribution: build/DiceMercenaries_TACT01_Windows.zip. CI and final package/source provenance are recorded separately after submission; local success is not Linux success.

Independent read-only review by /root/review_tactical: no unresolved P0/P1. Deferred findings:
- P2, tactical_lab.gd: victory can briefly appear then become defeat if the final enemy dies while the warrior is still falling. Final-fall settlement should be a follow-up regression/fix. This slice does not claim final terminal-message polish.
- P3, DEVELOPMENT_PRIORITIES.md: the detailed P1 row still describes full DM-03, whereas PLAN and the document update place TACT-01 first. PLAN is canonical; table cleanup deferred.
- Additional scene regression for wall obstruction and high-roll guard/shockwave recommended, not a P0/P1 blocker.

Human validation: NOT RUN. G1/G2/G3: unaccepted. Full AI Governance: partial. GDScript routing remains unresolved; copying resources or running native CI does not complete governance enforcement. The source checker still uses ambient Git/Python process resolution; no executable-trust hardening claimed.
