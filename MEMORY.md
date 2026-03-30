---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (Bug修复 - 启动加载设置 + 动态坐标)
**技术栈**: Love2D (LÖVE 11.5) + Lua (LuaJIT)
**开发模式**: 单人独立开发
**GitHub**: https://github.com/gallifreycar/roguelike-combat-game

---

## 一、快速启动

```bash
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

---

## 二、最近修复的Bug

### 2026-03-30 Bug修复（第二轮）

**问题描述**：
- 设置保存后，下次启动语言不恢复（仍显示英文）
- 地图点击坐标偏差（DPI缩放/窗口大小变化导致）

**修复内容**：
1. **启动加载设置**：
   - `main.lua`: 添加 SettingsManager 初始化
   - 启动时加载保存的语言设置并应用到 I18n
   - 应用音量和全屏设置

2. **动态坐标系统**：
   - `scenes/map.lua`: 使用 `love.graphics.getWidth()/getHeight()` 计算坐标
   - `scenes/menu.lua`: 按钮和文本居中显示
   - `scenes/settings.lua`: UI 元素居中显示
   - 解决 DPI 缩放和窗口大小变化时的坐标偏差问题

**根因分析**：
- 语言问题：main.lua 未初始化 SettingsManager，启动时不读取存档
- 坐标问题：硬编码坐标不考虑窗口/DPI变化，导致点击偏差

### 2026-03-30 Bug修复（第一轮）

**问题描述**：
- 设置无法保存/加载
- 存档无法正常工作
- UI图标/emoji加载不出来
- 游戏崩溃：effects.lua duration nil error

**修复内容**：
1. **文件系统修复**：
   - `systems/settings_manager.lua`: 改用 `love.filesystem` 替代 `io` 文件操作
   - `systems/save.lua`: 改用 `love.filesystem` 替代 `io` 文件操作

2. **图标/Emoji修复**：
   - 替换所有emoji为ASCII等效文本
   - 原因：NotoSansSC字体不支持emoji字符

3. **effects.lua nil错误修复**：
   - `systems/effects.lua`: 修复 attack_flash, flash, shake 的 update 函数
   - 解决：使用硬编码的 duration 值替代 effect.duration

4. **ESC键退出游戏问题修复**：
   - `core/input.lua`: 移除全局 ESC -> love.event.quit() 处理
   - `scenes/menu.lua`: 添加 ESC -> quit（只有菜单应该退出）
   - `core/state.lua`: State.pop() 栈空时返回 menu 而不是 nil

**原因**：Love2D 沙盒环境限制 `io` 操作，必须使用 `love.filesystem` API

---

## 三、迭代进度（20次迭代计划）

全部20次迭代已完成 ✅

---

## 四、核心功能

### 游戏流程
菜单 → 地图选择 → 战斗 → 奖励 → 地图 → Boss → 胜利

### 系统模块
- **牌组系统**: 抽牌、弃牌、洗牌、手牌上限
- **印记系统**: 13种印记效果
- **特效系统**: 伤害数字、闪光
- **融合系统**: 卡牌升级
- **地图系统**: 8层肉鸽地图
- **存档系统**: 进度保存（使用love.filesystem）
- **成就系统**: 9种成就
- **音效系统**: 音效管理
- **教程系统**: 新手引导
- **敌人意图**: 意图显示
- **设置系统**: 音量、语言、全屏（使用love.filesystem）

### 数据
- **18张卡牌**: 从Squirrel到Hydra
- **13种印记**: air_strike, tough, undead, poison等
- **8关地图**: Forest Path到Hydra's Lair

---

## 五、文件结构

```
roguelike-game/
├── main.lua              # 入口
├── conf.lua              # Love2D配置
├── core/                 # 核心模块
├── scenes/               # 场景
├── systems/              # 系统
├── data/                 # 数据定义
├── ui/                   # UI组件
├── config/               # 配置
├── utils/                # 工具函数
└── assets/fonts/         # 字体文件
```

---

## 六、注意事项

1. **文件操作**: 必须使用 `love.filesystem` 而非 `io`
2. **字体文件**: 位于 `assets/fonts/NotoSansSC-Regular.ttf`
3. **存档位置**: Love2D默认存档目录 `~/Library/Application Support/LOVE/roguelike-game/`
4. **坐标计算**: 使用 `love.graphics.getWidth()/getHeight()` 动态计算，避免硬编码

---

**接手须知**:
- 文件操作必须用 `love.filesystem`
- 所有20次迭代已完成
- GitHub已推送所有代码和修复
- 启动时需加载 SettingsManager 并应用设置
- UI 坐标使用动态窗口尺寸计算