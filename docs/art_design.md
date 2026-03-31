# Blood Cards 卡牌美术设计方案

## 1. 项目概述

### 当前状态
- 卡牌数量: 约25张（含新词条牌）
- 技术栈: LÖVE 2D + Lua
- 当前渲染: 纯文字渲染，无图案
- 卡牌尺寸: 100x130 (完整) / 100x80 (小型)

### 卡牌分类
| 稀有度 | 卡牌列表 |
|--------|----------|
| Common | Squirrel, Stoat, Bullfrog, Rat, Wolf |
| Uncommon | Turtle, Raven, Adder, Skunk, Insight, Combo Wolf, Death Raven |
| Rare | Cat, Grizzly, Moose, Mantis, Ox, Eagle, Hunter, Burst Cat, Guardian Dog |
| Legendary | Death Card, Hydra |

---

## 2. 美术方案对比

### 方案A: AI生成卡牌插图

#### 可用工具对比

| 工具 | 价格 | 风格一致性 | 商用授权 | 推荐度 |
|------|------|-----------|---------|--------|
| **Midjourney** | $10-60/月 | 高(同seed) | 需付费版 | ★★★★☆ |
| **DALL-E 3** | $0.04/张 | 中等 | 商用OK | ★★★☆☆ |
| **Stable Diffusion** | 免费(本地) | 高(同模型) | 完全商用 | ★★★★★ |
| **Leonardo.ai** | 免费额度/月费 | 高 | 商用OK | ★★★★☆ |

#### 成本估算
- **Midjourney**: $10/月基础版，约可生成200张
- **DALL-E 3**: $0.04/张 x 25张 = $1（但风格难统一）
- **Stable Diffusion**: 免费（需GPU或Colab）
- **Leonardo.ai**: 免费版150张/月，Pro $12/月

#### 推荐AI工具组合
1. **首选**: Stable Diffusion + ControlNet
   - 完全免费
   - 可训练LoRA保持风格一致
   - 商用无限制
   - 推荐模型: `DreamShaper` 或 `Deliberate`

2. **备选**: Leonardo.ai
   - 内置游戏风格模型
   - 批量生成方便
   - 免费额度够用

#### AI生成流程
```
1. 准备阶段
   - 确定美术风格（参考：暗黑系、像素风、手绘风）
   - 编写统一prompt模板
   - 测试生成并调整

2. 批量生成
   - 每张卡生成4-6个候选
   - 筛选最佳版本
   - 后期微调

3. 后处理
   - 统一尺寸裁剪
   - 调整色调/对比度
   - 添加边框/特效
```

#### Prompt模板示例（动物卡牌）
```
[主体] = wolf / raven / cat / etc.
[风格] = dark fantasy card game art, inscryption style

Prompt:
"[主体], dark fantasy creature portrait, card game illustration,
[风格], minimalist background, muted colors, ominous atmosphere,
high detail, centered composition, square aspect ratio"

Negative:
"bright colors, cartoon, anime, 3d render, text, watermark"
```

---

### 方案B: Figma设计

#### 可用资源
- **Figma Skill**: 已集成到项目中（需OAuth授权）
- 可用技能：
  - `figma-use`: 执行Figma Plugin API
  - `figma-generate-design`: 从代码生成设计
  - `figma-implement-design`: 从设计生成代码

#### Figma方案优势
- 完全免费
- 可设计矢量卡框模板
- 支持组件复用（Component）
- 团队协作友好

#### Figma方案劣势
- 需要设计能力
- 生物插图仍需外部资源
- 时间成本较高

#### Figma实现步骤
```
1. 创建设计系统
   - 卡牌尺寸模板 (100x130 / 200x260 @2x)
   - 稀有度颜色变量
   - 文字样式规范

2. 设计卡牌组件
   - 卡框背景组件（按稀有度分变体）
   - 属性数值组件
   - 印记图标组件

3. 批量生成
   - 使用Figma Plugin API批量创建
   - 或手动复制变体
```

#### Figma卡牌模板代码示例
```lua
-- 可通过figma-use调用创建
-- 卡牌基础尺寸: 100x130 pt
-- 导出倍率: @1x, @2x, @3x

-- 稀有度颜色方案（已存在于colors.lua）
common:   card_player_bg = {0.22, 0.32, 0.22}
uncommon: 边框蓝色
rare:     边框金色
legendary: 边框紫金渐变
```

---

### 方案C: 开源素材改编

#### 推荐素材来源

| 来源 | 授权 | 内容 | 网址 |
|------|------|------|------|
| **OpenGameArt** | CC0/CC-BY | 卡牌/生物图 | opengameart.org |
| **Kenney.nl** | CC0 | 大量2D素材 | kenney.nl |
| **Game-icons.net** | CC-BY | 4000+图标 | game-icons.net |
| **Lospec** | 免费使用 | 像素艺术参考 | lospec.com |
| **Itch.io** | 多种授权 | 独立游戏素材 | itch.io/game-assets |

#### 推荐素材集
1. **Kenney Card Game Assets**
   - 完全免费CC0
   - 包含卡框/图标
   - 风格简洁现代

2. **Game-icons.net**
   - 适合印记图标
   - 可调颜色/尺寸
   - CC-BY 3.0

3. **OpenGameArt Creature Pack**
   - 多种生物插图
   - 风格多样
   - 需筛选统一

#### 改编流程
```
1. 筛选素材
   - 按动物类型搜索
   - 选择风格统一的系列
   - 检查授权协议

2. 统一处理
   - 调整色调为暗黑风格
   - 统一尺寸比例
   - 添加边框装饰

3. 图标制作
   - 印记图标从game-icons获取
   - 调整为游戏配色
   - 导出PNG透明背景
```

---

## 3. 技术实现方案

### 3.1 LÖVE 2D 图片加载

#### 基础API
```lua
-- 加载图片
local image = love.graphics.newImage("path/to/image.png")

-- 绘制图片
love.graphics.draw(image, x, y)

-- 带参数绘制
love.graphics.draw(image, x, y, rotation, scaleX, scaleY, originX, originY)

-- 绘制图片部分（精灵图）
local quad = love.graphics.newQuad(x, y, width, height, imageWidth, imageHeight)
love.graphics.draw(image, quad, drawX, drawY)
```

#### 推荐文件结构
```
assets/
├── cards/
│   ├── squirrel.png
│   ├── stoat.png
│   ├── wolf.png
│   └── ... (每张卡一张图)
├── sigils/
│   ├── air_strike.png
│   ├── tough.png
│   ├── poison.png
│   └── ... (印记图标)
├── frames/
│   ├── common_frame.png
│   ├── uncommon_frame.png
│   ├── rare_frame.png
│   └── legendary_frame.png
└── ui/
    ├── blood_icon.png
    └── bone_icon.png
```

### 3.2 卡牌图片规格

#### 尺寸标准
| 类型 | 基础尺寸 | @2x尺寸 | @3x尺寸 |
|------|---------|---------|---------|
| 卡牌完整图 | 100x130 | 200x260 | 300x390 |
| 卡牌肖像区 | 80x60 | 160x120 | 240x180 |
| 印记图标 | 16x16 | 32x32 | 48x48 |
| 费用图标 | 24x24 | 48x48 | 72x72 |

#### 文件格式
- **推荐**: PNG（透明背景）
- **备选**: WebP（更小体积，需确认LÖVE支持）
- **色彩**: sRGB色彩空间
- **位深**: 8位/通道

#### 命名规范
```
cards/[card_id].png        # 卡牌主图
sigils/[sigil_id].png      # 印记图标
frames/[rarity]_frame.png  # 卡框
```

### 3.3 代码改造方案

#### 新增资源管理模块
```lua
-- core/assets.lua
local Assets = {}

function Assets.load()
    -- 卡牌图片
    Assets.cards = {}
    for id, card in pairs(require("data.cards").cards) do
        local path = "assets/cards/" .. id .. ".png"
        if love.filesystem.getInfo(path) then
            Assets.cards[id] = love.graphics.newImage(path)
        end
    end

    -- 印记图标
    Assets.sigils = {}
    for id, sigil in pairs(require("data.cards").sigils) do
        local path = "assets/sigils/" .. id .. ".png"
        if love.filesystem.getInfo(path) then
            Assets.sigils[id] = love.graphics.newImage(path)
        end
    end

    -- 卡框
    Assets.frames = {
        common = love.graphics.newImage("assets/frames/common_frame.png"),
        uncommon = love.graphics.newImage("assets/frames/uncommon_frame.png"),
        rare = love.graphics.newImage("assets/frames/rare_frame.png"),
        legendary = love.graphics.newImage("assets/frames/legendary_frame.png"),
    }
end

return Assets
```

#### 修改卡牌渲染
```lua
-- ui/card.lua 修改
local Assets = require("core.assets")

function CardUI.draw_full(card, x, y, is_player, options)
    options = options or {}

    -- 绘制卡牌图片（如有）
    if Assets.cards[card.id] then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Assets.cards[card.id], x, y, 0,
            CardUI.WIDTH / Assets.cards[card.id]:getWidth(),
            CardUI.HEIGHT / Assets.cards[card.id]:getHeight())
    else
        -- 回退到纯色背景
        if is_player then
            love.graphics.setColor(Colors.card_player_bg)
        else
            love.graphics.setColor(Colors.card_enemy_bg)
        end
        love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)
    end

    -- 绘制卡框
    if Assets.frames[card.rarity] then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Assets.frames[card.rarity], x, y)
    end

    -- ... 其余渲染逻辑
end
```

---

## 4. 推荐方案

### 最终推荐: 混合方案

```
方案组合: C(素材基础) + A(AI增强) + B(框架模板)
```

#### 分阶段实施

**Phase 1: 基础框架 (1-2天)**
- 使用Figma设计统一卡框模板
- 设计印记图标系统
- 导出基础UI元素

**Phase 2: 卡牌图像 (3-5天)**
- 使用Stable Diffusion生成生物插图
- 风格: 暗黑风格，类似Inscryption
- 统一prompt模板保持一致性
- 每张卡生成4-6个候选，选最佳

**Phase 3: 整合优化 (1-2天)**
- 编写资源加载代码
- 更新卡牌渲染逻辑
- 测试不同分辨率显示

**Phase 4: 打磨细节 (1-2天)**
- 添加卡牌特效（闪光、阴影）
- 优化加载性能
- 添加卡牌动画

### 工作量估算

| 阶段 | 任务 | 预估时间 |
|------|------|---------|
| Phase 1 | Figma卡框设计 | 4-6小时 |
| Phase 2 | AI生成25张卡图 | 6-10小时 |
| Phase 3 | 代码整合 | 4-6小时 |
| Phase 4 | 细节打磨 | 4-6小时 |
| **总计** | | **18-28小时** |

---

## 5. 风险与备选

### 潜在风险
1. **AI风格不一致** -> 使用固定seed/LoRA
2. **商用授权问题** -> 使用Stable Diffusion(完全商用OK)
3. **时间超预期** -> 先用开源素材占位，迭代优化

### 备选方案
1. **纯开源素材**: Kenney + Game-icons组合
2. **外包设计**: Fiverr约$50-200整套
3. **极简风格**: 纯文字+图标，延后美术开发

---

## 6. 下一步行动

1. [ ] 确认美术风格方向（暗黑/像素/手绘）
2. [ ] 授权Figma（如使用Figma方案）
3. [ ] 测试Stable Diffusion生成样图
4. [ ] 下载Kenney基础素材包
5. [ ] 开始Phase 1实现

---

## 附录: 参考资源

### AI工具
- Stable Diffusion WebUI: https://github.com/AUTOMATIC1111/stable-diffusion-webui
- Leonardo.ai: https://leonardo.ai
- Midjourney: https://midjourney.com

### 开源素材
- OpenGameArt: https://opengameart.org
- Kenney.nl: https://kenney.nl
- Game-icons.net: https://game-icons.net
- Itch.io: https://itch.io/game-assets/free

### 风格参考
- Inscryption (游戏)
- Slay the Spire (卡牌设计)
- Griftlands (暗黑手绘风)