---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代11)
**技术栈**: Love2D (LÖVE 11.5) + Lua (LuaJIT)
**开发模式**: 单人独立开发
**GitHub**: https://github.com/gallifreyCar/roguelike-combat-game

---

## 一、快速启动

```bash
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

---

## 二、迭代进度（20次迭代计划）

### 已完成迭代
| 迭代 | 内容 | 状态 |
|------|------|------|
| 01-10 | UI/结构/牌库/循环/印记/特效/奖励/融合/地图/设置 | ✅ |
| 11 | 存档系统 | ✅ |

### 迭代11 ✅ [已完成 2026-03-30]
**存档系统**

新增：
- systems/save.lua - 存档管理
- 保存玩家数据、牌组、地图进度
- 加载存档功能
- 存档检测和删除
- 统计数据追踪

### 待完成迭代（12-20）
更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 三、文件结构

```
systems/
├── save.lua     # 存档系统 ✅ 新增
└── ...
```

---

**接手须知**:
- 存档系统基础功能已完成
- 可在关键节点调用Save.save()保存进度
- 存档文件保存在 save/game_save.json