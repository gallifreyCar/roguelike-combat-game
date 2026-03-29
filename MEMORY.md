---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代03)
**技术栈**: Love2D (LÖVE 11.5) + Lua (LuaJIT)
**开发模式**: 单人独立开发
**GitHub**: https://github.com/gallifreyCar/roguelike-combat-game

---

## 一、快速启动

```bash
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

---

## 二、核心玩法

**Blood 经济系统**：
- 每回合开始 Blood = 1
- 每回合 Blood +1（上限 6）
- 右键献祭场上卡牌 = +1 Blood

**操作**：
- 左键拖拽：放牌到格子
- 右键点击：献祭卡牌获得 Blood
- 点击 BATTLE：开始自动战斗

---

## 三、迭代进度（20次迭代计划）

### 迭代01 ✅ [已完成 2026-03-30]
**UI修复 - 按钮重叠、布局优化**

改动：
- 新增 UI 布局常量（UI_TITLE_HEIGHT, UI_PLAYER_BOARD_Y 等）
- 重构 draw() 函数，添加分隔线
- 敌方HP移到标题栏右侧
- 战斗按钮移到中央位置 (600, 435)
- HP/Blood 状态栏移到底部 (y=510)
- 操作提示移到最底部 (y=550)
- 按钮悬停高亮效果

### 迭代02 ✅ [已完成 2026-03-30]
**项目结构重构 - 模块化、易扩展**

新增目录：`ui/`、`utils/`、`config/`
新增模块：button.lua、card.lua、colors.lua、settings.lua、math.lua、table.lua

### 迭代03 ✅ [已完成 2026-03-30]
**牌库系统接入 - Deck模块整合**

改动：
- 重构 systems/deck.lua 适配 Blood Cards 机制
- Deck 模块方法：init(), draw_cards(), place_card(), sacrifice_card()
- combat.lua 接入 Deck 模块
- 使用 Settings 配置（布局、尺寸等）
- 移除 battle.hand，改用 Deck.get_hand()
- 开局抽3张牌（从牌组）

### 迭代04 [待开始]
卡牌循环机制：抽牌/弃牌/洗牌完善

### 迭代05 [待开始]
印记效果落地：poison/undead/hydra 等

### 迭代06-20 [待规划]
攻击特效、奖励系统、卡牌融合、关卡地图、设置系统、存档、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 四、卡牌数据（18张）

| 卡牌 | Cost | ATK | HP | 特点 |
|------|------|-----|-----|------|
| Squirrel | 0 | 0 | 1 | 免费，献祭材料 |
| Stoat | 1 | 1 | 2 | 基础攻击 |
| Wolf | 2 | 2 | 2 | 平衡型 |
| Bullfrog | 1 | 1 | 4 | 肉盾 |
| Raven | 2 | 2 | 3 | 远程 |
| Grizzly | 3 | 4 | 6 | 重击 |

---

## 五、文件结构

```
roguelike-game/
├── main.lua           # 入口
├── conf.lua           # Love2D配置
├── core/              # 核心模块
│   ├── state.lua      # 状态机
│   ├── fonts.lua      # 字体管理
│   └── input.lua      # 输入处理
├── scenes/            # 场景
│   ├── combat.lua     # 战斗场景（已接入Deck）
│   ├── menu.lua       # 主菜单
│   ├── victory.lua    # 胜利画面
│   └── death.lua      # 死亡画面
├── systems/           # 系统
│   ├── deck.lua       # 牌组系统 ✅已接入
│   └── enemy.lua      # 敌人意图系统
├── data/              # 数据定义
│   ├── cards.lua      # 卡牌定义（18张）
│   └── levels.lua     # 关卡配置（8关）
├── ui/                # UI组件
│   ├── button.lua     # 按钮组件
│   └── card.lua       # 卡牌渲染组件
├── config/            # 配置
│   ├── colors.lua     # 颜色配置
│   └── settings.lua   # 游戏设置
├── utils/             # 工具函数
│   ├── math.lua       # 数学工具
│   └── table.lua      # 表工具
└── assets/fonts/      # 字体文件
```

---

## 六、下一步任务

1. 迭代04：卡牌循环机制（抽牌堆/弃牌堆显示）
2. 迭代05：印记效果落地
3. 迭代06：攻击特效

---

**接手须知**:
- 牌库系统已接入，使用 Deck 模块管理手牌
- combat.lua 使用 Settings 配置
- 下一步完善卡牌循环和印记效果