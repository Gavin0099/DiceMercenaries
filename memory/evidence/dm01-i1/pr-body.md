DM-01's existing checker emits five commands and rules/physics markers, while main a1068a8's bound validator accepted only the four-command DM-00 bootstrap. This integrates the existing physics lab from PR #3 without revising its game behavior and connects it to the current native acceptance and CI path.

The validator retains strict slice/HEAD/hash/command/version/exit/sentinel checks for the two known main scenes. DM-00 acceptance is preserved. Main's framework pin/lock, proposed contract classification and governance/memory workflow are unchanged. Windows/Linux execute pre/post-task native acceptance and disposable failure cases; Windows also verifies the existing development playtest ZIP.

Validation: 11 validator interface tests; actual Godot 4.7.2 rules16 and physics24 assertions; healthy DM-01, missing-engine, bad-script, bad-scene and healthy DM-00 cases matched locally. All 19 game/config/test source files match PR #3. Workflow syntax, drift and canonical-memory guard passed. Hosted latest-head CI is pending when this Draft is opened.

Reviewer entry: [memory/evidence/dm01-i1/REPORT.md](../blob/codex/dm01-main-integration/memory/evidence/dm01-i1/REPORT.md). Scope: [docs/slices/DM-01-I1.md](../blob/codex/dm01-main-integration/docs/slices/DM-01-I1.md).

Author-process review only. Owner skipped remaining DM-01-R1 GUI testing; this does not establish complete manual input/fun acceptance. No GUI operated in this slice. G1, DM-02, full governance/lifecycle qualification, merge and release are not claimed. This is a new integration Draft against main; earlier stacked PR #3 remains untouched.
