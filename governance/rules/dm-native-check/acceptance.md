# Native Slice Acceptance

- 明示選擇 `dm-native-check` 才執行原生 validator；規則載入不等於驗證成功。
- 使用固定 Godot 4.7.2，依唯一已知 main scene 選擇驗收：DM-00 執行 bootstrap；DM-01 執行純規則與原生物理場景測試。未知或重複 main scene 必須拒絕。
- 每次證據須完整包含版本、匯入、全部對應測試／成功標記及啟動，綁定當次 HEAD 與來源雜湊；不能只靠 checker 的成功布林值接受。
- 缺少引擎、錯誤版本、壞腳本、壞場景、檢查器失敗、缺少當次證據或證據與目前來源不符，均須回報失敗。
- 這份驗收只涵蓋各 slice 的原生工程檢查。操作手感、Owner 接受、風險分級及完整治理導入仍須各自的證據。
