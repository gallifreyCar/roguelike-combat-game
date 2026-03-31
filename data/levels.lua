-- data/levels.lua - 关卡定义
-- 定义每个关卡的敌人配置（Round 6 新手体验优化）
-- 难度曲线：1简单入门 → 2-3学习 → 4-5中等 → Boss独特机制

local Levels = {
    -- ========== 第一幕：入门阶段（确保首局获胜） ==========

    -- 关卡 1：新手教程级（极简敌人，0攻击）
    {
        name = "Tutorial Grove",
        enemies = {
            {card = "squirrel", slot = 2},  -- 0攻/1血，无威胁敌人
        },
        boss = false,
        gold_reward = 10,  -- 提高首胜奖励
        difficulty = 1,
        is_tutorial = true,  -- 标记为教程关卡
    },

    -- 关卡 2：实战入门
    {
        name = "Forest Path",
        enemies = {
            {card = "stoat", slot = 2},  -- 1攻/2血，简单敌人
        },
        boss = false,
        gold_reward = 8,
        difficulty = 1,
    },

    -- 关卡 3：学习站位
    {
        name = "Dark Woods",
        enemies = {
            {card = "stoat", slot = 1},  -- 1攻/2血
            {card = "rat", slot = 3},    -- 2攻/1血，脆皮高攻
        },
        boss = false,
        gold_reward = 12,
        difficulty = 1,
    },

    -- ========== 第二阶段：中等难度（引入印记敌人） ==========

    -- 关卡 4：印记敌人出现
    {
        name = "Swamp",
        enemies = {
            {card = "bullfrog", slot = 1},  -- 1攻/4血(tough=+2HP,实际6血)
            {card = "adder", slot = 3},     -- 1攻/2血(poison)
        },
        boss = false,
        gold_reward = 15,
        difficulty = 2,
    },

    -- 关卡 4：多敌人组合
    {
        name = "Mountain Pass",
        enemies = {
            {card = "wolf", slot = 1},  -- 2攻/2血
            {card = "wolf", slot = 3},  -- 2攻/2血，双狼夹击
        },
        boss = false,
        gold_reward = 18,
        difficulty = 2,
    },

    -- ========== 第三阶段：Boss战（独特机制） ==========

    -- 关卡 5：第一幕Boss - 熊Boss
    {
        name = "Bear's Den",
        enemies = {
            {card = "grizzly", slot = 2},  -- 4攻/6血，强力Boss
        },
        boss = true,
        boss_name = "Grizzly Bear",
        boss_mechanic = "trample",  -- Boss特性：溢出伤害打玩家
        gold_reward = 30,  -- Boss丰厚奖励
        difficulty = 3,
    },

    -- ========== 第二幕开始：困难挑战 ==========

    -- 关卡 6：三敌人阵型
    {
        name = "Cursed Marsh",
        enemies = {
            {card = "skunk", slot = 1},  -- 1攻/3血(stinky) - 降低对面攻击
            {card = "adder", slot = 2},  -- 1攻/2血(poison) - 中路毒蛇
            {card = "skunk", slot = 3},  -- 恶臭夹击
        },
        boss = false,
        gold_reward = 22,
        difficulty = 3,
    },

    -- 关卡 7：稀有敌人
    {
        name = "Abandoned Mine",
        enemies = {
            {card = "moose", slot = 2},  -- 2攻/4血(charge) - 冲锋攻击相邻列
        },
        boss = false,
        gold_reward = 25,
        difficulty = 3,
    },

    -- 关卡 8：终极Boss - Hydra
    {
        name = "Hydra's Lair",
        enemies = {
            {card = "hydra", slot = 2},  -- 3攻/4血(hydra) - 死亡分裂成两蛇
        },
        boss = true,
        boss_name = "Ancient Hydra",
        boss_mechanic = "split",  -- Boss特性：死亡分裂
        gold_reward = 50,  -- 终极Boss奖励
        difficulty = 4,
    },

    -- ========== 扩展关卡（更高难度） ==========

    -- 关卡 9：混合精英
    {
        name = "Dark Cathedral",
        enemies = {
            {card = "mantis", slot = 1},  -- 3攻/2血(double_strike) - 双击威胁
            {card = "cat", slot = 3},     -- 1攻/1血(undead) - 复活敌人
        },
        boss = false,
        gold_reward = 28,
        difficulty = 4,
    },

    -- 关卡 10：终极挑战
    {
        name = "Void Gate",
        enemies = {
            {card = "dragon", slot = 2},  -- 5攻/5血(air_strike+trample) - 传说龙
        },
        boss = true,
        boss_name = "Void Dragon",
        boss_mechanic = "air_strike",  -- Boss特性：飞行攻击
        gold_reward = 80,
        difficulty = 5,
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