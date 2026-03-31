-- systems/fusion.lua - 卡牌融合系统
-- 支持：同卡融合（固定加成）+ 骰子融合（异卡随机融合）+ 自由融合（任意卡组合）
-- 融合后卡牌获得属性提升、新印记和可能的变异效果

local Fusion = {}
local CardData = require("data.cards")
local TableUtils = require("utils.table")

-- 融合次数限制：每局最多5次融合
Fusion.MAX_FUSIONS = 5
Fusion.fusion_count = 0

-- 检查是否还能融合
function Fusion.can_fuse_more()
    return Fusion.fusion_count < Fusion.MAX_FUSIONS
end

-- 获取剩余融合次数
function Fusion.get_remaining_fusions()
    return Fusion.MAX_FUSIONS - Fusion.fusion_count
end

-- 增加融合计数
function Fusion.increment_fusion_count()
    Fusion.fusion_count = Fusion.fusion_count + 1
end

-- 重置融合计数（新游戏开始时）
function Fusion.reset_fusion_count()
    Fusion.fusion_count = 0
end

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
-- Round 5 平衡调整：成功率根据风险收益重新设计
-- 原则：高收益低成功率，低收益高成功率
local DICE_FUSION_RECIPES = {
    -- 低级融合：废牌利用（高成功率，低收益）
    {
        id = "squirrel_boost",
        ingredients = {"squirrel", "*"},  -- * 表示任意卡
        result = {
            attack_bonus = 0,
            hp_bonus = 1,
            sigil_chance = 0.25,  -- 提高印记概率
            sigil_pool = {"tough"},
        },
        success_rate = 0.95,  -- 提高成功率：松鼠是免费牌，失败代价低
        fail_result = "squirrel",  -- 失败返还松鼠
        description = "Squirrel sacrifice enhances any card",
        risk_level = "low",
    },

    -- 毒攻融合：剧毒+攻击（中等成功率，中等收益）
    {
        id = "poison_attacker",
        ingredients = {"adder", "wolf"},  -- 毒蛇 + 狼
        result = {
            create_card = "poison_wolf",  -- 创建特殊卡
            attack_bonus = 1,
            hp_bonus = 1,
            sigils = {"poison", "double_strike"},
        },
        success_rate = 0.70,  -- 提高：两张普通牌融合
        fail_result = "partial",  -- 返还一张
        description = "Poison Wolf: High attack with poison",
        risk_level = "medium",
    },

    -- 飞行突击：飞行+攻击（中等成功率，高风险）
    {
        id = "air_assassin",
        ingredients = {"raven", "wolf"},
        result = {
            create_card = "sky_hunter",
            attack_bonus = 2,
            hp_bonus = 0,
            sigils = {"air_strike", "charge"},
        },
        success_rate = 0.60,  -- 提高收益很高，失败全部丢失
        fail_result = "none",  -- 全部丢失
        description = "Sky Hunter: Flying charge attack",
        risk_level = "high",
    },

    -- 坦克融合：高血量组合（高成功率，稳定收益）
    {
        id = "fortress",
        ingredients = {"turtle", "bullfrog"},
        result = {
            attack_bonus = 0,
            hp_bonus = 4,
            sigils = {"tough", "guardian"},
        },
        success_rate = 0.85,  -- 提高：防御牌融合风险低
        fail_result = "turtle",  -- 返还乌龟
        description = "Fortress: Ultimate tank with guardian",
        risk_level = "low",
    },

    -- 复活融合：不死组合（中等成功率，独特收益）
    {
        id = "undead_army",
        ingredients = {"cat", "*"},  -- 猫 + 任意卡
        result = {
            attack_bonus = 1,
            hp_bonus = 2,
            sigil_chance = 0.85,  -- 高印记概率
            sigil_pool = {"undead", "tough"},
        },
        success_rate = 0.65,  -- 提高：猫本身是稀有牌
        fail_result = "partial",
        description = "Undead fusion: Grant second life",
        risk_level = "medium",
    },

    -- 毒雾组合：范围毒（中等成功率）
    {
        id = "toxic_cloud",
        ingredients = {"adder", "skunk"},
        result = {
            create_card = "toxic_beast",
            attack_bonus = 0,
            hp_bonus = 2,
            sigils = {"poison", "stinky"},
        },
        success_rate = 0.65,  -- 提高
        fail_result = "adder",
        description = "Toxic Beast: Poison + debuff combo",
        risk_level = "medium",
    },

    -- 暴击融合：双击+高攻（高风险高收益）
    {
        id = "berserker",
        ingredients = {"mantis", "wolf"},
        result = {
            attack_bonus = 2,
            hp_bonus = 0,
            sigils = {"double_strike", "trample"},
        },
        success_rate = 0.55,  -- 保持较低：两张稀有牌，收益极高
        fail_result = "none",
        description = "Berserker: Double strike + trample",
        risk_level = "high",
    },

    -- 传说融合：终极组合（极高风险，最高收益）
    {
        id = "legendary",
        ingredients = {"grizzly", "eagle"},
        result = {
            create_card = "legendary_beast",
            attack_bonus = 3,
            hp_bonus = 4,
            sigils = {"air_strike", "trample", "sharp_quills"},
        },
        success_rate = 0.40,  -- 提高：两张稀有牌，但收益最高
        fail_result = "partial",  -- 至少返还一张
        description = "Legendary Beast: Ultimate power!",
        risk_level = "extreme",
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

    -- 有几率获得新印记（Round 5 平衡：提高到35%）
    if love.math.random() < 0.35 then
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

-- ==================== 自由融合系统（新功能） ====================

-- 变异效果池：融合时可能获得的额外效果
local MUTATION_POOL = {
    -- 正向变异（增益）
    {name = "power_boost", type = "positive", weight = 0.15,
     effect = function(card) card.attack = card.attack + 2 end,
     desc = "+2 Attack"},
    {name = "vitality", type = "positive", weight = 0.15,
     effect = function(card) card.hp = card.hp + 2; card.max_hp = card.max_hp + 2 end,
     desc = "+2 Max HP"},
    {name = "cost_reduce", type = "positive", weight = 0.10,
     effect = function(card) card.cost = math.max(0, card.cost - 1) end,
     desc = "Cost -1"},
    {name = "regeneration", type = "positive", weight = 0.08,
     effect = function(card) table.insert(card.sigils, "regen") end,
     desc = "Regen sigil"},
    {name = "vampire", type = "positive", weight = 0.05,
     effect = function(card) table.insert(card.sigils, "vampire") end,
     desc = "Vampire sigil (heal on hit)"},

    -- 中性变异（特殊效果）
    {name = "swap_stats", type = "neutral", weight = 0.10,
     effect = function(card)
         local old_atk = card.attack
         card.attack = math.floor(card.hp * 0.8)
         card.hp = math.floor(old_atk * 1.5)
         card.max_hp = card.hp
     end,
     desc = "Stats swapped (ATK=HP*0.8, HP=ATK*1.5)"},
    {name = "glass_cannon", type = "neutral", weight = 0.08,
     effect = function(card)
         card.attack = card.attack * 2
         card.hp = math.max(1, math.floor(card.hp * 0.5))
         card.max_hp = card.hp
     end,
     desc = "Double ATK, half HP"},
    {name = "blood_cost", type = "neutral", weight = 0.10,
     effect = function(card)
         card.cost = card.cost + 2
         card.attack = card.attack + 3
     end,
     desc = "+3 ATK but +2 cost"},

    -- 负向变异（风险）
    {name = "weaken", type = "negative", weight = 0.08,
     effect = function(card) card.attack = math.max(0, card.attack - 1) end,
     desc = "-1 Attack"},
    {name = "fragile", type = "negative", weight = 0.06,
     effect = function(card) card.hp = math.max(1, card.hp - 1); card.max_hp = card.max_hp - 1 end,
     desc = "-1 Max HP"},
    {name = "expensive", type = "negative", weight = 0.05,
     effect = function(card) card.cost = card.cost + 1 end,
     desc = "Cost +1"},
}

-- 检查两张卡是否可以自由融合（任意两张不同卡）
function Fusion.can_free_fuse(card1, card2)
    if not card1 or not card2 then return false end
    if card1.fused or card2.fused then return false end
    return true  -- 任意两张卡都可以自由融合
end

-- 应用随机变异
local function apply_mutation(card)
    -- 45% 概率发生变异（Round 5 平衡：提高到45%）
    if love.math.random() > 0.45 then return nil end

    -- 根据权重选择变异
    local total_weight = 0
    for _, mutation in ipairs(MUTATION_POOL) do
        total_weight = total_weight + mutation.weight
    end

    local roll = love.math.random() * total_weight
    for _, mutation in ipairs(MUTATION_POOL) do
        roll = roll - mutation.weight
        if roll <= 0 then
            mutation.effect(card)
            return mutation
        end
    end

    return nil
end

-- 执行自由融合（随机结果 + 可能变异）
function Fusion.free_fuse(card1, card2)
    if not Fusion.can_free_fuse(card1, card2) then
        return nil
    end

    -- 基础属性：取两张卡的平均值
    local base_atk = math.floor((card1.attack + card2.attack) / 2)
    local base_hp = math.floor((card1.hp + card2.hp) / 2)
    local base_cost = math.floor((card1.cost + card2.cost) / 2)

    -- 随机变异：属性可能有 +/- 1 的变化
    local atk_variation = love.math.random(-1, 1)
    local hp_variation = love.math.random(-1, 1)

    local final_atk = math.max(0, base_atk + atk_variation)
    local final_hp = math.max(1, base_hp + hp_variation)

    -- 合并印记
    local merged_sigils = {}
    local sigil_set = {}
    for _, sigil in ipairs(card1.sigils or {}) do
        if not sigil_set[sigil] then
            table.insert(merged_sigils, sigil)
            sigil_set[sigil] = true
        end
    end
    for _, sigil in ipairs(card2.sigils or {}) do
        if not sigil_set[sigil] then
            table.insert(merged_sigils, sigil)
            sigil_set[sigil] = true
        end
    end

    -- 随机获得新印记（25%几率，提高到25%）
    if love.math.random() < 0.25 then
        local all_sigils = {"tough", "double_strike", "poison", "air_strike", "undead", "stinky", "regen", "vampire"}
        local new_sigil = all_sigils[love.math.random(#all_sigils)]
        if not sigil_set[new_sigil] then
            table.insert(merged_sigils, new_sigil)
            sigil_set[new_sigil] = true
        end
    end

    -- 计算稀有度
    local rarity = "common"
    if #merged_sigils >= 3 then
        rarity = "rare"
    elseif #merged_sigils >= 2 or final_atk >= 4 or final_hp >= 6 then
        rarity = "uncommon"
    end

    -- 生成融合卡牌名称
    local name_prefix = card1.name:sub(1, 4)
    local name_suffix = card2.name:sub(1, 4)
    local fused_name = name_prefix .. "-" .. name_suffix .. " Hybrid"

    -- 生成融合卡牌
    local fused_id = "free_" .. card1.id .. "_" .. card2.id
    local fused_card = {
        id = fused_id,
        name = fused_name,
        cost = base_cost,
        attack = final_atk,
        hp = final_hp,
        max_hp = final_hp,
        sigils = merged_sigils,
        rarity = rarity,
        fused = true,
        free_fused = true,
    }

    -- 应用随机变异
    local mutation = apply_mutation(fused_card)
    if mutation then
        fused_card.mutation = mutation.name
        fused_card.mutation_desc = mutation.desc
        fused_card.mutation_type = mutation.type
        -- 变异后的稀有度调整
        if mutation.type == "positive" and rarity == "common" then
            fused_card.rarity = "uncommon"
        elseif mutation.type == "negative" and rarity == "rare" then
            fused_card.rarity = "uncommon"
        end
    end

    return fused_card
end

-- 获取自由融合预览
function Fusion.free_fuse_preview(card1, card2)
    if not card1 or not card2 then return nil end

    local base_atk = math.floor((card1.attack + card2.attack) / 2)
    local base_hp = math.floor((card1.hp + card2.hp) / 2)

    return {
        name = "Hybrid",
        attack_min = math.max(0, base_atk - 1),
        attack_max = base_atk + 1,
        hp_min = math.max(1, base_hp - 1),
        hp_max = base_hp + 1,
        possible_sigils = {"tough", "double_strike", "poison", "air_strike", "undead", "stinky"},
    }
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