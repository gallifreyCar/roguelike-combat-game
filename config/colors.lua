-- config/colors.lua - 游戏颜色配置
-- 统一管理所有颜色，便于主题切换

local Colors = {
    -- 背景
    bg_main = {0.08, 0.06, 0.05},
    bg_panel = {0.1, 0.08, 0.06},
    bg_title = {0.15, 0.12, 0.1},

    -- 文字
    text_primary = {1, 1, 1},
    text_secondary = {0.7, 0.65, 0.5},
    text_hint = {0.5, 0.45, 0.4},
    text_gold = {1, 0.85, 0.2},

    -- 卡牌
    card_player_bg = {0.22, 0.32, 0.22},
    card_enemy_bg = {0.32, 0.22, 0.22},
    card_border = {0.5, 0.4, 0.25},
    card_highlight = {0.7, 0.6, 0.4},
    card_hover_bg = {0.35, 0.45, 0.35},
    card_small_bg = {0.25, 0.22, 0.18},

    -- Cost
    cost_bg = {0.15, 0.15, 0.15},
    cost_text = {0.9, 0.4, 0.3},

    -- 属性
    attack_text = {1, 0.75, 0.3},
    hp_text = {0.4, 0.8, 0.4},

    -- 血量条
    hp_bar_bg = {0.2, 0.2, 0.2},
    hp_bar_fill = {0.3, 0.7, 0.3},
    hp_bar_player = {0.2, 0.4, 0.7},
    hp_bar_enemy = {0.8, 0.2, 0.2},

    -- 格子
    slot_empty = {0.18, 0.15, 0.12},
    slot_valid = {0.25, 0.35, 0.25},
    slot_invalid = {0.35, 0.25, 0.25},
    slot_border = {0.35, 0.28, 0.2},

    -- 按钮
    button_primary = {0.2, 0.35, 0.2},
    button_hover = {0.3, 0.5, 0.3},
    button_border = {0.5, 0.7, 0.5},
    button_text = {1, 0.95, 0.7},

    -- 状态
    blood_bg = {0.6, 0.2, 0.2},
    blood_text = {1, 0.8, 0.3},

    -- 特效
    sigil_text = {0.9, 0.7, 0.5},
    drag_hint = {0.6, 0.6, 0.4},

    -- 分隔线
    separator_bg = {0.25, 0.2, 0.15},
    separator_text = {0.6, 0.5, 0.3},
}

return Colors