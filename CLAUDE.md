# Roguelike Combat Game

回合制战斗肉鸽游戏，参考《杀戮尖塔》玩法，使用 Love2D + Lua 开发。

## 快速开始

```bash
# 安装 Love2D (macOS)
brew install love
# 或从 https://love2d.org 下载 dmg

# 运行项目
cd roguelike-game
love .
```

## 项目结构

- `main.lua` - 入口
- `core/` - 核心模块（状态机、输入）
- `scenes/` - 场景（菜单、战斗、奖励、死亡）
- `systems/` - 系统（牌组、敌人、效果）
- `data/` - 数据定义（卡牌、敌人）

## 开发规范

- Lua 模块用 `return Table` 导出
- 场景统一接口: `enter/exit/update/draw/keypressed`
- 卡牌数据用 table 定义，ID 唯一

## 文档

- `MEMORY.md` - 项目长期记忆（进度、下一步任务）