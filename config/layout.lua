-- config/layout.lua - 响应式布局系统
-- 统一管理所有 UI 元素位置，支持动态窗口尺寸

local Layout = {}

-- 基准尺寸（设计稿）
local DESIGN_WIDTH = 1280
local DESIGN_HEIGHT = 720

-- 获取当前窗口尺寸
function Layout.get_size()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

-- 获取缩放比例
function Layout.get_scale()
    local w, h = Layout.get_size()
    return w / DESIGN_WIDTH, h / DESIGN_HEIGHT
end

-- 居中计算
function Layout.center_x(width)
    local w = Layout.get_size()
    return (w - width) / 2
end

function Layout.center_y(height)
    local _, h = Layout.get_size()
    return (h - height) / 2
end

-- 居中位置（返回 x, y）
function Layout.center(width, height)
    return Layout.center_x(width), Layout.center_y(height)
end

-- 相对定位（百分比）
function Layout.relative(x_percent, y_percent)
    local w, h = Layout.get_size()
    return w * x_percent, h * y_percent
end

-- 相对定位（仅 X）
function Layout.relative_x(x_percent)
    return Layout.get_size() * x_percent
end

-- 相对定位（仅 Y）
function Layout.relative_y(y_percent)
    local _, h = Layout.get_size()
    return h * y_percent
end

-- 卡牌布局
function Layout.card_slot(index, total_slots)
    local Settings = require("config.settings")
    local w = Layout.get_size()
    local slot_gap = Settings.board_slot_gap
    local card_width = Settings.card_width
    local total_width = total_slots * card_width + (total_slots - 1) * (slot_gap - card_width)
    local start_x = (w - total_width) / 2

    return start_x + (index - 1) * slot_gap
end

-- 敌人区域
function Layout.enemy_area()
    local Settings = require("config.settings")
    local _, h = Layout.get_size()
    return {
        x = Layout.card_slot(1, 4),
        y = h * 0.07,  -- 相对位置
        width = Settings.card_width,
        height = Settings.card_height,
    }
end

-- 玩家棋盘区域
function Layout.player_board()
    local Settings = require("config.settings")
    local _, h = Layout.get_size()
    return {
        x = Layout.card_slot(1, 4),
        y = h * 0.375,  -- 相对位置
        width = Settings.card_width,
        height = Settings.card_height,
    }
end

-- 手牌面板
function Layout.hand_panel()
    local Settings = require("config.settings")
    local w, h = Layout.get_size()
    return {
        x = w - w * 0.14,  -- 右侧 14% 宽度
        y = h * 0.07,
        width = w * 0.14,
        height = h * 0.86,
    }
end

-- 战斗按钮
function Layout.battle_button()
    local Settings = require("config.settings")
    local w, h = Layout.get_size()
    local btn_w = Settings.button_width
    local btn_h = Settings.button_height
    return {
        x = (w - btn_w) / 2,
        y = h * 0.605,
        width = btn_w,
        height = btn_h,
    }
end

-- 状态栏
function Layout.status_bar()
    local w, h = Layout.get_size()
    return {
        x = w * 0.04,
        y = h * 0.71,
        width = w * 0.72,
        height = h * 0.05,
    }
end

-- 敌人 HP 条
function Layout.enemy_hp_bar()
    local w, h = Layout.get_size()
    return {
        x = w * 0.82,
        y = h * 0.01,
        width = w * 0.14,
        height = h * 0.04,
    }
end

-- 标题栏
function Layout.title_bar()
    local w, h = Layout.get_size()
    return {
        x = 0,
        y = 0,
        width = w,
        height = h * 0.06,
    }
end

-- 分隔线区域
function Layout.separator()
    local w, h = Layout.get_size()
    return {
        x = w * 0.08,
        y = h * 0.33,
        width = w * 0.68,
        height = h * 0.04,
    }
end

-- 提示文本位置（移到底部，避免遮挡）
function Layout.hint_position()
    local w, h = Layout.get_size()
    return w * 0.04, h * 0.94  -- 移到底部 94%
end

-- 战斗日志位置
function Layout.combat_log()
    local w, h = Layout.get_size()
    return {
        x = w * 0.55,
        y = h * 0.21,
    }
end

-- 消息显示位置
function Layout.message_position()
    local w, h = Layout.get_size()
    return w * 0.23, h * 0.08
end

-- 底部按钮区域
function Layout.bottom_buttons(button_count, button_width, button_height, gap)
    gap = gap or 50
    local w, h = Layout.get_size()
    local total_width = button_count * button_width + (button_count - 1) * gap
    local start_x = (w - total_width) / 2
    local y = h * 0.86

    local buttons = {}
    for i = 1, button_count do
        buttons[i] = {
            x = start_x + (i - 1) * (button_width + gap),
            y = y,
            width = button_width,
            height = button_height,
        }
    end
    return buttons
end

-- 菜单按钮（垂直排列）
function Layout.menu_buttons(button_count, button_width, button_height, gap)
    gap = gap or 15
    local w, h = Layout.get_size()
    local start_x = (w - button_width) / 2
    local total_height = button_count * button_height + (button_count - 1) * gap
    local start_y = (h - total_height) * 0.65  -- 略微偏上居中

    local buttons = {}
    for i = 1, button_count do
        buttons[i] = {
            x = start_x,
            y = start_y + (i - 1) * (button_height + gap),
            width = button_width,
            height = button_height,
        }
    end
    return buttons
end

-- 检测点是否在矩形内
function Layout.in_rect(px, py, rect)
    return px >= rect.x and px <= rect.x + rect.width and
           py >= rect.y and py <= rect.y + rect.height
end

-- 鼠标是否在按钮上
function Layout.mouse_in_button(button)
    local mx, my = love.mouse.getPosition()
    return Layout.in_rect(mx, my, button)
end

-- 鼠标是否在矩形内（直接参数版本）
function Layout.mouse_in_rect(x, y, width, height)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

return Layout