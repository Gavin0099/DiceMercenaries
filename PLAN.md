# DiceMercenaries PLAN

> **最後更新**: 2026-10-13
> **Owner**: Gavin0099
> **Freshness**: Sprint (7d)

## Current Phase
目前授權：TACT-02「戰士對護衛與法師」獨立候選，介面與測試包說明使用繁體中文。固定低骰比較突進打斷與掩體等待兩條路線，保留每輪一名職業；舊實驗室保留，真人趣味性與 G1 尚待驗收。
TACT-01 warrior tactical encounter authorized after Owner rejected ballistic-only gameplay and approved the proposed limited-movement, shield/charge, two telegraphed enemies and terrain prototype. Fixed rolls are comparison fixtures, not full DM-03; G1 remains pending.
DM-02 fixed-module destruction and repo-specific image/motion skills authorized by Owner. Governance remains partial; human gameplay acceptance pending.
Godot resource consolidation and development prioritization authorized on 2026-10-13. This documentation task does not authorize DM-03 or later gameplay implementation.

## Development Priorities

Canonical ordering; rationale and acceptance criteria: [docs/DEVELOPMENT_PRIORITIES.md](docs/DEVELOPMENT_PRIORITIES.md). Resources: [docs/GODOT_RESOURCES.md](docs/GODOT_RESOURCES.md).

1. P0: consolidate source/version-aware resources, troubleshooting and research records (current documentation scope).
2. P0 next candidate: human Windows DM-01/02 playtest and actual input/physics blockers; plan GDScript/governance enforcement debt separately. Partial governance and human acceptance remain open.
3. P1 目前：TACT-02 單戰士對護衛與法師、低骰兩條通關路線及中文介面；TACT-01 保留比較。完整 D20 與命運值隨後驗證，本次僅授權這個獨立測試關。
4. P2: DM-04 distinct warrior/mage behavior, then DM-05 enemy intent and DM warnings.
5. P3: DM-06 equipment/build differences and G2.
6. P4: DM-07 branch trial, then DM-08 guild/run separation and safe saves.
7. P5: DM-09 cohesive tutorial/UI/art/audio and Windows export, then G3.
8. P6: DM-10 additional content/Demo candidate after the gates; release requires separate approval.

Do not expand content when core input/gameplay validation fails. Resource completeness is not gameplay acceptance. Later entries are planning candidates only.

## Active Sprint
- TACT-02：法師施法／恢復、掩體、格擋、衝鋒冷卻與命中打斷；固定低骰合法路線通關測試。沒有完整 D20、裝備、地圖或法師／盜賊玩家角色。
- TACT-01: side-view warrior, finite movement, shield/charge, two locked enemy forecasts, wall/bridge, fixed-roll comparison. Independent candidate; no full DM-03/fate or later content.
- GOV-00: pinned submodule, baseline, repo instructions, installed local hooks, runtime smoke and reviewer evidence.
- DM-00: independent Godot 4.7.2 project, empty main scene, headless test entry, Windows CI.
- DM-01: fixed greybox battlefield, movement, manual ballistic aiming, swept projectile collision, bounded knockback/wall damage, Windows development playtest.
- DM-02: thin wall/platform/bridge break cases, shallow/deep fall outcomes, collision removal, repo character-art/combat-motion skills.
- DOC-01: candidate Godot source-verification knowledge base; DM-02 stacks on its Draft PR #4.
- Each slice has its own branch and Draft PR. No merge, deploy or release.

## Backlog
Full DM-03 onward follow docs/GAME_PLAN.md §12 and G1/G2/G3. TACT-01 is the explicitly authorized experiment; other later slices remain unauthorized.

## Decision Log
- 使用者要求實作戰士處理護衛＋法師的候選，並全部使用中文。詳見 docs/slices/TACT-02.md；不推論成真人驗收通過、合併或發布授權。
- Owner accepted the tactical prototype proposal and requested implementation on 2026-10-13. Movement/skill/forecast choices replace variable angle/power in the new entry scene; old physics labs stay as regression fixtures. Candidate values are recorded in docs/slices/TACT-01.md; no gate acceptance or merge/release authorization inferred.
- Owner requested Godot resource consolidation from a 2023 article plus GDQuest/KidsCanCode/Docs/Discord, additional useful resources and priority planning on 2026-10-13. Keep third-party tutorials as references; version/API/license checks precede adoption.
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
