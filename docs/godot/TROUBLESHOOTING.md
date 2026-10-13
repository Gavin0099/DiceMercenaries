# Godot 功能開發排查表

更新：2026-10-13。這是排查建議；未聲稱每種問題已在本案發生。
資源入口：[GODOT_RESOURCES](../GODOT_RESOURCES.md)。引擎：4.7.2。

| 症狀 | 先檢查 | 用什麼證據判定修好 |
| --- | --- | --- |
| 教學程式貼入後 parser error | 教學版本、3.x 節點／API、型別推導；查內建 Class Reference | 本案引擎 import 與最小場景啟動無 parser error |
| 撞不到敵人或穿牆 | collision layer/mask、形狀、移動步長、首次命中查詢是否排除自己 | 最大速度／最薄牆的測試仍命中；預覽與實際首次撞點吻合於容差 |
| 地形畫面消失但仍阻擋 | 不能只 hide sprite；檢查 deferred collider disable、生效物理步 | 破壞前擋住、破壞後能穿過；連續 reset 不留下幽靈碰撞 |
| 同一攻擊反覆扣血 | attack_id、每目標去重、撞牆／墜落上限與事件再入 | 重複 hit、連續物理接觸、已死亡目標不造成額外扣血 |
| 相同 seed 擲骰不同 | 是否混用全域 RNG；動畫／音效是否多抽一次；seed/state 初始化順序 | 同 RNG 初始狀態與相同抽樣操作序列一致；開關裝飾不影響 D20 |
| 點 UI 時順便發射 | UI mouse_filter、事件消耗、`_input`／`_unhandled_input` 路徑、瞄準取消 | 按技能／取消／切畫面不發射；合法攻擊只能觸發一次 |
| 暫停後無法恢復 | process_mode、UI 與 gameplay 是否採正確暫停模式 | 暫停時 UI 可恢復；恢復後攻擊／回合不重複結算 |
| 動畫跳過讓傷害漏算或重算 | 規則是否依賴動畫結束；已結算事件是否重播 | 正常、跳過、加速、減少動態效果的規則結果一致 |
| 改一個角色裝備影響所有人 | shared Resource 是否存 runtime HP／槽位／冷卻 | 同定義的兩個角色或兩輪遊戲狀態隔離 |
| 小視窗遮住骰點或危險區 | anchors、containers、字體與 UI 事件遮擋 | 真實小視窗操作可看懂並完成瞄準／取消／出招 |
| Windows 可執行但解壓版失敗 | 相對路徑、漏檔、大小寫、engine/template 版本、檔案鎖 | 全新目錄完整解壓後匯入／啟動；暫時鎖有界重試、永久錯誤會失敗 |
| 存檔損壞或跨輪殘留 | guild/run 分離、版本、寫入中斷、舊檔遷移 | 損壞／中斷／舊版本 fixture 不覆蓋有效 guild；新輪不帶走舊裝備 |

## 問題處理順序

1. 留下確切 Godot 版本、repo commit、OS、錯誤 log、重現操作與預期行為。
2. 把問題縮到相關 `.gd`／`.tscn`，先查官方 API；需要教學时查 KidsCanCode／GDQuest。
3. 提出最小修正，先定義能暴露原問題的測試；對涉及 Windows 的問題，Linux 成功不能當 Windows 證據。
4. 用 [研究模板](RESEARCH_TEMPLATE.md) 記來源與結果；必要時保存原生畫面。
5. 仍無法解決才準備 Forum／Discord 問題草稿，移除私人資料；未獲授權不代發。

常用既有檢查入口：`python tools/check_project.py --godot <Godot 的絕對路徑>`。
先讀工具與 README 確認參數及引擎；此文件新增並不代表本次重跑遊戲測試。
