---
name: dicemercenaries-combat-motion
description: Design and implement readable DiceMercenaries character cutout animation, projectile/contact/terrain-break/landing feedback and coordinated UI or audio comparisons in Godot. Use for animation, game feel, VFX or performance briefs; keep physics, damage and state authority outside decorative timelines.
---

# DiceMercenaries 戰鬥演出

讀當次要求、PLAN.md、docs/GAME_PLAN.md、目前切片及實際 Godot renderer；記錄 branch／commit／dirty state，保存同場景基線。區分提案、素材、比較工具及原生整合，按授權完成可逆改進。讀 [原生事件與分層](references/native-contract.md)、[比較與交付](references/review.md)，素材工作使用 `$dicemercenaries-character-art`；來源見 [sources.md](references/sources.md)。

## 共用介面

先讀 [全戰場介面](references/game-ui.md)。將瞄準、生命值、危險、案例切換及結果放在同一資訊層級；實際 Godot 小視窗、縮放文字與降低動態分開驗證。不要為排版添加不存在的技能或費用，也不要將 TacticalGo UI20 核准移轉。

## 讓動作可讀

使用「輸入／瞄準 → 預備 → 發射 → 真實接觸 → 擊退或破壞 → 落地 → 可操作」語法。出手、道具、接觸及落定分開；碎片及全身彈跳不能代替身體演技。

原畫分層保留頭／身體、握手＋道具、布料及必要背板；握手與武器共用經檢查的 transform hierarchy 和 pivot。未見的身體明列假設；新 bitmap／補畫使用 image generation 工具，保存 prompt、reference 及 hash。原畫可在 renderer 遮罩分層，不任意重畫身分。沒有可用人物時完成節奏 brief 或灰盒回饋，不冒稱 rig 完成。

CharacterBody2D／碰撞器保持真實位置，裝飾 Sprite2D／rig 位於其子層；腳底及發射口符合現行合約。先比較 rest／預備／release 的實際尺寸，再加稀疏效果；32／48／64 px 診斷之外仍須量測 runtime。

## 物理權威與生命週期

- 發射只由確認輸入及 shot_id 建立一次。預覽／取消沒有成功命中、破壞、傷害效果。
- 接觸、HP、擊退、collider 移除、落地及深坑結果由 Combat／Domain 決定，以真實事件啟動裝飾；Tween／音訊／碎片回呼不能追加傷害、恢復碰撞或決定勝負。
- 不直接套 TacticalGo 的固定格點 receipt：本作還在物理解算，最終位置只能由實際接觸／穩定狀態讀取。不能用演出曲線搬動正式角色，不能把彈道預覽當成確定終態。
- 分開物理解算、可操作條件、短裝飾及音訊尾韻。目前按 projectile 結束與 target 穩定解鎖；改鎖定／發射時機屬遊戲行為，不能包成純視覺修正。聲音尾韻不得自行延長輸入鎖。
- 重置、案例切換、離場及過期 shot_id 使舊裝飾失效。降低動態取消閃光、碎片、鏡頭晃動及裝飾縮放，保留方向、HP、危險、破壞終態及同一物理結果；不能加速／跳過物理以製造靜態版本。

先實作一個已授權序列，不同輪重做全部角色、UI、音樂及規則。聲音只在素材／生成來源存在且在範圍內時接入；播放／混音量測和聽感分開。缺少人物或聲音時明列，不用更多粒子掩蓋。

交付正常速度全戰場影片、同輸入正常／降低動態終態、來源及新鮮相關測試。分開工程、視覺改善、玩家理解與 Owner 接受，不從測試數／像素移動／對標推論市場水準。
