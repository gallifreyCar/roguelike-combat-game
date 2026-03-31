-- docs/RELEASE_CHECKLIST.md
-- Blood Cards v1.0.0 发布检查清单
-- 创建日期: 2026-03-31

# Blood Cards 发布检查清单 (Round 10)

## 1. 配置检查
- [x] conf.lua 版本号正确
- [x] conf.lua 游戏标题正确 (Blood Cards)
- [x] conf.lua 控制台关闭 (发布模式)
- [x] main.lua DEBUG_MODE = false
- [x] main.lua HOTLOAD_MODE = false
- [x] config/settings.lua debug_mode = false

## 2. 资源文件完整性

### 卡牌图片 (47张)
| 类型 | 数量 | 状态 |
|------|------|------|
| 普通 (common) | 8 | OK |
| 稀有 (uncommon) | 14 | OK |
| 珍贵 (rare) | 19 | OK |
| 传说 (legendary) | 7 | OK |
| @2x 高清版本 | 47 | OK |

所有卡牌图片与 data/cards.lua 定义完全匹配。

### 印记图标 (18种)
| 印记 | 图片 | 状态 |
|------|------|------|
| air_strike | OK | |
| tough | OK | |
| undead | OK | |
| bifurcated | OK | |
| poison | OK | |
| stinky | OK | |
| guardian | OK | |
| charge | OK | |
| double_strike | OK | |
| trample | OK | |
| sharp_quills | OK | |
| bone_snake | OK | |
| hydra | OK | |
| draw | OK | |
| combo | OK | |
| death_draw | OK | |
| kill_bonus | OK | |
| turn_blood | OK | |

### 卡框 (4种)
| 稀有度 | 图片 | 状态 |
|--------|------|------|
| common | OK | |
| uncommon | OK | |
| rare | OK | |
| legendary | OK | |

### UI图标 (4种)
| 图标 | 状态 |
|------|------|
| blood_icon | OK |
| bone_icon | OK |
| attack_icon | OK |
| hp_icon | OK |

### 字体
| 字体 | 状态 |
|------|------|
| NotoSansSC-Regular.otf | OK |

## 3. 场景完整性
| 场景 | 文件 | 状态 |
|------|------|------|
| menu | scenes/menu.lua | OK |
| combat | scenes/combat.lua | OK |
| victory | scenes/victory.lua | OK |
| death | scenes/death.lua | OK |
| reward | scenes/reward.lua | OK |
| fusion | scenes/fusion.lua | OK |
| shop | scenes/shop.lua | OK |
| map | scenes/map.lua | OK |
| settings | scenes/settings.lua | OK |
| story | scenes/story.lua | OK |
| progression | scenes/progression.lua | OK |

所有场景在 core/state.lua 中正确注册。

## 4. 调试代码检查
| 检查项 | 状态 | 备注 |
|--------|------|------|
| DEBUG_MODE | OK | 已关闭 |
| HOTLOAD_MODE | OK | 已关闭 |
| print() 语句 | OK | 已清理所有运行时调试输出 |
| Fonts.print() | OK | 正常渲染函数，保留 |
| love.graphics.print() | OK | 正常渲染函数，保留 |

## 5. 硬编码测试数据检查
- [x] 无硬编码测试数据残留
- [x] 初始牌组使用 data/cards.lua 正常配置
- [x] 无测试用敌人数据

## 6. 多语言支持
| 语言 | 状态 | 完成度 |
|------|------|--------|
| English (EN) | OK | 100% |
| Chinese (CN) | OK | 100% |
| Japanese (JP) | 部分 | ~70% |
| Korean (KR) | 部分 | ~70% |

## 7. 打包发布
### macOS
```bash
# 创建 .love 文件
cd /Users/gallifreycar/Documents/roguelike-game
zip -r blood_cards_v1.0.0.love . -x "*.git*" -x "*.DS_Store" -x "*docs/*" -x "*tools/*"

# 合并到 macOS 应用
cat /Applications/love.app/Contents/MacOS/love blood_cards_v1.0.0.love > blood_cards_mac
chmod +x blood_cards_mac
```

### Windows
```bash
# 需要 Windows 版 LÖVE
copy /b love.exe+blood_cards_v1.0.0.love blood_cards.exe
```

## 8. 发布前测试清单
- [ ] 启动游戏无错误
- [ ] 主菜单正常显示
- [ ] 新游戏流程完整
- [ ] 战斗系统正常
- [ ] 地图导航正常
- [ ] 融合系统正常
- [ ] 存档/读取正常
- [ ] 设置界面正常
- [ ] 多语言切换正常
- [ ] 通关流程正常

## 9. 发布信息
- 版本: v1.0.0
- 发布名: Round 10 Release
- 日期: 2026-03-31
- 平台: macOS / Windows / Linux (LÖVE 11.5)