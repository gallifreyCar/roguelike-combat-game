-- systems/map.lua - 关卡地图系统
-- 肉鸽风格的地图选择，分支路线，不同事件类型

local Map = {}

-- 地图配置
local MAP_CONFIG = {
    rows = 8,          -- 地图层数
    min_nodes = 3,     -- 每层最少节点
    max_nodes = 4,     -- 每层最多节点
}

-- 节点类型
local NODE_TYPES = {
    battle = {
        name = "Battle",
        icon = "[!]",
        color = {0.8, 0.3, 0.3},
        weight = 0.40,
    },
    elite = {
        name = "Elite",
        icon = "[E]",
        color = {0.8, 0.5, 0.2},
        weight = 0.10,
    },
    reward = {
        name = "Reward",
        icon = "[+]",
        color = {0.3, 0.7, 0.3},
        weight = 0.15,
    },
    fusion = {
        name = "Fusion",
        icon = "[F]",
        color = {0.6, 0.3, 0.7},
        weight = 0.15,
    },
    event = {
        name = "Event",
        icon = "[?]",
        color = {0.7, 0.7, 0.3},
        weight = 0.10,
    },
    shop = {
        name = "Shop",
        icon = "[$]",
        color = {0.5, 0.5, 0.8},
        weight = 0.10,
    },
    boss = {
        name = "Boss",
        icon = "[BOSS]",
        color = {0.6, 0.2, 0.2},
        weight = 0,
    },
    start = {
        name = "Start",
        icon = "[S]",
        color = {0.4, 0.4, 0.4},
        weight = 0,
    },
}

-- 当前地图状态
local map_state = {
    nodes = {},        -- 所有节点
    current_row = 1,   -- 当前层
    current_col = 1,   -- 当前位置
    visited = {},      -- 已访问节点
}

-- 生成随机节点类型
local function random_node_type()
    local roll = love.math.random()
    local cumulative = 0

    for type_name, type_data in pairs(NODE_TYPES) do
        cumulative = cumulative + type_data.weight
        if roll < cumulative then
            return type_name
        end
    end

    return "battle"
end

-- 生成地图
function Map.generate()
    map_state.nodes = {}
    map_state.visited = {}

    for row = 1, MAP_CONFIG.rows do
        local node_count = love.math.random(MAP_CONFIG.min_nodes, MAP_CONFIG.max_nodes)

        -- 最后一层是Boss
        if row == MAP_CONFIG.rows then
            node_count = 1
        end

        map_state.nodes[row] = {}

        for col = 1, node_count do
            local node_type
            if row == 1 then
                node_type = "start"
            elseif row == MAP_CONFIG.rows then
                node_type = "boss"
            else
                node_type = random_node_type()
            end

            map_state.nodes[row][col] = {
                row = row,
                col = col,
                type = node_type,
                accessible = (row == 1),  -- 只有第一层可访问
                completed = false,
            }
        end
    end

    -- 设置起始位置
    map_state.current_row = 1
    map_state.current_col = 1
    map_state.nodes[1][1].completed = true

    return map_state
end

-- 获取当前节点
function Map.get_current()
    return map_state.nodes[map_state.current_row] and
           map_state.nodes[map_state.current_row][map_state.current_col]
end

-- 获取下一层可访问的节点
function Map.get_next_nodes()
    local next_row = map_state.current_row + 1
    if next_row > MAP_CONFIG.rows then return {} end

    -- [BUG FIX] 确保 nodes 数组存在，防止返回 nil
    local nodes = map_state.nodes[next_row]
    if not nodes then
        return {}
    end
    return nodes
end

-- 选择下一个节点
function Map.select_node(col)
    local next_row = map_state.current_row + 1
    if next_row > MAP_CONFIG.rows then return false end

    local node = map_state.nodes[next_row][col]
    if not node then return false end

    -- 更新位置
    map_state.current_row = next_row
    map_state.current_col = col
    node.completed = true

    -- 标记下一层的节点可访问
    if map_state.nodes[next_row + 1] then
        for _, n in ipairs(map_state.nodes[next_row + 1]) do
            n.accessible = true
        end
    end

    return true, node
end

-- 检查是否到达终点
function Map.is_complete()
    return map_state.current_row >= MAP_CONFIG.rows
end

-- 获取地图数据
function Map.get_map()
    return map_state
end

-- 获取节点类型信息
function Map.get_node_type(type_name)
    return NODE_TYPES[type_name] or NODE_TYPES.battle
end

-- 获取当前层数
function Map.get_current_row()
    return map_state.current_row
end

-- 重置地图
function Map.reset()
    map_state = {
        nodes = {},
        current_row = 1,
        current_col = 1,
        visited = {},
    }
end

return Map