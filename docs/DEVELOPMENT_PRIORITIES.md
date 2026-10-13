# 開發優先權：先降低核心風險，再擴內容

更新：2026-10-13。排序的單一真相在 [PLAN](../PLAN.md)；本文件只解釋依據與驗收方式。
目前優先測試 [TACT-02 單職業通關](slices/TACT-02.md)：低骰戰士對護衛與法師，以突進打斷與掩體等待比較兩條路線。中文介面；先驗證玩家能否理解並願意重試，再擴職業與內容。
資源整合後，Owner 另行接受 TACT-01 戰士回合原型並要求往下做。當前先驗證站位／選招／預告，完整 D20 與其餘後續功能仍待各自授權。

## 目前起點

DM-02 head `577a1155b77a5b71de3e3a9b1a819d18617a96c1` 已有地形實作與測試。DM-00～02 是堆疊 Draft 候選，不是 main 的已合併成果。
[PR #5](https://github.com/Gavin0099/DiceMercenaries/pull/5) 的 Windows/Linux [CI 38389769617](https://github.com/Gavin0099/DiceMercenaries/actions/runs/38389769617) 已成功；DM-02 evidence 記錄 81 項規則／整合斷言。真人操作與趣味性尚未驗收。
G1 的完整驗收包含 DM-01～03；現在可以先試 DM-01/02 的操作與地形，不能提前宣稱完整 G1 通過。

更新：當前優先實作 [TACT-01](slices/TACT-01.md)，把發射玩具改成有限移動、盾擊／衝撞、敵人預告的小型戰鬥。固定骰點只是比較工具；先判斷戰術選擇是否成立，再完整實作 DM-03。此更新不把此前 G1 未驗收改成已通過。

## 優先順序與停止條件

| 優先級 | 工作 | 為什麼排這裡 | 完成／進入下一階段的條件 | 先查什麼 |
| --- | --- | --- | --- | --- |
| P0（本次） | 整合資源入口、排查表、研究模板與 PLAN | 讓每次功能研究沿用可追溯來源，避免重複找資料及套用舊 API | 文件互鏈有效、來源／版本／未查項目明確，未改 gameplay | GODOT_RESOURCES、GODOT_TECH_REFERENCE |
| P0（下一步候選） | Windows 真人試玩 DM-01/02，處理實際 blocker | CI 不會證明瞄準直覺、射偏可理解、地形危險看得懂 | 记录意圖／實際結果／原因／能否修正；若操作核心不好玩先修，暫停擴內容 | 輸入、物理、ray-casting、CollisionShape2D、排查表 |
| P0（平行債務候選） | 按風險補治理與 GDScript 驗證缺口 | 保護後面的核心規則與存檔修改；已有 native CI 不代表完整治理 | 先定義 GDScript 路由與真實失敗案例；再驗證 validator、lifecycle、stacked PR 治理 CI。完整採納由 Owner/reviewer 判定 | GOVERNANCE_ADOPTION_AUDIT、既有測試與 workflow |
| P1 | DM-03：D20、四階、命運值、自然 20 | 這是遊戲差異的核心；先證明骰子真的改變戰術 | 3/10/17/20 可強制測試；修正不偽造自然 20；低骰回合末才發命運值；完成 G1 真人驗收 | RNG、typed GDScript、RULES_D20、GAME_PLAN §3/12 |
| P2 | DM-04 → DM-05：戰士／法師，再加敵人意圖與 DM 預警 | 先有不同打法，再讓一場回合戰鬥成立 | 同地圖同骰點有不同操作；危險至少提前完整一回合預警，有合法對策 | AnimationPlayer、InputEvent、pause/process_mode、Resources |
| P3 | DM-06：少量裝備與同職業兩個流派 | 沒有核心差異時，增加裝備只會增加數量 | 換構築改變站位／目標／破壞順序；無無限連鎖，G2 通過 | Resources、Domain 去重／事件上限 |
| P4 | DM-07 → DM-08：分岔試煉，再補公會／存檔 | 戰鬥與流派成立後才值得把它們串成一輪 | 路線可達 Boss、選路有理由；guild 保留且 run 重置；損壞存檔不覆寫有效紀錄 | 技術知識庫的 graph 模板建議、Saving games |
| P5 | DM-09：教學、UI／音效／視覺整合與正式 Windows export | 有完整流程才能測玩家能否獨立理解並想重玩 | 乾淨環境啟動、縮小視窗可用、完整一輪與 G3；真人條件依 GAME_PLAN | UI anchors、export、專屬 character-art／combat-motion skills |
| P6 | DM-10：盜賊、額外流派／內容與 Demo 候選 | 用驗收結果決定擴充，避免先堆美術與關卡 | G1/G2/G3 通過後再決定 Demo 範圍；發布另行核准 | 已驗證研究紀錄與玩家回饋 |

P0 治理債務可以規劃為獨立小項，但不能用本次整理資源宣稱治理已完成；它也不會自行覆銷既有 Owner 對 partial 治理下工作的授權。
資源閱讀以當前 slice 為限：現在優先物理／輸入／D20，存檔／程序生成／進階動畫等到對應阶段再深入。

## 先不投入的內容

- 大量角色圖與完整動畫製作：先有職業可辨識打法；現在的 art/motion skills 是規範與方法。
- 任意像素挖地、通用地圖生成框架、複雜 AnimationTree：先用固定破壞模組、可達 graph 模板與 AnimationPlayer。
- 多人連線、後端、換成 C#、行動裝置移植：不屬目前 Windows／GDScript 單人核心驗證。
- 新增課程／套件採購：免費官方文件與範例先解具體問題，再評估是否真的欠缺。

## 每個功能都用同一個短流程

對照授權與規格 → 找官方 API → 必要時參考一個最小範例 → 記版本／授權 → 寫最小改動與失敗驗證 → 原生檢查 → 需要時真人試玩 → 更新研究紀錄與 PLAN。
驗證不足時保留 candidate 狀態；不要因資源齊全或 CI 綠燈直接跨 Gate。
