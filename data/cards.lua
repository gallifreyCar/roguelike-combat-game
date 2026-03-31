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
    -- 【新】过牌卡
    insight = {
        id = "insight",
        name = "Insight",
        cost = 1,
        attack = 0,
        hp = 1,
        sigils = {"draw"},  -- 放置时抽2张牌
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

    -- ========== 【新】词条牌（触发效果） ==========
    -- 连击狼：打出后下张牌-1费用
    combo_wolf = {
        id = "combo_wolf",
        name = "Combo Wolf",
        cost = 2,
        attack = 2,
        hp = 2,
        sigils = {"combo"},  -- 连击：打出后下张牌费用-1
        rarity = "uncommon",
    },
    -- 亡语蝙蝠：死亡时抽2张牌
    death_raven = {
        id = "death_raven",
        name = "Death Raven",
        cost = 2,
        attack = 1,
        hp = 2,
        sigils = {"death_draw"},  -- 亡语：死亡时抽2张牌
        rarity = "uncommon",
    },
    -- 猎杀者：击杀敌人时+1攻击
    hunter = {
        id = "hunter",
        name = "Hunter",
        cost = 2,
        attack = 1,
        hp = 3,
        sigils = {"kill_bonus"},  -- 击杀时+1攻击
        rarity = "rare",
    },
    -- 爆发猫：回合开始时+1Blood
    burst_cat = {
        id = "burst_cat",
        name = "Burst Cat",
        cost = 1,
        attack = 0,
        hp = 2,
        sigils = {"turn_blood"},  -- 回合开始+1Blood
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

    -- ========== 解锁卡牌 ==========
    guardian_dog = {
        id = "guardian_dog",
        name = "Guardian Dog",
        cost = 2,
        attack = 2,
        hp = 3,
        sigils = {"guardian", "tough"},  -- 保护+坚韧
        rarity = "uncommon",
    },

    -- ========== 【扩展】更多卡牌 ==========
    -- 1费扩展
    bat = {
        id = "bat",
        name = "Bat",
        cost = 1,
        attack = 1,
        hp = 1,
        sigils = {"air_strike"},  -- 飞行
        rarity = "common",
    },
    snail = {
        id = "snail",
        name = "Snail",
        cost = 1,
        attack = 0,
        hp = 3,
        sigils = {"tough"},  -- 坚韧
        rarity = "common",
    },
    bee = {
        id = "bee",
        name = "Bee",
        cost = 1,
        attack = 2,
        hp = 1,
        sigils = {"poison"},  -- 毒
        rarity = "uncommon",
    },

    -- 2费扩展
    fox = {
        id = "fox",
        name = "Fox",
        cost = 2,
        attack = 3,
        hp = 2,
        sigils = {},
        rarity = "common",
    },
    owl = {
        id = "owl",
        name = "Owl",
        cost = 2,
        attack = 1,
        hp = 3,
        sigils = {"air_strike", "tough"},  -- 飞行+坚韧
        rarity = "rare",
    },
    snake = {
        id = "snake",
        name = "Snake",
        cost = 2,
        attack = 2,
        hp = 2,
        sigils = {"poison"},  -- 毒
        rarity = "uncommon",
    },
    spider = {
        id = "spider",
        name = "Spider",
        cost = 2,
        attack = 1,
        hp = 4,
        sigils = {"stinky"},  -- 臭气
        rarity = "uncommon",
    },
    crow = {
        id = "crow",
        name = "Crow",
        cost = 2,
        attack = 2,
        hp = 2,
        sigils = {"death_draw"},  -- 亡语抽牌
        rarity = "uncommon",
    },
    rabbit = {
        id = "rabbit",
        name = "Rabbit",
        cost = 2,
        attack = 1,
        hp = 3,
        sigils = {"undead"},  -- 复活
        rarity = "uncommon",
    },

    -- 3费扩展
    lion = {
        id = "lion",
        name = "Lion",
        cost = 3,
        attack = 4,
        hp = 4,
        sigils = {},
        rarity = "rare",
    },
    shark = {
        id = "shark",
        name = "Shark",
        cost = 3,
        attack = 5,
        hp = 2,
        sigils = {"trample"},  -- 践踏
        rarity = "rare",
    },
    scorpion = {
        id = "scorpion",
        name = "Scorpion",
        cost = 3,
        attack = 2,
        hp = 3,
        sigils = {"poison", "sharp_quills"},  -- 毒+刺
        rarity = "rare",
    },
    boar = {
        id = "boar",
        name = "Boar",
        cost = 3,
        attack = 3,
        hp = 5,
        sigils = {"charge"},  -- 冲锋
        rarity = "uncommon",
    },
    frog_king = {
        id = "frog_king",
        name = "Frog King",
        cost = 3,
        attack = 2,
        hp = 5,
        sigils = {"tough", "guardian"},  -- 坚韧+守护
        rarity = "rare",
    },

    -- 4费扩展
    dragon = {
        id = "dragon",
        name = "Dragon",
        cost = 4,
        attack = 5,
        hp = 5,
        sigils = {"air_strike", "trample"},  -- 飞行+践踏
        rarity = "legendary",
    },
    bear = {
        id = "bear",
        name = "Bear",
        cost = 4,
        attack = 4,
        hp = 7,
        sigils = {"tough"},
        rarity = "rare",
    },
    kraken = {
        id = "kraken",
        name = "Kraken",
        cost = 4,
        attack = 3,
        hp = 8,
        sigils = {"bifurcated"},  -- 双击
        rarity = "rare",
    },

    -- 5费扩展
    phoenix = {
        id = "phoenix",
        name = "Phoenix",
        cost = 5,
        attack = 4,
        hp = 4,
        sigils = {"undead", "air_strike"},  -- 复活+飞行
        rarity = "legendary",
    },
    titan = {
        id = "titan",
        name = "Titan",
        cost = 5,
        attack = 6,
        hp = 10,
        sigils = {"trample", "tough"},
        rarity = "legendary",
    },

    -- 特殊功能卡
    blood_worm = {
        id = "blood_worm",
        name = "Blood Worm",
        cost = 0,
        attack = 0,
        hp = 2,
        sigils = {"turn_blood"},  -- 回合开始+1Blood
        rarity = "rare",
    },
    mirror_cat = {
        id = "mirror_cat",
        name = "Mirror Cat",
        cost = 1,
        attack = 1,
        hp = 1,
        sigils = {"undead", "undead"},  -- 双重复活
        rarity = "legendary",
    },
    gem_crab = {
        id = "gem_crab",
        name = "Gem Crab",
        cost = 1,
        attack = 0,
        hp = 5,
        sigils = {"tough", "guardian"},
        rarity = "rare",
    },
    assassin_bug = {
        id = "assassin_bug",
        name = "Assassin Bug",
        cost = 2,
        attack = 1,
        hp = 2,
        sigils = {"poison", "double_strike"},  -- 毒+双击
        rarity = "rare",
    },
    ghost_wolf = {
        id = "ghost_wolf",
        name = "Ghost Wolf",
        cost = 2,
        attack = 3,
        hp = 1,
        sigils = {"air_strike", "undead"},  -- 飞行+复活
        rarity = "rare",
    },
    queen_bee = {
        id = "queen_bee",
        name = "Queen Bee",
        cost = 3,
        attack = 2,
        hp = 4,
        sigils = {"hydra", "poison"},  -- 分裂+毒
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
    -- 【扩展】新印记
    draw = {
        name = "Draw",
        desc = "Draw 2 cards when placed",
    },
    combo = {
        name = "Combo",
        desc = "Next card costs 1 less",
    },
    death_draw = {
        name = "Death Draw",
        desc = "Draw 2 cards when this card dies",
    },
    kill_bonus = {
        name = "Hunter",
        desc = "+1 ATK when killing enemy",
    },
    turn_blood = {
        name = "Blood Maker",
        desc = "+1 Blood at turn start",
    },
}

-- 按稀有度分组
local Rarities = {
    common = {"squirrel", "stoat", "bullfrog", "rat", "wolf", "bat", "snail", "fox"},
    uncommon = {"turtle", "raven", "adder", "skunk", "insight", "combo_wolf", "death_raven",
                "bee", "snake", "spider", "crow", "rabbit", "boar", "guardian_dog"},
    rare = {"cat", "grizzly", "moose", "mantis", "ox", "eagle", "hunter", "burst_cat",
            "owl", "lion", "shark", "scorpion", "frog_king", "bear", "kraken",
            "blood_worm", "gem_crab", "assassin_bug", "ghost_wolf"},
    legendary = {"deathcard", "hydra", "dragon", "phoenix", "titan", "mirror_cat", "queen_bee"},
}

-- 获取随机卡牌（按稀有度）
function Cards.getRandomCardByRarity(rarity)
    local pool = Rarities[rarity] or Rarities.common
    if #pool == 0 then return nil end

    local card_id = pool[love and love.math and love.math.random(#pool) or math.random(#pool)]
    local template = Cards[card_id]
    if not template then return nil end

    -- 返回完整复制的卡牌数据
    return {
        id = template.id,
        name = template.name,
        cost = template.cost,
        attack = template.attack,
        hp = template.hp,
        max_hp = template.hp,
        sigils = template.sigils or {},
        rarity = template.rarity,
    }
end

return {
    cards = Cards,
    sigils = Sigils,
    rarities = Rarities,
}