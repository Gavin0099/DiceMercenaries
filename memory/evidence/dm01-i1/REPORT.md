# DM-01-I1 reviewer entry

The existing physics lab is integrated onto main a1068a8. Draft handoff only; no native GUI, merge or release is authorized in this slice.

## Candidate identity

- Integration implementation: `0dcd0b8a9466512ec290a516c8b39a5cd175566f`.
- Original game candidate: PR #3, `92f4f4183310acbd862ac34790e5b26dcc944643`.
- Base: `a1068a8971bfe658bd5819651f19780c902ad67a`.
- Framework remains `2a09d542900579e9527e3e08ce18b1d34e056e96`; lock, contract and governance workflow unchanged.
- `game-preservation.json` verifies the 19 game/config/test files match the original candidate. The validator/checker/CI wiring is the integration delta; game behavior was not revised.

## Review and validation

`review.json` is the author-process review, not independent approval. No blocking finding was identified for this bounded integration Draft. Inspect the checker/validator profile selection, exact command and marker checks, hash/head binding and retained DM-00 behavior first.

- `runtime.json`: post-commit Windows native acceptance at the implementation HEAD. Command: `python -X utf8 tools/check_governance.py --godot <official 4.7.2 console binary> --output memory/evidence/dm01-i1/runtime.json`. Pre-task/post-task and the bound native validator pass; 11 interface tests pass; actual engine rules16 and physics24 assertions pass.
- `native-cases-precommit.json`: real disposable healthy DM-01, missing engine, bad script, bad scene and DM-00 healthy cases all match. This is precommit evidence; hosted CI repeats these cases at the delivered head.
- `workflow-syntax.json`: both workflow documents and Python step syntax checked. `governance-drift.yml` is unchanged.
- `memory-preflight.json`: canonical-memory workflow guard ran; historical warning debt is retained. A companion commit adds canonical memory bound to the implementation.
- CI: pinned checksum/engine/PyYAML and full history retained, Windows/Linux native gates and current-diff memory checks run on this Draft. Exact latest-head hosted results must be read from the PR; this local packet does not manufacture hosted success.
- Windows development ZIP: produced and extraction-checked by CI with the existing packaging helpers. It uses the editor engine in game mode; it is not a release export.

## Limits and next decision

Owner skipped remaining DM-01-R1 GUI testing. The partial earlier run is not full manual input/fun acceptance. G1, DM-02, human-approved domain classification, full adoption and memory lifecycle/evidence qualification remain unclaimed. Existing historical memory warnings are not waived or converted into proof.

Review the integration Draft and its latest-head CI. Do not merge automatically or advance gameplay scope from this engineering handoff.
