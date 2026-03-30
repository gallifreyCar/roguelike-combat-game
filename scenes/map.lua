-- scenes/map.lua - 关卡地图场景
-- 使用 Theme 和 Components 重构

local MapScene = {}
local Map = require("systems.map")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Settings = require("config.settings")

local hovered_node = nil

function MapScene.enter()
    local map_data = Map.get_map()
    if not map_data.nodes or #map_data.nodes == 0 then
        Map.generate()
    end
    hovered_node = nil
end

function MapScene.exit()
    hovered_node = nil
end

function MapScene.update(dt)
    local mx, my = love.mouse.getPosition()
    hovered_node = nil

    local win_w, win_h = Layout.get_size()
    local map_data = Map.get_map()
    local current_row = Map.get_current_row()
    local next_row = current_row + 1
    local next_nodes = Map.get_next_nodes()

    if #next_nodes == 0 then return end

    -- 计算节点位置
    local node_w = Settings.map_node_width
    local node_h = Settings.map_node_height
    local spacing = Settings.map_node_spacing

    local node_count = #next_nodes
    local total_width = node_count * node_w + (node_count - 1) * (spacing - node_w)
    local center_x = (win_w - total_width) / 2
    local base_y = win_h - 100
    local node_y = base_y - (next_row - 1) * Settings.map_row_spacing

    for col, node in ipairs(next_nodes) do
        local x = center_x + (col - 1) * spacing
        if mx >= x and mx <= x + node_w and my >= node_y and my <= node_y + node_h then
            hovered_node = node
        end
    end
end

function MapScene.draw()
    Theme.setColor("bg_secondary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    local title_w = 250
    Components.panel(Layout.center_x(title_w), 20, title_w, 40, {
        bg = "bg_button",
    })
    Components.text(I18n.t("map_title"), win_w / 2, 28, {
        color = "text_primary",
        align = "center",
    })

    local map_data = Map.get_map()
    local node_w = Settings.map_node_width
    local node_h = Settings.map_node_height
    local spacing = Settings.map_node_spacing
    local base_y = win_h - 100

    -- 绘制所有层
    for row, nodes in ipairs(map_data.nodes) do
        local y = base_y - (row - 1) * Settings.map_row_spacing
        local node_count = #nodes
        local total_width = node_count * node_w + (node_count - 1) * (spacing - node_w)
        local center_x = (win_w - total_width) / 2

        -- 层标签
        local label = (row == #map_data.nodes) and I18n.t("boss") or I18n.t("floor") .. " " .. row
        Components.text(label, center_x - 80, y + 30, {color = "text_hint"})

        for col, node in ipairs(nodes) do
            local x = center_x + (col - 1) * spacing
            local node_type = Map.get_node_type(node.type)
            local base_color = node_type.color  -- 直接从 NODE_TYPES 获取颜色

            -- 节点背景
            if node.completed then
                love.graphics.setColor(0.3, 0.3, 0.35)
            elseif node == hovered_node then
                love.graphics.setColor(base_color[1] + 0.2, base_color[2] + 0.2, base_color[3] + 0.2)
            else
                love.graphics.setColor(base_color[1] * 0.7, base_color[2] * 0.7, base_color[3] * 0.7)
            end
            love.graphics.rectangle("fill", x, y, node_w, node_h, 6, 6)

            -- 节点边框
            if node == hovered_node then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("line", x, y, node_w, node_h, 6, 6)

            -- 节点内容
            Theme.setColor("text_value")
            Fonts.print(node_type.icon, x + 40, y + 5, 16)
            Theme.setColor("text_primary")
            Fonts.print(node_type.name, x + 20, y + 30, 12)

            -- 已完成标记
            if node.completed then
                Theme.setColor("accent_green")
                Fonts.print(I18n.t("ok"), x + 65, y + 5, 12)
            end
        end
    end

    -- 当前位置指示
    Components.text("▼ " .. I18n.t("you_are_here"), win_w / 2, win_h - 40, {
        color = "accent_yellow",
        align = "center",
    })

    -- 悬停提示
    if hovered_node then
        Components.panel((win_w - 250) / 2, win_h - 80, 250, 40, {
            bg = "bg_panel",
        })
        Components.text(I18n.t("click_select"), win_w / 2, win_h - 70, {
            color = "text_primary",
            align = "center",
        })
    end
end

function MapScene.keypressed(key)
    if key == "escape" then
        Map.reset()
        State.switch("menu")
    end
end

function MapScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    if hovered_node then
        local success, node = Map.select_node(hovered_node.col)
        if success then
            if node.type == "battle" or node.type == "elite" or node.type == "boss" then
                State.switch("combat")
            elseif node.type == "reward" then
                State.push("reward")
            else
                State.switch("combat")
            end
        end
    end
end

return MapScene