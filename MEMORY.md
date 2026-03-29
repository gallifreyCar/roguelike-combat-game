---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代07)
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

**Blood 经济系统**：每回合 Blood +1（上限6），献祭得 Blood

**战斗流程**：
1. 从手牌放牌到棋盘
2. 点击 BATTLE 自动战斗
3. 胜利 → 奖励选择 → 下一关

**奖励系统** ✨新增：
- 战斗胜利后选择1张卡牌加入牌组
- 3张随机卡牌选项
- 按稀有度权重生成
- 可跳过奖励

---

## 三、迭代进度（20次迭代计划）

### 已完成迭代
| 迭代 | 内容 | 状态 |
|------|------|------|
| 01 | UI修复 | ✅ |
| 02 | 项目结构重构 | ✅ |
| 03 | 牌库系统接入 | ✅ |
| 04 | 卡牌循环机制 | ✅ |
| 05 | 印记效果落地 | ✅ |
| 06 | 攻击特效 | ✅ |
| 07 | 奖励系统 | ✅ |

### 迭代07 ✅ [已完成 2026-03-30]
**奖励系统**

改动：
- 重构 scenes/reward.lua
- 3张卡牌奖励选项
- 稀有度权重生成（common 50%, uncommon 35%, rare 12%, legendary 3%）
- 选择后添加到牌组
- 战斗胜利后进入奖励场景
- combat.lua 添加 resume() 处理下一关

### 待完成迭代（08-20）
卡牌融合、关卡地图、设置系统、存档、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 四、下一步任务

1. 迭代08：卡牌融合
2. 迭代09：关卡地图
3. 迭代10：设置系统

---

**接手须知**:
- 奖励系统完整：战斗胜利 → 选择卡牌 → 加入牌组 → 下一关
- 稀有度权重可在 reward.lua 中调整
- 下一步实现卡牌融合或关卡地图