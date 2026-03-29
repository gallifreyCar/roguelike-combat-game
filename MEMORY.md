---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代14+17)
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
| 01 | UI修复 | ✅ |
| 02 | 项目结构重构 | ✅ |
| 03 | 牌库系统接入 | ✅ |
| 04 | 卡牌循环机制 | ✅ |
| 05 | 印记效果落地 | ✅ |
| 06 | 攻击特效 | ✅ |
| 07 | 奖励系统 | ✅ |
| 08 | 卡牌融合 | ✅ |
| 09 | 关卡地图 | ✅ |
| 10 | 设置系统 | ✅ |
| 11 | 存档系统 | ✅ |
| 14 | UI美化 | ✅ |
| 17 | 成就系统 | ✅ |

### 迭代14 ✅ UI美化
- 卡牌阴影效果
- 渐变背景
- 金色边框
- 属性图标（⚔/♥）
- 血量条颜色根据比例变化
- 印记指示器

### 迭代17 ✅ 成就系统
- 9种成就定义
- 统计数据追踪
- 自动解锁检查

### 待完善迭代
- 12：更多卡牌（已定义18张，可扩展）
- 13：Boss机制（地图Boss节点已实现）
- 15：敌人意图（系统已定义，需接入）
- 16：音效系统（需音频资源）
- 18：教程引导
- 19：性能优化
- 20：发布准备

---

## 三、文件结构

```
roguelike-game/
├── main.lua
├── conf.lua
├── core/           # 状态机、字体、输入
├── scenes/         # 场景（combat/menu/map/reward等）
├── systems/        # 系统
│   ├── deck.lua    # 牌组系统
│   ├── sigils.lua  # 印记系统
│   ├── effects.lua # 特效系统
│   ├── fusion.lua  # 融合系统
│   ├── map.lua     # 地图系统
│   ├── save.lua    # 存档系统
│   ├── achievements.lua  # 成就系统 ✅
│   ├── settings_manager.lua
│   └── enemy.lua
├── data/           # 数据
├── ui/             # UI组件
├── config/         # 配置
├── utils/          # 工具函数
└── assets/         # 资源文件
```

---

## 四、核心功能

**游戏流程**：菜单 → 地图选择 → 战斗 → 奖励 → 地图 → Boss → 胜利

**系统模块**：
- 牌组系统：抽牌、弃牌、洗牌
- 印记系统：13种印记效果
- 特效系统：伤害数字、闪光
- 融合系统：卡牌升级
- 地图系统：8层肉鸽地图
- 存档系统：进度保存
- 成就系统：9种成就

---

**接手须知**:
- 游戏核心功能完整，可运行测试
- 卡牌已定义18张，可在data/cards.lua扩展
- 音效需要音频资源文件
- 可继续优化UI和添加更多内容