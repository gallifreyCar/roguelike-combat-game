# Assets 目录结构

此目录存放游戏资源文件。

## 目录说明

### /cards
存放卡牌主图，命名规则：`[card_id].png`

当前需要的卡牌图片：
- squirrel.png - 松鼠
- stoat.png - 白鼬
- bullfrog.png - 牛蛙
- rat.png - 老鼠
- turtle.png - 乌龟
- wolf.png - 狼
- raven.png - 渡鸦
- adder.png - 毒蛇
- skunk.png - 臭鼬
- cat.png - 猫
- grizzly.png - 灰熊
- moose.png - 驼鹿
- mantis.png - 螳螂
- ox.png - 牛
- eagle.png - 鹰
- insight.png - 洞察
- combo_wolf.png - 连击狼
- death_raven.png - 亡语蝙蝠
- hunter.png - 猎杀者
- burst_cat.png - 爆发猫
- deathcard.png - 死亡卡牌
- hydra.png - 九头蛇
- guardian_dog.png - 守护犬

### /sigils
存放印记图标，命名规则：`[sigil_id].png`

当前需要的印记图标：
- air_strike.png - 飞行
- tough.png - 坚韧
- undead.png - 复活
- poison.png - 毒
- stinky.png - 恶臭
- guardian.png - 守护
- charge.png - 冲锋
- double_strike.png - 双击
- trample.png - 践踏
- sharp_quills.png - 尖刺
- bone_snake.png - 骨蛇
- hydra.png - 分裂
- draw.png - 过牌
- combo.png - 连击
- death_draw.png - 亡语抽牌
- kill_bonus.png - 击杀增益
- turn_blood.png - 回合血量

### /frames
存放卡框（按稀有度），命名规则：`[rarity]_frame.png`

- common_frame.png - 普通卡框
- uncommon_frame.png - 稀有卡框
- rare_frame.png - 史诗卡框
- legendary_frame.png - 传说卡框

### /ui
存放UI元素

- blood_icon.png - 血滴图标
- bone_icon.png - 骨头图标
- attack_icon.png - 攻击图标
- hp_icon.png - 生命图标

## 图片规格

| 类型 | 基础尺寸 | @2x尺寸 | 格式 |
|------|---------|---------|------|
| 卡牌主图 | 100x130 | 200x260 | PNG |
| 印记图标 | 16x16 | 32x32 | PNG |
| 卡框 | 100x130 | 200x260 | PNG |
| UI图标 | 24x24 | 48x48 | PNG |

## 注意事项

1. 所有图片使用PNG格式，支持透明背景
2. 推荐@2x尺寸以保证高清显示
3. 卡牌主图建议使用暗色调风格
4. 印记图标需要清晰可辨认