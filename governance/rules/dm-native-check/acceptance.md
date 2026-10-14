# DM-00 Native Acceptance

- 明示選擇 `dm-native-check` 才執行原生 validator；規則載入不等於驗證成功。
- 使用固定 Godot 4.7.2，執行既有 `tools/check_project.py` 的匯入、bootstrap 測試與啟動檢查。
- 缺少引擎、錯誤版本、壞腳本、壞場景、檢查器失敗、缺少當次證據或證據與目前來源不符，均須回報失敗。
- 這份驗收只涵蓋 DM-00 骨架。玩法、Owner 接受、風險分級及完整治理導入仍須各自的證據。
