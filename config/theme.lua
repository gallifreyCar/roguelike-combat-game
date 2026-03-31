-- config/theme.lua - 主题系统
-- 统一颜色管理，支持主题切换和动画效果
-- 增强视觉层次：标题/正文/提示 对比度优化

local Theme = {}

-- 当前主题
local current_theme = "dark"

-- 主题定义（增强版：更好的视觉层次）
local themes = {
    dark = {
        -- 背景色（层次分明）
        bg_primary = {0.08, 0.06, 0.05},
        bg_secondary = {0.06, 0.08, 0.1},
        bg_card = {0.15, 0.28, 0.15},
        bg_card_enemy = {0.28, 0.15, 0.15},
        bg_panel = {0.1, 0.08, 0.06},
        bg_button = {0.18, 0.28, 0.18},
        bg_button_hover = {0.28, 0.45, 0.28},
        bg_slot = {0.15, 0.12, 0.10},
        bg_slot_hover = {0.22, 0.30, 0.22},

        -- 文字色（增强对比度）
        text_title = {1, 0.88, 0.55},     -- 标题：明亮金色，最强对比
        text_primary = {1, 0.95, 0.85},   -- 正文：明亮暖白
        text_secondary = {0.78, 0.68, 0.48}, -- 次级：略暗暖色
        text_hint = {0.48, 0.42, 0.38},   -- 提示：明显较暗
        text_value = {1, 1, 1},           -- 数值：纯白突出
        text_success = {0.5, 1, 0.5},     -- 成功：绿色
        text_warning = {1, 0.85, 0.3},    -- 警告：黄色

        -- 强调色（更鲜明）
        accent_gold = {1, 0.82, 0.32},
        accent_red = {0.85, 0.25, 0.25},
        accent_green = {0.35, 0.75, 0.35},
        accent_blue = {0.45, 0.65, 0.85},
        accent_yellow = {1, 1, 0.55},
        accent_purple = {0.65, 0.35, 0.85},
        accent_orange = {1, 0.6, 0.25},

        -- 动画发光色（更柔和）
        glow_white = {1, 1, 1},
        glow_gold = {1, 0.92, 0.65},
        glow_green = {0.55, 1, 0.55},
        glow_red = {1, 0.45, 0.45},
        glow_blue = {0.65, 0.85, 1},

        -- 边框色
        border_normal = {0.48, 0.48, 0.48},
        border_highlight = {1, 1, 0.95},
        border_gold = {0.62, 0.52, 0.35},
        border_glow = {1, 0.95, 0.75},

        -- 状态色（更清晰）
        hp_high = {0.35, 0.75, 0.35},
        hp_mid = {0.85, 0.72, 0.25},
        hp_low = {0.85, 0.35, 0.35},
        hp_critical = {1, 0.25, 0.25},
        blood = {1, 0.82, 0.35},

        -- 节点类型颜色（更鲜明）
        node_battle = {0.85, 0.35, 0.35},
        node_elite = {0.85, 0.55, 0.25},
        node_reward = {0.35, 0.75, 0.35},
        node_shop = {0.55, 0.55, 0.85},
        node_event = {0.75, 0.75, 0.35},
        node_boss = {0.65, 0.25, 0.25},
        node_start = {0.45, 0.45, 0.45},

        -- 意图颜色
        intent_attack = {1, 0.35, 0.35},
        intent_defend = {0.35, 0.65, 1},
        intent_buff = {1, 0.82, 0.35},

        -- 粒子颜色
        particle_attack = {1, 0.92, 0.65},
        particle_heal = {0.35, 1, 0.55},
        particle_death = {0.85, 0.35, 0.35},
        particle_victory = {1, 0.88, 0.25},
        particle_place = {1, 0.92, 0.55},
    },
}

-- 获取颜色
function Theme.color(name)
    local theme = themes[current_theme]
    if theme and theme[name] then
        return theme[name]
    end
    return {1, 1, 1} -- 默认白色
end

-- 设置颜色（便捷方法）
function Theme.setColor(name, alpha)
    local c = Theme.color(name)
    alpha = alpha or 1
    love.graphics.setColor(c[1], c[2], c[3], alpha)
end

-- 切换主题
function Theme.set_theme(name)
    if themes[name] then
        current_theme = name
    end
end

-- 获取当前主题名
function Theme.get_theme()
    return current_theme
end

-- 获取节点类型颜色
function Theme.node_color(node_type)
    local mapping = {
        battle = "node_battle",
        elite = "node_elite",
        reward = "node_reward",
        shop = "node_shop",
        event = "node_event",
        boss = "node_boss",
        start = "node_start",
    }
    return Theme.color(mapping[node_type] or "node_battle")
end

return Theme