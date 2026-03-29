-- data/cards.lua - 卡牌定义（邪恶冥刻风格）
-- 每张卡有：攻击力、血量、消耗（献祭所需）、技能

local Cards = {
    -- 基础卡牌
    squirrel = {
        id = "squirrel",
        name = "Squirrel",
        cost = 0,           -- 献祭消耗（0=免费放）
        attack = 0,
        hp = 1,
        sigils = {},        -- 印记/技能
        rarity = "common",
    },
    stoat = {
        id = "stoat",
        name = "Stoat",
        cost = 1,
        attack = 1,
        hp = 2,
        sigils = {},
        rarity = "common",
    },
    wolf = {
        id = "wolf",
        name = "Wolf",
        cost = 2,
        attack = 2,
        hp = 2,
        sigils = {},
        rarity = "common",
    },
    grizzly = {
        id = "grizzly",
        name = "Grizzly",
        cost = 3,
        attack = 4,
        hp = 6,
        sigils = {},
        rarity = "rare",
    },
    raven = {
        id = "raven",
        name = "Raven",
        cost = 2,
        attack = 2,
        hp = 3,
        sigils = {"air_strike"},  -- 可以越过前排直接攻击
        rarity = "uncommon",
    },
    bullfrog = {
        id = "bullfrog",
        name = "Bullfrog",
        cost = 1,
        attack = 1,
        hp = 4,
        sigils = {"tough"},       -- 额外生命
        rarity = "common",
    },
    -- 特殊卡牌
    deathcard = {
        id = "deathcard",
        name = "Death Card",
        cost = 3,
        attack = 3,
        hp = 3,
        sigils = {"undead"},       -- 死后复活一次
        rarity = "legendary",
    },
}

-- 印记效果
local Sigils = {
    air_strike = {
        name = "Air Strike",
        desc = "Can attack directly",
    },
    tough = {
        name = "Tough",
        desc = "+2 Max HP",
    },
    undead = {
        name = "Undead",
        desc = "Revive once",
    },
    bifurcated = {
        name = "Bifurcated",
        desc = "Attack 2 lanes",
    },
}

return {
    cards = Cards,
    sigils = Sigils,
}