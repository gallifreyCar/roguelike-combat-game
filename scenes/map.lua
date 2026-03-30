-- scenes/map.lua - 关卡地图场景
-- 显示肉鸽风格地图，选择下一关

local MapScene = {}
local Map = require("systems.map")
local State = require("core.state")
local Fonts = require("core.fonts")

local hovered_node = nil

-- 节点尺寸配置
local NODE_WIDTH = 100
local NODE_HEIGHT = 50
local NODE_SPACING = 150  -- 列间距
local ROW_SPACING = 70    -- 行间距

function MapScene.enter()
    -- 如果地图为空，生成新地图
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

    -- 获取动态窗口尺寸
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    local map_data = Map.get_map()
    local current_row = Map.get_current_row()
    local next_row = current_row + 1
    local next_nodes = Map.get_next_nodes()

    if #next_nodes == 0 then return end

    -- 计算节点居中偏移
    local node_count = #next_nodes
    local total_width = node_count * NODE_WIDTH + (node_count - 1) * (NODE_SPACING - NODE_WIDTH)
    local center_x = (win_w - total_width) / 2

    -- 计算下一层节点的 Y 坐标（基于窗口高度）
    local base_y = win_h - 100  -- 底部基准位置
    local node_y = base_y - (next_row - 1) * ROW_SPACING

    -- 检测悬停
    for col, node in ipairs(next_nodes) do
        local x = center_x + (col - 1) * NODE_SPACING
        local y = node_y
        if mx >= x and mx <= x + NODE_WIDTH and my >= y and my <= y + NODE_HEIGHT then
            hovered_node = node
        end
    end
end

function MapScene.draw()
    love.graphics.clear(0.05, 0.08, 0.12)

    -- 获取动态窗口尺寸
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    -- 标题（居中）
    local title_w = 250
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.rectangle("fill", (win_w - title_w) / 2, 20, title_w, 40, 6, 6)
    love.graphics.setColor(1, 0.9, 0.8)
    Fonts.print("[ MAP ]", (win_w - title_w) / 2 + 80, 28, 18)

    local map_data = Map.get_map()
    local current_row = Map.get_current_row()

    -- 基准 Y 位置（与 update 函数一致）
    local base_y = win_h - 100

    -- 绘制所有层
    for row, nodes in ipairs(map_data.nodes) do
        local y = base_y - (row - 1) * ROW_SPACING

        -- 计算该层节点居中偏移
        local node_count = #nodes
        local total_width = node_count * NODE_WIDTH + (node_count - 1) * (NODE_SPACING - NODE_WIDTH)
        local center_x = (win_w - total_width) / 2

        -- 层标签
        love.graphics.setColor(0.4, 0.4, 0.45)
        if row == #map_data.nodes then
            Fonts.print("BOSS", center_x - 80, y + 30, 12)
        else
            Fonts.print("Floor " .. row, center_x - 80, y + 30, 12)
        end

        for col, node in ipairs(nodes) do
            local x = center_x + (col - 1) * NODE_SPACING
            local node_type = Map.get_node_type(node.type)

            -- 节点背景
            if node.completed then
                love.graphics.setColor(0.3, 0.3, 0.35)
            elseif node == hovered_node then
                love.graphics.setColor(node_type.color[1] + 0.2, node_type.color[2] + 0.2, node_type.color[3] + 0.2)
            else
                love.graphics.setColor(node_type.color[1] * 0.7, node_type.color[2] * 0.7, node_type.color[3] * 0.7)
            end

            love.graphics.rectangle("fill", x, y, NODE_WIDTH, NODE_HEIGHT, 6, 6)

            -- 节点边框
            if node == hovered_node then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("line", x, y, NODE_WIDTH, NODE_HEIGHT, 6, 6)

            -- 节点图标和名称
            love.graphics.setColor(1, 1, 1)
            Fonts.print(node_type.icon, x + 40, y + 5, 16)
            Fonts.print(node_type.name, x + 20, y + 30, 12)

            -- 已完成标记
            if node.completed then
                love.graphics.setColor(0.5, 0.8, 0.5)
                Fonts.print("[OK]", x + 65, y + 5, 12)
            end
        end
    end

    -- 当前位置指示（居中）
    love.graphics.setColor(1, 1, 0.5)
    Fonts.print("▼ You are here", win_w / 2 - 60, win_h - 40, 14)

    -- 悬停提示（居中）
    if hovered_node then
        love.graphics.setColor(0.2, 0.25, 0.3)
        love.graphics.rectangle("fill", (win_w - 250) / 2, win_h - 80, 250, 40, 4, 4)
        love.graphics.setColor(1, 1, 1)
        Fonts.print("Click to select this node", (win_w - 230) / 2, win_h - 70, 14)
    end
end

function MapScene.keypressed(key)
    if key == "escape" then
        -- 返回菜单（临时）
        Map.reset()
        State.switch("menu")
    end
end

function MapScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    if hovered_node then
        local success, node = Map.select_node(hovered_node.col)
        if success then
            -- 根据节点类型进入对应场景
            if node.type == "battle" or node.type == "elite" or node.type == "boss" then
                State.switch("combat")
            elseif node.type == "reward" then
                State.push("reward")
            else
                -- 默认进入战斗
                State.switch("combat")
            end
        end
    end
end

return MapScene