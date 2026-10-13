# DiceMercenaries — Godot 4.7.2 技術知識庫

> 查核日：2026-10-13（Asia/Taipei）。狀態：research/candidate。
> 目標引擎：Godot 4.7.2 stable + typed GDScript。
> 本文件不改變 docs/GAME_PLAN.md、docs/DECISIONS.md、PLAN.md 的 Owner 授權、Gameplay Gates 與實作範圍。

2026-10-13 資源整合補充：[統一資源入口](GODOT_RESOURCES.md)、[問題排查表](godot/TROUBLESHOOTING.md)、[研究紀錄模板](godot/RESEARCH_TEMPLATE.md)。優先順序見 [PLAN](../PLAN.md)，排序理由見 [開發優先權](DEVELOPMENT_PRIORITIES.md)。下方早期研究內容保留，最新實作狀態以本補充與 PLAN／PR evidence 為準。

## 1. 查證結論與信任階層

1. 官方 [Godot 4.7.2 stable](https://godotengine.org/article/maintenance-release-godot-4-7-2/) 發布於 **2026-08-18**。Godot 4.8 開發版文件不得視為 4.7.2 可用功能。
2. API 採 [Godot 官方英文 stable 文件](https://docs.godotengine.org/en/stable/)（查核時為 4.7 分支）與引擎內建 Class Reference 為準。
3. [繁體中文文件入口](https://docs.godotengine.org/zh-tw/stable/) 可供閱讀，但此次查核顯示其導向 zh-tw/4.x 並標示最新不穩定文件；逐個 API 仍以英文 stable 核對。
4. GDQuest 適合學結構，KidsCanCode 適合查最小功能實作，官方 Discord/Forum 適合協助排除未解問題；**聲譽或網頁標籤不構成 Godot 4.7.2 相容證明**。

## 2. 來源登記（來源存在已查核；未複製第三方 demo 並執行專案測試）

| ID | 來源 | 目的 / 關鍵發現 |
| --- | --- | --- |
| O01 | [Release/Archive](https://godotengine.org/download/archive/4.7.2-stable/) | 固定正式引擎版本；CI 需記錄具體 engine commit/checksum |
| O02 | [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html) | 場景盡量自足；依賴透過擁有者配置，避免通用 Autoload 管理器膨脹 |
| O03 | [Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html) | 貼近場景放相關資產，將規則與 UI 分層 |
| O04 | [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) | 官方明確說明物理**不保證 deterministic**，不可把固定 Seed 誤稱跨平台逐影格相同 |
| O05 | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) | disabled 應用 Object.set_deferred() 改動，DM-02 破壞後需要確認碰撞真正解除 |
| O06 | [RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html) | seed / state 可控，適合 D20、地圖、獎勵獨立 RNG stream |
| O07 | [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) | 自訂 Resource/.tres 定義職業、武器、骰印；多個實例共用資源，別意外共享戰局 mutable state |
| O08 | [AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) | AnimationPlayer 儲存動畫，AnimationTree 管進階轉場；不要誤以為它包含獨立動畫資料 |
| O09 | [Physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_quick_start_guide.html) | 物理移動在 physics step；初次定位及瞬移後應 reset interpolation |
| O10 | [Command-line Godot](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) | --headless、--path、--script、--write-movie 等用於原生 CI；自動化不等於玩家手感驗收 |
| G01 | [GDQuest Godot 4 第一個 Roguelite](https://gdquest.com/library/first_2d_game_godot4_vampire_survivor/) | 2D 移動、發射物、追蹤敵人、遊戲環；**程式 MIT，遊戲圖像 CC BY-NC-SA，不能直接進商用 Steam 版** |
| G02 | [GDQuest Godot 4 範例 Repo](https://github.com/gdquest-demos/getting-started-with-godot-4) | 2D/3D complete demo；參考前確認實際 commit 與檔案 license |
| G03 | [GDQuest Godot 4 How-tos](https://github.com/gdquest-demos/godot-4-how-tos) | 查功能片段；逐檔對照 4.7.2 API |
| G04 | [GDQuest procedural generation](https://github.com/GDQuest/godot-procedural-generation) | 以後的地圖生成概念；**不提前導入**第三方地圖框架 |
| K01 | [KidsCanCode 4.x Recipes](https://kidscancode.org/godot_recipes/4.x/) | 圖文配小 demo；網站有「Godot 4.0 最新」舊文字，不能因此認定新 API 完整 |
| K02 | [Physics recipes](https://kidscancode.org/godot_recipes/4.x/physics/index.html) | RigidBody2D 互動與撞擊；其中 [Drag & Drop](https://kidscancode.org/godot_recipes/4.x/physics/rigidbody_drag_drop/) 展示 freeze 與 impulse |
| K03 | [AnimationTree StateMachine](https://kidscancode.org/godot_recipes/4.x/animation/using_animation_sm/) | 多動作轉場的概念；採用前查官方 AnimationTree API |
| C01 | [Godot 官方社群](https://godotengine.org/community/)／[Discord](https://discord.gg/godotengine)／[Forum](https://forum.godotengine.org/) | 已確認官方 Discord 與社群營運的 Godot Café **不是同一個**；社群解法均需自行測試 |

**已發現的版本陷阱**：KidsCanCode 部分標示 4.x 的 RigidBody2D 說明仍提到舊的 body mode/kinematic 模型；使用具體 API 前，必須先查 O04/O05 及 4.7 類別參照，而不是逐行複製示例。

## 3. 必須對應的開發 Slice

### DM-02 — 地形破壞（已實作候選，真人驗收待進行）

- 最小實作先以 StaticBody2D + CollisionShape2D 做固定 HP 的薄牆、橋板、平台。主地面與邊界不可破壞；不做像素切割、無限動態地形或完整 TileMap 破壞。
- Combat adapter 負責碰撞事實和 terrain_hit 事件，Domain 負責去重、上限、HP、Destroyed 判定；visual crumble 與破壞事件的生命週期不得相互遞迴扣血。
- 破壞判定通過後，採 collision_shape.set_deferred("disabled", true)；經過物理步後以實際碰撞測試驗證已可通過，不以「畫面消失」替代測試。
- 新手地圖先分「落到低層」與「危險深坑」，明確決定碰撞、傷害與 Boss 特例。對照 GAME_PLAN §5 與 §12，不擅自增加規則。
- **負向驗證**：重複撞擊不得重扣、撞牆傷害有界、破壞後不殘留幽靈碰撞、破壞中 reset 不卡住、平台消失後角色可落下、連鎖效果不無限迴圈。
- 純規則 fixture + Windows/Linux native physics scene + 破壞前後畫面；物理測試看合理容差／關係，非逐影格 bit-identical。

### DM-03 — D20 與 RNG

- raw_roll、effective_roll、natural_20 分開，由純 typed GDScript domain rule 判定。
- 對地圖、戰利品、D20、敵人決策保留獨立 RandomNumberGenerator 與 seed/state 或抽樣紀錄；視覺骰子演出不得再次消耗 gameplay RNG。
- 強制 3、10、17、20 的 fixtures 驗證基本招式依然能用、命運修正不可偽造自然 20。Seed 可重現 RNG 序列，**不可推導 Godot 物理跨平台決定性**。

### DM-04/DM-05 — 職業、回合與動畫

- 先用 AnimationPlayer 管 idle / prepare / attack / hit / die；真的需要多狀態混合時才加 AnimationTree。
- 動畫與音效讀取 Domain 事件，不能以動畫是否播完作為唯一規則真相；需要跳過、加速、減少動態效果路徑。
- 分支地城是一張選路 graph，不等於場景路徑尋找，不必過早導入 NavigationAgent2D。
- 視覺元件應避免遮蔽主戰場、D20、敵人意圖與 DM 預警；人類辨識與手感未做之前不可標注成遊戲體驗 PASS。

### 後續 Roguelite — 地圖與裝備

- 先由模板建立 5–7 層可到 Boss 的 directed graph；記錄 seed、node ID、edges、node kind，用可達性/路線差異測試，不能因 G04 存在就引入整套 PCG。
- 裝備和職業用 Resource/.tres 表述可配置規則，run-time 狀態、裝備槽與掉落由獨立結構保存；不要直接修改共享的 Resource 作為角色持有狀態。

## 4. TacticalGo 技術移植：方法可複用，角色規格不可照搬

已檢視 Gavin0099/TacticalGo main 的 .agents/skills/tacticalgo-character-style/SKILL.md、style-v0.1.md 與 prompt-template.md。它主要是棋盤近俯視 Soft Handmade 2.5D 角色 token，而 DiceMercenaries 為橫向物理戰場。

- **可參考的方法**：同角色個別身份參考、STYLE 和 IDENTITY 区分、原始素材不可覆寫、prompt 與 SHA-256 留存、透明背景、實際縮放後辨識、approval/availability/rights/QA 四項狀態分立。
- **不可直接照搬**：棋盤基座和交點對齊、單一立繪縮成 32/48/64 像素就當戰鬥 Sprite、人物 PNG、既有角色 identities、歷史審核的移轉。
- 真正需要 side-view 動作 sprite/sprite sheet 或骨架動畫時，應另外設計 DiceMercenaries 專屬 art/animation skill，定義鏡頭、動作、Hitbox、材質、一致性、授權及尺寸 Gate；不能宣稱此次文件已完成圖像生成或動畫 skill 改寫。

## 5. 新來源採納 Gate

每一份未來要用的教學必須記錄：

| 欄位 | 至少包含 |
| --- | --- |
| Source | URL、查核日期、標示的 Godot 版本、特定 commit（若有） |
| Licenses | **程式**、**圖片/音訊**分別紀錄；未知不匯入 |
| Target | DM-XX、真正要解決的 failure、最小改動方案 |
| Official check | 官方對應 API、已排除過時寫法 |
| Evidence | repo commit、Godot --version、Windows/Linux test、負向案例、截圖/影片 |
| Status | researched / candidate / validated / rejected；沒有可檢驗證據不能稱 validated |
| Limits | 未完事項、人體操作/權利/版本限制、Owner Gate |

查 Discord/Forum 前先有最小可重現 .tscn/.gd、Godot 版本、平台、預期/實際行為、日誌以及已查過的官方文件；取得建議後仍用本案引擎/CI 驗證。禁止把社群回覆轉述成正式引擎合約。

## 6. 非宣稱與治理邊界

- 此文件只是一份 source-verified 的規劃產物，沒有新增 gameplay、素材、遊戲效能 benchmark，也未完成這些第三方 demo 的 Godot 4.7.2 移植。
- Repo 現有 GOV-00、DM-00、DM-01、DOC-01、DM-02 是 stacked Draft PR；不得寫入 main、不合併、不發布。這次資料研究沒有改變任何 slice Gate。
- 原始治理 audit 仍是 partial（GDScript routing、validators、post-task/runtime、CI enforcement/Owner acceptance 待確認）；本文件與技能不能使治理自動變完整。
