---
name: roguelike-game-context
description: "回合制战斗肉鸽游戏项目长期记忆——技术栈、架构、进度、下一步任务"
type: project
---

# Roguelike Combat Game — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30
**技术栈**: Love2D (LÖVE) + Lua (LuaJIT)
**开发模式**: 单人独立开发

## 一、项目背景

**目标**: 开发一款回合制战斗肉鸽游戏，参考《杀戮尖塔》玩法机制，使用 Balatro 同款技术栈（Love2D + Lua）。

**核心玩法**:
- 卡牌战斗系统（能量 → 出牌 → 效果 → 弃牌）
- 回合制敌人 AI（意图显示）
- 肉鸽循环（层级推进、奖励选择、种子系统）

**参考游戏**:
- 《杀戮尖塔》— 回合制卡牌战斗肉鸽标杆
- 《Balatro》— Love2D + Lua 技术栈参考

## 二、技术栈

| 层面 | 方案 |
|------|------|
| **引擎** | LÖVE 11.5 (Mysterious Mysteries) ✅ 已安装 |
| **语言** | LuaJIT (Love2D 内置) |
| **渲染** | Love2D graphics API |
| **存档** | love.filesystem + JSON |
| **随机** | 种子系统 |

## 三、架构设计

```
roguelike-game/
├── main.lua          # 入口
├── conf.lua          # Love2D 配置
├── core/
│   ├── state.lua     # 状态机
│   └── input.lua     # 输入处理
├── scenes/
│   ├── menu.lua      # 主菜单
│   ├── combat.lua    # 战斗场景
│   └── death.lua     # 死亡结算
├── systems/
│   ├── deck.lua      # 牌组管理
│   └── enemy.lua     # 敌人 AI
└── MEMORY.md         # 项目长期记忆
```

**核心模块**:

| 模块 | 责任 | 状态 |
|------|------|------|
| StateManager | 游戏状态机：菜单→战斗→奖励→死亡 | ✅ 基础实现 |
| DeckManager | 卡牌 CRUD、抽牌堆、弃牌堆、手牌 | ✅ 基础实现 |
| CombatSystem | 回合流程、伤害计算、效果触发 | ⚠️ 框架完成，待完善 |
| EnemyAI | 敌人行为决策、意图显示 | ✅ 基础实现 |

## 四、当前进度

**Phase 1: MVP 骨架 (进行中)**

已完成:
- [x] 项目目录结构
- [x] main.lua 入口文件
- [x] conf.lua 配置
- [x] core/state.lua 状态机
- [x] core/input.lua 输入处理
- [x] scenes/menu.lua 主菜单
- [x] scenes/combat.lua 战斗场景（基础框架）
- [x] scenes/death.lua 死亡场景
- [x] systems/deck.lua 牌组系统（基础）
- [x] systems/enemy.lua 敌人系统（基础）
- [x] **Love2D 11.5 安装成功**（通过代理 127.0.0.1:7897 下载）
- [x] 项目能启动运行

**当前问题**:
- ⚠️ **主菜单报错**：启动后界面有报错信息，需要调试修复

待完成:
- [ ] 修复主菜单报错
- [ ] 验证完整战斗流程
- [ ] scenes/reward.lua 奖励场景
- [ ] systems/effect.lua 效果系统（完整）
- [ ] data/cards.lua 卡牌数据扩展
- [ ] UI 渲染优化

## 五、下一步任务

**立即要做的**:

1. **调试并修复主菜单报错**
   - 查看报错信息
   - 定位问题代码
   - 修复后重新验证

2. **验证基础战斗流程**
   - 空格开始 → 进入战斗 → 手牌显示 → E 结束回合 → 敌人攻击 → 循环

3. **完善卡牌效果系统**
   - systems/effect.lua 完整实现
   - 攻击、护盾、增益、减益效果

**后续任务** (Phase 2):
- 层级生成系统
- 奖励选择场景
- 种子系统（可复现随机）
- 存档系统

## 六、开发环境配置

**Love2D 安装**:
```bash
# 方法1：通过代理下载（已验证可行）
curl -x http://127.0.0.1:7897 -L -o /tmp/love-11.5-macos.zip "https://github.com/love2d/love/releases/download/11.5/love-11.5-macos.zip"
unzip /tmp/love-11.5-macos.zip -d /tmp/
cp -R /tmp/love.app /Applications/

# 运行项目
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

**项目路径**: `/Users/gallifreycar/Documents/roguelike-game`

## 七、开发规范

**代码风格**:
- Lua 模块用 `return Table` 导出
- 状态场景统一接口: `enter(), exit(), update(dt), draw(), keypressed(key)`
- 卡牌数据用 table 定义，ID 唯一

**Git 规范**:
- 每完成一个模块提交一次
- commit message: `[module] 功能描述`

**测试方法**:
- 运行命令: `/Applications/love.app/Contents/MacOS/love .`
- 控制台输出调试信息

## 八、已知问题

| 问题 | 状态 | 备注 |
|------|------|------|
| Homebrew 网络问题 | ✅ 已解决 | 通过代理下载 |
| Love2D 安装 | ✅ 已完成 | 版本 11.5 |
| 主菜单报错 | 🔴 待修复 | 启动后看到报错信息 |

## 九、关键设计决策

**为什么选 Love2D**:
- Balatro 同款，单人开发友好
- Lua 轻量，快速迭代
- 无需复杂引擎学习曲线

**为什么回合制**:
- 比 Balatro 的即时计算更易实现
- 参考《杀戮尖塔》成熟模式

**种子系统设计**:
- 每局游戏用字符串种子
- Fisher-Yates shuffle 用种子随机
- 支持每日挑战、分享种子

---

**接手须知**:
1. 先读取此文档，确认当前进度和问题
2. Love2D 已安装，项目能启动但主菜单有报错
3. 下一步：调试报错 → 验证战斗流程 → 完善效果系统