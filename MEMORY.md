---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代09)
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

**游戏流程**：菜单 → 地图选择 → 战斗 → 奖励 → 地图 → ...

**关卡地图** ✨新增：
- 8层地图，每层3-4个节点
- 节点类型：战斗、精英、奖励、商店、事件、Boss
- 分支路线选择
- 最后一层Boss战

---

## 三、迭代进度（20次迭代计划）

### 已完成迭代
| 迭代 | 内容 | 状态 |
|------|------|------|
| 01-08 | UI/结构/牌库/循环/印记/特效/奖励/融合 | ✅ |
| 09 | 关卡地图系统 | ✅ |

### 迭代09 ✅ [已完成 2026-03-30]
**关卡地图系统**

新增：
- systems/map.lua - 地图生成与导航
- scenes/map.lua - 地图选择场景
- 节点类型：battle(50%), elite(15%), reward(15%), shop(10%), event(10%), boss
- 8层地图，每层随机节点
- 菜单开始游戏进入地图

### 待完成迭代（10-20）
设置系统、存档、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 四、文件结构

```
systems/
├── map.lua      # 地图系统 ✅ 新增
└── ...

scenes/
├── map.lua      # 地图场景 ✅ 新增
└── ...
```

---

**接手须知**:
- 游戏流程完整：菜单 → 地图 → 战斗 → 奖励 → 地图
- 地图系统支持肉鸽风格路线选择
- 下一步实现设置系统或存档