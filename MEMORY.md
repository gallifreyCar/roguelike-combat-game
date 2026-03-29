---
name: roguelike-game-context
description: "邪恶冥刻风格自动战斗肉鸽游戏项目长期记忆——启动方法、设计文档、开发计划"
type: project
---

# Card Sacrifice — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30
**技术栈**: Love2D (LÖVE 11.5) + Lua (LuaJIT)
**开发模式**: 单人独立开发
**GitHub**: https://github.com/gallifreyCar/roguelike-combat-game

---

## 一、快速启动

### 方法1：终端命令（推荐）

```bash
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

### 方法2：创建快捷命令

```bash
# 添加别名到 shell 配置
echo 'alias cardgame="/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game"' >> ~/.zshrc
source ~/.zshrc

# 之后直接输入
cardgame
```

### 方法3：双击启动

1. 打开 Finder
2. 进入 `/Users/gallifreycar/Documents/roguelike-game`
3. 选中所有文件，拖到 `/Applications/love.app` 图标上

### 方法4：打包成 .love 文件

```bash
cd /Users/gallifreycar/Documents/roguelike-game
zip -r ../CardSacrifice.love .
# 双击 CardSacrifice.love 即可运行
```

---

## 二、项目设计

### 2.1 核心玩法

**邪恶冥刻风格自动战斗卡牌肉鸽**

```
┌─────────────────────────────────────────────────────┐
│  阶段1: 放置                                         │
│  ├─ 从手牌选择卡牌 (Q/W/E/R/T)                      │
│  ├─ 放置到4格棋盘 (1-4)                             │
│  └─ 高费卡需要"血"资源（献祭死掉的卡获得）          │
├─────────────────────────────────────────────────────┤
│  阶段2: 战斗                                         │
│  ├─ 按 SPACE 开始自动战斗                           │
│  ├─ 卡牌自动攻击对应列敌人                          │
│  ├─ 列无敌人则直接攻击敌方玩家                      │
│  └─ 卡牌有HP，可以死亡                              │
├─────────────────────────────────────────────────────┤
│  循环: 放置 → 战斗 → 放置 → 战斗...                  │
│  胜利: 敌方HP归零                                   │
│  失败: 玩家HP归零                                   │
└─────────────────────────────────────────────────────┘
```

### 2.2 核心机制

| 机制 | 说明 |
|------|------|
| **卡牌放置** | 4格棋盘，每格放一张卡 |
| **自动战斗** | 卡牌自动攻击，无需手动操作 |
| **卡牌HP** | 卡牌有血量，归零则死亡 |
| **献祭系统** | 卡牌死亡获得 +1 Blood，用于放置高费卡 |
| **意图显示** | 敌方卡牌显示 ATK/DEF 意图 |

### 2.3 卡牌设计

```lua
Card = {
    id = "wolf",
    name = "Wolf",
    cost = 2,        -- 放置需要的 Blood
    attack = 2,      -- 每回合造成的伤害
    hp = 2,          -- 当前血量
    max_hp = 2,      -- 最大血量
    sigils = {},     -- 特殊能力/印记
    rarity = "common", -- 稀有度
}
```

**当前卡牌**:

| 卡牌 | Cost | Attack | HP | 特点 |
|------|------|--------|-----|------|
| Squirrel | 0 | 0 | 1 | 免费放置 |
| Stoat | 1 | 1 | 2 | 基础卡 |
| Wolf | 2 | 2 | 2 | 平衡型 |
| Bullfrog | 1 | 1 | 4 | 肉盾 |
| Raven | 2 | 2 | 3 | Air Strike印记 |
| Grizzly | 3 | 4 | 6 | 重击手 |
| Death Card | 3 | 3 | 3 | 传说卡，复活印记 |

### 2.4 架构设计

```
roguelike-game/
├── main.lua              # 入口：初始化 + 游戏循环
├── conf.lua              # LÖVE 配置（窗口、分辨率）
├── core/
│   ├── state.lua         # 状态机（场景切换）
│   └── input.lua         # 输入处理
├── scenes/
│   ├── menu.lua          # 主菜单
│   ├── combat.lua        # 战斗场景（核心）
│   ├── victory.lua       # 胜利界面
│   └── death.lua         # 失败界面
├── systems/
│   └── enemy.lua         # 敌人AI
├── data/
│   └── cards.lua         # 卡牌定义
├── assets/
│   ├── sprites/          # 图片资源
│   ├── fonts/            # 字体
│   └── sounds/           # 音效
└── MEMORY.md             # 本文档
```

### 2.5 状态机

```
┌─────┐     ┌───────┐     ┌─────────┐
│Menu │ →→ │Combat │ →→ │Victory  │
└─────┘     └───────┘     └─────────┘
    ↑           │              │
    │           ↓              │
    │       ┌──────┐           │
    └────── │Death │ ←─────────┘
            └──────┘
```

---

## 三、开发计划

### Phase 1: 核心战斗 ✅ (已完成)

- [x] 4格棋盘放置系统
- [x] 自动战斗逻辑
- [x] 卡牌HP系统
- [x] 献祭/Blood资源
- [x] 敌人AI
- [x] 胜利/失败判定

### Phase 2: 内容扩展 (下一步)

- [ ] 更多卡牌（10-20张）
- [ ] 印记系统实现
  - [ ] Air Strike（越过前排）
  - [ ] Tough（额外生命）
  - [ ] Undead（复活）
  - [ ] Bifurcated（双列攻击）
- [ ] 更多敌人类型
- [ ] Boss战

### Phase 3: 肉鸽循环

- [ ] 地图/层级系统
- [ ] 奖励选择（卡牌奖励）
- [ ] 商店系统
- [ ] 种子系统（可复现随机）
- [ ] 存档系统

### Phase 4: 视觉打磨

- [ ] 卡牌美术
- [ ] UI动画
- [ ] 音效
- [ ] 背景音乐
- [ ] 粒子效果

### Phase 5: 发布

- [ ] 打包 .love 文件
- [ ] Steam上架准备
- [ ] itch.io发布

---

## 四、开发指南

### 4.1 添加新卡牌

编辑 `data/cards.lua`:

```lua
new_card = {
    id = "new_card",
    name = "New Card",
    cost = 2,
    attack = 3,
    hp = 4,
    sigils = {"air_strike"},
    rarity = "uncommon",
},
```

### 4.2 添加新印记

在 `data/cards.lua` 的 Sigils 表添加:

```lua
new_sigil = {
    name = "New Sigil",
    desc = "Description of effect",
},
```

然后在 `scenes/combat.lua` 的战斗逻辑中实现效果。

### 4.3 修改战斗参数

在 `scenes/combat.lua` 顶部:

```lua
local BOARD_SLOTS = 4        -- 棋盘格子数
local PLAYER_MAX_HP = 10     -- 玩家初始HP
```

### 4.4 调试技巧

```lua
-- 在代码中打印调试信息
print("Debug: " .. variable)

-- LÖVE 控制台会显示输出
-- macOS: 终端运行 love 命令可见
```

### 4.5 热重载

修改 `.lua` 文件后，重启游戏即可生效。无需重新编译。

---

## 五、技术细节

### 5.1 战斗流程

```
玩家回合开始
    ↓
选择手牌 (Q/W/E/R/T)
    ↓
选择格子放置 (1-4)
    │
    ├─ 格子空 → 放置成功
    │   └─ 检查 Blood 是否足够
    │
    └─ 格子有卡 → 提示"已被占用"
    ↓
按 SPACE 开始战斗
    ↓
玩家卡牌攻击（从左到右）
    │
    ├─ 对应列有敌方卡牌 → 攻击敌方卡牌
    └─ 对应列为空 → 攻击敌方玩家
    ↓
敌方卡牌攻击（从左到右）
    │
    ├─ 对应列有玩家卡牌 → 攻击玩家卡牌
    └─ 对应列为空 → 攻击玩家
    ↓
清理死亡卡牌
    │
    └─ 玩家卡牌死亡 → +1 Blood
    ↓
检查胜负
    │
    ├─ 敌方HP ≤ 0 → 胜利
    ├─ 玩家HP ≤ 0 → 失败
    └─ 都没死 → 下一回合
    ↓
回合+1，抽新牌，敌人放新卡
```

### 5.2 渲染层级

```
背景层 (clear)
    ↓
敌方区域 (HP条 + 卡牌格子)
    ↓
玩家区域 (HP条 + Blood + 卡牌格子)
    ↓
手牌
    ↓
状态文本 (回合数、消息)
```

### 5.3 Git 工作流

```bash
# 查看状态
git status

# 添加所有修改
git add -A

# 提交
git commit -m "描述修改内容"

# 推送到 GitHub
git push

# 查看历史
git log --oneline
```

---

## 六、已知问题

| 问题 | 状态 | 解决方案 |
|------|------|---------|
| 无卡牌美术 | 🔴 待处理 | 需要设计或使用占位图 |
| 无音效 | 🔴 待处理 | 需要添加音频文件 |
| 无肉鸽循环 | 🔴 待处理 | Phase 3 开发 |
| 印记未实现 | 🟡 部分完成 | 需要在战斗逻辑中实现 |

---

## 七、参考资源

### 技术文档
- [LÖVE Wiki](https://love2d.org/wiki/Main_Page)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)

### 游戏设计参考
- [Inscryption](https://www.inscryption.com/) - 核心玩法
- [Slay the Spire](https://www.megacrit.com/) - 肉鸽结构
- [Library of Ruina](https://store.steampowered.com/app/1256670/Library_of_Ruina/) - 卡牌战斗

---

**接手须知**:
1. 先读取本文档了解项目状态
2. 使用 `/Applications/love.app/Contents/MacOS/love .` 启动测试
3. 核心代码在 `scenes/combat.lua`
4. 卡牌数据在 `data/cards.lua`
5. 当前处于 Phase 1 完成，准备进入 Phase 2