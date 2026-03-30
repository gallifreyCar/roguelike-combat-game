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
    return {
        x = Layout.card_slot(1, 4),
        y = Settings.ui_enemy_area_y,
        width = Settings.card_width,
        height = Settings.card_height,
    }
end

-- 玩家棋盘区域
function Layout.player_board()
    local Settings = require("config.settings")
    return {
        x = Layout.card_slot(1, 4),
        y = Settings.ui_player_board_y,
        width = Settings.card_width,
        height = Settings.card_height,
    }
end

-- 手牌面板
function Layout.hand_panel()
    local Settings = require("config.settings")
    local w, h = Layout.get_size()
    return {
        x = w - 180,
        y = 50,
        width = 180,
        height = h - 100,
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
        y = Settings.ui_button_area_y + 5,
        width = btn_w,
        height = btn_h,
    }
end

-- 状态栏
function Layout.status_bar()
    local Settings = require("config.settings")
    local w = Layout.get_size()
    return {
        x = 50,
        y = Settings.ui_status_bar_y,
        width = w - 100,
        height = 35,
    }
end

-- 底部按钮区域
function Layout.bottom_buttons(button_count, button_width, button_height, gap)
    gap = gap or 50
    local w, h = Layout.get_size()
    local total_width = button_count * button_width + (button_count - 1) * gap
    local start_x = (w - total_width) / 2
    local y = h - 100

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

return Layout