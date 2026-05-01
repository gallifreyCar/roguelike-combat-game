---
name: roguelike-game-context
description: "回合制战斗肉鸽游戏项目长期记忆——技术栈、架构、进度、下一步任务"
type: project
---

# Roguelike Combat Game — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-05-02
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

**当前阶段: Love2D 主版本 + 浏览器可测版本同步迭代**

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
- [x] 浏览器可测版本 `web/`，可用 `python3 -m http.server 8765` 运行
- [x] `tools/export_web_data.py` 从 `data/cards.lua` 和 `data/levels.lua` 生成 `web/game-data.js`
- [x] Web 版地图、奖励、重开、继续、第一关战斗流程已通过浏览器烟测
- [x] Web 版补齐核心印记效果：飞行、坚韧、抽牌、毒、恶臭、双击、不死、冲锋、分叉、践踏、尖刺、九头蛇分裂、亡语抽牌、猎杀、血源

**当前问题**:
- Web 版是为了浏览器试玩和调试，应长期从 Lua 数据导出，避免手写两份卡牌/关卡配置。
- Love2D 版仍是主版本；Web 版优先保持核心数值、关卡、卡牌、印记语义一致，UI 表达可不同。

待完成:
- [ ] 将 Web 版进一步补齐商店/融合/局外成长等 Love2D 独有系统，或明确哪些系统只在 Love2D 主版存在
- [ ] 给 `tools/export_web_data.py` 增加自动化测试，防止 Lua 数据格式改动后悄悄导出错
- [ ] 继续试玩中后期关卡，调参敌人增援概率和 Boss 难度
- [ ] UI 渲染优化与移动端适配复查

## 五、下一步任务

**立即要做的**:

1. **保持 Love/Web 长期一致**
   - 修改卡牌或关卡时先改 `data/cards.lua` / `data/levels.lua`
   - 再运行 `python3 tools/export_web_data.py`
   - 浏览器打开 `http://127.0.0.1:8765/web/` 烟测

2. **验证基础战斗流程**
   - 新局 → 地图 → 进第一关 → 出牌 → Battle → 领奖 → 回地图 → 菜单继续

3. **完善玩法完成度**
   - 中后期关卡难度曲线
   - 奖励池稀有度权重
   - 商店/融合/局外成长在 Web 版中的取舍

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
2. Love2D 主版和 Web 试玩版要优先保持卡牌/关卡/核心规则一致
3. 下一步：改 Lua 数据 → 导出 Web 数据 → 浏览器烟测 → 再继续补玩法完成度
