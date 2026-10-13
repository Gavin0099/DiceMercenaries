# Godot 開發資源入口

查核日：2026-10-13（Asia/Taipei）。本案固定 Godot 4.7.2 + typed GDScript。
用途：開發前找對文件、遇到問題有排查路徑、避免把舊教學當成目前 API。
這份索引收錄連結與自行整理的摘要；未匯入課程全文、第三方程式、圖片、音樂或外掛。

## 從哪裡開始

1. 先讀 [PLAN](../PLAN.md) 的目前優先順序與授權範圍。
2. 找下方「按功能查資源」的對應列，再讀 [技術知識庫](GODOT_TECH_REFERENCE.md) 的設計限制。
3. 卡關時用 [問題排查表](godot/TROUBLESHOOTING.md)，需要採用第三方實作時填 [研究紀錄](godot/RESEARCH_TEMPLATE.md)。
4. [開發優先權說明](DEVELOPMENT_PRIORITIES.md) 解釋 PLAN 的排序依據；玩法規則仍以 [GAME_PLAN](GAME_PLAN.md) 與 [DECISIONS](DECISIONS.md) 為準。

## 核心資源：先查這四類

| 資源 | 用在什麼情境 | 查核與採用界線 |
| --- | --- | --- |
| [Godot Docs 英文 stable](https://docs.godotengine.org/en/stable/) | 查節點、屬性、方法與正式行為；API 第一查證入口 | stable 會隨新版本移動；使用前對照本案 4.7.2 引擎內建 Class Reference |
| [Godot Docs 繁體中文](https://docs.godotengine.org/zh-tw/stable/) | 先理解概念與編輯器操作 | 本次導向 zh-tw/4.x，標示 master 分支；翻譯與版本不能直接視為 4.7.2 API 保證 |
| [GDQuest 免費 Library](https://www.gdquest.com/library/)、[Learn GDScript From Zero](https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/learn_gdscript/learn_gdscript_app) | 系統學習 GDScript、場景與程式結構 | 教學入口已查核，未在本案執行全部範例；課程頁和專案內程式／素材授權分開查 |
| [KidsCanCode Godot 4 Recipes](https://kidscancode.org/godot_recipes/4.x/) | 角色控制、物理、動畫等單一功能的最小範例 | 4.x 標籤不代表所有片段符合 4.7.2；參照官方 API 再寫本案 adapter |
| [官方 Community](https://godotengine.org/community/)、[官方 Discord](https://discord.gg/godotengine)、[官方 Forum](https://forum.godotengine.org/) | 最小重現仍無法解決時求助；Forum 便於日後檢索 | Discord 連結由官方社群頁確認；未測試登入／加入。回覆是待驗證建議，發問需另有使用者授權 |

建議學習路徑：GDScript 基礎 → 場景／節點／signals → 2D 輸入與物理 → 本案灰盒場景 → D20 純規則 → 職業／回合。已熟悉的部分直接跳過，不必先修完完整課程才開發。

另外補入三篇已開啟查核的 GDQuest Godot 4.x 專題：[讀懂錯誤訊息](https://www.gdquest.com/library/reading_godot_error_messages/)、[找不到節點／null instance 排查](https://www.gdquest.com/library/null_instance_error/)、[理解 raycast](https://www.gdquest.com/library/raycast_introduction/)。可在 DM-01～03 開發卡關時直接查；範例尚未在本案原生執行。

查核限制：Learn GDScript From Zero 的當前入口由官方文件與 GDQuest 搜尋結果確認，但本次直接開啟 school 頁面失敗；未驗證互動課程可完整操作。

## 按功能查資源

以下是本案依失敗風險挑選的官方文件，均於本次開啟查核；文件存在不等於功能已實作或通過原生驗證。

| 功能／問題 | 官方文件 | 本案位置／驗證重點 |
| --- | --- | --- |
| 型別、錯誤推導、null | [Static typing](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html) | 全部 `.gd`；集合取值和 `as` 的 null 路徑要檢查 |
| 移動、碰撞層、物理更新 | [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) | DM-01/02；用 physics step，形狀尺寸與碰撞 mask 要吻合 |
| 彈道與首次命中 | [Ray-casting](https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html) | DM-01；預覽／實際命中／高速穿牆要對照，不直接把 ray 當成有半徑的彈體 |
| 破壞後仍擋路 | [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) | DM-02；deferred disable 後等物理步並測實際通過 |
| UI 點擊誤發射、重複輸入 | [Using InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) | DM-03～05；檢查 UI 消耗事件、取消瞄準與一回合一發 |
| D20、種子與亂數分流 | [RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html) | DM-03；raw/effective/natural20 分開，視覺不得改變骰點 |
| 攻擊／受擊／死亡動畫 | [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) | DM-04/05；動畫是回饋，不能成為扣血唯一權威 |
| 暫停、加速、跳過動畫 | [Pausing and process mode](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) | DM-05；pause 後操作 UI 仍可用，回合不重複結算 |
| 裝備、技能定義共享 | [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) | DM-04/06；定義與每輪 mutable state 分開 |
| 縮小視窗後 HUD 超出 | [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html) | DM-03～09；D20／意圖／危險區資訊仍可見 |
| 存檔與跨輪重置 | [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) | DM-08；官方例子是概念起點，版本／原子寫入／損壞保護要另設計 |
| Windows 正式匯出 | [Exporting projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html) | DM-09；export templates 與引擎版本一致，乾淨解壓啟動；現有包仍是 development build |
| 執行錯誤與效能 | [Debugger panel](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html) | 任一 slice；先取具體錯誤／量測，別憑猜測重構 |

固定引擎取得：[Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/)。測試入口、CI 與既有 evidence 參見 [README](../README.md)。

## 使用者提供的 2023 資源整理

來源：Muryan，2023-09-22，[巴哈姆特〈Godot 教學資源〉](https://home.gamer.com.tw/artwork.php?sn=5798518)。
本次已找到原文網址，但開啟遇到 403；內容依使用者貼文整理。版本欄是原文當年的標示，非各作者目前全部課程的版本。略去網站選單、留言、排行榜與過期 Discord 邀請碼。

| 原文資源 | 原文標示 | 本案安排 |
| --- | --- | --- |
| 官方 Docs | 3.5／4.1 | 換用上方當前入口，API 再對照 4.7.2 |
| GDQuest：Learn GDScript／First 2D Game | 3.5／3.1 | 基礎概念可讀；先用上方 Godot 4 學習入口與下方 Godot 4 demo |
| HeartBeast：Pixel Platformer／Heart Platformer | 3.4／4.0 | [作者官方站](https://www.heartgamedev.com/) 已查核；特定影片連結未從貼文取得。移動／手感概念作補充，不整套照搬 |
| Udemy：Firebelley Games | 貼文未列確切版本 | [作者課程站](https://www.godotcourses.com/) 已查核；選課前確認指定課程版本、單人 2D 適用性與範例權利，無須先購課 |
| Udemy：Victor Meunier | 未列確切課程／版本 | 保留來源名稱，待取得確切課程網址；回饋／特效排在核心驗收之後 |
| 阿空的遊戲部屋：Godot C# 彈幕 | 3.5／C# | 僅作中文介面／概念補充；本案採 GDScript，非換語言理由。確切影片待查 |
| 中央創遊：Godot 教學 | 3.4／GDScript | 中文基礎補充，舊 API 不能直接採用。確切系列網址待查 |
| Rika：GDScript 零基礎圖文入門 | 貼文未列版本 | [原文提供的圖文網站](https://reimenn.github.io/MyGDSciprtBook/) 已開啟；本次未逐章確認版本及範例相容性 |
| A VEGETABLES BIRD'S BLOG | 未列版本／網址 | 保留待查，不自行猜網站或宣稱已驗證 |
| 台灣 Discord／Facebook、公會 | 2023 的社群資訊 | 從官方 Community 的 User groups 找當前入口；本次未確認各群組可加入性 |

另外可直接查 [GDQuest Godot 4 起步 demo repo](https://github.com/gdquest-demos/getting-started-with-godot-4) 與 [Godot 4 第一個 2D Roguelite](https://www.gdquest.com/library/first_2d_game_godot4_vampire_survivor/)：用來讀程式結構與小型完整流程，不把即時生存遊戲的整套設計套到回合制。本案既有知識庫記錄該 Roguelite 的程式／圖像不同授權；任何實際匯入仍須逐檔查明權利。

## 維護規則

- 官方 API 優先；教學示範第二；社群回覆最後，均需本案驗證。
- `researched`：查了來源；`candidate`：提出採用方式；`validated`：本案指定引擎與測試證據通過；`rejected`：不適用並記原因。
- 網址可開啟、名氣、影片標題或「Godot 4」標籤，都不能替代程式與素材授權、版本、原生測試。
- 做功能前只讀相關項目；遇到新問題再補一筆研究紀錄，避免形成無法維護的大型教學鏡像。
- 來源失效或 stable 升版時保留歷史查核日期，再記新結果；不把舊查核日期當成永久有效。
