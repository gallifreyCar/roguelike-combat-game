-- ui/button.lua - 可复用按钮组件
-- 提供按钮渲染、悬停检测、点击回调（增强动画效果）

local Fonts = require("core.fonts")
local Animation = require("systems.animation")

local Button = {}

-- 按钮动画状态缓存
local button_anim_states = {}

-- 默认样式
local default_style = {
    bg_color = {0.2, 0.35, 0.2},
    bg_hover = {0.3, 0.5, 0.3},
    bg_pressed = {0.15, 0.25, 0.15},
    border_color = {0.5, 0.7, 0.5},
    border_hover = {1, 1, 0.8},
    text_color = {1, 0.95, 0.7},
    radius = 8,
    glow_color = {1, 1, 0.9},
}

-- 创建按钮实例
function Button.create(x, y, width, height, text, style)
    style = style or default_style

    -- 按钮唯一标识
    local btn_id = text .. "_" .. x .. "_" .. y

    -- 初始化动画状态
    if not button_anim_states[btn_id] then
        button_anim_states[btn_id] = {
            hover_progress = 0,
            press_progress = 0,
            glow_pulse = 0,
        }
    end

    return {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        style = style,
        hover = false,
        visible = true,
        enabled = true,
        id = btn_id,
        state = button_anim_states[btn_id],
    }
end

-- 检测鼠标是否在按钮上
function Button.contains(btn, mx, my)
    if not btn.visible or not btn.enabled then return false end
    return mx >= btn.x and mx <= btn.x + btn.width and
           my >= btn.y and my <= btn.y + btn.height
end

-- 更新按钮状态（检测悬停和动画）
function Button.update(btn, mx, my)
    local was_hover = btn.hover
    btn.hover = Button.contains(btn, mx, my)

    -- 悬停动画平滑过渡
    if btn.hover then
        btn.state.hover_progress = math.min(1, btn.state.hover_progress + 0.15)
    else
        btn.state.hover_progress = math.max(0, btn.state.hover_progress - 0.15)
    end

    -- 发光脉冲动画（悬停时）
    if btn.hover then
        btn.state.glow_pulse = (btn.state.glow_pulse + 0.08) % (math.pi * 2)
    end
end

-- 绘制按钮（增强动画效果）
function Button.draw(btn)
    if not btn.visible then return end

    local style = btn.style
    local state = btn.state

    -- 悬停发光效果
    if state.hover_progress > 0 then
        local glow_intensity = state.hover_progress * 0.2
        local pulse = btn.hover and (math.sin(state.glow_pulse) * 0.1 + 0.1) or 0
        love.graphics.setColor(style.glow_color[1], style.glow_color[2], style.glow_color[3], glow_intensity + pulse)
        love.graphics.rectangle("fill", btn.x - 4, btn.y - 4, btn.width + 8, btn.height + 8,
                                style.radius + 2, style.radius + 2)
    end

    -- 背景
    if btn.enabled then
        if btn.hover then
            love.graphics.setColor(style.bg_hover or default_style.bg_hover)
        else
            love.graphics.setColor(style.bg_color or default_style.bg_color)
        end
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
    end
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height,
                            style.radius or default_style.radius,
                            style.radius or default_style.radius)

    -- 边框（悬停时发光）
    if btn.hover then
        love.graphics.setColor(style.border_hover or default_style.border_hover)
    else
        love.graphics.setColor(style.border_color or default_style.border_color)
    end
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height,
                            style.radius or default_style.radius,
                            style.radius or default_style.radius)

    -- 文字
    if btn.enabled then
        love.graphics.setColor(style.text_color or default_style.text_color)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end

    -- 文字居中
    local text_width = Fonts.get():getWidth(btn.text)
    local text_x = btn.x + (btn.width - text_width) / 2
    local text_y = btn.y + (btn.height - 16) / 2
    Fonts.print(btn.text, text_x, text_y)
end

-- 点击处理（带动画效果）
function Button.on_click(btn)
    if not btn.enabled or not btn.hover then return false end

    -- 触发点击动画
    Animation.button_press(btn.x, btn.y, btn.width, btn.height)

    btn.state.press_progress = 1
    return true
end

-- 创建不同风格的按钮
function Button.primary(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.2, 0.4, 0.5},
        bg_hover = {0.3, 0.55, 0.65},
        bg_pressed = {0.15, 0.3, 0.4},
        border_color = {0.4, 0.6, 0.8},
        border_hover = {0.6, 0.8, 1},
        text_color = {1, 1, 1},
        glow_color = {0.6, 0.8, 1},
    })
end

function Button.danger(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.5, 0.25, 0.2},
        bg_hover = {0.6, 0.35, 0.25},
        bg_pressed = {0.4, 0.2, 0.15},
        border_color = {0.8, 0.4, 0.3},
        border_hover = {1, 0.5, 0.4},
        text_color = {1, 0.9, 0.9},
        glow_color = {1, 0.5, 0.4},
    })
end

function Button.success(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.2, 0.35, 0.2},
        bg_hover = {0.25, 0.45, 0.25},
        bg_pressed = {0.15, 0.25, 0.15},
        border_color = {0.4, 0.6, 0.4},
        border_hover = {0.6, 0.9, 0.6},
        text_color = {1, 0.95, 0.7},
        glow_color = {0.6, 1, 0.6},
    })
end

function Button.gold(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.3, 0.25, 0.15},
        bg_hover = {0.4, 0.35, 0.2},
        bg_pressed = {0.25, 0.2, 0.1},
        border_color = {0.6, 0.5, 0.3},
        border_hover = {1, 0.9, 0.6},
        text_color = {1, 0.9, 0.6},
        glow_color = {1, 0.9, 0.6},
    })
end

return Button