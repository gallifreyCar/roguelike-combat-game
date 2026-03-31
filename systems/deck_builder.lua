-- systems/deck_builder.lua - 牌组构建系统
-- 管理玩家自定义牌组、开局选牌

local DeckBuilder = {}
local Save = require("systems.save")
local MetaProgression = require("systems.meta_progression")
local CardData = require("data.cards")

-- 配置
DeckBuilder.DECK_SIZE = 15        -- 牌组大小
DeckBuilder.MAX_SAME_CARD = 2     -- 同ID最多数量
DeckBuilder.MAX_DECKS = 3         -- 最多保存3个牌组方案

-- 牌组数据
local builder_state = {
    current_deck = {},       -- 当前构建中的牌组
    saved_decks = {},        -- 保存的牌组方案
    selected_slot = 1,       -- 当前选择的牌组槽位
}

-- 初始化
function DeckBuilder.init()
    local data = Save.get_data()
    builder_state.saved_decks = data.saved_decks or {}
    builder_state.current_deck = {}
    builder_state.selected_slot = 1

    -- 如果有保存的牌组，加载第一个
    if builder_state.saved_decks[1] then
        builder_state.current_deck = DeckBuilder.copy_deck(builder_state.saved_decks[1])
    end
end

-- 获取当前牌组
function DeckBuilder.get_current_deck()
    return builder_state.current_deck
end

-- 获取牌组中的卡牌数量
function DeckBuilder.get_deck_size()
    return #builder_state.current_deck
end

-- 获取某张卡在牌组中的数量
function DeckBuilder.get_card_count(card_id)
    local count = 0
    for _, card in ipairs(builder_state.current_deck) do
        if card.id == card_id then
            count = count + 1
        end
    end
    return count
end

-- 检查是否可以添加卡牌
function DeckBuilder.can_add_card(card_id)
    -- 检查牌组是否已满
    if #builder_state.current_deck >= DeckBuilder.DECK_SIZE then
        return false, "Deck is full"
    end

    -- 检查卡牌是否已解锁
    if not MetaProgression.is_card_unlocked(card_id) then
        -- 检查是否是基础卡牌（不需要解锁）
        local template = CardData.cards[card_id]
        if template and template.rarity ~= "common" then
            -- 检查是否是解锁卡
            if MetaProgression.is_unlock_card(card_id) then
                return false, "Card not unlocked"
            end
        end
    end

    -- 检查同卡数量限制
    local count = DeckBuilder.get_card_count(card_id)
    if count >= DeckBuilder.MAX_SAME_CARD then
        return false, "Max " .. DeckBuilder.MAX_SAME_CARD .. " same cards"
    end

    return true
end

-- 添加卡牌到牌组
function DeckBuilder.add_card(card_id)
    local can_add, reason = DeckBuilder.can_add_card(card_id)
    if not can_add then
        return false, reason
    end

    local template = CardData.cards[card_id]
    if not template then
        return false, "Card not found"
    end

    -- 添加卡牌（带family字段）
    table.insert(builder_state.current_deck, {
        id = card_id,
        name = template.name,
        cost = template.cost,
        attack = template.attack,
        hp = template.hp,
        max_hp = template.max_hp or template.hp,
        sigils = template.sigils or {},
        family = template.family,
        rarity = template.rarity,
    })

    return true
end

-- 移除卡牌（按索引）
function DeckBuilder.remove_card(index)
    if index < 1 or index > #builder_state.current_deck then
        return false
    end

    table.remove(builder_state.current_deck, index)
    return true
end

-- 清空牌组
function DeckBuilder.clear_deck()
    builder_state.current_deck = {}
end

-- 随机填充牌组（用于快速开始）
function DeckBuilder.random_fill()
    builder_state.current_deck = {}

    -- 获取所有可用卡牌
    local available = DeckBuilder.get_available_cards()

    -- 按稀有度权重选择
    local weights = {
        common = 50,
        uncommon = 30,
        rare = 15,
        legendary = 5,
    }

    while #builder_state.current_deck < DeckBuilder.DECK_SIZE and #available > 0 do
        -- 随机选择一张
        local roll = love.math.random(100)
        local rarity = "common"
        local cumulative = 0

        for r, w in pairs(weights) do
            cumulative = cumulative + w
            if roll < cumulative then
                rarity = r
                break
            end
        end

        -- 找到该稀有度的卡牌
        local pool = {}
        for _, card_id in ipairs(available) do
            local template = CardData.cards[card_id]
            if template and template.rarity == rarity then
                if DeckBuilder.can_add_card(card_id) then
                    table.insert(pool, card_id)
                end
            end
        end

        -- 如果该稀有度没有可用卡，尝试其他稀有度
        if #pool == 0 then
            for _, card_id in ipairs(available) do
                if DeckBuilder.can_add_card(card_id) then
                    table.insert(pool, card_id)
                end
            end
        end

        if #pool > 0 then
            local card_id = pool[love.math.random(#pool)]
            DeckBuilder.add_card(card_id)
        else
            break
        end
    end
end

-- 获取所有可用卡牌（已解锁的）
function DeckBuilder.get_available_cards()
    local available = {}

    for card_id, template in pairs(CardData.cards) do
        -- 跳过squirrel（献祭材料，自动添加）
        if card_id ~= "squirrel" then
            -- common卡牌默认解锁
            if template.rarity == "common" then
                table.insert(available, card_id)
            -- 其他稀有度需要检查解锁状态
            elseif MetaProgression.is_card_unlocked(card_id) or not MetaProgression.is_unlock_card(card_id) then
                table.insert(available, card_id)
            end
        end
    end

    return available
end

-- 保存牌组
function DeckBuilder.save_deck(slot)
    slot = slot or builder_state.selected_slot
    builder_state.saved_decks[slot] = DeckBuilder.copy_deck(builder_state.current_deck)
    Save.get_data().saved_decks = builder_state.saved_decks
    Save.save()
    return true
end

-- 加载牌组
function DeckBuilder.load_deck(slot)
    slot = slot or builder_state.selected_slot
    if builder_state.saved_decks[slot] then
        builder_state.current_deck = DeckBuilder.copy_deck(builder_state.saved_decks[slot])
        return true
    end
    return false
end

-- 复制牌组
function DeckBuilder.copy_deck(deck)
    local copy = {}
    for _, card in ipairs(deck) do
        table.insert(copy, {
            id = card.id,
            name = card.name,
            cost = card.cost,
            attack = card.attack,
            hp = card.hp,
            max_hp = card.max_hp,
            sigils = card.sigils or {},
            family = card.family,
            rarity = card.rarity,
        })
    end
    return copy
end

-- 检查牌组是否有效
function DeckBuilder.is_deck_valid()
    return #builder_state.current_deck == DeckBuilder.DECK_SIZE
end

-- 获取牌组统计
function DeckBuilder.get_deck_stats()
    local stats = {
        total = #builder_state.current_deck,
        families = {},
        rarities = {},
        avg_cost = 0,
        avg_attack = 0,
        avg_hp = 0,
    }

    local total_cost = 0
    local total_attack = 0
    local total_hp = 0

    for _, card in ipairs(builder_state.current_deck) do
        -- 体系统计
        if card.family then
            stats.families[card.family] = (stats.families[card.family] or 0) + 1
        end

        -- 稀有度统计
        stats.rarities[card.rarity] = (stats.rarities[card.rarity] or 0) + 1

        -- 属性统计
        total_cost = total_cost + (card.cost or 0)
        total_attack = total_attack + (card.attack or 0)
        total_hp = total_hp + (card.hp or 0)
    end

    if stats.total > 0 then
        stats.avg_cost = math.floor(total_cost / stats.total * 10) / 10
        stats.avg_attack = math.floor(total_attack / stats.total * 10) / 10
        stats.avg_hp = math.floor(total_hp / stats.total * 10) / 10
    end

    return stats
end

-- 获取保存的牌组列表
function DeckBuilder.get_saved_decks()
    return builder_state.saved_decks
end

-- 删除保存的牌组
function DeckBuilder.delete_deck(slot)
    builder_state.saved_decks[slot] = nil
    Save.get_data().saved_decks = builder_state.saved_decks
    Save.save()
end

-- 应用牌组到Deck系统（开局时调用）
function DeckBuilder.apply_deck()
    local Deck = require("systems.deck")

    -- 重置牌组
    Deck.reset()

    -- 清空初始牌组，用自定义牌组替换
    -- 注意：这个需要修改Deck.init()逻辑

    return builder_state.current_deck
end

return DeckBuilder