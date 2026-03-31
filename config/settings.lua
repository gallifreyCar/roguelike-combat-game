-- config/settings.lua - 游戏配置
-- 全局游戏设置常量 - 单一真相来源

local Settings = {
    -- ==================== 屏幕配置 ====================
    screen_width = 1280,
    screen_height = 720,
    design_width = 1280,
    design_height = 720,

    -- ==================== 战斗配置 ====================
    board_slots = 4,
    player_max_hp = 20,
    max_blood = 3,        -- 血量上限改为3
    starting_blood = 1,   -- 起始1血

    -- ==================== 卡牌尺寸 ====================
    card_width = 120,     -- 增大卡牌宽度
    card_height = 160,    -- 增大卡牌高度
    card_small_width = 120,
    card_small_height = 90,
    card_radius = 6,

    -- ==================== 手牌配置 ====================
    hand_x = 1100,
    hand_y = 100,
    hand_card_gap = 105,  -- 调整间距
    max_hand_size = 8,

    -- ==================== UI 布局 ====================
    ui_title_height = 45,
    ui_enemy_area_y = 50,
    ui_separator_y = 235,
    ui_player_board_y = 270,
    ui_button_area_y = 435,
    ui_status_bar_y = 510,
    ui_hint_y = 550,

    -- ==================== 按钮尺寸 ====================
    button_width = 160,
    button_height = 55,
    button_small_width = 150,
    button_small_height = 40,
    button_radius = 6,

    -- ==================== 格子布局 ====================
    board_start_x = 150,
    board_slot_gap = 130,

    -- ==================== 敌人区域 ====================
    enemy_hp_bar_x = 1050,
    enemy_hp_bar_y = 8,
    enemy_hp_bar_width = 180,
    enemy_hp_bar_height = 32,

    -- ==================== 战斗动画 ====================
    battle_animation_speed = 0.5,
    damage_display_time = 1.5,
    death_animation_time = 0.3,

    -- ==================== 难度配置 ====================
    enemy_hp_base = 10,
    enemy_hp_per_level = 2,

    -- ==================== 抽牌概率 ====================
    draw_prob_squirrel = 0.40,
    draw_prob_common = 0.35,
    draw_prob_uncommon = 0.20,
    draw_prob_rare = 0.05,

    -- ==================== 战斗日志 ====================
    combat_log_max = 5,
    combat_log_display_time = 2.0,

    -- ==================== 地图配置 ====================
    map_rows = 8,
    map_min_nodes = 3,
    map_max_nodes = 4,
    map_node_width = 100,
    map_node_height = 50,
    map_node_spacing = 150,
    map_row_spacing = 70,

    -- ==================== 节点权重 ====================
    node_weight_battle = 0.50,
    node_weight_elite = 0.15,
    node_weight_reward = 0.15,
    node_weight_shop = 0.10,
    node_weight_event = 0.10,

    -- ==================== 面板配置 ====================
    panel_radius = 8,

    -- ==================== 调试配置 ====================
    debug_mode = false,
    show_fps = false,
    show_hitboxes = false,
}

return Settings