-- config/theme.lua - 主题系统
-- 统一颜色管理，支持主题切换

local Theme = {}

-- 当前主题
local current_theme = "dark"

-- 主题定义
local themes = {
    dark = {
        -- 背景色
        bg_primary = {0.08, 0.06, 0.05},
        bg_secondary = {0.06, 0.08, 0.1},
        bg_card = {0.15, 0.28, 0.15},
        bg_card_enemy = {0.28, 0.15, 0.15},
        bg_panel = {0.1, 0.08, 0.06},
        bg_button = {0.2, 0.35, 0.2},
        bg_button_hover = {0.3, 0.5, 0.3},
        bg_slot = {0.18, 0.15, 0.12},
        bg_slot_hover = {0.25, 0.35, 0.25},

        -- 文字色
        text_primary = {1, 0.95, 0.85},
        text_secondary = {0.8, 0.7, 0.5},
        text_hint = {0.5, 0.45, 0.4},
        text_value = {1, 1, 1},

        -- 强调色
        accent_gold = {1, 0.8, 0.3},
        accent_red = {0.8, 0.2, 0.2},
        accent_green = {0.3, 0.7, 0.3},
        accent_blue = {0.4, 0.6, 0.8},
        accent_yellow = {1, 1, 0.5},

        -- 边框色
        border_normal = {0.5, 0.5, 0.5},
        border_highlight = {1, 1, 1},
        border_gold = {0.6, 0.5, 0.3},

        -- 状态色
        hp_high = {0.3, 0.7, 0.3},
        hp_mid = {0.8, 0.7, 0.2},
        hp_low = {0.8, 0.3, 0.3},
        blood = {1, 0.8, 0.3},

        -- 节点类型颜色
        node_battle = {0.8, 0.3, 0.3},
        node_elite = {0.8, 0.5, 0.2},
        node_reward = {0.3, 0.7, 0.3},
        node_shop = {0.5, 0.5, 0.8},
        node_event = {0.7, 0.7, 0.3},
        node_boss = {0.6, 0.2, 0.2},
        node_start = {0.4, 0.4, 0.4},

        -- 意图颜色
        intent_attack = {1, 0.3, 0.3},
        intent_defend = {0.3, 0.6, 1},
        intent_buff = {1, 0.8, 0.3},
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