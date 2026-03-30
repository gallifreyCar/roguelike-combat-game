-- data/cards.lua - 卡牌定义
-- 每张卡有：攻击力、血量、消耗、印记

local Cards = {
    -- ========== 免费/献祭材料 ==========
    squirrel = {
        id = "squirrel",
        name = "Squirrel",
        cost = 0,
        attack = 0,
        hp = 1,
        sigils = {},
        rarity = "common",
    },

    -- ========== 1费卡 ==========
    stoat = {
        id = "stoat",
        name = "Stoat",
        cost = 1,
        attack = 1,
        hp = 2,
        sigils = {},
        rarity = "common",
    },
    bullfrog = {
        id = "bullfrog",
        name = "Bullfrog",
        cost = 1,
        attack = 1,
        hp = 4,
        sigils = {"tough"},
        rarity = "common",
    },
    rat = {
        id = "rat",
        name = "Rat",
        cost = 1,
        attack = 2,
        hp = 1,
        sigils = {},
        rarity = "common",
    },
    turtle = {
        id = "turtle",
        name = "Turtle",
        cost = 1,
        attack = 0,
        hp = 6,
        sigils = {"guardian"},  -- 保护相邻卡牌
        rarity = "uncommon",
    },

    -- ========== 2费卡 ==========
    wolf = {
        id = "wolf",
        name = "Wolf",
        cost = 2,
        attack = 2,
        hp = 2,
        sigils = {},
        rarity = "common",
    },
    raven = {
        id = "raven",
        name = "Raven",
        cost = 2,
        attack = 2,
        hp = 3,
        sigils = {"air_strike"},
        rarity = "uncommon",
    },
    adder = {
        id = "adder",
        name = "Adder",
        cost = 2,
        attack = 1,
        hp = 2,
        sigils = {"poison"},  -- 毒：命中后每回合-1hp
        rarity = "uncommon",
    },
    skunk = {
        id = "skunk",
        name = "Skunk",
        cost = 2,
        attack = 1,
        hp = 3,
        sigils = {"stinky"},  -- 降低对面敌人攻击力
        rarity = "uncommon",
    },
    cat = {
        id = "cat",
        name = "Cat",
        cost = 2,
        attack = 1,
        hp = 1,
        sigils = {"undead"},  -- 死后复活一次
        rarity = "rare",
    },

    -- ========== 3费卡 ==========
    grizzly = {
        id = "grizzly",
        name = "Grizzly",
        cost = 3,
        attack = 4,
        hp = 6,
        sigils = {},
        rarity = "rare",
    },
    moose = {
        id = "moose",
        name = "Moose",
        cost = 3,
        attack = 2,
        hp = 4,
        sigils = {"charge"},  -- 冲锋：同时攻击相邻两列
        rarity = "rare",
    },
    mantis = {
        id = "mantis",
        name = "Mantis",
        cost = 3,
        attack = 3,
        hp = 2,
        sigils = {"double_strike"},  -- 攻击两次
        rarity = "rare",
    },

    -- ========== 4费卡 ==========
    ox = {
        id = "ox",
        name = "Ox",
        cost = 4,
        attack = 4,
        hp = 6,
        sigils = {"trample"},  -- 践踏：溢出伤害打到玩家
        rarity = "rare",
    },
    eagle = {
        id = "eagle",
        name = "Eagle",
        cost = 4,
        attack = 3,
        hp = 4,
        sigils = {"air_strike", "sharp_quills"},  -- 飞行+刺
        rarity = "rare",
    },

    -- ========== 传说卡 ==========
    deathcard = {
        id = "deathcard",
        name = "Death Card",
        cost = 3,
        attack = 3,
        hp = 3,
        sigils = {"undead", "bone_snake"},  -- 复活+骷髅蛇
        rarity = "legendary",
    },
    hydra = {
        id = "hydra",
        name = "Hydra",
        cost = 5,
        attack = 3,
        hp = 4,
        sigils = {"hydra"},  -- 死亡时分裂成两个小蛇
        rarity = "legendary",
    },
}

-- 印记效果说明
local Sigils = {
    air_strike = {
        name = "Air Strike",
        desc = "Flying - attacks directly if lane empty",
    },
    tough = {
        name = "Tough",
        desc = "+2 Max HP",
    },
    undead = {
        name = "Undead",
        desc = "Revive once after death",
    },
    bifurcated = {
        name = "Bifurcated",
        desc = "Attack 2 lanes",
    },
    poison = {
        name = "Poison",
        desc = "Poisoned enemy loses 1 HP/turn",
    },
    stinky = {
        name = "Stinky",
        desc = "Reduce opposite enemy ATK",
    },
    guardian = {
        name = "Guardian",
        desc = "Protect adjacent cards",
    },
    charge = {
        name = "Charge",
        desc = "Attack adjacent lanes too",
    },
    double_strike = {
        name = "Double Strike",
        desc = "Attack twice per turn",
    },
    trample = {
        name = "Trample",
        desc = "Overflow damage hits player",
    },
    sharp_quills = {
        name = "Sharp Quills",
        desc = "Deal damage when attacked",
    },
    bone_snake = {
        name = "Bone Snake",
        desc = "Leave a 1/1 snake on death",
    },
    hydra = {
        name = "Hydra",
        desc = "Split into 2 snakes on death",
    },
}

-- 按稀有度分组
local Rarities = {
    common = {"squirrel", "stoat", "bullfrog", "rat", "wolf"},
    uncommon = {"turtle", "raven", "adder", "skunk"},
    rare = {"cat", "grizzly", "moose", "mantis", "ox", "eagle"},  -- [BUG FIX] "mant" 改为 "mantis"
    legendary = {"deathcard", "hydra"},
}

return {
    cards = Cards,
    sigils = Sigils,
    rarities = Rarities,
}