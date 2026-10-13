---
name: dicemercenaries-character-art
description: Generate or refine consistent side-view fantasy character and terrain art candidates for DiceMercenaries with individual references, transparency, measured anchors and native-size review. Use for image generation, poses, cutout backing or art briefs; not gameplay, collision changes or release approval.
---

# DiceMercenaries 角色與場景美術

先讀當次要求、PLAN.md、docs/GAME_PLAN.md 與目前切片，查看實際 Godot 畫面、素材、branch／commit／dirty state。依要求交付提案、生成候選或已授權的整合。讀 [風格與定位](references/style.md)、[提示模板](references/prompt-template.md)；追溯方法時讀 [來源與界線](references/sources.md)。

## 固定身分與側視用途

- 先檢視個別角色 PNG 並核對來源及 SHA-256。新角色標為 STYLE reference 並要求不同臉孔；既有角色姿勢／拆層使用 IDENTITY reference，鎖定臉、髮、服裝、道具手與解剖。
- 沒有核准 master 時，可依已授權要求提出或生成新候選；不得虛構角色、素材可用性或 Owner 核准。只要求 brief 時交付 brief，不自行生成圖片。
- 使用 2D 側視／輕微三分之四的橫向戰場視角。俯視棋盤、拼圖及剪影 QA 頁不是身分 seed。勿把 TacticalGo 或 KCK 人物、底座及核准搬入本專案。
- 戰場角色、肖像、頭像各自檢查。灰盒角色約 44–48 logical px 高，另做 32／48／64 px 診斷；有新 renderer 時重新量測，不把此快照固定成永久規格。
- 測量 painted bounds、腳底接觸 anchor、道具尖端及發射口；透明邊界不是腳底。碰撞形狀和 projectile origin 由遊戲程式決定，美術不得自行改射程、擊退或命中規則。

## 生成與保存

使用 image generation 工具產生／修改 bitmap。隔離角色請求真正透明背景，不帶地板、烘焙陰影、陣營底座或額外人物。保留版本化原圖、完整 prompt、reference role／hash、尺寸、原始檔與 decoded RGBA hash；未知工具版本記 unknown。

勿覆寫核准 master。分開記錄 approval、availability、rights、qa；生成和 alpha／尺寸檢查不代表正式整合核准。完成所要求的小批次；具體缺陷做針對性修正，沒有改善就保留最佳候選與缺口。

以明／暗戰場、灰階、剪影及實際尺寸核對職業道具、朝向、地面接觸與輪廓。團隊訊息使用外部形狀／文字，避免重畫臉或衣服；效果不得蓋掉危險、可破壞提示及彈道。

需要角色演出時使用 `$dicemercenaries-combat-motion`。交付原圖、尺寸檢查、來源及可觀察缺陷；分開報告工程、視覺比較與玩家接受，不從生成姿勢推論動畫完成。
