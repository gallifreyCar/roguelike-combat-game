#!/usr/bin/env python3
"""
Blood Cards - 美术素材生成器
生成卡牌主图、卡框、印记图标、UI图标
风格：暗黑系卡牌游戏（参考Inscryption）
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

# 基础路径
BASE_PATH = "/Users/gallifreycar/Documents/roguelike-game/assets"

# 尺寸定义
CARD_WIDTH = 100
CARD_HEIGHT = 130
CARD_2X_WIDTH = 200
CARD_2X_HEIGHT = 260
ICON_SIZE = 16
ICON_2X_SIZE = 32

# 稀有度颜色方案（暗黑系）
RARITY_COLORS = {
    "common": {
        "bg": (34, 51, 34),      # 深绿背景
        "border": (68, 85, 68),  # 灰绿边框
        "accent": (102, 119, 102)
    },
    "uncommon": {
        "bg": (25, 45, 70),      # 深蓝背景
        "border": (50, 90, 140), # 蓝边框
        "accent": (80, 130, 180)
    },
    "rare": {
        "bg": (45, 40, 30),      # 深金背景
        "border": (180, 150, 60),# 金边框
        "accent": (220, 180, 80)
    },
    "legendary": {
        "bg": (30, 25, 45),      # 深紫背景
        "border": (120, 80, 180),# 紫边框
        "accent": (180, 120, 220)
    }
}

# 卡牌生物配色（每种生物独特颜色）
CREATURE_COLORS = {
    # Common
    "squirrel": (139, 90, 43),    # 棕色
    "stoat": (245, 245, 220),     # 米白
    "bullfrog": (60, 120, 60),    # 绿色
    "rat": (80, 70, 65),          # 灰鼠色
    "wolf": (105, 105, 115),      # 灰色
    "bat": (50, 40, 50),          # 蝙蝠黑
    "snail": (100, 130, 100),     # 蜗牛绿
    "fox": (180, 100, 50),        # 狐狸橙

    # Uncommon
    "turtle": (70, 90, 70),       # 深绿
    "raven": (30, 30, 35),        # 黑色
    "adder": (80, 100, 50),       # 蛇绿
    "skunk": (30, 30, 30),        # 黑白
    "insight": (180, 180, 200),   # 灰蓝（概念卡）
    "combo_wolf": (120, 100, 90), # 暗灰狼
    "death_raven": (50, 40, 60),  # 死亡黑
    "bee": (200, 180, 50),        # 蜜蜂黄
    "snake": (80, 100, 50),       # 蛇绿
    "spider": (40, 35, 40),       # 蜘蛛黑
    "crow": (25, 25, 30),         # 乌鸦黑
    "rabbit": (180, 170, 160),    # 兔子灰
    "boar": (100, 70, 50),        # 野猪棕
    "guardian_dog": (100, 90, 70),# 保护犬

    # Rare
    "cat": (80, 80, 90),          # 灰猫
    "grizzly": (100, 80, 60),     # 棕熊
    "moose": (90, 75, 65),        # 深棕
    "mantis": (50, 100, 50),      # 螳螂绿
    "ox": (80, 60, 50),           # 牛棕
    "eagle": (120, 100, 80),      # 金鹰
    "hunter": (70, 60, 80),       # 深紫猎人
    "burst_cat": (150, 80, 80),   # 红猫
    "owl": (80, 70, 60),          # 猫头鹰褐
    "lion": (170, 130, 70),       # 狮子金
    "shark": (70, 80, 100),       # 鲨鱼蓝
    "scorpion": (60, 50, 40),     # 蝎子褐
    "frog_king": (50, 100, 50),   # 青蛙王绿
    "bear": (90, 70, 50),         # 熊棕
    "kraken": (40, 50, 80),       # 海妖深蓝
    "blood_worm": (120, 40, 40),  # 血虫红
    "gem_crab": (80, 120, 140),   # 宝石蟹蓝
    "assassin_bug": (50, 40, 35), # 刺客虫黑
    "ghost_wolf": (150, 150, 180),# 幽灵狼灰蓝

    # Legendary
    "deathcard": (40, 35, 50),    # 死亡紫
    "hydra": (60, 80, 100),       # 蛇蓝
    "dragon": (140, 50, 50),      # 龙红
    "phoenix": (200, 100, 50),    # 凤凰橙
    "titan": (80, 80, 100),       # 泰坦灰
    "mirror_cat": (180, 180, 200),# 镜像猫银
    "queen_bee": (200, 160, 50),  # 蜂后金
}

# 印记图标设计
SIGIL_DESIGNS = {
    "air_strike": {"symbol": "↑", "desc": "飞行"},
    "tough": {"symbol": "◆", "desc": "坚韧"},
    "undead": {"symbol": "✝", "desc": "复活"},
    "bifurcated": {"symbol": "⫿", "desc": "双击"},
    "poison": {"symbol": "☠", "desc": "毒"},
    "stinky": {"symbol": "~", "desc": "臭气"},
    "guardian": {"symbol": "☐", "desc": "守护"},
    "charge": {"symbol": "→", "desc": "冲锋"},
    "double_strike": {"symbol": "×", "desc": "双打"},
    "trample": {"symbol": "⬇", "desc": "践踏"},
    "sharp_quills": {"symbol": "⬡", "desc": "刺"},
    "bone_snake": {"symbol": "S", "desc": "蛇"},
    "hydra": {"symbol": "Ω", "desc": "多头"},
    "draw": {"symbol": "+", "desc": "过牌"},
    "combo": {"symbol": "!", "desc": "连击"},
    "death_draw": {"symbol": "D", "desc": "亡语"},
    "kill_bonus": {"symbol": "K", "desc": "猎杀"},
    "turn_blood": {"symbol": "B", "desc": "回血"},
}

def create_card_image(card_id, rarity="common", size="1x"):
    """创建卡牌主图"""
    w = CARD_WIDTH if size == "1x" else CARD_2X_WIDTH
    h = CARD_HEIGHT if size == "1x" else CARD_2X_HEIGHT

    # 创建透明背景
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 获取颜色
    colors = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
    creature_color = CREATURE_COLORS.get(card_id, (100, 100, 100))

    # 绘制背景（渐变效果）
    bg = colors["bg"]
    for y in range(h):
        ratio = y / h
        r = int(bg[0] + (creature_color[0] - bg[0]) * ratio * 0.3)
        g = int(bg[1] + (creature_color[1] - bg[1]) * ratio * 0.3)
        b = int(bg[2] + (creature_color[2] - bg[2]) * ratio * 0.3)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))

    # 绘制生物形状（根据类型）
    draw_creature(draw, card_id, w, h, creature_color, size)

    # 绘制边框
    border_color = colors["border"]
    border_width = 3 if size == "1x" else 6
    draw.rectangle([0, 0, w-1, h-1], outline=border_color + (255,), width=border_width)

    # 绘制内框
    inner_border = colors["accent"]
    inner_width = 1 if size == "1x" else 2
    margin = border_width + 2
    draw.rectangle([margin, margin, w-margin-1, h-margin-1],
                   outline=inner_border + (200,), width=inner_width)

    return img

def draw_creature(draw, card_id, w, h, color, size):
    """绘制生物图形"""
    scale = 1 if size == "1x" else 2

    # 计算中心区域
    center_x = w // 2
    center_y = h // 2 - 15 * scale

    # 生物类型分类
    creature_type = get_creature_type(card_id)

    # 根据类型绘制不同形状
    if creature_type == "bird":
        # 鸟类：三角形翅膀
        draw_bird(draw, center_x, center_y, color, scale)
    elif creature_type == "snake":
        # 蛇类：S形
        draw_snake(draw, center_x, center_y, color, scale)
    elif creature_type == "bear":
        # 熊类：大圆形
        draw_bear(draw, center_x, center_y, color, scale)
    elif creature_type == "small":
        # 小动物：小圆
        draw_small_creature(draw, center_x, center_y, color, scale)
    elif creature_type == "concept":
        # 概念卡：抽象形状
        draw_concept(draw, center_x, center_y, color, scale)
    else:
        # 默认：中等圆形
        draw_medium_creature(draw, center_x, center_y, color, scale)

def get_creature_type(card_id):
    """获取生物类型分类"""
    birds = ["raven", "eagle", "death_raven"]
    snakes = ["adder", "hydra", "bone_snake"]
    bears = ["grizzly"]
    small = ["squirrel", "rat", "skunk", "cat", "burst_cat", "insight"]
    concepts = ["deathcard", "insight"]

    if card_id in birds:
        return "bird"
    elif card_id in snakes:
        return "snake"
    elif card_id in bears:
        return "bear"
    elif card_id in small:
        return "small"
    elif card_id in concepts:
        return "concept"
    return "medium"

def draw_bird(draw, cx, cy, color, scale):
    """绘制鸟类"""
    s = scale
    # 身体（椭圆）
    draw.ellipse([cx-20*s, cy-15*s, cx+20*s, cy+25*s], fill=color + (255,))
    # 翅膀（三角形）
    darker = tuple(max(0, c-30) for c in color)
    draw.polygon([(cx-35*s, cy), (cx-15*s, cy-20*s), (cx-15*s, cy+10*s)],
                 fill=darker + (255,))
    draw.polygon([(cx+35*s, cy), (cx+15*s, cy-20*s), (cx+15*s, cy+10*s)],
                 fill=darker + (255,))
    # 眼睛
    draw.ellipse([cx-8*s, cy-5*s, cx-3*s, cy+2*s], fill=(255, 255, 255, 200))
    draw.ellipse([cx+3*s, cy-5*s, cx+8*s, cy+2*s], fill=(255, 255, 255, 200))

def draw_snake(draw, cx, cy, color, scale):
    """绘制蛇"""
    s = scale
    # S形身体
    points = []
    for i in range(20):
        t = i / 19
        x = cx + math.sin(t * 3 * math.pi) * 25 * s
        y = cy - 30*s + t * 50*s
        points.append((x, y))

    # 绘制曲线
    for i in range(len(points)-1):
        draw.line([points[i], points[i+1]], fill=color + (255,), width=8*s)

    # 头部
    draw.ellipse([cx-10*s, cy-35*s, cx+10*s, cy-20*s], fill=color + (255,))
    # 眼睛
    draw.ellipse([cx-6*s, cy-30*s, cx-2*s, cy-26*s], fill=(255, 0, 0, 200))
    draw.ellipse([cx+2*s, cy-30*s, cx+6*s, cy-26*s], fill=(255, 0, 0, 200))

def draw_bear(draw, cx, cy, color, scale):
    """绘制熊"""
    s = scale
    # 大身体
    draw.ellipse([cx-35*s, cy-30*s, cx+35*s, cy+40*s], fill=color + (255,))
    # 头部
    draw.ellipse([cx-25*s, cy-45*s, cx+25*s, cy-15*s], fill=color + (255,))
    # 耳朵
    draw.ellipse([cx-30*s, cy-50*s, cx-15*s, cy-35*s], fill=color + (255,))
    draw.ellipse([cx+15*s, cy-50*s, cx+30*s, cy-35*s], fill=color + (255,))
    # 眼睛
    darker = tuple(max(0, c-20) for c in color)
    draw.ellipse([cx-12*s, cy-35*s, cx-5*s, cy-28*s], fill=(20, 20, 20, 200))
    draw.ellipse([cx+5*s, cy-35*s, cx+12*s, cy-28*s], fill=(20, 20, 20, 200))

def draw_small_creature(draw, cx, cy, color, scale):
    """绘制小动物"""
    s = scale
    # 小身体
    draw.ellipse([cx-15*s, cy-15*s, cx+15*s, cy+20*s], fill=color + (255,))
    # 头
    draw.ellipse([cx-12*s, cy-25*s, cx+12*s, cy-5*s], fill=color + (255,))
    # 眼睛
    draw.ellipse([cx-7*s, cy-18*s, cx-3*s, cy-14*s], fill=(0, 0, 0, 200))
    draw.ellipse([cx+3*s, cy-18*s, cx+7*s, cy-14*s], fill=(0, 0, 0, 200))
    # 小尾巴（如果是squirrel）
    draw.polygon([(cx+15*s, cy+10*s), (cx+30*s, cy+20*s), (cx+20*s, cy+15*s)],
                 fill=color + (200,))

def draw_medium_creature(draw, cx, cy, color, scale):
    """绘制中等生物（狼、鼬等）"""
    s = scale
    # 身体
    draw.ellipse([cx-25*s, cy-20*s, cx+25*s, cy+30*s], fill=color + (255,))
    # 头部
    draw.ellipse([cx-20*s, cy-35*s, cx+20*s, cy-5*s], fill=color + (255,))
    # 耳朵
    darker = tuple(max(0, c-15) for c in color)
    draw.polygon([(cx-25*s, cy-30*s), (cx-15*s, cy-50*s), (cx-5*s, cy-30*s)],
                 fill=darker + (255,))
    draw.polygon([(cx+25*s, cy-30*s), (cx+15*s, cy-50*s), (cx+5*s, cy-30*s)],
                 fill=darker + (255,))
    # 眼睛
    draw.ellipse([cx-10*s, cy-25*s, cx-4*s, cy-19*s], fill=(200, 200, 50, 200))
    draw.ellipse([cx+4*s, cy-25*s, cx+10*s, cy-19*s], fill=(200, 200, 50, 200))

def draw_concept(draw, cx, cy, color, scale):
    """绘制概念卡（抽象形状）"""
    s = scale
    # 中心符号
    draw.ellipse([cx-20*s, cy-20*s, cx+20*s, cy+20*s], fill=color + (255,))
    # 神秘光环
    for i in range(3):
        offset = i * 10 * s
        alpha = 150 - i * 40
        draw.ellipse([cx-20*s-offset, cy-20*s-offset, cx+20*s+offset, cy+20*s+offset],
                     outline=color + (alpha,), width=2*s)

def create_frame_image(rarity, size="1x"):
    """创建卡框"""
    w = CARD_WIDTH if size == "1x" else CARD_2X_WIDTH
    h = CARD_HEIGHT if size == "1x" else CARD_2X_HEIGHT

    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    colors = RARITY_COLORS[rarity]

    # 外框
    border_w = 4 if size == "1x" else 8
    draw.rectangle([0, 0, w-1, h-1], outline=colors["border"] + (255,), width=border_w)

    # 内框装饰
    accent = colors["accent"]
    inner_margin = border_w + 2
    draw.rectangle([inner_margin, inner_margin, w-inner_margin-1, h-inner_margin-1],
                   outline=accent + (150,), width=1 if size == "1x" else 2)

    # 角装饰
    corner_size = 10 if size == "1x" else 20
    for corner in [(0, 0), (w-corner_size, 0), (0, h-corner_size), (w-corner_size, h-corner_size)]:
        draw.rectangle([corner[0], corner[1], corner[0]+corner_size, corner[1]+corner_size],
                       outline=accent + (200,), width=1 if size == "1x" else 2)

    return img

def create_sigil_icon(sigil_id, size="1x"):
    """创建印记图标"""
    w = ICON_SIZE if size == "1x" else ICON_2X_SIZE
    h = w

    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 背景圆
    bg_color = (40, 40, 50)
    draw.ellipse([0, 0, w-1, h-1], fill=bg_color + (255,))

    # 边框
    draw.ellipse([0, 0, w-1, h-1], outline=(100, 100, 120, 255), width=1)

    # 符号
    design = SIGIL_DESIGNS.get(sigil_id, {"symbol": "?"})
    symbol = design["symbol"]

    # 尝试使用字体绘制符号
    try:
        # 使用系统字体
        font_size = int(w * 0.6)
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", font_size)
    except:
        font = ImageFont.load_default()

    # 计算文字位置（居中）
    bbox = draw.textbbox((0, 0), symbol, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = (w - text_w) // 2
    y = (h - text_h) // 2 - 1

    # 根据印记类型选择颜色
    sigil_colors = {
        "attack": (255, 100, 100),   # 红色（攻击类）
        "defense": (100, 255, 100),  # 绿色（防御类）
        "special": (200, 200, 255),  # 蓝色（特殊）
        "utility": (255, 255, 100),  # 黄色（功能）
    }

    # 印记分类
    attack_sigils = ["air_strike", "charge", "double_strike", "trample", "poison", "combo", "kill_bonus"]
    defense_sigils = ["tough", "guardian", "undead"]

    if sigil_id in attack_sigils:
        text_color = sigil_colors["attack"]
    elif sigil_id in defense_sigils:
        text_color = sigil_colors["defense"]
    else:
        text_color = sigil_colors["special"]

    draw.text((x, y), symbol, fill=text_color + (255,), font=font)

    return img

def create_ui_icon(icon_name, size="1x"):
    """创建UI图标"""
    w = ICON_SIZE * 2 if size == "1x" else ICON_2X_SIZE * 2  # UI图标更大
    h = w

    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if icon_name == "blood_icon":
        # 血滴形状
        center = w // 2
        # 圆形底部
        draw.ellipse([w//4, h//3, w*3//4, h*3//4], fill=(180, 50, 50, 255))
        # 尖顶
        draw.polygon([(center, 0), (w//4, h//3), (w*3//4, h//3)], fill=(180, 50, 50, 255))

    elif icon_name == "bone_icon":
        # 骨头形状
        draw.ellipse([0, h//4, w//4, h*3//4], fill=(220, 220, 200, 255))
        draw.ellipse([w*3//4, h//4, w, h*3//4], fill=(220, 220, 200, 255))
        draw.rectangle([w//4, h//3, w*3//4, h*2//3], fill=(220, 220, 200, 255))

    elif icon_name == "attack_icon":
        # 剑形状
        center = w // 2
        draw.polygon([(center, 0), (center-w//6, h//2), (center, h), (center+w//6, h//2)],
                     fill=(200, 200, 220, 255))
        draw.rectangle([center-w//8, h//2, center+w//8, h-5], fill=(150, 100, 50, 255))

    elif icon_name == "hp_icon":
        # 心形
        center = w // 2
        draw.ellipse([w//6, h//6, center, h//2], fill=(200, 80, 80, 255))
        draw.ellipse([center, h//6, w*5//6, h//2], fill=(200, 80, 80, 255))
        draw.polygon([(w//6, h//2), (center, h), (w*5//6, h//2)], fill=(200, 80, 80, 255))

    return img

def ensure_dir(path):
    """确保目录存在"""
    os.makedirs(path, exist_ok=True)

def generate_all_assets():
    """生成所有素材"""
    print("=" * 50)
    print("Blood Cards 美术素材生成器")
    print("=" * 50)

    # 创建目录
    ensure_dir(f"{BASE_PATH}/cards")
    ensure_dir(f"{BASE_PATH}/frames")
    ensure_dir(f"{BASE_PATH}/sigils")
    ensure_dir(f"{BASE_PATH}/ui")

    # 卡牌稀有度映射
    card_rarities = {
        # Common
        "squirrel": "common", "stoat": "common", "bullfrog": "common",
        "rat": "common", "wolf": "common", "bat": "common", "snail": "common", "fox": "common",
        # Uncommon
        "turtle": "uncommon", "raven": "uncommon", "adder": "uncommon",
        "skunk": "uncommon", "insight": "uncommon", "combo_wolf": "uncommon",
        "death_raven": "uncommon", "guardian_dog": "uncommon",
        "bee": "uncommon", "snake": "uncommon", "spider": "uncommon",
        "crow": "uncommon", "rabbit": "uncommon", "boar": "uncommon",
        # Rare
        "cat": "rare", "grizzly": "rare", "moose": "rare", "mantis": "rare",
        "ox": "rare", "eagle": "rare", "hunter": "rare", "burst_cat": "rare",
        "owl": "rare", "lion": "rare", "shark": "rare", "scorpion": "rare",
        "frog_king": "rare", "bear": "rare", "kraken": "rare",
        "blood_worm": "rare", "gem_crab": "rare", "assassin_bug": "rare", "ghost_wolf": "rare",
        # Legendary
        "deathcard": "legendary", "hydra": "legendary",
        "dragon": "legendary", "phoenix": "legendary", "titan": "legendary",
        "mirror_cat": "legendary", "queen_bee": "legendary",
    }

    # 生成卡牌图片（1x和2x）
    print("\n[1] 生成卡牌图片...")
    for card_id, rarity in card_rarities.items():
        for size in ["1x", "2x"]:
            img = create_card_image(card_id, rarity, size)
            filename = f"{card_id}.png" if size == "1x" else f"{card_id}@2x.png"
            img.save(f"{BASE_PATH}/cards/{filename}")
            print(f"  ✓ {filename}")

    # 生成卡框
    print("\n[2] 生成卡框...")
    for rarity in ["common", "uncommon", "rare", "legendary"]:
        for size in ["1x", "2x"]:
            img = create_frame_image(rarity, size)
            filename = f"{rarity}_frame.png" if size == "1x" else f"{rarity}_frame@2x.png"
            img.save(f"{BASE_PATH}/frames/{filename}")
            print(f"  ✓ {filename}")

    # 生成印记图标
    print("\n[3] 生成印记图标...")
    for sigil_id in SIGIL_DESIGNS.keys():
        for size in ["1x", "2x"]:
            img = create_sigil_icon(sigil_id, size)
            filename = f"{sigil_id}.png" if size == "1x" else f"{sigil_id}@2x.png"
            img.save(f"{BASE_PATH}/sigils/{filename}")
            print(f"  ✓ {filename}")

    # 生成UI图标
    print("\n[4] 生成UI图标...")
    for icon_name in ["blood_icon", "bone_icon", "attack_icon", "hp_icon"]:
        for size in ["1x", "2x"]:
            img = create_ui_icon(icon_name, size)
            filename = f"{icon_name}.png" if size == "1x" else f"{icon_name}@2x.png"
            img.save(f"{BASE_PATH}/ui/{filename}")
            print(f"  ✓ {filename}")

    print("\n" + "=" * 50)
    print("素材生成完成！")
    print(f"总计: {len(card_rarities)*2} 卡牌图片")
    print(f"      {4*2} 卡框图片")
    print(f"      {len(SIGIL_DESIGNS)*2} 印记图标")
    print(f"      {4*2} UI图标")
    print("=" * 50)

if __name__ == "__main__":
    generate_all_assets()