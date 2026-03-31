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
    """绘制生物图形（增强版）"""
    scale = 1 if size == "1x" else 2

    # 计算中心区域
    center_x = w // 2
    center_y = h // 2 - 15 * scale

    # 生物类型分类
    creature_type = get_creature_type(card_id)

    # 根据类型绘制不同形状
    if creature_type == "bird":
        draw_bird(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "snake":
        draw_snake(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "bear":
        draw_bear(draw, center_x, center_y, color, scale)
    elif creature_type == "wolf":
        draw_wolf(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "cat":
        draw_cat(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "small":
        draw_small_creature(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "amphibian":
        draw_amphibian(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "large":
        draw_large_creature(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "bug":
        draw_bug(draw, center_x, center_y, color, scale, card_id)
    elif creature_type == "concept":
        draw_concept(draw, center_x, center_y, color, scale)
    else:
        draw_medium_creature(draw, center_x, center_y, color, scale)

def get_creature_type(card_id):
    """获取生物类型分类（细化）"""
    # 鸟类：翅膀展开、尖嘴
    birds = ["raven", "eagle", "death_raven", "crow", "owl", "phoenix", "bat"]
    # 蛇类：S形身体
    snakes = ["adder", "hydra", "snake", "blood_worm", "bone_snake"]
    # 熊类：大圆身体、小耳
    bears = ["grizzly", "bear", "titan"]
    # 狼类：长嘴、尖耳
    wolves = ["wolf", "ghost_wolf", "combo_wolf", "fox", "hunter"]
    # 猫类：尖耳、尾巴
    cats = ["cat", "burst_cat", "mirror_cat", "lion"]
    # 小动物：小圆身体
    small = ["squirrel", "rat", "skunk", "rabbit", "bee", "queen_bee"]
    # 两栖/爬行
    amphibians = ["bullfrog", "frog_king", "turtle", "mantis", "scorpion"]
    # 大型动物
    large = ["moose", "ox", "boar", "shark", "kraken", "dragon"]
    # 节肢动物
    bugs = ["spider", "assassin_bug", "snail", "gem_crab"]
    # 概念卡
    concepts = ["deathcard", "insight"]

    if card_id in birds:
        return "bird"
    elif card_id in snakes:
        return "snake"
    elif card_id in bears:
        return "bear"
    elif card_id in wolves:
        return "wolf"
    elif card_id in cats:
        return "cat"
    elif card_id in small:
        return "small"
    elif card_id in amphibians:
        return "amphibian"
    elif card_id in large:
        return "large"
    elif card_id in bugs:
        return "bug"
    elif card_id in concepts:
        return "concept"
    return "medium"

def draw_bird(draw, cx, cy, color, scale, card_id="raven"):
    """绘制鸟类（增强版）"""
    s = scale
    darker = tuple(max(0, c-30) for c in color)

    # 身体（椭圆）
    draw.ellipse([cx-18*s, cy-12*s, cx+18*s, cy+22*s], fill=color + (255,))

    # 翅膀形状根据鸟类调整
    if card_id in ["eagle", "phoenix"]:
        # 大翅膀展开
        draw.polygon([(cx-40*s, cy-5*s), (cx-15*s, cy-25*s), (cx-15*s, cy+15*s)],
                     fill=darker + (255,))
        draw.polygon([(cx+40*s, cy-5*s), (cx+15*s, cy-25*s), (cx+15*s, cy+15*s)],
                     fill=darker + (255,))
    elif card_id == "owl":
        # 猫头鹰：圆翅膀
        draw.ellipse([cx-35*s, cy-10*s, cx-15*s, cy+20*s], fill=darker + (255,))
        draw.ellipse([cx+15*s, cy-10*s, cx+35*s, cy+20*s], fill=darker + (255,))
    else:
        # 普通鸟类翅膀
        draw.polygon([(cx-35*s, cy), (cx-15*s, cy-20*s), (cx-15*s, cy+10*s)],
                     fill=darker + (255,))
        draw.polygon([(cx+35*s, cy), (cx+15*s, cy-20*s), (cx+15*s, cy+10*s)],
                     fill=darker + (255,))

    # 头部
    draw.ellipse([cx-12*s, cy-28*s, cx+12*s, cy-8*s], fill=color + (255,))

    # 喙
    beak_color = (200, 150, 50) if card_id == "eagle" else (80, 60, 40)
    draw.polygon([(cx, cy-20*s), (cx-5*s, cy-15*s), (cx+5*s, cy-15*s)],
                 fill=beak_color + (255,))

    # 眼睛
    if card_id == "owl":
        # 猫头鹰大眼睛
        draw.ellipse([cx-10*s, cy-25*s, cx-3*s, cy-18*s], fill=(255, 200, 0, 255))
        draw.ellipse([cx+3*s, cy-25*s, cx+10*s, cy-18*s], fill=(255, 200, 0, 255))
        draw.ellipse([cx-8*s, cy-23*s, cx-5*s, cy-20*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+5*s, cy-23*s, cx+8*s, cy-20*s], fill=(0, 0, 0, 255))
    else:
        draw.ellipse([cx-8*s, cy-22*s, cx-3*s, cy-17*s], fill=(255, 255, 255, 200))
        draw.ellipse([cx+3*s, cy-22*s, cx+8*s, cy-17*s], fill=(255, 255, 255, 200))
        draw.ellipse([cx-6*s, cy-20*s, cx-4*s, cy-18*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+4*s, cy-20*s, cx+6*s, cy-18*s], fill=(0, 0, 0, 255))

def draw_snake(draw, cx, cy, color, scale, card_id="snake"):
    """绘制蛇（增强版）"""
    s = scale

    # 根据类型调整蛇的形态
    if card_id == "hydra":
        # 九头蛇：多条蛇身
        for offset in [-20, 0, 20]:
            for i in range(15):
                t = i / 14
                x = cx + offset*s + math.sin(t * 2.5 * math.pi) * 15 * s
                y = cy - 25*s + t * 45*s
                if i < 14:
                    draw.ellipse([x-4*s, y-4*s, x+4*s, y+4*s], fill=color + (255,))
            # 头
            draw.ellipse([cx+offset*s-6*s, cy-30*s, cx+offset*s+6*s, cy-18*s], fill=color + (255,))
    else:
        # 普通蛇：S形身体
        points = []
        for i in range(20):
            t = i / 19
            x = cx + math.sin(t * 3 * math.pi) * 25 * s
            y = cy - 30*s + t * 50*s
            points.append((x, y))

        # 绘制曲线（用椭圆代替线条，更粗）
        for i in range(len(points)-1):
            mid_x = (points[i][0] + points[i+1][0]) / 2
            mid_y = (points[i][1] + points[i+1][1]) / 2
            draw.ellipse([mid_x-5*s, mid_y-5*s, mid_x+5*s, mid_y+5*s], fill=color + (255,))

        # 头部（三角形）
        draw.polygon([
            (cx, cy-40*s),
            (cx-12*s, cy-25*s),
            (cx+12*s, cy-25*s)
        ], fill=color + (255,))

        # 眼睛
        eye_color = (255, 0, 0) if card_id in ["adder", "blood_worm"] else (255, 200, 0)
        draw.ellipse([cx-8*s, cy-35*s, cx-3*s, cy-30*s], fill=eye_color + (255,))
        draw.ellipse([cx+3*s, cy-35*s, cx+8*s, cy-30*s], fill=eye_color + (255,))

        # 舌头
        draw.line([(cx, cy-40*s), (cx, cy-48*s)], fill=(255, 100, 100, 255), width=2*s)

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

def draw_small_creature(draw, cx, cy, color, scale, card_id="squirrel"):
    """绘制小动物（增强版）"""
    s = scale
    darker = tuple(max(0, c-20) for c in color)

    if card_id == "squirrel":
        # 松鼠：大尾巴
        # 身体
        draw.ellipse([cx-12*s, cy-10*s, cx+12*s, cy+18*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-10*s, cy-22*s, cx+10*s, cy-5*s], fill=color + (255,))
        # 大尾巴（蓬松）
        draw.ellipse([cx+8*s, cy-5*s, cx+35*s, cy+25*s], fill=color + (255,))
        draw.ellipse([cx+12*s, cy+5*s, cx+30*s, cy+30*s], fill=darker + (200,))
        # 耳朵
        draw.ellipse([cx-8*s, cy-28*s, cx-2*s, cy-20*s], fill=color + (255,))
        draw.ellipse([cx+2*s, cy-28*s, cx+8*s, cy-20*s], fill=color + (255,))
        # 眼睛
        draw.ellipse([cx-6*s, cy-16*s, cx-2*s, cy-12*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-16*s, cx+6*s, cy-12*s], fill=(0, 0, 0, 255))

    elif card_id == "rat":
        # 老鼠：长尾巴、尖嘴
        draw.ellipse([cx-10*s, cy-8*s, cx+10*s, cy+15*s], fill=color + (255,))
        # 头（尖）
        draw.polygon([(cx, cy-25*s), (cx-10*s, cy-8*s), (cx+10*s, cy-8*s)], fill=color + (255,))
        # 耳朵（大圆）
        draw.ellipse([cx-12*s, cy-20*s, cx-4*s, cy-12*s], fill=color + (255,))
        draw.ellipse([cx+4*s, cy-20*s, cx+12*s, cy-12*s], fill=color + (255,))
        # 长尾巴
        draw.line([(cx, cy+15*s), (cx+25*s, cy+30*s)], fill=color + (255,), width=3*s)
        # 眼睛
        draw.ellipse([cx-5*s, cy-14*s, cx-2*s, cy-11*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-14*s, cx+5*s, cy-11*s], fill=(0, 0, 0, 255))

    elif card_id == "rabbit":
        # 兔子：长耳朵
        draw.ellipse([cx-15*s, cy-5*s, cx+15*s, cy+20*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-12*s, cy-20*s, cx+12*s, cy-2*s], fill=color + (255,))
        # 长耳朵
        draw.ellipse([cx-10*s, cy-45*s, cx-3*s, cy-20*s], fill=color + (255,))
        draw.ellipse([cx+3*s, cy-45*s, cx+10*s, cy-20*s], fill=color + (255,))
        # 耳朵内部
        draw.ellipse([cx-8*s, cy-40*s, cx-5*s, cy-22*s], fill=(255, 180, 180, 200))
        draw.ellipse([cx+5*s, cy-40*s, cx+8*s, cy-22*s], fill=(255, 180, 180, 200))
        # 眼睛
        draw.ellipse([cx-6*s, cy-12*s, cx-2*s, cy-8*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-12*s, cx+6*s, cy-8*s], fill=(0, 0, 0, 255))
        # 鼻子
        draw.ellipse([cx-2*s, cy-3*s, cx+2*s, cy], fill=(255, 150, 150, 255))

    elif card_id in ["bee", "queen_bee"]:
        # 蜜蜂：条纹身体
        draw.ellipse([cx-12*s, cy-15*s, cx+12*s, cy+15*s], fill=(200, 180, 50) + (255,))  # 黄
        # 黑条纹
        draw.rectangle([cx-12*s, cy-8*s, cx+12*s, cy-4*s], fill=(30, 30, 30, 255))
        draw.rectangle([cx-12*s, cy+2*s, cx+12*s, cy+6*s], fill=(30, 30, 30, 255))
        # 翅膀
        draw.ellipse([cx-25*s, cy-18*s, cx-8*s, cy-5*s], fill=(200, 220, 255, 150))
        draw.ellipse([cx+8*s, cy-18*s, cx+25*s, cy-5*s], fill=(200, 220, 255, 150))
        # 头
        draw.ellipse([cx-8*s, cy-25*s, cx+8*s, cy-15*s], fill=(30, 30, 30, 255))
        # 眼睛
        draw.ellipse([cx-5*s, cy-22*s, cx-2*s, cy-18*s], fill=(255, 255, 255, 200))
        draw.ellipse([cx+2*s, cy-22*s, cx+5*s, cy-18*s], fill=(255, 255, 255, 200))
        if card_id == "queen_bee":
            # 蜂后皇冠
            draw.polygon([(cx-5*s, cy-30*s), (cx, cy-38*s), (cx+5*s, cy-30*s)], fill=(255, 200, 0, 255))

    else:  # skunk 等
        # 默认小动物
        draw.ellipse([cx-12*s, cy-10*s, cx+12*s, cy+18*s], fill=color + (255,))
        draw.ellipse([cx-10*s, cy-22*s, cx+10*s, cy-5*s], fill=color + (255,))
        # 白色条纹（臭鼬）
        if card_id == "skunk":
            draw.line([(cx-3*s, cy-15*s), (cx-3*s, cy+15*s)], fill=(255, 255, 255, 255), width=6*s)
        draw.ellipse([cx-6*s, cy-16*s, cx-2*s, cy-12*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-16*s, cx+6*s, cy-12*s], fill=(0, 0, 0, 255))

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

def draw_wolf(draw, cx, cy, color, scale, card_id="wolf"):
    """绘制狼（增强版）"""
    s = scale
    darker = tuple(max(0, c-25) for c in color)

    # 身体
    draw.ellipse([cx-22*s, cy-15*s, cx+22*s, cy+25*s], fill=color + (255,))

    # 头部（长嘴）
    draw.ellipse([cx-15*s, cy-35*s, cx+15*s, cy-10*s], fill=color + (255,))
    # 长嘴
    draw.polygon([(cx, cy-22*s), (cx-10*s, cy-5*s), (cx+10*s, cy-5*s)], fill=color + (255,))

    # 尖耳朵
    draw.polygon([(cx-18*s, cy-28*s), (cx-10*s, cy-50*s), (cx-2*s, cy-30*s)], fill=darker + (255,))
    draw.polygon([(cx+18*s, cy-28*s), (cx+10*s, cy-50*s), (cx+2*s, cy-30*s)], fill=darker + (255,))

    # 眼睛（黄色）
    draw.ellipse([cx-10*s, cy-28*s, cx-4*s, cy-22*s], fill=(200, 180, 50, 255))
    draw.ellipse([cx+4*s, cy-28*s, cx+10*s, cy-22*s], fill=(200, 180, 50, 255))
    # 瞳孔
    draw.ellipse([cx-8*s, cy-26*s, cx-6*s, cy-24*s], fill=(0, 0, 0, 255))
    draw.ellipse([cx+6*s, cy-26*s, cx+8*s, cy-24*s], fill=(0, 0, 0, 255))

    # 尾巴
    draw.ellipse([cx+15*s, cy+10*s, cx+35*s, cy+25*s], fill=color + (255,))

    # 特殊效果
    if card_id == "ghost_wolf":
        # 幽灵狼：半透明
        for y in range(int(cy-50*s), int(cy+35*s)):
            for x in range(int(cx-35*s), int(cx+35*s)):
                if (x - cx)**2 + (y - cy)**2 < (30*s)**2:
                    draw.point((x, y), fill=color + (100,))

def draw_cat(draw, cx, cy, color, scale, card_id="cat"):
    """绘制猫（增强版）"""
    s = scale
    darker = tuple(max(0, c-20) for c in color)

    # 身体
    draw.ellipse([cx-18*s, cy-10*s, cx+18*s, cy+25*s], fill=color + (255,))

    # 头部
    draw.ellipse([cx-15*s, cy-30*s, cx+15*s, cy-8*s], fill=color + (255,))

    # 尖耳朵（三角形）
    draw.polygon([(cx-15*s, cy-22*s), (cx-10*s, cy-42*s), (cx-5*s, cy-22*s)], fill=color + (255,))
    draw.polygon([(cx+15*s, cy-22*s), (cx+10*s, cy-42*s), (cx+5*s, cy-22*s)], fill=color + (255,))
    # 内耳
    draw.polygon([(cx-13*s, cy-24*s), (cx-10*s, cy-38*s), (cx-7*s, cy-24*s)], fill=(255, 180, 180, 200))
    draw.polygon([(cx+13*s, cy-24*s), (cx+10*s, cy-38*s), (cx+7*s, cy-24*s)], fill=(255, 180, 180, 200))

    # 眼睛（猫眼）
    eye_color = (100, 200, 100) if card_id != "burst_cat" else (255, 100, 100)
    draw.ellipse([cx-10*s, cy-22*s, cx-3*s, cy-15*s], fill=eye_color + (255,))
    draw.ellipse([cx+3*s, cy-22*s, cx+10*s, cy-15*s], fill=eye_color + (255,))
    # 瞳孔（竖线）
    draw.ellipse([cx-7*s, cy-20*s, cx-6*s, cy-17*s], fill=(0, 0, 0, 255))
    draw.ellipse([cx+6*s, cy-20*s, cx+7*s, cy-17*s], fill=(0, 0, 0, 255))

    # 鼻子
    draw.polygon([(cx, cy-8*s), (cx-3*s, cy-5*s), (cx+3*s, cy-5*s)], fill=(255, 150, 150, 255))

    # 尾巴
    draw.line([(cx+15*s, cy+20*s), (cx+30*s, cy+10*s)], fill=color + (255,), width=5*s)

    # 特殊效果
    if card_id == "lion":
        # 狮子鬃毛
        for angle in range(0, 360, 20):
            rad = math.radians(angle)
            x1 = cx + math.cos(rad) * 18*s
            y1 = cy - 20*s + math.sin(rad) * 18*s
            x2 = cx + math.cos(rad) * 28*s
            y2 = cy - 20*s + math.sin(rad) * 28*s
            draw.line([(x1, y1), (x2, y2)], fill=(180, 140, 60, 255), width=3*s)

def draw_amphibian(draw, cx, cy, color, scale, card_id="bullfrog"):
    """绘制两栖/爬行动物"""
    s = scale
    darker = tuple(max(0, c-20) for c in color)

    if card_id in ["bullfrog", "frog_king"]:
        # 青蛙：蹲姿
        # 身体（宽扁）
        draw.ellipse([cx-25*s, cy-5*s, cx+25*s, cy+20*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-18*s, cy-20*s, cx+18*s, cy], fill=color + (255,))
        # 大眼睛（突出）
        draw.ellipse([cx-15*s, cy-30*s, cx-5*s, cy-18*s], fill=(255, 255, 255, 255))
        draw.ellipse([cx+5*s, cy-30*s, cx+15*s, cy-18*s], fill=(255, 255, 255, 255))
        draw.ellipse([cx-12*s, cy-27*s, cx-8*s, cy-22*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+8*s, cy-27*s, cx+12*s, cy-22*s], fill=(0, 0, 0, 255))
        # 后腿（蹲）
        draw.ellipse([cx-35*s, cy+5*s, cx-20*s, cy+25*s], fill=color + (255,))
        draw.ellipse([cx+20*s, cy+5*s, cx+35*s, cy+25*s], fill=color + (255,))

        if card_id == "frog_king":
            # 皇冠
            draw.polygon([(cx-10*s, cy-35*s), (cx-5*s, cy-45*s), (cx, cy-35*s),
                         (cx+5*s, cy-45*s), (cx+10*s, cy-35*s)], fill=(255, 200, 0, 255))

    elif card_id == "turtle":
        # 乌龟：壳
        # 壳（圆形）
        draw.ellipse([cx-25*s, cy-15*s, cx+25*s, cy+25*s], fill=color + (255,))
        # 壳纹理
        draw.ellipse([cx-18*s, cy-8*s, cx+18*s, cy+18*s], fill=darker + (200,))
        # 头
        draw.ellipse([cx-8*s, cy-25*s, cx+8*s, cy-10*s], fill=color + (255,))
        # 腿
        draw.ellipse([cx-28*s, cy+5*s, cx-18*s, cy+15*s], fill=color + (255,))
        draw.ellipse([cx+18*s, cy+5*s, cx+28*s, cy+15*s], fill=color + (255,))
        # 眼睛
        draw.ellipse([cx-5*s, cy-22*s, cx-2*s, cy-18*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-22*s, cx+5*s, cy-18*s], fill=(0, 0, 0, 255))

    elif card_id == "mantis":
        # 螳螂
        # 身体（细长）
        draw.ellipse([cx-8*s, cy-20*s, cx+8*s, cy+30*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-10*s, cy-30*s, cx+10*s, cy-18*s], fill=color + (255,))
        # 大眼睛
        draw.ellipse([cx-12*s, cy-28*s, cx-5*s, cy-22*s], fill=(100, 200, 100, 255))
        draw.ellipse([cx+5*s, cy-28*s, cx+12*s, cy-22*s], fill=(100, 200, 100, 255))
        # 镰刀臂
        draw.line([(cx-8*s, cy-5*s), (cx-25*s, cy-25*s)], fill=color + (255,), width=4*s)
        draw.line([(cx+8*s, cy-5*s), (cx+25*s, cy-25*s)], fill=color + (255,), width=4*s)

    elif card_id == "scorpion":
        # 蝎子
        # 身体
        draw.ellipse([cx-15*s, cy-10*s, cx+15*s, cy+20*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-12*s, cy-22*s, cx+12*s, cy-8*s], fill=color + (255,))
        # 钳子
        draw.ellipse([cx-30*s, cy-15*s, cx-15*s, cy-5*s], fill=color + (255,))
        draw.ellipse([cx+15*s, cy-15*s, cx+30*s, cy-5*s], fill=color + (255,))
        # 尾巴（上卷）
        points = [(cx, cy+20*s), (cx+10*s, cy+35*s), (cx+5*s, cy+45*s)]
        draw.line(points, fill=color + (255,), width=5*s)
        # 毒刺
        draw.polygon([(cx+5*s, cy+45*s), (cx+2*s, cy+52*s), (cx+8*s, cy+48*s)], fill=(200, 50, 50, 255))

    else:
        # 默认两栖
        draw.ellipse([cx-20*s, cy-10*s, cx+20*s, cy+20*s], fill=color + (255,))
        draw.ellipse([cx-15*s, cy-25*s, cx+15*s, cy-5*s], fill=color + (255,))
        draw.ellipse([cx-8*s, cy-20*s, cx-2*s, cy-14*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-20*s, cx+8*s, cy-14*s], fill=(0, 0, 0, 255))

def draw_large_creature(draw, cx, cy, color, scale, card_id="moose"):
    """绘制大型动物"""
    s = scale
    darker = tuple(max(0, c-25) for c in color)

    if card_id == "moose":
        # 驼鹿：大角
        # 身体
        draw.ellipse([cx-30*s, cy-15*s, cx+30*s, cy+30*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-18*s, cy-35*s, cx+18*s, cy-10*s], fill=color + (255,))
        # 长鼻
        draw.ellipse([cx-10*s, cy-20*s, cx+10*s, cy], fill=color + (255,))
        # 大角（铲形）
        draw.polygon([(cx-35*s, cy-45*s), (cx-20*s, cy-70*s), (cx-5*s, cy-45*s)],
                     fill=darker + (255,))
        draw.polygon([(cx+35*s, cy-45*s), (cx+20*s, cy-70*s), (cx+5*s, cy-45*s)],
                     fill=darker + (255,))
        # 眼睛
        draw.ellipse([cx-12*s, cy-28*s, cx-6*s, cy-22*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+6*s, cy-28*s, cx+12*s, cy-22*s], fill=(0, 0, 0, 255))

    elif card_id == "ox":
        # 牛
        draw.ellipse([cx-28*s, cy-12*s, cx+28*s, cy+28*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-22*s, cy-35*s, cx+22*s, cy-8*s], fill=color + (255,))
        # 牛角
        draw.polygon([(cx-25*s, cy-30*s), (cx-35*s, cy-55*s), (cx-15*s, cy-35*s)],
                     fill=(200, 180, 150, 255))
        draw.polygon([(cx+25*s, cy-30*s), (cx+35*s, cy-55*s), (cx+15*s, cy-35*s)],
                     fill=(200, 180, 150, 255))
        # 鼻环
        draw.ellipse([cx-5*s, cy-10*s, cx+5*s, cy-2*s], outline=(200, 180, 0, 255), width=2*s)
        # 眼睛
        draw.ellipse([cx-15*s, cy-25*s, cx-8*s, cy-18*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+8*s, cy-25*s, cx+15*s, cy-18*s], fill=(0, 0, 0, 255))

    elif card_id == "boar":
        # 野猪
        draw.ellipse([cx-25*s, cy-10*s, cx+25*s, cy+25*s], fill=color + (255,))
        # 头（尖）
        draw.polygon([(cx-20*s, cy-30*s), (cx+20*s, cy-30*s), (cx+15*s, cy-5*s), (cx-15*s, cy-5*s)],
                     fill=color + (255,))
        # 獠牙
        draw.polygon([(cx-8*s, cy-12*s), (cx-15*s, cy-2*s), (cx-5*s, cy-8*s)], fill=(255, 255, 230, 255))
        draw.polygon([(cx+8*s, cy-12*s), (cx+15*s, cy-2*s), (cx+5*s, cy-8*s)], fill=(255, 255, 230, 255))
        # 眼睛
        draw.ellipse([cx-12*s, cy-22*s, cx-6*s, cy-16*s], fill=(200, 50, 50, 255))
        draw.ellipse([cx+6*s, cy-22*s, cx+12*s, cy-16*s], fill=(200, 50, 50, 255))

    elif card_id == "shark":
        # 鲨鱼
        # 身体（流线型）
        draw.polygon([(cx-30*s, cy), (cx+30*s, cy-10*s), (cx+25*s, cy+15*s)], fill=color + (255,))
        # 背鳍
        draw.polygon([(cx-5*s, cy-10*s), (cx+5*s, cy-35*s), (cx+15*s, cy-10*s)], fill=color + (255,))
        # 尾鳍
        draw.polygon([(cx+25*s, cy), (cx+40*s, cy-15*s), (cx+40*s, cy+10*s)], fill=color + (255,))
        # 眼睛
        draw.ellipse([cx-20*s, cy-5*s, cx-15*s, cy], fill=(0, 0, 0, 255))
        # 牙齿
        for i in range(5):
            draw.polygon([(cx-10*s+i*4*s, cy+8*s), (cx-8*s+i*4*s, cy+12*s), (cx-6*s+i*4*s, cy+8*s)],
                         fill=(255, 255, 255, 255))

    elif card_id == "kraken":
        # 海妖
        # 主体
        draw.ellipse([cx-25*s, cy-25*s, cx+25*s, cy+20*s], fill=color + (255,))
        # 触手
        for i in range(8):
            angle = i * 45
            rad = math.radians(angle)
            x1 = cx + math.cos(rad) * 25*s
            y1 = cy + 10*s + math.sin(rad) * 15*s
            x2 = cx + math.cos(rad) * 40*s
            y2 = cy + 25*s + math.sin(rad) * 25*s
            draw.line([(x1, y1), (x2, y2)], fill=color + (255,), width=6*s)
        # 眼睛（大）
        draw.ellipse([cx-12*s, cy-15*s, cx+12*s, cy+5*s], fill=(255, 200, 0, 255))
        draw.ellipse([cx-5*s, cy-10*s, cx+5*s, cy], fill=(0, 0, 0, 255))

    elif card_id == "dragon":
        # 龙
        # 身体
        draw.ellipse([cx-30*s, cy-10*s, cx+30*s, cy+25*s], fill=color + (255,))
        # 头
        draw.ellipse([cx-20*s, cy-40*s, cx+20*s, cy-10*s], fill=color + (255,))
        # 翅膀
        draw.polygon([(cx-20*s, cy-5*s), (cx-45*s, cy-30*s), (cx-15*s, cy+10*s)], fill=color + (200,))
        draw.polygon([(cx+20*s, cy-5*s), (cx+45*s, cy-30*s), (cx+15*s, cy+10*s)], fill=color + (200,))
        # 角
        draw.polygon([(cx-15*s, cy-35*s), (cx-20*s, cy-55*s), (cx-8*s, cy-38*s)], fill=(150, 50, 50, 255))
        draw.polygon([(cx+15*s, cy-35*s), (cx+20*s, cy-55*s), (cx+8*s, cy-38*s)], fill=(150, 50, 50, 255))
        # 眼睛
        draw.ellipse([cx-12*s, cy-30*s, cx-5*s, cy-22*s], fill=(255, 200, 0, 255))
        draw.ellipse([cx+5*s, cy-30*s, cx+12*s, cy-22*s], fill=(255, 200, 0, 255))
        # 喷火
        draw.polygon([(cx, cy-15*s), (cx-10*s, cy+5*s), (cx+10*s, cy+5*s)], fill=(255, 150, 50, 200))

    else:
        # 默认大型
        draw.ellipse([cx-28*s, cy-15*s, cx+28*s, cy+28*s], fill=color + (255,))
        draw.ellipse([cx-20*s, cy-35*s, cx+20*s, cy-8*s], fill=color + (255,))
        draw.ellipse([cx-12*s, cy-25*s, cx-5*s, cy-18*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+5*s, cy-25*s, cx+12*s, cy-18*s], fill=(0, 0, 0, 255))

def draw_bug(draw, cx, cy, color, scale, card_id="spider"):
    """绘制节肢动物"""
    s = scale

    if card_id == "spider":
        # 蜘蛛
        # 身体（两部分）
        draw.ellipse([cx-12*s, cy-25*s, cx+12*s, cy-5*s], fill=color + (255,))  # 头
        draw.ellipse([cx-15*s, cy-5*s, cx+15*s, cy+20*s], fill=color + (255,))  # 腹
        # 腿（8条）
        for i in range(4):
            offset = i * 8 * s
            # 左腿
            draw.line([(cx-12*s, cy+offset-15*s), (cx-30*s, cy+offset-20*s)], fill=color + (255,), width=2*s)
            # 右腿
            draw.line([(cx+12*s, cy+offset-15*s), (cx+30*s, cy+offset-20*s)], fill=color + (255,), width=2*s)
        # 眼睛（多眼）
        for ox in [-6, -2, 2, 6]:
            draw.ellipse([cx+ox*s-2*s, cy-20*s, cx+ox*s+2*s, cy-15*s], fill=(255, 0, 0, 255))

    elif card_id == "assassin_bug":
        # 刺客虫
        draw.ellipse([cx-10*s, cy-20*s, cx+10*s, cy+15*s], fill=color + (255,))
        draw.ellipse([cx-8*s, cy-30*s, cx+8*s, cy-18*s], fill=color + (255,))
        # 镰刀前肢
        draw.line([(cx-10*s, cy-10*s), (cx-25*s, cy-25*s)], fill=color + (255,), width=3*s)
        draw.line([(cx+10*s, cy-10*s), (cx+25*s, cy-25*s)], fill=color + (255,), width=3*s)
        # 眼睛
        draw.ellipse([cx-6*s, cy-26*s, cx-2*s, cy-22*s], fill=(255, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-26*s, cx+6*s, cy-22*s], fill=(255, 0, 0, 255))

    elif card_id == "snail":
        # 蜗牛
        darker = tuple(max(0, c-20) for c in color)
        # 壳（螺旋）
        draw.ellipse([cx-20*s, cy-15*s, cx+10*s, cy+20*s], fill=color + (255,))
        # 壳纹
        draw.arc([cx-18*s, cy-12*s, cx+8*s, cy+17*s], 0, 300, fill=darker + (200,), width=2*s)
        # 身体
        draw.ellipse([cx-5*s, cy+10*s, cx+25*s, cy+25*s], fill=(180, 160, 140, 255))
        # 触角
        draw.line([(cx+15*s, cy+10*s), (cx+10*s, cy-10*s)], fill=(180, 160, 140, 255), width=2*s)
        draw.line([(cx+20*s, cy+10*s), (cx+25*s, cy-10*s)], fill=(180, 160, 140, 255), width=2*s)
        # 触角眼
        draw.ellipse([cx+8*s, cy-12*s, cx+12*s, cy-8*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+23*s, cy-12*s, cx+27*s, cy-8*s], fill=(0, 0, 0, 255))

    elif card_id == "gem_crab":
        # 宝石蟹
        draw.ellipse([cx-22*s, cy-10*s, cx+22*s, cy+20*s], fill=color + (255,))
        # 钳子
        draw.ellipse([cx-35*s, cy-5*s, cx-20*s, cy+15*s], fill=color + (255,))
        draw.ellipse([cx+20*s, cy-5*s, cx+35*s, cy+15*s], fill=color + (255,))
        # 宝石（中心）
        draw.polygon([(cx, cy-5*s), (cx-8*s, cy+5*s), (cx, cy+15*s), (cx+8*s, cy+5*s)],
                     fill=(100, 200, 255, 255))
        # 眼睛（柄眼）
        draw.line([(cx-8*s, cy-10*s), (cx-12*s, cy-25*s)], fill=color + (255,), width=2*s)
        draw.line([(cx+8*s, cy-10*s), (cx+12*s, cy-25*s)], fill=color + (255,), width=2*s)
        draw.ellipse([cx-15*s, cy-28*s, cx-9*s, cy-22*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+9*s, cy-28*s, cx+15*s, cy-22*s], fill=(0, 0, 0, 255))

    else:
        # 默认虫子
        draw.ellipse([cx-15*s, cy-15*s, cx+15*s, cy+15*s], fill=color + (255,))
        draw.ellipse([cx-10*s, cy-25*s, cx+10*s, cy-12*s], fill=color + (255,))
        draw.ellipse([cx-6*s, cy-20*s, cx-2*s, cy-16*s], fill=(0, 0, 0, 255))
        draw.ellipse([cx+2*s, cy-20*s, cx+6*s, cy-16*s], fill=(0, 0, 0, 255))

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