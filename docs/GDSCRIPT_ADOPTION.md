# S3 GDScript native adoption candidate

Owner authorized S3 review and Draft delivery, followed by a separate S4 CI slice on 2026-10-14. This branch stacks on DM-00 (`feat/dm-00`); other gameplay branches and the original uncommitted candidate remain outside scope. No consumer merge or release is authorized.

## Adoption and acceptance

The governed F-7 apply verified the remote framework target `2a09d542900579e9527e3e08ce18b1d34e056e96`, updated the framework checkout and lock, and installed repo-local hooks/instructions. Its historical apply result was `partially_updated` because the pin was then uncommitted. Committing the pin resolves that local consistency issue; it does not establish complete governance adoption.

The validator freshly runs the existing DM-00 Godot 4.7.2 checker and verifies HEAD/source hashes, version, import, bootstrap sentinel and startup results. The wrapper explicitly rejects a failed validator even when framework domain results are advisory. Local canonical SYSTEM_PROMPT language lines match the pinned source.

Commands from repo root:

    python tools/check_governance.py --godot <Godot-4.7.2-console-path> --output memory/evidence/s3-delivery/runtime.json
    python tools/test_native_acceptance.py --godot <Godot-4.7.2-console-path> --output memory/evidence/s3-delivery/native-cases.json

Windows normal-project pre/post-task acceptance uses the default pinned submodule path. Eight interface tests use stub evidence and are not native-engine proof. Four disposable real-engine cases must accept healthy and reject missing engine, bad script and bad scene, while preserving original game source. Disposable cases explicitly reuse this checkout's pinned framework path; they do not establish committed framework adoption in each temporary project.

## Review and delivery

Author-process review covers the explicit rule/validator binding, fresh evidence, HEAD/hash checks, Windows path normalization and failure propagation. No blocking finding was identified in this scope. Independent technical review and Owner acceptance are not claimed. The bound canonical review entry and native receipts under `memory/evidence/s3-delivery/` identify the implementation commit; the separate memory companion shares this Draft PR.

## Boundaries

S3 changes no CI workflow. S4 separately adds hosted Windows/Linux native acceptance and memory checks. This candidate claims no gameplay gate, non-bypassable CI, automatic memory lifecycle, approved risk classification, release, formal memory evidence qualification or complete governance adoption.
