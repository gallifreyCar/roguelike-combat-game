---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代04)
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

**卡牌循环**：
- 牌组 → 抽牌堆 → 手牌 → 棋盘 → (死亡/存活)
- 手牌上限：8张
- 抽牌堆空时自动洗弃牌堆

**操作**：
- 左键拖拽：放牌到格子
- 右键点击：献祭卡牌获得 Blood
- 点击 BATTLE：开始自动战斗

---

## 三、迭代进度（20次迭代计划）

### 迭代01 ✅ UI修复
布局优化、按钮位置、分隔线

### 迭代02 ✅ 项目结构重构
新增 ui/、utils/、config/ 目录

### 迭代03 ✅ 牌库系统接入
Deck模块整合到combat.lua

### 迭代04 ✅ [已完成 2026-03-30]
**卡牌循环机制**

改动：
- 状态栏显示牌组信息（抽牌堆/弃牌堆数量）
- 手牌上限：8张
- Deck.draw_cards() 检查手牌上限
- 添加 Deck.recycle_card() 方法（回收卡牌到弃牌堆）

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
├── core/              # 核心模块（state/fonts/input）
├── scenes/            # 场景（combat/menu/victory/death）
├── systems/           # 系统
│   ├── deck.lua       # 牌组系统 ✅
│   └── enemy.lua      # 敌人意图系统
├── data/              # 数据定义（cards/levels）
├── ui/                # UI组件（button/card）
├── config/            # 配置（colors/settings）
├── utils/             # 工具函数（math/table）
└── assets/fonts/      # 字体文件
```

---

## 六、下一步任务

1. 迭代05：印记效果落地
2. 迭代06：攻击特效
3. 迭代07：奖励系统

---

**接手须知**:
- 牌库循环完整：抽牌堆 → 手牌 → 弃牌堆
- 手牌上限8张，可在config/settings.lua调整
- 下一步实现印记效果和攻击特效