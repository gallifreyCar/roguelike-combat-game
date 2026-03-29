-- systems/fusion.lua - 卡牌融合系统
-- 两张相同卡牌融合升级

local Fusion = {}
local CardData = require("data.cards")

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

    -- 创建融合后的卡牌
    local fused_card = {
        id = card1.id,
        name = card1.name .. "+",
        cost = card1.cost,
        attack = card1.attack + FUSION_RULES.stat_boost.attack,
        hp = card1.hp + FUSION_RULES.stat_boost.hp,
        max_hp = card1.max_hp + FUSION_RULES.stat_boost.hp,
        sigils = card1.sigils or {},
        rarity = card1.rarity,
        fused = true,
    }

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
    local pairs = {}

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
            table.insert(pairs, {
                card_id = id,
                count = data.count,
                indices = data.indices,
            })
        end
    end

    return pairs
end

return Fusion