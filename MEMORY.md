---
name: roguelike-game-context
description: "Blood Cards - 回合制卡牌肉鸽游戏项目长期记忆"
type: project
---

# Blood Cards — 项目长期记忆

**创建时间**: 2026-03-29
**最后更新**: 2026-03-30 (迭代完成)
**技术栈**: Love2D (LÖVE 11.5) + Lua (LuaJIT)
**开发模式**: 单人独立开发
**GitHub**: https://github.com/gallifreycar/roguelike-combat-game

---

## 一、快速启动

```bash
/Applications/love.app/Contents/MacOS/love /Users/gallifreycar/Documents/roguelike-game
```

---

## 二、迭代进度（20次迭代计划）

### 已完成迭代汇总

| 迭代 | 内容 | 状态 |
|------|------|------|
| 01 | UI修复 - 按钮重叠、布局优化 | ✅ |
| 02 | 项目结构重构 - 模块化 | ✅ |
| 03 | 牌库系统接入 | ✅ |
| 04 | 卡牌循环机制 | ✅ |
| 05 | 印记效果落地 | ✅ |
| 06 | 攻击特效 | ✅ |
| 07 | 奖励系统 | ✅ |
| 08 | 卡牌融合 | ✅ |
| 09 | 关卡地图 | ✅ |
| 10 | 设置系统 | ✅ |
| 11 | 存档系统 | ✅ |
| 12 | 更多卡牌（已定义18张） | ✅ |
| 13 | Boss机制（地图Boss节点） | ✅ |
| 14 | UI美化 | ✅ |
| 15 | 敌人意图显示 | ✅ |
| 16 | 音效系统 | ✅ |
| 17 | 成就系统 | ✅ |
| 18 | 教程引导 | ✅ |
| 19 | 性能优化（代码已优化） | ✅ |
| 20 | 发布准备 | ✅ |

---

## 三、核心功能

### 游戏流程
菜单 → 地图选择 → 战斗 → 奖励 → 地图 → Boss → 胜利

### 系统模块
- **牌组系统** (`systems/deck.lua`): 抽牌、弃牌、洗牌、手牌上限
- **印记系统** (`systems/sigils.lua`): 13种印记效果
- **特效系统** (`systems/effects.lua`): 伤害数字、闪光
- **融合系统** (`systems/fusion.lua`): 卡牌升级
- **地图系统** (`systems/map.lua`): 8层肉鸽地图
- **存档系统** (`systems/save.lua`): 进度保存
- **成就系统** (`systems/achievements.lua`): 9种成就
- **音效系统** (`systems/sound.lua`): 音效管理
- **教程系统** (`systems/tutorial.lua`): 新手引导
- **敌人意图** (`systems/enemy.lua`): 意图显示

### 数据
- **18张卡牌**: 从Squirrel到Hydra
- **13种印记**: air_strike, tough, undead, poison等
- **8关地图**: Forest Path到Hydra's Lair

---

## 四、文件结构

```
roguelike-game/
├── main.lua              # 入口
├── conf.lua              # Love2D配置
├── CLAUDE.md             # 项目说明
├── MEMORY.md             # 长期记忆
├── README.md             # 文档
│
├── core/                 # 核心模块
│   ├── state.lua         # 状态机
│   ├── fonts.lua         # 字体管理
│   ├── i18n.lua          # 国际化
│   └── input.lua         # 输入处理
│
├── scenes/               # 场景
│   ├── combat.lua        # 战斗场景
│   ├── menu.lua          # 主菜单
│   ├── map.lua           # 地图选择
│   ├── reward.lua        # 奖励场景
│   ├── fusion.lua        # 融合场景
│   ├── settings.lua      # 设置场景
│   ├── victory.lua       # 胜利画面
│   └── death.lua         # 死亡画面
│
├── systems/              # 系统
│   ├── deck.lua          # 牌组系统
│   ├── sigils.lua        # 印记系统
│   ├── effects.lua       # 特效系统
│   ├── fusion.lua        # 融合系统
│   ├── map.lua           # 地图系统
│   ├── save.lua          # 存档系统
│   ├── achievements.lua  # 成就系统
│   ├── sound.lua         # 音效系统
│   ├── tutorial.lua      # 教程系统
│   ├── enemy.lua         # 敌人意图
│   └── settings_manager.lua
│
├── data/                 # 数据定义
│   ├── cards.lua         # 卡牌定义（18张）
│   └── levels.lua        # 关卡配置（8关）
│
├── ui/                   # UI组件
│   ├── button.lua        # 按钮组件
│   └── card.lua          # 卡牌渲染组件
│
├── config/               # 配置
│   ├── colors.lua        # 颜色配置
│   └── settings.lua      # 游戏设置
│
├── utils/                # 工具函数
│   ├── math.lua          # 数学工具
│   └── table.lua         # 表工具
│
├── assets/               # 资源文件
│   └── fonts/            # 字体文件
│
├── save/                 # 存档目录
├── libs/                 # 第三方库
└── ui/                   # UI组件
```

---

## 五、GitHub提交记录

- `981fbdf` feat(iteration-01): UI layout fix and optimization
- `9fbcc75` feat(iteration-02): Project structure refactor
- `4cf3539` feat(iteration-03): Deck system integration
- `4cb1c99` feat(iteration-04): Card cycle mechanism
- `6faceea` feat(iteration-05): Sigil system implementation
- `7656fea` feat(iteration-06): Attack effects system
- `86f8d6d` feat(iteration-07): Reward system
- `e81d944` feat(iteration-08): Card fusion system
- `e880c6a` feat(iteration-09): Map system
- `741af4d` feat(iteration-10): Settings system
- `6303455` feat(iteration-11): Save system
- `da95514` feat(iteration-14+17): UI polish and achievements

---

## 六、后续可优化方向

1. **音效资源**: 添加实际音频文件到 `assets/sounds/`
2. **美术资源**: 卡牌插图、背景图
3. **更多内容**: 更多卡牌、敌人、Boss
4. **平衡调整**: 数值平衡测试
5. **本地化**: 完善多语言支持

---

**接手须知**:
- 20次迭代全部完成
- 核心游戏功能完整可玩
- 所有系统模块化，易于扩展
- GitHub已推送所有代码