-- config/settings.lua - 游戏配置
-- 全局游戏设置常量

local Settings = {
    -- 屏幕尺寸
    screen_width = 1280,
    screen_height = 720,

    -- 战斗配置
    board_slots = 4,
    player_max_hp = 20,
    max_blood = 6,

    -- 卡牌尺寸
    card_width = 100,
    card_height = 130,
    card_small_height = 80,

    -- 手牌配置
    hand_x = 1100,
    hand_y = 100,
    hand_card_gap = 90,
    max_hand_size = 10,

    -- UI布局
    ui_title_height = 45,
    ui_enemy_area_y = 50,
    ui_separator_y = 235,
    ui_player_board_y = 270,
    ui_button_area_y = 435,
    ui_status_bar_y = 510,
    ui_hint_y = 550,

    -- 按钮尺寸
    button_width = 160,
    button_height = 55,

    -- 格子布局
    board_start_x = 150,
    board_slot_gap = 130,

    -- 战斗动画
    battle_animation_speed = 0.5,
    damage_display_time = 1.5,
    death_animation_time = 0.3,

    -- 难度配置
    enemy_hp_base = 10,
    enemy_hp_per_level = 2,

    -- 抽牌概率
    draw_prob_squirrel = 0.40,
    draw_prob_common = 0.35,
    draw_prob_uncommon = 0.20,
    draw_prob_rare = 0.05,
}

return Settings