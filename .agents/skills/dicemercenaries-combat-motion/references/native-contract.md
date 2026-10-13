# Godot 接點快照

每次現場核對實際程式；下面是 DM-02 候選的接點。

| 接點 | 責任 |
| --- | --- |
| scripts/domain/shot_rules.gd | 發射參數、拋物線與每發直接／撞牆傷害限制 |
| scripts/domain/terrain_rules.gd | 模組命中及給定落差／深坑類型的傷害 |
| scripts/combat/projectile_body.gd | swept ray、shot_id、真實碰撞 |
| scripts/combat/target_body.gd | CharacterBody2D 擊退、落地／深坑、HP及腳底基準 |
| scripts/combat/breakable_terrain.gd | broken state、安全物理時點停用collider、無碰撞碎片 |
| scripts/presentation/physics_lab.gd | 瞄準、預覽、可操作phase |
| scripts/presentation/terrain_lab.gd | 三案例、危險、降低效果、重置 |

target.resolved 目前包含 target_id／kind／amount，不是跨存檔 receipt 系統。勿虛構事件類別。碎片240ms、命中環280ms是候選裝飾值，非競品數值或永久規則。broken立即採納，set_deferred在安全物理時點停用碰撞，不等碎片完播。

目前只有灰盒效果，body／prop／cloth rig尚未製作，不能宣稱人物動畫完成。來源照片、Canvas模擬及程式測試不是Godot runtime影片。

Player 的發射原點目前固定在 position + Vector2(26, -7)，朝向來自移動，不隨瞄準翻轉。左右手持武器的 muzzle 對齊會涉及發射原點與預覽規則，須另外授權行為變更；不能當作純視覺修正。Player 尚無 HP／擊退流程；Target 的接點不可冒稱 Player 已支援。
