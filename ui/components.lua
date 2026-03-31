-- ui/components.lua - UI 组件库
-- 通用 UI 组件：Button、Panel、Card、ProgressBar（增强动画效果）
-- 支持 hover/pressed 状态、点击音效、过渡动画

local Components = {}
local Theme = require("config.theme")
local Layout = require("config.layout")
local Fonts = require("core.fonts")
local Animation = require("systems.animation")
local Sound = require("systems.sound")

-- ==================== Button 组件 ====================

-- 按钮动画状态缓存
local button_states = {}

-- 检测按钮是否被点击（用于 pressed 状态）
local pressed_button = nil

function Components.button(text, x, y, width, height, options)
    options = options or {}
    local hover = options.hover or Layout.mouse_in_button({x = x, y = y, width = width, height = height})
    local style = options.style or "default"
    local animate = options.animate ~= false  -- 默认启用动画
    local pressed = options.pressed or false

    -- 按钮唯一标识（用于动画状态）
    local btn_id = text .. "_" .. x .. "_" .. y

    -- 初始化按钮状态
    if not button_states[btn_id] then
        button_states[btn_id] = {
            hover_progress = 0,
            press_progress = 0,
            scale = 1,
            was_hover = false,
            was_pressed = false,
        }
    end

    local state = button_states[btn_id]

    -- 悬停动画平滑过渡
    if hover and not state.was_hover then
        state.hover_progress = 0
        -- 播放悬停音效（首次进入悬停状态）
        if options.sound_hover ~= false then
            Sound.play("hover")
        end
    elseif not hover and state.was_hover then
        state.hover_progress = 1
    end

    -- 更新悬停进度（更快响应）
    if hover then
        state.hover_progress = math.min(1, state.hover_progress + 0.2)
    else
        state.hover_progress = math.max(0, state.hover_progress - 0.15)
    end

    -- 按下动画（快速按下，缓慢恢复）
    if pressed then
        state.press_progress = math.min(1, state.press_progress + 0.4)
        state.scale = 1 - state.press_progress * 0.08
    else
        state.press_progress = math.max(0, state.press_progress - 0.1)
        state.scale = 1 - state.press_progress * 0.08
    end

    state.was_hover = hover
    state.was_pressed = pressed

    -- 样式映射（增强版）
    local styles = {
        default = {
            bg = hover and "bg_button_hover" or "bg_button",
            bg_pressed = "bg_slot",
            border = hover and "border_highlight" or "border_normal",
            border_pressed = "border_normal",
            text = "text_primary",
        },
        primary = {
            bg = hover and "accent_green" or "bg_button",
            bg_pressed = "bg_slot",
            border = hover and "border_highlight" or "border_highlight",
            border_pressed = "border_normal",
            text = hover and "text_value" or "text_primary",
        },
        danger = {
            bg = hover and "accent_red" or "bg_card_enemy",
            bg_pressed = "bg_slot",
            border = hover and "border_glow" or "border_normal",
            border_pressed = "border_normal",
            text = hover and "text_value" or "text_primary",
        },
        success = {
            bg = hover and "accent_green" or "bg_button",
            bg_pressed = "bg_slot",
            border = hover and "border_glow" or "border_highlight",
            border_pressed = "border_normal",
            text = hover and "text_value" or "text_primary",
        },
        gold = {
            bg = hover and "accent_gold" or "bg_button",
            bg_pressed = "bg_slot",
            border = hover and "border_glow" or "border_gold",
            border_pressed = "border_normal",
            text = hover and "text_value" or "text_primary",
        },
    }

    local s = styles[style] or styles.default
    local radius = options.radius or 8

    -- 应用缩放变换
    local scale = state.scale
    local draw_x = x + (width / 2) - (width * scale / 2)
    local draw_y = y + (height / 2) - (height * scale / 2)
    local draw_w = width * scale
    local draw_h = height * scale

    -- 悬停发光效果（增强）
    if state.hover_progress > 0 and not pressed then
        local glow_alpha = state.hover_progress * 0.25
        -- 外发光
        Theme.setColor("glow_gold", glow_alpha)
        love.graphics.rectangle("fill", draw_x - 4, draw_y - 4, draw_w + 8, draw_h + 8, radius + 3, radius + 3)
        -- 内发光
        Theme.setColor("glow_white", glow_alpha * 0.3)
        love.graphics.rectangle("fill", draw_x - 2, draw_y - 2, draw_w + 4, draw_h + 4, radius + 1, radius + 1)
    end

    -- 按下效果（暗色压缩）
    if pressed or state.press_progress > 0 then
        local press_alpha = state.press_progress * 0.4
        Theme.setColor("bg_primary", press_alpha)
        love.graphics.rectangle("fill", draw_x, draw_y, draw_w, draw_h, radius, radius)
    end

    -- 绘制背景
    local bg_color = pressed and s.bg_pressed or s.bg
    Theme.setColor(bg_color)
    love.graphics.rectangle("fill", draw_x, draw_y, draw_w, draw_h, radius, radius)

    -- 绘制边框（悬停时高亮）
    local border_color = pressed and s.border_pressed or s.border
    Theme.setColor(border_color)
    love.graphics.rectangle("line", draw_x, draw_y, draw_w, draw_h, radius, radius)

    -- 绘制文字（居中）
    Theme.setColor(s.text)
    local font = Fonts.get(options.font_size or 16)
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    local text_x = draw_x + (draw_w - text_width) / 2
    local text_y = draw_y + (draw_h - text_height) / 2 - 2
    Fonts.print(text, text_x, text_y, options.font_size or 16)
end

-- 设置按下状态（供外部调用）
function Components.set_pressed(btn_id, pressed)
    if button_states[btn_id] then
        button_states[btn_id].was_pressed = pressed
    end
end

-- 触发按钮点击效果（音效 + 动画）
function Components.trigger_click(btn_id)
    Sound.play("click")
end

-- ==================== Panel 组件 ====================

function Components.panel(x, y, width, height, options)
    options = options or {}
    local radius = options.radius or 8
    local bg_color = options.bg or "bg_panel"
    local border_color = options.border
    local shadow = options.shadow or true  -- 默认添加阴影

    -- 绘制阴影（增加层次感）
    if shadow then
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 3, y + 3, width, height, radius, radius)
    end

    Theme.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    if border_color then
        Theme.setColor(border_color)
        love.graphics.rectangle("line", x, y, width, height, radius, radius)
    end
end

-- ==================== ProgressBar 组件 ====================

-- 进度条动画状态缓存
local progress_states = {}

function Components.progress_bar(x, y, width, height, value, max_value, options)
    options = options or {}
    local radius = options.radius or 4
    local bg_color = options.bg or "bg_slot"
    local fill_color = options.fill or "accent_green"
    local animate = options.animate or true
    local glow = options.glow or false

    -- 进度条唯一标识
    local bar_id = x .. "_" .. y

    -- 计算目标宽度
    local target_width = (value / max_value) * width

    -- 初始化或更新动画状态
    if not progress_states[bar_id] then
        progress_states[bar_id] = {
            current_width = target_width,
            pulse_offset = 0,
        }
    end

    local state = progress_states[bar_id]

    -- 平滑过渡动画
    if animate then
        local diff = target_width - state.current_width
        if math.abs(diff) > 1 then
            state.current_width = state.current_width + diff * 0.1
        else
            state.current_width = target_width
        end
    else
        state.current_width = target_width
    end

    -- 发光脉冲效果（用于HP低于30%时警告）
    if glow then
        state.pulse_offset = (state.pulse_offset + 0.1) % (math.pi * 2)
        local pulse = math.sin(state.pulse_offset) * 0.3 + 0.5
        love.graphics.setColor(1, 0.3, 0.3, pulse * 0.3)
        love.graphics.rectangle("fill", x - 2, y - 2, width + 4, height + 4, radius + 2, radius + 2)
    end

    -- 背景
    Theme.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    -- 填充（使用动画后的宽度）
    local fill_width = state.current_width
    if fill_width > 0 then
        Theme.setColor(fill_color)
        love.graphics.rectangle("fill", x, y, fill_width, height, radius, radius)

        -- 高光效果（顶部白色线条）
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", x, y, fill_width, height / 3, radius, radius)
    end
end

-- ==================== Card 组件 ====================

-- 卡牌动画状态缓存
local card_states = {}

function Components.card(data, x, y, options)
    options = options or {}
    local width = options.width or 100
    local height = options.height or 130
    local is_enemy = options.is_enemy or false
    local hover = options.hover
    local animate = options.animate or true

    -- 卡牌唯一标识
    local card_id = (data.id or "unknown") .. "_" .. x .. "_" .. y

    -- 初始化动画状态
    if not card_states[card_id] then
        card_states[card_id] = {
            hover_progress = 0,
            scale = 1,
        }
    end

    local state = card_states[card_id]

    -- 悬停动画
    if animate then
        if hover then
            state.hover_progress = math.min(1, state.hover_progress + 0.2)
            state.scale = 1 + state.hover_progress * 0.05
        else
            state.hover_progress = math.max(0, state.hover_progress - 0.2)
            state.scale = 1 + state.hover_progress * 0.05
        end
    end

    -- 悬停发光效果
    if state.hover_progress > 0 then
        local glow = state.hover_progress * 0.2
        love.graphics.setColor(1, 1, 0.9, glow)
        love.graphics.rectangle("fill", x - 3, y - 3, width + 6, height + 6, 7, 7)
    end

    -- 背景
    local bg = is_enemy and "bg_card_enemy" or "bg_card"
    Theme.setColor(bg)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)

    -- 边框（悬停时高亮）
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
        -- 低HP时添加发光警告效果
        Components.progress_bar(x + 8, y + 95, 84, 10, data.hp, data.max_hp, {
            fill = bar_color,
            bg = "bg_slot",
            glow = hp_ratio < 0.25,
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

-- ==================== 【性能优化】清理函数 ====================

-- 清理按钮状态缓存（场景切换时调用）
function Components.clear_buttons()
    button_states = {}
end

-- 清理进度条状态缓存
function Components.clear_progress_bars()
    progress_states = {}
end

-- 清理卡牌状态缓存
function Components.clear_cards()
    card_states = {}
end

-- 清理所有动画状态缓存（防止内存泄漏）
function Components.clear_all()
    button_states = {}
    progress_states = {}
    card_states = {}
end

return Components