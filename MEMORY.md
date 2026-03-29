---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30
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

## 三、卡牌数据

| 卡牌 | Cost | ATK | HP | 特点 |
|------|------|-----|-----|------|
| Squirrel | 0 | 0 | 1 | 免费，献祭材料 |
| Stoat | 1 | 1 | 2 | 基础攻击 |
| Wolf | 2 | 2 | 2 | 平衡型 |
| Bullfrog | 1 | 1 | 4 | 肉盾 |
| Raven | 2 | 2 | 3 | 远程 |
| Grizzly | 3 | 4 | 6 | 重击 |

---

## 四、开发路线

### Phase 1: 核心战斗 ✅
- [x] 4格棋盘
- [x] 拖拽放牌
- [x] 献祭系统
- [x] 自动战斗
- [x] Blood 经济

### Phase 2: 内容扩展 (进行中)
- [ ] 更多卡牌（10-15张）
- [ ] 更多敌人配置
- [ ] 难度递增

### Phase 3: 肉鸽循环
- [ ] 关卡选择
- [ ] 奖励系统
- [ ] 牌组构建

---

## 五、文件结构

```
scenes/combat.lua  # 核心战斗逻辑
data/cards.lua     # 卡牌定义
core/state.lua     # 状态机
```

---

**接手须知**: 核心玩法已验证，下一步扩展卡牌和关卡。