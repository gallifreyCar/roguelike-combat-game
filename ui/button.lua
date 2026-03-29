-- ui/button.lua - 可复用按钮组件
-- 提供按钮渲染、悬停检测、点击回调

local Fonts = require("core.fonts")

local Button = {}

-- 默认样式
local default_style = {
    bg_color = {0.2, 0.35, 0.2},
    bg_hover = {0.3, 0.5, 0.3},
    border_color = {0.5, 0.7, 0.5},
    text_color = {1, 0.95, 0.7},
    radius = 8,
}

-- 创建按钮实例
function Button.create(x, y, width, height, text, style)
    style = style or default_style

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
    }
end

-- 检测鼠标是否在按钮上
function Button.contains(btn, mx, my)
    if not btn.visible or not btn.enabled then return false end
    return mx >= btn.x and mx <= btn.x + btn.width and
           my >= btn.y and my <= btn.y + btn.height
end

-- 更新按钮状态（检测悬停）
function Button.update(btn, mx, my)
    btn.hover = Button.contains(btn, mx, my)
end

-- 绘制按钮
function Button.draw(btn)
    if not btn.visible then return end

    local style = btn.style

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

    -- 边框
    love.graphics.setColor(style.border_color or default_style.border_color)
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height,
                            style.radius or default_style.radius,
                            style.radius or default_style.radius)

    -- 文字
    if btn.enabled then
        love.graphics.setColor(style.text_color or default_style.text_color)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    Fonts.print(btn.text, btn.x + 10, btn.y + 10)
end

-- 创建不同风格的按钮
function Button.primary(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.2, 0.4, 0.5},
        bg_hover = {0.3, 0.55, 0.65},
        border_color = {0.4, 0.6, 0.8},
        text_color = {1, 1, 1},
    })
end

function Button.danger(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.5, 0.25, 0.2},
        bg_hover = {0.6, 0.35, 0.25},
        border_color = {0.8, 0.4, 0.3},
        text_color = {1, 0.9, 0.9},
    })
end

function Button.success(x, y, text)
    return Button.create(x, y, 160, 50, text, {
        bg_color = {0.2, 0.35, 0.2},
        bg_hover = {0.25, 0.45, 0.25},
        border_color = {0.4, 0.6, 0.4},
        text_color = {1, 0.95, 0.7},
    })
end

return Button