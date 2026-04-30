-- systems/map.lua - 关卡地图系统
-- 3章节设计：森林→海洋→天空
-- 每章3层，最后一层是Boss

local Map = {}

-- 地图配置
local MAP_CONFIG = {
    rows = 10,         -- 总层数（增加一层给森林成长空间）
    min_nodes = 3,
    max_nodes = 4,
}

-- 章节定义
local CHAPTERS = {
    {
        id = "forest",
        name = "Forest",
        name_cn = "森林",
        rows = {1, 2, 3, 4},  -- 森林扩展到4层
        boss_row = 4,         -- Boss移到第4层
        enemies = {"wolf", "rat", "skunk", "squirrel"},
        elite_enemies = {"grizzly", "moose"},
        boss = "bear",
        color = {0.3, 0.5, 0.3},  -- 森林绿
        bg_color = {0.15, 0.25, 0.15},
    },
    {
        id = "ocean",
        name = "Ocean",
        name_cn = "海洋",
        rows = {5, 6, 7},      -- 海洋3层
        boss_row = 7,
        enemies = {"shark", "kraken", "gem_crab", "blood_worm"},
        elite_enemies = {"hydra", "frog_king"},
        boss = "dragon",
        color = {0.2, 0.4, 0.7},  -- 海蓝
        bg_color = {0.1, 0.2, 0.35},
    },
    {
        id = "sky",
        name = "Sky",
        name_cn = "天空",
        rows = {8, 9, 10},     -- 天空3层
        boss_row = 10,
        enemies = {"raven", "eagle", "owl", "bat"},
        elite_enemies = {"phoenix", "ghost_wolf"},
        boss = "titan",
        color = {0.6, 0.7, 0.9},  -- 天蓝
        bg_color = {0.25, 0.3, 0.45},
    },
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
    nodes = {},
    current_row = 1,
    current_col = 1,
    visited = {},
    current_chapter = 1,
}

-- 获取当前章节
local function get_chapter_by_row(row)
    for i, chapter in ipairs(CHAPTERS) do
        local first_row = chapter.rows[1]
        local last_row = chapter.rows[#chapter.rows]
        if row >= first_row and row <= last_row then
            return i, chapter
        end
    end
    return 1, CHAPTERS[1]
end

-- 生成随机节点类型
local function random_node_type(row)
    local roll = love.math.random()
    local cumulative = 0

    -- 章节Boss层
    local _, chapter = get_chapter_by_row(row)
    if row == chapter.boss_row then
        return "boss"
    end

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
    map_state.current_chapter = 1

    for row = 1, MAP_CONFIG.rows do
        local node_count = love.math.random(MAP_CONFIG.min_nodes, MAP_CONFIG.max_nodes)
        local chapter_idx, chapter = get_chapter_by_row(row)

        -- Boss层只有1个节点
        if row == chapter.boss_row then
            node_count = 1
        end

        map_state.nodes[row] = {}

        for col = 1, node_count do
            local node_type
            if row == 1 then
                node_type = "start"
            elseif row == chapter.boss_row then
                node_type = "boss"
            else
                node_type = random_node_type(row)
            end

            map_state.nodes[row][col] = {
                row = row,
                col = col,
                type = node_type,
                accessible = (row == 1),
                completed = false,
                chapter = chapter_idx,
            }
        end
    end

    map_state.current_row = 1
    map_state.current_col = 1
    map_state.nodes[1][1].completed = true

    return map_state
end

-- 获取当前章节信息
function Map.get_current_chapter()
    return get_chapter_by_row(map_state.current_row)
end

-- 获取章节敌人池
function Map.get_chapter_enemies(row)
    local _, chapter = get_chapter_by_row(row)
    return chapter.enemies, chapter.elite_enemies, chapter.boss
end

-- 获取章节背景色
function Map.get_chapter_bg_color(row)
    local _, chapter = get_chapter_by_row(row or map_state.current_row)
    return chapter.bg_color
end

-- 获取所有章节定义
function Map.get_chapters()
    return CHAPTERS
end

-- 检查是否是章节Boss
function Map.is_chapter_boss(row)
    local _, chapter = get_chapter_by_row(row)
    return row == chapter.boss_row
end

-- 获取章节Boss
function Map.get_chapter_boss(row)
    local _, chapter = get_chapter_by_row(row)
    return chapter.boss
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

    -- 检查是否进入新章节
    local old_chapter = get_chapter_by_row(map_state.current_row)
    local new_chapter = get_chapter_by_row(next_row)
    if new_chapter ~= old_chapter then
        map_state.current_chapter = select(1, get_chapter_by_row(next_row))
    end

    map_state.current_row = next_row
    map_state.current_col = col
    node.completed = true

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
        current_chapter = 1,
    }
end

return Map
