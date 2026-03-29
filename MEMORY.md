---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代08)
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

**Blood 经济**：每回合 Blood +1（上限6），献祭得 Blood
**战斗流程**：放牌 → 战斗 → 奖励 → 下一关
**卡牌融合** ✨：两张相同卡牌融合升级（ATK+1, HP+2, 可能获得新印记）

---

## 三、迭代进度（20次迭代计划）

### 已完成迭代
| 迭代 | 内容 | 状态 |
|------|------|------|
| 01-07 | UI/结构/牌库/循环/印记/特效/奖励 | ✅ |
| 08 | 卡牌融合系统 | ✅ |

### 迭代08 ✅ [已完成 2026-03-30]
**卡牌融合系统**

新增：
- systems/fusion.lua - 融合逻辑
- scenes/fusion.lua - 融合场景
- 融合规则：ATK+1, HP+2, 30%几率获得新印记
- 可查找牌组中可融合的卡牌对
- 注册fusion场景到状态机

### 待完成迭代（09-20）
关卡地图、设置系统、存档、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 四、文件结构

```
systems/
├── deck.lua     # 牌组系统
├── sigils.lua   # 印记系统
├── effects.lua  # 特效系统
├── fusion.lua   # 融合系统 ✅ 新增
└── enemy.lua    # 敌人意图

scenes/
├── fusion.lua   # 融合场景 ✅ 新增
└── ...
```

---

**接手须知**:
- 融合系统基础框架已完成
- 融合场景可在菜单或奖励后访问
- 下一步实现关卡地图或设置系统