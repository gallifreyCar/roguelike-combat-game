-- systems/fusion.lua - 卡牌融合系统
-- 支持：同卡融合（固定加成）+ 骰子融合（异卡随机融合）

local Fusion = {}
local CardData = require("data.cards")
local TableUtils = require("utils.table")

-- 融合规则：升级后的卡牌属性
local FUSION_RULES = {
    -- 基础属性加成
    stat_boost = {
        attack = 1,      -- 攻击力+1
        hp = 2,          -- HP+2
    },

    -- 可能获得的新印记
    possible_sigils = {
        "tough",         -- 坚韧
        "double_strike", -- 双击
        "poison",        -- 毒
    },
}

-- ==================== 骰子融合系统 ====================

-- 融合配方定义：两张不同卡牌融合成强力新卡
-- 每个配方包含：原料、结果、成功率、失败后果
local DICE_FUSION_RECIPES = {
    -- 低级融合：废牌利用
    {
        id = "squirrel_boost",
        ingredients = {"squirrel", "*"},  -- * 表示任意卡
        result = {
            attack_bonus = 0,
            hp_bonus = 1,
            sigil_chance = 0.2,
            sigil_pool = {"tough"},
        },
        success_rate = 0.9,  -- 高成功率
        fail_result = "squirrel",  -- 失败返还松鼠
        description = "Squirrel sacrifice enhances any card",
    },

    -- 毒攻融合：剧毒+攻击
    {
        id = "poison_attacker",
        ingredients = {"adder", "wolf"},  -- 毒蛇 + 狼
        result = {
            create_card = "poison_wolf",  -- 创建特殊卡
            attack_bonus = 1,
            hp_bonus = 1,
            sigils = {"poison", "double_strike"},
        },
        success_rate = 0.6,
        fail_result = "partial",  -- 返还一张
        description = "Poison Wolf: High attack with poison",
    },

    -- 飞行突击：飞行+攻击
    {
        id = "air_assassin",
        ingredients = {"raven", "wolf"},
        result = {
            create_card = "sky_hunter",
            attack_bonus = 2,
            hp_bonus = 0,
            sigils = {"air_strike", "charge"},
        },
        success_rate = 0.5,
        fail_result = "none",  -- 全部丢失
        description = "Sky Hunter: Flying charge attack",
    },

    -- 坦克融合：高血量组合
    {
        id = "fortress",
        ingredients = {"turtle", "bullfrog"},
        result = {
            attack_bonus = 0,
            hp_bonus = 4,
            sigils = {"tough", "guardian"},
        },
        success_rate = 0.7,
        fail_result = "turtle",  -- 返还乌龟
        description = "Fortress: Ultimate tank with guardian",
    },

    -- 复活融合：不死组合
    {
        id = "undead_army",
        ingredients = {"cat", "*"},  -- 猫 + 任意卡
        result = {
            attack_bonus = 1,
            hp_bonus = 2,
            sigil_chance = 0.8,
            sigil_pool = {"undead", "tough"},
        },
        success_rate = 0.5,
        fail_result = "partial",
        description = "Undead fusion: Grant second life",
    },

    -- 毒雾组合：范围毒
    {
        id = "toxic_cloud",
        ingredients = {"adder", "skunk"},
        result = {
            create_card = "toxic_beast",
            attack_bonus = 0,
            hp_bonus = 2,
            sigils = {"poison", "stinky"},
        },
        success_rate = 0.55,
        fail_result = "adder",
        description = "Toxic Beast: Poison + debuff combo",
    },

    -- 暴击融合：双击+高攻
    {
        id = "berserker",
        ingredients = {"mantis", "wolf"},
        result = {
            attack_bonus = 2,
            hp_bonus = 0,
            sigils = {"double_strike", "trample"},
        },
        success_rate = 0.45,
        fail_result = "none",
        description = "Berserker: Double strike + trample",
    },

    -- 传说融合：终极组合
    {
        id = "legendary",
        ingredients = {"grizzly", "eagle"},
        result = {
            create_card = "legendary_beast",
            attack_bonus = 3,
            hp_bonus = 4,
            sigils = {"air_strike", "trample", "sharp_quills"},
        },
        success_rate = 0.3,
        fail_result = "partial",
        description = "Legendary Beast: Ultimate power!",
    },
}

-- 特殊融合卡牌模板
local SPECIAL_FUSION_CARDS = {
    poison_wolf = {
        id = "poison_wolf",
        name = "Poison Wolf",
        cost = 2,
        attack = 3,
        hp = 3,
        sigils = {"poison"},
        rarity = "rare",
        fused = true,
    },
    sky_hunter = {
        id = "sky_hunter",
        name = "Sky Hunter",
        cost = 3,
        attack = 4,
        hp = 3,
        sigils = {"air_strike"},
        rarity = "rare",
        fused = true,
    },
    toxic_beast = {
        id = "toxic_beast",
        name = "Toxic Beast",
        cost = 2,
        attack = 2,
        hp = 4,
        sigils = {"poison", "stinky"},
        rarity = "rare",
        fused = true,
    },
    legendary_beast = {
        id = "legendary_beast",
        name = "Legendary Beast",
        cost = 4,
        attack = 6,
        hp = 7,
        sigils = {"air_strike", "trample"},
        rarity = "legendary",
        fused = true,
    },
}

-- ==================== 同卡融合（原有功能） ====================

-- 检查两张卡是否可以融合
function Fusion.can_fuse(card1, card2)
    if not card1 or not card2 then return false end
    if card1.id ~= card2.id then return false end
    if card1.fused then return false end  -- 已融合的不能再融合
    return true
end

-- 执行融合
function Fusion.fuse(card1, card2)
    if not Fusion.can_fuse(card1, card2) then
        return nil
    end

    -- 确保 max_hp 有值
    local base_max_hp = card1.max_hp or card1.hp

    -- 创建融合后的卡牌
    local fused_card = {
        id = card1.id,
        name = card1.name .. "+",
        cost = card1.cost,
        attack = card1.attack + FUSION_RULES.stat_boost.attack,
        hp = card1.hp + FUSION_RULES.stat_boost.hp,
        max_hp = base_max_hp + FUSION_RULES.stat_boost.hp,
        sigils = {},  -- 创建新表避免浅拷贝
        rarity = card1.rarity,
        fused = true,
    }

    -- 复制原有印记到新表
    for _, sigil in ipairs(card1.sigils or {}) do
        table.insert(fused_card.sigils, sigil)
    end

    -- 有几率获得新印记
    if love.math.random() < 0.3 then
        local new_sigil = FUSION_RULES.possible_sigils[
            love.math.random(#FUSION_RULES.possible_sigils)
        ]
        -- 避免重复印记
        local has_sigil = false
        for _, s in ipairs(fused_card.sigils) do
            if s == new_sigil then has_sigil = true break end
        end
        if not has_sigil then
            table.insert(fused_card.sigils, new_sigil)
        end
    end

    return fused_card
end

-- 获取融合预览
function Fusion.preview(card1, card2)
    if not Fusion.can_fuse(card1, card2) then
        return nil
    end

    return {
        name = card1.name .. "+",
        attack = card1.attack + FUSION_RULES.stat_boost.attack,
        hp = card1.hp + FUSION_RULES.stat_boost.hp,
        new_sigils = FUSION_RULES.possible_sigils,
    }
end

-- 在牌组中查找可融合的卡牌对
function Fusion.find_fusible_pairs(deck)
    local card_counts = {}
    local result_pairs = {}  -- 改名避免与内置函数 pairs() 冲突

    -- 统计每种卡牌数量
    for i, card in ipairs(deck) do
        if not card.fused then
            if not card_counts[card.id] then
                card_counts[card.id] = {count = 0, indices = {}}
            end
            card_counts[card.id].count = card_counts[card.id].count + 1
            table.insert(card_counts[card.id].indices, i)
        end
    end

    -- 找出可以融合的配对
    for id, data in pairs(card_counts) do
        if data.count >= 2 then
            table.insert(result_pairs, {
                card_id = id,
                count = data.count,
                indices = data.indices,
            })
        end
    end

    return result_pairs
end

-- ==================== 骰子融合（新功能） ====================

-- 查找可用的骰子融合配方
function Fusion.find_dice_fusion_recipes(card1, card2)
    if not card1 or not card2 then return {} end

    local matching_recipes = {}
    local card1_id = card1.id
    local card2_id = card2.id

    for _, recipe in ipairs(DICE_FUSION_RECIPES) do
        local ing = recipe.ingredients
        local match = false

        -- 检查配方是否匹配（顺序无关）
        if ing[2] == "*" then
            -- 通配符：第一张卡必须匹配，第二张任意
            match = (card1_id == ing[1] or card2_id == ing[1])
        elseif ing[1] == "*" then
            match = (card1_id == ing[2] or card2_id == ing[2])
        else
            -- 两张卡都必须匹配
            match = (card1_id == ing[1] and card2_id == ing[2]) or
                    (card1_id == ing[2] and card2_id == ing[1])
        end

        if match then
            table.insert(matching_recipes, recipe)
        end
    end

    return matching_recipes
end

-- 执行骰子融合
-- 返回：success (bool), result (card or string), message (string)
function Fusion.dice_fuse(card1, card2, recipe)
    if not card1 or not card2 or not recipe then
        return false, nil, "Invalid fusion parameters"
    end

    -- 投骰子决定成功与否
    local roll = love.math.random()
    local success = roll < recipe.success_rate

    if success then
        -- 成功：创建融合卡牌
        local result_card

        if recipe.result.create_card then
            -- 使用预定义的特殊卡牌
            local template = SPECIAL_FUSION_CARDS[recipe.result.create_card]
            if template then
                result_card = {
                    id = template.id,
                    name = template.name,
                    cost = template.cost,
                    attack = template.attack + (recipe.result.attack_bonus or 0),
                    hp = template.hp + (recipe.result.hp_bonus or 0),
                    max_hp = template.hp + (recipe.result.hp_bonus or 0),
                    sigils = template.sigils or {},
                    rarity = template.rarity,
                    fused = true,
                }
            end
        else
            -- 基于第一张卡增强
            local base_card = card1.id == recipe.ingredients[1] and card1 or card2
            result_card = {
                id = base_card.id .. "_fused",
                name = base_card.name .. "★",
                cost = base_card.cost,
                attack = base_card.attack + (recipe.result.attack_bonus or 0),
                hp = base_card.hp + (recipe.result.hp_bonus or 0),
                max_hp = (base_card.max_hp or base_card.hp) + (recipe.result.hp_bonus or 0),
                sigils = {},
                rarity = base_card.rarity,
                fused = true,
            }

            -- 添加印记
            if recipe.result.sigils then
                for _, sigil in ipairs(recipe.result.sigils) do
                    table.insert(result_card.sigils, sigil)
                end
            elseif recipe.result.sigil_chance then
                if love.math.random() < recipe.result.sigil_chance then
                    local sigil = recipe.result.sigil_pool[love.math.random(#recipe.result.sigil_pool)]
                    table.insert(result_card.sigils, sigil)
                end
            end
        end

        return true, result_card, "Fusion successful! Created " .. result_card.name
    else
        -- 失败：根据配方决定后果
        local fail_card = nil
        local message = "Fusion failed! "

        if recipe.fail_result == "partial" then
            -- 返还一张随机卡
            local returned = love.math.random(2) == 1 and card1 or card2
            fail_card = returned
            message = message .. "Lost one card, kept " .. returned.name
        elseif recipe.fail_result == "squirrel" then
            -- 返还松鼠
            fail_card = {id = "squirrel", name = "Squirrel", cost = 0, attack = 0, hp = 1, sigils = {}}
            message = message .. "Only got a Squirrel back..."
        elseif recipe.fail_result == "turtle" or recipe.fail_result == "adder" then
            -- 返还特定卡
            local template = CardData.cards[recipe.fail_result]
            if template then
                fail_card = TableUtils and TableUtils.deep_copy(template) or {
                    id = template.id, name = template.name, cost = template.cost,
                    attack = template.attack, hp = template.hp, sigils = template.sigils or {}
                }
            end
            message = message .. "Salvaged a " .. recipe.fail_result
        else
            -- 全部丢失
            message = message .. "Both cards were destroyed!"
        end

        return false, fail_card, message
    end
end

-- 获取骰子融合的预览信息
function Fusion.dice_fuse_preview(card1, card2)
    local recipes = Fusion.find_dice_fusion_recipes(card1, card2)

    if #recipes == 0 then
        return nil
    end

    -- 返回所有可能的配方供玩家选择
    local previews = {}
    for _, recipe in ipairs(recipes) do
        local preview = {
            id = recipe.id,
            description = recipe.description,
            success_rate = math.floor(recipe.success_rate * 100) .. "%",
            risk = recipe.success_rate < 0.5 and "high" or (recipe.success_rate < 0.7 and "medium" or "low"),
        }

        if recipe.result.create_card and SPECIAL_FUSION_CARDS[recipe.result.create_card] then
            local template = SPECIAL_FUSION_CARDS[recipe.result.create_card]
            preview.result_name = template.name
            preview.result_attack = template.attack + (recipe.result.attack_bonus or 0)
            preview.result_hp = template.hp + (recipe.result.hp_bonus or 0)
            preview.result_sigils = template.sigils
        else
            preview.result_name = "Enhanced Card"
            preview.result_sigils = recipe.result.sigils
        end

        table.insert(previews, preview)
    end

    return previews
end

-- 检查两张卡是否可以进行骰子融合
function Fusion.can_dice_fuse(card1, card2)
    if not card1 or not card2 then return false end
    if card1.fused or card2.fused then return false end  -- 已融合的不能再融合

    local recipes = Fusion.find_dice_fusion_recipes(card1, card2)
    return #recipes > 0
end

-- 获取所有配方（供UI显示）
function Fusion.get_all_dice_recipes()
    return DICE_FUSION_RECIPES
end

-- 获取特殊融合卡牌列表
function Fusion.get_special_fusion_cards()
    return SPECIAL_FUSION_CARDS
end

return Fusion