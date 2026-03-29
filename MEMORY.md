---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代05)
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

**印记系统** ✨新增：
- 不死(Undead)：死亡后复活一次
- 毒(Poison)：命中敌人后每回合-1HP
- 飞行(Air Strike)：空列直接攻击敌方HP
- 双击(Double Strike)：攻击两次
- 恶臭(Stinky)：降低对面敌人攻击力
- 坚韧(Tough)：+2最大HP

---

## 三、迭代进度（20次迭代计划）

### 迭代01 ✅ UI修复
### 迭代02 ✅ 项目结构重构
### 迭代03 ✅ 牌库系统接入
### 迭代04 ✅ 卡牌循环机制

### 迭代05 ✅ [已完成 2026-03-30]
**印记效果落地**

新增：
- systems/sigils.lua - 印记系统模块
- 支持13种印记效果定义
- 接入战斗场景：
  - 不死(Undead)：死亡复活
  - 毒(Poison)：回合结束伤害
  - 飞行(Air Strike)：空列攻击
  - 双击(Double Strike)：攻击两次
  - 恶臭(Stinky)：减攻击力

### 迭代06 [待开始]
攻击特效：伤害数字、闪光、动画

### 迭代07-20 [待规划]
奖励系统、卡牌融合、关卡地图、设置系统、存档、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 四、卡牌数据（18张 + 13印记）

**印记列表**：
- air_strike - 飞行
- tough - 坚韧
- undead - 不死
- poison - 毒
- stinky - 恶臭
- double_strike - 双击
- charge - 冲锋
- trample - 践踏
- sharp_quills - 尖刺
- bone_snake - 骨蛇
- hydra - 九头蛇
- guardian - 守护
- bifurcated - 分叉

---

## 五、文件结构

```
roguelike-game/
├── systems/
│   ├── deck.lua     # 牌组系统 ✅
│   ├── sigils.lua   # 印记系统 ✅ 新增
│   └── enemy.lua    # 敌人意图系统
└── ... (其他目录结构不变)
```

---

## 六、下一步任务

1. 迭代06：攻击特效（伤害数字、动画）
2. 迭代07：奖励系统
3. 迭代08：卡牌融合

---

**接手须知**:
- 印记系统已接入，核心印记效果可工作
- 可以在 data/cards.lua 中配置卡牌的印记
- 下一步添加战斗特效和奖励系统