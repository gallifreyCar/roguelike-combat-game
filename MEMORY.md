---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代10)
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

### 迭代10 ✅ [已完成 2026-03-30]
**设置系统**

新增：
- systems/settings_manager.lua - 设置持久化管理
- scenes/settings.lua - 设置场景
- 音量控制（主音量、音乐、音效）
- 全屏切换
- 语言选择（en/zh）
- 教程开关
- 设置持久化到文件

### 待完成迭代（11-20）
存档系统、更多卡牌、Boss机制、UI美化、敌人意图、音效、成就、教程、性能优化、发布准备

---

## 三、文件结构

```
systems/
├── settings_manager.lua  # 设置管理 ✅ 新增
└── ...

scenes/
├── settings.lua          # 设置场景 ✅ 新增
└── ...
```

---

**接手须知**:
- 游戏功能基本完整：菜单→地图→战斗→奖励→循环
- 设置可持久化到 save/settings.json
- 下一步实现存档系统或Boss机制