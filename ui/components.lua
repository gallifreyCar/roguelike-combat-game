-- ui/components.lua - UI 组件库
-- 通用 UI 组件：Button、Panel、Card、ProgressBar

local Components = {}
local Theme = require("config.theme")
local Layout = require("config.layout")
local Fonts = require("core.fonts")

-- ==================== Button 组件 ====================

function Components.button(text, x, y, width, height, options)
    options = options or {}
    local hover = options.hover or Layout.mouse_in_button({x = x, y = y, width = width, height = height})
    local style = options.style or "default"

    -- 样式映射
    local styles = {
        default = {
            bg = hover and "bg_button_hover" or "bg_button",
            border = "border_normal",
            text = "text_primary",
        },
        primary = {
            bg = hover and "accent_green" or "bg_button",
            border = "border_highlight",
            text = "text_primary",
        },
        danger = {
            bg = hover and "accent_red" or "bg_card_enemy",
            border = "border_normal",
            text = "text_primary",
        },
    }

    local s = styles[style] or styles.default
    local radius = options.radius or 6

    -- 绘制背景
    Theme.setColor(s.bg)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    -- 绘制边框
    Theme.setColor(hover and "border_highlight" or s.border)
    love.graphics.rectangle("line", x, y, width, height, radius, radius)

    -- 绘制文字
    Theme.setColor(s.text)
    local text_x = x + (width - Fonts.get():getWidth(text)) / 2
    local text_y = y + (height - 16) / 2
    Fonts.print(text, text_x, text_y, options.font_size or 14)
end

-- ==================== Panel 组件 ====================

function Components.panel(x, y, width, height, options)
    options = options or {}
    local radius = options.radius or 8
    local bg_color = options.bg or "bg_panel"
    local border_color = options.border

    Theme.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    if border_color then
        Theme.setColor(border_color)
        love.graphics.rectangle("line", x, y, width, height, radius, radius)
    end
end

-- ==================== ProgressBar 组件 ====================

function Components.progress_bar(x, y, width, height, value, max_value, options)
    options = options or {}
    local radius = options.radius or 4
    local bg_color = options.bg or "bg_slot"
    local fill_color = options.fill or "accent_green"

    -- 背景
    Theme.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    -- 填充
    local fill_width = (value / max_value) * width
    if fill_width > 0 then
        Theme.setColor(fill_color)
        love.graphics.rectangle("fill", x, y, fill_width, height, radius, radius)
    end
end

-- ==================== Card 组件 ====================

function Components.card(data, x, y, options)
    options = options or {}
    local width = options.width or 100
    local height = options.height or 130
    local is_enemy = options.is_enemy or false
    local hover = options.hover

    -- 背景
    local bg = is_enemy and "bg_card_enemy" or "bg_card"
    Theme.setColor(bg)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)

    -- 边框
    Theme.setColor(hover and "border_highlight" or "border_gold")
    love.graphics.rectangle("line", x, y, width, height, 5, 5)

    -- 名称
    Theme.setColor("text_primary")
    Fonts.print(data.name or "", x + 8, y + 6, 14)

    -- 费用（红圈）
    if data.cost then
        Theme.setColor("accent_red")
        love.graphics.circle("fill", x + 15, y + 45, 14)
        Theme.setColor("text_value")
        Fonts.print(tostring(data.cost), x + 11, y + 38, 14)
    end

    -- 属性
    Theme.setColor("accent_gold")
    Fonts.print("ATK:" .. (data.attack or 0), x + 8, y + 50, 11)

    Theme.setColor("accent_red")
    Fonts.print("HP:" .. (data.hp or 0), x + 55, y + 50, 11)

    -- 血量条
    if data.max_hp and data.max_hp > 0 then
        local hp_ratio = data.hp / data.max_hp
        local bar_color = hp_ratio > 0.5 and "hp_high" or (hp_ratio > 0.25 and "hp_mid" or "hp_low")
        Components.progress_bar(x + 8, y + 95, 84, 10, data.hp, data.max_hp, {
            fill = bar_color,
            bg = "bg_slot",
        })
    end
end

-- ==================== Text 组件 ====================

function Components.text(text, x, y, options)
    options = options or {}
    local color = options.color or "text_primary"
    local size = options.size or 16
    local align = options.align or "left"

    if align == "center" then
        x = x - Fonts.get(size):getWidth(text) / 2
    elseif align == "right" then
        x = x - Fonts.get(size):getWidth(text)
    end

    Theme.setColor(color)
    Fonts.print(text, x, y, size)
end

-- ==================== Tooltip 组件 ====================

function Components.tooltip(text, x, y, options)
    options = options or {}
    local padding = options.padding or 10
    local font_size = options.font_size or 12
    local width = Fonts.get(font_size):getWidth(text) + padding * 2
    local height = font_size + padding * 2

    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", x, y, width, height, 4, 4)

    Theme.setColor("text_primary")
    Fonts.print(text, x + padding, y + padding / 2, font_size)
end

return Components