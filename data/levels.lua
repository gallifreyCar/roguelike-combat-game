-- data/levels.lua - 关卡定义
-- 定义每个关卡的敌人配置

local Levels = {
    -- 关卡 1：入门
    {
        name = "Forest Path",
        enemies = {
            {card = "stoat", slot = 2},
        },
        boss = false,
        gold_reward = 0,
    },

    -- 关卡 2
    {
        name = "Dark Woods",
        enemies = {
            {card = "stoat", slot = 1},
            {card = "rat", slot = 3},
        },
        boss = false,
        gold_reward = 1,
    },

    -- 关卡 3
    {
        name = "Swamp",
        enemies = {
            {card = "bullfrog", slot = 1},
            {card = "adder", slot = 2},
        },
        boss = false,
        gold_reward = 1,
    },

    -- 关卡 4
    {
        name = "Mountain Pass",
        enemies = {
            {card = "wolf", slot = 1},
            {card = "wolf", slot = 3},
        },
        boss = false,
        gold_reward = 2,
    },

    -- 关卡 5：Boss
    {
        name = "Bear's Den",
        enemies = {
            {card = "grizzly", slot = 2},
        },
        boss = true,
        boss_name = "Grizzly Bear",
        gold_reward = 3,
    },

    -- 关卡 6：第二幕开始
    {
        name = "Cursed Marsh",
        enemies = {
            {card = "skunk", slot = 1},
            {card = "adder", slot = 2},
            {card = "skunk", slot = 3},
        },
        boss = false,
        gold_reward = 2,
    },

    -- 关卡 7
    {
        name = "Abandoned Mine",
        enemies = {
            {card = "moose", slot = 2},
        },
        boss = false,
        gold_reward = 2,
    },

    -- 关卡 8：Boss
    {
        name = "Hydra's Lair",
        enemies = {
            {card = "hydra", slot = 2},
        },
        boss = true,
        boss_name = "Ancient Hydra",
        gold_reward = 5,
    },
}

-- 根据关卡号获取关卡数据
local function get_level(level_num)
    if level_num > #Levels then
        level_num = #Levels  -- 循环最后一关
    end
    return Levels[level_num]
end

-- 获取总关卡数
local function get_max_levels()
    return #Levels
end

return {
    levels = Levels,
    get_level = get_level,
    get_max_levels = get_max_levels,
}