# 骰子傭兵團 — 治理導入與 DM-00 審查報告

結果：已完成本地治理導入候選與 DM-00 骨架；尚未交付 GitHub Draft PR，未合併、部署或發布。
原因：repo 為空；初始化 main 的空提交被自動審查拒絕。Git transport 也無推送認證，後續應使用 GitHub connector 交付。
下一步：Owner 明確批准一次性初始化 main（只放無玩法的初始說明或空提交），再提交 GOV-00 與 DM-00 各自 Draft PR。

## 實際完成

- 原規格完整保留為 docs/GAME_PLAN.md，與上傳來源逐位元相同。
- pinned framework submodule：.ai-governance-framework，b74bbde22727391dadfdc017cb1bad9c20169ad6。
- repo 專屬 AGENTS、PLAN、contract、版本 manifest、memory 骨架、canonical writer 記錄與 Git/Copilot 本機檢查表面。
- DM-00：Godot 4.7.2，1280×720 空場景，typed GDScript 原生測試入口、分層目錄、Python 檢查命令與 Windows/Linux CI。
- 本機 hook 確實在 commit 路徑觸發；push 因認證不足未進入有效遠端交付，不宣稱 push-hook 成功。
- 已修正治理子模組 CSV 被 Godot 誤匯入、引擎崩潰問題；子模組改為隱藏目錄。來源 framework 未修改。

## 驗證

| 檢查 | 結果 | 證據 |
|---|---|---|
| Framework drift / readiness | PASS / ready=true | .governance/evidence/readiness.txt |
| Hook 安裝 | valid=true | .governance/evidence/hooks.txt |
| Runtime smoke | ok=true；含 advisory | .governance/evidence/runtime-smoke.json |
| Memory authority workflow | 執行且未阻擋 | .governance/evidence/memory-workflow.txt |
| Linux Godot 匯入、場景 contract、啟動 | PASS | artifacts/evidence/dm-00/native-check.json |
| 官方 Linux engine archive SHA-512 | 相符 | artifacts/evidence/dm-00/failure-checks.json |
| 錯誤 scene metadata／缺引擎 | 均拒絕，非零 exit | artifacts/evidence/dm-00/failure-checks.json |
| CI YAML 與 Python 編譯 | PASS | 本機 yaml.safe_load / py_compile |
| Windows CI／editor 操作 | NOT RUN | tests/manual/DM-00.md |
| G1/G2/G3／真人遊玩 | NOT RUN | 無戰鬥實作 |
| 獨立複審／Owner 接受 | NOT RUN | 候選狀態 |

原生測試綁定來源 commit：3feade22ead26264c5c762a7433077753b168e9f；並附 project/scene/test/runner 的 SHA-256，避免把測試結果誤綁到後續修改。

## 不可升級的聲明

目前框架 summary 是 partial：validator_surface 未接入；game native check 是獨立工程工具，不冒稱已接上治理領域 validator。
Runtime smoke 通過不等於 ChatGPT Work 每次 lifecycle 自動執行；Copilot 格式符合不等於在 VS Code/CLI 實際啟動過。
領域 offline-single-player-game、medium risk 是建議分級，尚未有人類核准；保存／核心規則提升 L2。
GDScript 未列於框架 LANG enum。未更改來源規則、未冒稱 Python/JS 支援遊戲邏輯；後續 DM-01 前需解決 routing。
未完成 F-7 full update；這是首次手動 submodule 導入，不宣稱最新版或 full governance。
Known debt 清除條件：Owner 審核分級與治理缺口、Windows native CI/人工驗收通過、各切片獨立 Draft PR 可審查。
Owner-accepted validation debt：NONE。

## 框架原始導入摘要

[governance_maturity_summary]
report_only              = true
user_facing_status       = partial
user_facing_meaning      = Missing surfaces: validator_surface
framework_topology       = submodule_consumer
static_self_contained    = yes
runtime_capable          = not_checked
hook_config_framework_root = inside_repo
framework_pin_freshness  = current_vs_local_tracking
lock_consistency         = consistent
agents_calibration       = repo_specific_minimal
repo_specific_rules      = true
domain_contract_present = true
validator_surface        = false
memory_workflow_surface  = not_checked
claim_ceiling            = repo_specific_assisted
missing_surfaces         = validator_surface
signal_conflicts         = 0
claim_boundary           = report-only; does not prove full governance adoption, runtime self-contained execution, hook enforcement, memory completeness, domain correctness, or release readiness
[human_readable_adoption_summary]
用途：這段用人類可讀的方式說明 AI Governance 更新後，目前哪些功能已導入、哪些尚未導入或尚未驗證。
先看結論：
這份檢查做了什麼：檢查 framework、版本帳本、repo 規則、hooks、領域合約、自動檢查與記憶工作流的可見狀態。
現在能不能用：可使用已導入的治理檔案；但不能說這個 repo 已完整導入。
還差什麼：尚未宣告 repo 專屬自動檢查。
整體導入狀態：partial - 已有部分 AI Governance 功能，但仍缺少至少一個必要表面.
需要查技術細項再往下看：
AI Governance 功能導入狀態：
| 功能 | 狀態 | 這個功能是做什麼 |
| --- | --- | --- |
| 版本帳實一致性（Lock vs checkout consistency） | 已可用 | 比對 governance/framework.lock.json 的 adopted_commit 與本地 framework checkout HEAD；不做 fetch，也不宣稱真實遠端最新版。 |
| 框架本體（Framework checkout） | 已可用 | 提供 AI Governance 工具與規則來源；目前偵測到的導入型態是 submodule_consumer。 |
| 版本新鮮度（Framework version freshness） | 已可用 | 檢查本地 framework 是否追上本地已知 tracking ref；真正遠端最新證據由 updater 另外回報。 |
| 本 repo 規則（Repo governance instructions） | 已可用 | 讓 agent 進入這個 repo 時知道本 repo 的風險、測試與操作規則。 |
| 靜態治理檔案（Static framework files） | 已可用 | 提供不跑 runtime 也能讀到的治理文件、規則與導入狀態。 |
| runtime 治理能力（Runtime-capable governance） | 未驗證 | 代表 repo 是否具備可執行的 runtime governance；只有明確回報已可用時才算導入。 |
| 本機 commit/push 檢查（Git hooks） | 已可用 | 在本機 commit 或 push 前提示/檢查治理狀態；這不等於所有機器都已強制執行。 |
| 領域合約（Domain contract） | 已可用 | 用 contract.yaml 宣告這個 repo 自己的治理需求與驗證入口。 |
| 自動驗證層（Validator surface） | 未導入 | 列出 repo 專屬 validator，讓更新後能知道是否接上自動檢查。 |
| 記憶工作流（Memory workflow） | 未驗證 | 顯示 memory 寫入/檢查流程是否有被觀測；不代表記憶內容已完整同步。 |
技術細項：
- AI Governance framework checkout: present - 偵測到的導入型態是 submodule_consumer
- Framework version freshness: current_vs_local_tracking - 比較本地 framework 與本地已知 tracking ref；這不是遠端最新 head 的證明
- Repo governance instructions: 已可用 - AGENTS.md 包含 agent 應遵守的 repo 專屬治理規則
- Static framework files: yes - 檢查可見 framework 檔案是否足以提供靜態治理指引
- Runtime-capable governance: not_checked - 這份 summary 不證明 runtime execution 已可用
- Git hook framework root: inside_repo - 顯示本機 pre-commit/pre-push hooks 指向哪裡；hook 是本機狀態，不代表所有環境都強制執行
- Domain contract: 已可用 - contract.yaml 宣告 repo 專屬治理合約
- Validator surface: 未導入 - validator 是 contract 宣告的 repo 專屬自動檢查
- Memory workflow surface: not_checked - 這份 summary 不推論 memory 是否完整同步
尚未導入或尚未被證明：
- validator_surface: 需要後續處理，不能因此宣稱 full adoption
白話結論：
- AI Governance 是部分導入：核心表面已存在，但這個 repo 還不能宣稱完整導入。
不能從這份 summary 宣稱：
- domain correctness
- framework pin matches the true remote head
- full governance adoption
- hook or CI enforcement
- memory consolidation completeness
- release readiness
- runtime self-contained governance
- runtime smoke passed
[cannot_claim]
- domain correctness
- framework pin matches the true remote head
- full governance adoption
- hook or CI enforcement
- memory consolidation completeness
- release readiness
- runtime self-contained governance
- runtime smoke passed
[capability_states]
- topology: Detected (source=adoption_doctor.adoption_class)
  reason: topology=submodule_consumer
  reason: .gitmodules declares initialized framework path .ai-governance-framework
- static_runtime_surface: Verified (source=adoption_doctor.self_contained)
  reason: framework root is inside the target repo and required static runtime surfaces are present
  reason: this does not prove hooks installed, pin fresh, runtime smoke passed, all tests passed, or enforcement
- runtime_capable_static: Unproven (source=adoption_doctor.runtime_capable)
  reason: runtime smoke is out of scope for the static report-only doctor
- readiness.contract_files_complete: Verified (source=external_repo_readiness.checks.contract_files_complete)
  reason: contract_files_complete=true
- readiness.contract_resolved: Verified (source=external_repo_readiness.checks.contract_resolved)
  reason: contract_resolved=true
- readiness.framework_release_compatible: Verified (source=external_repo_readiness.checks.framework_release_compatible)
  reason: framework_release_compatible=true
- readiness.framework_source_canonical: Verified (source=external_repo_readiness.checks.framework_source_canonical)
  reason: framework_source_canonical=true
- readiness.framework_version_current: Verified (source=external_repo_readiness.checks.framework_version_current)
  reason: framework_version_current=true
- readiness.framework_version_known: Verified (source=external_repo_readiness.checks.framework_version_known)
  reason: framework_version_known=true
- readiness.git_repo_present: Verified (source=external_repo_readiness.checks.git_repo_present)
  reason: git_repo_present=true
- readiness.gitlab_adapter_scope_consistent: Verified (source=external_repo_readiness.checks.gitlab_adapter_scope_consistent)
  reason: gitlab_adapter_scope_consistent=true
- readiness.governance_baseline_present: Verified (source=external_repo_readiness.checks.governance_baseline_present)
  reason: governance_baseline_present=true
- readiness.governance_drift_clean: Verified (source=external_repo_readiness.checks.governance_drift_clean)
  reason: governance_drift_clean=true
- readiness.hooks_ready: Verified (source=external_repo_readiness.checks.hooks_ready)
  reason: hooks_ready=true
- readiness.plan_fresh_enough: Verified (source=external_repo_readiness.checks.plan_fresh_enough)
  reason: plan_fresh_enough=true
- readiness.plan_present: Verified (source=external_repo_readiness.checks.plan_present)
  reason: plan_present=true
- readiness.project_facts_drift_free: Verified (source=external_repo_readiness.checks.project_facts_drift_free)
  reason: project_facts_drift_free=true
- readiness.project_facts_intakeable: Verified (source=external_repo_readiness.checks.project_facts_intakeable)
  reason: project_facts_intakeable=true
- readiness.project_facts_present: Verified (source=external_repo_readiness.checks.project_facts_present)
  reason: project_facts_present=true
- readiness.project_facts_schema_complete: Verified (source=external_repo_readiness.checks.project_facts_schema_complete)
  reason: project_facts_schema_complete=true
- readiness.overall: Verified (source=external_repo_readiness.ready)
  reason: external repo readiness returned ready=true
- hook_installation: Verified (source=hook_install_validator.validate_hook_install)
  reason: hook_install_validator returned valid=true
- runtime_evidence: Verified (source=governance_maturity_summary.runtime_evidence_lookup)
  reason: latest attributable runtime smoke result by reported generated_at ok=true generated_at=2026-10-13T09:47:25Z: /workspace/scratch/1ae49dba32c3/DiceMercenaries/.governance/evidence/runtime-smoke.json
  reason: evidence_path=/workspace/scratch/1ae49dba32c3/DiceMercenaries/.governance/evidence/runtime-smoke.json
  reason: reported_repo_root=/workspace/scratch/1ae49dba32c3/DiceMercenaries
- external_runtime_execution: Not Applicable (source=governance_maturity_summary.external_runtime_execution)
  reason: external runtime execution applies only when the framework dependency and hook root are external
