# DM-01 candidate review

Source implementation: 714cc6d00c7ba89319b7700d19096a815e848606. Owner authorized next slice despite partial governance. Separate stacked Draft PR #3, base feat/dm-00. No merge/release or later slice authorization.

## Implemented
Fixed greybox lab, keyboard move/jump, mouse direction/power, first-hit arc preview, swept projectile collision, target knockback, direct 2 HP and bounded wall 1 HP per target/shot. Escape cancels; R/Reset reloads even mid-flight. Miss/timeout restores input.

## Evidence
Native Linux import, 16 pure-rule assertions, 24 scene/physics assertions and startup passed on source implementation. Native report: native-check.json. Negative runner checks reject missing engine and missing success sentinel; their reports preserve earlier local implementation identities.
Scripted native capture: ready.png, aiming.png, impact.png, settled.png. Captured game implementation bytes match the implementation; subsequent local amendments touched test assertions only. Target1 HP goes from six to four after a high arc clearing the wall. These are script-driven native frames, not human play evidence.
Windows/Linux CI, extracted Windows package and hosted capture are attached to PR #3 when available; do not infer them from Linux results.

## Self-review
Checked input -> prepare -> projectile -> collision adapter -> pure damage -> HP/impulse feedback. Domain is RefCounted and acquires no scene/OS/file/time state. Collision ray prevents ordinary fast-projectile tunneling; same-shot damage tokens bound wall damage. No peer-project imports. Test expected ballistic fixture is independent (100,250 at t=1 for origin zero, v=(100,-200), g=900).
Scope mismatch in source plan is explicitly resolved in docs/slices/DM-01.md: destruction is DM-02.
No independent reviewer approval or gameplay/fun acceptance. Visual inspection confirms HUD, trajectory and impact ring display; resizing/human desktop input still pending.

## Limitations
Partial AI governance: GDScript routing, validator declaration, runtime post-task and CI enforcement remain open. The Owner authorized proceeding, not claiming them fixed.
The Windows ZIP contains the official editor engine in game mode and source, not a release export. Packaging is verified independently of the checkout cache. No D20, terrain destruction, enemy turns, saves, guild levels or G1 acceptance.

## Next acceptance
Owner plays the ZIP: intentionally clear the wall, hit and push a target into a wall, cancel/reset, and decide whether aiming is understandable and worth a second attempt. Do not automatically start DM-02.

## Hosted delivery evidence
Run 38383615455 at correction HEAD 797ff1f86f7c74c9a70300885e35d40b665175ef passed: both Windows/Linux native checks, Linux script-driven rendered capture, and Windows ZIP extraction/import/startup. First run 38383343966 failed only at the undeclared ffmpeg conversion after native tests and capture passed; the correction keeps native AVI and removes that dependency. Game and test bytes did not change.
The downloaded Windows package is from the first run's successful Windows job at source 714cc6d and has the same game bytes as the correction HEAD. Its source-hashes.json and extracted-package JSON are retained.
