# 骰子傭兵團

獨立 Godot 4.7.2＋typed GDScript 專案，優先提供 Windows 測試包。
原始設計：[完整遊戲計畫](docs/GAME_PLAN.md)。目前候選：[戰士對護衛與法師](docs/slices/TACT-02.md)。每輪一名職業，最終方向為戰士、法師、盜賊。

## 啟動與操作

解壓縮測試包，雙擊 `Play.cmd`。首次啟動會匯入專案。
這是包含官方編輯器引擎的開發測試包，尚非正式匯出發行版。

- A／D 或點地面移動，每回合共 240 移動額度。
- 1 移動、2 盾擊、3 衝鋒；選招後點敵人。4 格擋並結束回合。
- E 結束回合、Esc 切回移動、R 重開、M 減少動態。
- 法師奇數回合施法，偶數回合恢復。藍色掩體阻擋法術；護衛仍能攻擊掩體內的角色。
- 命中蓄力法師可打斷；衝鋒使用後下一回合冷卻。
- 骰點按鈕是固定比較工具；尚無完整隨機 D20、命運值、裝備、地圖或存檔。

請用低骰 3 比較「突進打斷」與「掩體等待」。程式測試不證明趣味性，真人驗收仍待進行。
舊物理、地形及戰術實驗室保留在 `scenes/battle`。

## 開發檢查

使用官方 Godot 4.7.2 stable：

```powershell
python tools/check_project.py --godot C:/完整路徑/Godot.exe --output artifacts/evidence/tact-02/native-check.json
```

Windows／Linux 原生檢查設定在 `.github/workflows/dm-00.yml`。
治理框架使用固定版本子模組，目前導入仍不完整；沒有自動合併或發布。
新工作目錄需安裝本機治理 hooks：

```powershell
git clone --recurse-submodules https://github.com/Gavin0099/DiceMercenaries.git
cd DiceMercenaries
$env:PYTHONPATH = ".ai-governance-framework"
python -m governance_tools.hook_installer --repo . --framework-root .ai-governance-framework
```

## 開發資源

- [Godot 資源入口](docs/GODOT_RESOURCES.md)、[技術參考](docs/GODOT_TECH_REFERENCE.md)。
- [問題排查](docs/godot/TROUBLESHOOTING.md)、[研究記錄模板](docs/godot/RESEARCH_TEMPLATE.md)。
- [目前計畫](PLAN.md)、[開發優先權](docs/DEVELOPMENT_PRIORITIES.md)。
