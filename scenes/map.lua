-- scenes/map.lua - 关卡地图场景
-- 使用 Theme 和 Components 重构，响应式布局
-- 【Round 3 改进】增强按钮交互、视觉层次、节点悬停效果

local MapScene = {}
local Map = require("systems.map")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Settings = require("config.settings")
local Sound = require("systems.sound")
local Animation = require("systems.animation")
local Deck = require("systems.deck")

local hovered_node = nil
local pressed_node = nil
local pressed_back = false
local hovered_right_btn = nil  -- 右侧按钮悬停状态
local pressed_right_btn = nil

-- 右侧按钮定义
local RIGHT_BUTTONS = {
    { id = "deck", label = "[D] Deck", scene = nil },  -- deck在当前场景用弹窗显示
    { id = "achievements", label = "[A] 成就", scene = "achievements" },
}

-- 节点动画状态缓存
local node_states = {}

function MapScene.enter()
    local map_data = Map.get_map()
    if not map_data.nodes or #map_data.nodes == 0 then
        Map.generate()
    end
    hovered_node = nil
    pressed_node = nil
    pressed_back = false
    node_states = {}

    -- 场景过渡动画
    Animation.fade_in(0.3)
end

function MapScene.exit()
    hovered_node = nil
    pressed_node = nil
    pressed_back = false
    hovered_right_btn = nil
    pressed_right_btn = nil
    node_states = {}
end

-- 获取节点动画状态
local function get_node_state(node_id)
    if not node_states[node_id] then
        node_states[node_id] = {
            hover_progress = 0,
            pulse_offset = 0,
        }
    end
    return node_states[node_id]
end

function MapScene.update(dt)
    local mx, my = love.mouse.getPosition()
    hovered_node = nil
    hovered_right_btn = nil

    local win_w, win_h = Layout.get_size()

    -- 检查右上角按钮悬停
    local btn_width = 100
    local btn_height = 35
    local btn_gap = 10
    local btn_start_x = win_w - btn_width - 15
    local btn_y = 12

    for i, btn in ipairs(RIGHT_BUTTONS) do
        local btn_x = btn_start_x - (i - 1) * (btn_width + btn_gap)
        if mx >= btn_x and mx <= btn_x + btn_width and my >= btn_y and my <= btn_y + btn_height then
            hovered_right_btn = btn.id
            break
        end
    end

    local map_data = Map.get_map()
    local current_row = Map.get_current_row()
    local next_row = current_row + 1
    local next_nodes = Map.get_next_nodes()

    if #next_nodes == 0 then return end

    -- 计算节点位置（响应式）
    local node_w = Settings.map_node_width
    local node_h = Settings.map_node_height
    local spacing = Settings.map_node_spacing

    local node_count = #next_nodes
    local total_width = node_count * node_w + (node_count - 1) * (spacing - node_w)
    local center_x = (win_w - total_width) / 2
    local base_y = win_h * 0.86  -- 使用百分比
    local node_y = base_y - (next_row - 1) * Settings.map_row_spacing

    for col, node in ipairs(next_nodes) do
        local x = center_x + (col - 1) * spacing
        if mx >= x and mx <= x + node_w and my >= node_y and my <= node_y + node_h then
            hovered_node = node
        end

        -- 更新节点动画状态
        local state = get_node_state(node.id or ("node_" .. col))
        if hovered_node == node then
            state.hover_progress = math.min(1, state.hover_progress + 0.15)
            state.pulse_offset = (state.pulse_offset + 0.08) % (math.pi * 2)
        else
            state.hover_progress = math.max(0, state.hover_progress - 0.1)
        end
    end

    -- Animation.update已在main.lua中调用，无需重复
end

function MapScene.draw()
    Theme.setColor("bg_secondary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 【改进】返回按钮（增强悬停效果）
    local back_hover = love.mouse.getX() >= 10 and love.mouse.getX() <= 90 and
                       love.mouse.getY() >= 10 and love.mouse.getY() <= 45

    -- 阴影
    Theme.setColor("bg_primary", 0.35)
    love.graphics.rectangle("fill", 13, 13, 80, 35, 6, 6)

    -- 背景
    local back_color = (pressed_back or back_hover) and "accent_red" or "bg_panel"
    Theme.setColor(back_color, back_hover and 0.55 or 1)
    love.graphics.rectangle("fill", 10, 10, 80, 35, 6, 6)

    -- 边框
    Theme.setColor(back_hover and "border_glow" or "border_normal", back_hover and 0.8 or 0.5)
    love.graphics.rectangle("line", 10, 10, 80, 35, 6, 6)

    -- 文字
    Theme.setColor(back_hover and "text_value" or "text_primary")
    Fonts.print("← ESC", 25, 18, 14)

    -- 标题面板（增强阴影和边框）
    local title_w = win_w * 0.22
    -- 阴影
    Theme.setColor("bg_primary", 0.35)
    love.graphics.rectangle("fill", Layout.center_x(title_w) + 3, win_h * 0.035, title_w, win_h * 0.058, 10, 10)
    -- 主面板
    Components.panel(Layout.center_x(title_w), win_h * 0.03, title_w, win_h * 0.058, {
        bg = "bg_button",
        radius = 10,
    })
    Components.text(I18n.t("map_title"), win_w / 2, win_h * 0.042, {
        color = "text_title",
        size = 18,
        align = "center",
    })

    -- 右上角功能按钮
    local btn_width = 100
    local btn_height = 35
    local btn_gap = 10
    local btn_start_x = win_w - btn_width - 15
    local btn_y = 12

    for i, btn in ipairs(RIGHT_BUTTONS) do
        local btn_x = btn_start_x - (i - 1) * (btn_width + btn_gap)
        local is_hovered = (hovered_right_btn == btn.id)
        local is_pressed = (pressed_right_btn == btn.id)

        -- 阴影
        Theme.setColor("bg_primary", 0.35)
        love.graphics.rectangle("fill", btn_x + 3, btn_y + 3, btn_width, btn_height, 6, 6)

        -- 背景
        local bg_color = is_pressed and "accent_gold" or (is_hovered and "bg_slot_hover" or "bg_panel")
        Theme.setColor(bg_color, is_hovered and 0.8 or 1)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_width, btn_height, 6, 6)

        -- 边框
        Theme.setColor(is_hovered and "border_glow" or "border_normal", is_hovered and 0.8 or 0.5)
        love.graphics.rectangle("line", btn_x, btn_y, btn_width, btn_height, 6, 6)

        -- 文字
        Theme.setColor(is_hovered and "text_value" or "text_primary")
        Fonts.print(btn.label, btn_x + 15, btn_y + 10, 13)
    end

    -- 牌库信息面板（左下角）
    local deck_info = Deck.get_info()
    local info_panel_w = 200
    local info_panel_h = 50
    local info_x = 15
    local info_y = win_h - info_panel_h - 15

    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", info_x, info_y, info_panel_w, info_panel_h, 8, 8)
    Theme.setColor("border_gold", 0.4)
    love.graphics.rectangle("line", info_x, info_y, info_panel_w, info_panel_h, 8, 8)

    Theme.setColor("text_secondary")
    Fonts.print("牌库: " .. deck_info.deck_size .. " 张", info_x + 10, info_y + 8, 12)
    Fonts.print("抽牌堆: " .. deck_info.draw_pile_size .. " | 弃牌堆: " .. deck_info.discard_pile_size, info_x + 10, info_y + 28, 11)

    local map_data = Map.get_map()
    local node_w = Settings.map_node_width
    local node_h = Settings.map_node_height
    local spacing = Settings.map_node_spacing
    local base_y = win_h * 0.86  -- 使用百分比

    -- 绘制所有层（响应式）
    for row, nodes in ipairs(map_data.nodes) do
        local y = base_y - (row - 1) * Settings.map_row_spacing
        local node_count = #nodes
        local total_width = node_count * node_w + (node_count - 1) * (spacing - node_w)
        local center_x = (win_w - total_width) / 2

        -- 层标签（使用 text_hint）
        local label = (row == #map_data.nodes) and I18n.t("boss") or I18n.t("floor") .. " " .. row
        Components.text(label, center_x - win_w * 0.065, y + node_h * 0.55, {
            color = "text_hint",
            size = 12,
        })

        for col, node in ipairs(nodes) do
            local x = center_x + (col - 1) * spacing
            local node_type = Map.get_node_type(node.type)
            local base_color = node_type.color

            -- 获取节点动画状态
            local node_state = get_node_state(node.id or ("node_" .. row .. "_" .. col))
            local is_hovered = (node == hovered_node)
            local is_pressed = (node == pressed_node)

            -- 悬停发光效果
            if is_hovered and node_state.hover_progress > 0 then
                local glow_alpha = node_state.hover_progress * 0.35
                local pulse = math.sin(node_state.pulse_offset) * 0.1 + 0.1
                Theme.setColor("glow_gold", glow_alpha + pulse)
                love.graphics.rectangle("fill", x - 5, y - 5, node_w + 10, node_h + 10, 10, 10)
            end

            -- 节点背景
            if node.completed then
                love.graphics.setColor(0.28, 0.28, 0.32, 0.8)
            elseif is_hovered then
                -- 悬停时更亮
                local brightness = 0.15 + node_state.hover_progress * 0.15
                love.graphics.setColor(base_color[1] + brightness, base_color[2] + brightness, base_color[3] + brightness)
            else
                love.graphics.setColor(base_color[1] * 0.72, base_color[2] * 0.72, base_color[3] * 0.72)
            end
            love.graphics.rectangle("fill", x, y, node_w, node_h, 8, 8)

            -- 节点边框
            if is_hovered then
                Theme.setColor("border_highlight")
            elseif node.completed then
                Theme.setColor("border_normal", 0.5)
            else
                Theme.setColor("border_normal", 0.7)
            end
            love.graphics.rectangle("line", x, y, node_w, node_h, 8, 8)

            -- 节点内容
            Theme.setColor("text_value")
            Fonts.print(node_type.icon, x + node_w * 0.38, y + node_h * 0.08, 18)

            Theme.setColor(node.completed and "text_hint" or "text_primary")
            Fonts.print(node_type.name, x + node_w * 0.18, y + node_h * 0.58, 13)

            -- 已完成标记
            if node.completed then
                Theme.setColor("accent_green")
                Fonts.print(I18n.t("ok"), x + node_w * 0.62, y + node_h * 0.08, 12)
            end
        end
    end

    -- 当前位置指示（增强视觉效果）
    local indicator_pulse = math.sin(love.timer.getTime() * 3) * 0.15 + 0.85
    Components.text("▼ " .. I18n.t("you_are_here"), win_w / 2, win_h * 0.94, {
        color = "accent_yellow",
        align = "center",
        size = 14,
    })

    -- 悬停提示（增强面板）
    if hovered_node then
        local hint_w = win_w * 0.22
        -- 阴影
        Theme.setColor("bg_primary", 0.35)
        love.graphics.rectangle("fill", Layout.center_x(hint_w) + 3, win_h * 0.895, hint_w, win_h * 0.058, 8, 8)
        -- 主面板
        Components.panel(Layout.center_x(hint_w), win_h * 0.89, hint_w, win_h * 0.058, {
            bg = "bg_panel",
            radius = 8,
        })
        Components.text(I18n.t("click_select"), win_w / 2, win_h * 0.905, {
            color = "text_primary",
            align = "center",
            size = 14,
        })
    end

    -- 绘制过渡动画
    Animation.draw()
end

function MapScene.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        Map.reset()
        Animation.fade_out(0.2, function()
            State.switch("menu")
        end)
    elseif key == "d" then
        -- 快捷键 D 打开牌库
        Sound.play("click")
        State.push("fusion")
    elseif key == "a" then
        -- 快捷键 A 打开成就
        Sound.play("click")
        State.push("achievements")
    end
end

function MapScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 返回按钮点击检测
    if x >= 10 and x <= 90 and y >= 10 and y <= 45 then
        pressed_back = true
        Sound.play("click")
        return
    end

    -- 右上角按钮点击检测
    if hovered_right_btn then
        pressed_right_btn = hovered_right_btn
        Sound.play("click")
        return
    end

    -- 节点点击检测
    if hovered_node then
        pressed_node = hovered_node
        Sound.play("click")
    end
end

function MapScene.mousereleased(x, y, button)
    if button ~= 1 then return end

    -- 返回按钮释放
    if pressed_back then
        if x >= 10 and x <= 90 and y >= 10 and y <= 45 then
            Map.reset()
            Animation.fade_out(0.2, function()
                State.switch("menu")
            end)
        end
        pressed_back = false
        return
    end

    -- 右上角按钮释放
    if pressed_right_btn and pressed_right_btn == hovered_right_btn then
        if pressed_right_btn == "achievements" then
            State.push("achievements")
        elseif pressed_right_btn == "deck" then
            -- TODO: 可以添加牌库查看弹窗，暂时跳转到融合场景预览
            State.push("fusion")
        end
    end
    pressed_right_btn = nil

    -- 节点点击处理
    if pressed_node and hovered_node == pressed_node then
        local success, node = Map.select_node(hovered_node.col)
        if success then
            if node.type == "battle" or node.type == "elite" or node.type == "boss" then
                Animation.fade_out(0.2, function()
                    State.switch("combat")
                end)
            elseif node.type == "reward" then
                State.push("reward")
            elseif node.type == "fusion" then
                State.push("fusion")
            elseif node.type == "shop" then
                State.push("shop")
            elseif node.type == "event" then
                -- 剧情事件：NPC对话、选择分支、风险收益
                State.push("story_event")
            else
                Animation.fade_out(0.2, function()
                    State.switch("combat")
                end)
            end
        end
    end
    pressed_node = nil
end

return MapScene