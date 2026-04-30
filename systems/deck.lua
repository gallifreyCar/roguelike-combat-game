-- systems/deck.lua - 牌组系统
-- 管理：牌组、抽牌堆、手牌、弃牌堆
-- 【重构】移除兜底机制，依靠牌组自循环
-- 【扩展】支持局外成长系统加成

local CardData = require("data.cards")
local TableUtils = require("utils.table")

local Deck = {}

-- 牌组状态
local deck_state = {
    deck = {},           -- 玩家牌组（永久）
    draw_pile = {},      -- 抽牌堆
    hand = {},           -- 当前手牌
    discard_pile = {},   -- 弃牌堆
}

-- 局外成长加成缓存
local meta_bonuses = nil

--- 设置局外成长加成（由 MetaProgression 调用）
-- @param bonuses table: 包含 hp_bonus, gold_bonus, blood_bonus 等字段
function Deck.set_meta_bonuses(bonuses)
    meta_bonuses = bonuses
end

--- 初始化牌组（开局默认牌组）
-- 【重构】扩充到15张，确保第一轮战斗有足够战力
-- 【扩展】应用局外成长加成
function Deck.init()
    deck_state.deck = {}
    deck_state.draw_pile = {}
    deck_state.hand = {}
    deck_state.discard_pile = {}

    -- 扩大的初始牌组（15张基础牌）
    -- 确保低费牌充足，第一轮能稳定战斗
    local starter_cards = {
        -- 0费献祭材料（3张）
        "squirrel", "squirrel", "squirrel",
        -- 1费基础攻击（6张）- 核心战力
        "stoat", "stoat",           -- 2张基础1/2
        "rat", "rat",               -- 2张高攻2/1
        "bullfrog", "bullfrog",     -- 2张肉盾1/4
        -- 2费中坚（4张）
        "wolf", "wolf",             -- 2张狼 2/2
        "raven", "raven",           -- 2张渡鸦（飞行）
        -- 功能牌（2张）
        "turtle",                   -- 守护者
        "insight",                  -- 过牌
    }

    for _, card_id in ipairs(starter_cards) do
        Deck.add_to_deck(card_id)
    end

    -- 应用局外成长加成
    if meta_bonuses then
        -- 更好的松鼠：给松鼠+1 HP
        if meta_bonuses.better_squirrel then
            for _, card in ipairs(deck_state.deck) do
                if card.id == "squirrel" then
                    card.hp = card.hp + 1
                    card.max_hp = card.max_hp + 1
                end
            end
        end

        -- 起始稀有牌：添加一张随机稀有牌
        if meta_bonuses.starting_rare then
            local MetaProgression = require("systems.meta_progression")
            local rare_card_id = MetaProgression.get_random_rare_card()
            if rare_card_id then
                Deck.add_to_deck(rare_card_id)
            end
        end
    end

    Deck.shuffle_draw_pile()
end

--- 添加卡牌到牌组
-- @param card_id string: 卡牌模板ID
function Deck.add_to_deck(card_id)
    local template = CardData.cards[card_id]
    if template then
        deck_state.deck[#deck_state.deck + 1] = TableUtils.deep_copy(template)
        deck_state.draw_pile[#deck_state.draw_pile + 1] = TableUtils.deep_copy(template)
    end
end

--- 洗抽牌堆
function Deck.shuffle_draw_pile()
    TableUtils.shuffle(deck_state.draw_pile)
end

--- 抽牌到手牌
-- @param n number: 抽牌数量
-- 手牌上限由 Settings.max_hand_size 控制
function Deck.draw_cards(n)
    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    for i = 1, n do
        -- 手牌上限检查
        if #deck_state.hand >= max_hand then
            break
        end

        -- 抽牌堆空了，洗弃牌堆
        if #deck_state.draw_pile == 0 then
            if #deck_state.discard_pile == 0 then
                -- 没牌可抽了，回合结束等待弃牌堆回收
                break
            end
            -- 弃牌堆进入抽牌堆
            for _, card in ipairs(deck_state.discard_pile) do
                deck_state.draw_pile[#deck_state.draw_pile + 1] = card
            end
            deck_state.discard_pile = {}
            Deck.shuffle_draw_pile()
        end

        if #deck_state.draw_pile > 0 then
            local card = deck_state.draw_pile[#deck_state.draw_pile]
            deck_state.draw_pile[#deck_state.draw_pile] = nil

            -- 添加到手牌
            deck_state.hand[#deck_state.hand + 1] = {
                id = card.id,
                name = card.name,
                cost = card.cost,
                attack = card.attack,
                hp = card.hp,
                max_hp = card.max_hp or card.hp,
                sigils = card.sigils or {},
            }
        end
    end
end

--- 从手牌打出一张牌（返回卡牌数据）
-- @param index number: 手牌索引
-- @return table|nil: 打出的卡牌数据，索引无效返回nil
function Deck.play_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)

    deck_state.discard_pile[#deck_state.discard_pile + 1] = card
    return card
end

-- 献祭手牌（不进入弃牌堆，直接销毁）
function Deck.sacrifice_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)
    return card
end

-- 放置卡牌（从手牌移到棋盘）
function Deck.place_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)
    return card
end

-- 弃掉所有手牌
function Deck.discard_hand()
    for _, card in ipairs(deck_state.hand) do
        deck_state.discard_pile[#deck_state.discard_pile + 1] = card
    end
    deck_state.hand = {}
end

-- 回收卡牌到弃牌堆（棋盘上的牌回合结束时回收）
function Deck.recycle_card(card)
    if card then
        deck_state.discard_pile[#deck_state.discard_pile + 1] = {
            id = card.id,
            name = card.name,
            cost = card.cost,
            attack = card.attack,
            hp = card.hp,
            max_hp = card.max_hp,
            sigils = card.sigils or {},
        }
    end
end

-- 获取手牌列表
function Deck.get_hand()
    return deck_state.hand
end

-- 获取整个牌库（用于融合/查看）
function Deck.get_deck()
    return deck_state.deck
end

-- 获取抽牌堆
function Deck.get_draw_pile()
    return deck_state.draw_pile
end

-- 获取弃牌堆
function Deck.get_discard_pile()
    return deck_state.discard_pile
end

-- 获取所有卡牌（用于融合选择）
function Deck.get_all_cards_for_fusion()
    local all_cards = {}
    for _, card in ipairs(deck_state.deck) do
        table.insert(all_cards, {
            id = card.id,
            name = card.name,
            cost = card.cost,
            attack = card.attack,
            hp = card.hp,
            max_hp = card.max_hp or card.hp,
            sigils = card.sigils or {},
            fused = card.fused,
        })
    end
    return all_cards
end

-- 获取手牌数量
function Deck.hand_size()
    return #deck_state.hand
end

-- 获取牌组信息（用于UI显示）
function Deck.get_info()
    return {
        deck_size = #deck_state.deck,
        draw_pile_size = #deck_state.draw_pile,
        hand_size = #deck_state.hand,
        discard_pile_size = #deck_state.discard_pile,
    }
end

-- 别名：get_cards = get_deck（兼容性）
function Deck.get_cards()
    return Deck.get_deck()
end

-- 获取松鼠卡数量
function Deck.get_squirrel_count()
    local count = 0
    for _, card in ipairs(deck_state.deck) do
        if card.id == "squirrel" then
            count = count + 1
        end
    end
    return count
end

-- 设置自定义牌组（用于deck_builder）
function Deck.set_custom_deck(cards)
    if not cards or #cards == 0 then return false end

    deck_state.deck = {}
    deck_state.draw_pile = {}

    for _, card in ipairs(cards) do
        if card and card.id then
            local template = CardData.cards[card.id]
            if template then
                deck_state.deck[#deck_state.deck + 1] = TableUtils.deep_copy(template)
            end
        end
    end

    -- 同步到抽牌堆
    Deck.reset_for_battle()
    return true
end

-- 重置牌组（新游戏）
function Deck.reset()
    Deck.init()
end

-- 重置抽牌堆（每场战斗开始时调用）
-- 将所有牌放入抽牌堆并洗牌，清空手牌和弃牌堆
function Deck.reset_for_battle()
    -- 清空手牌和弃牌堆
    deck_state.hand = {}
    deck_state.discard_pile = {}

    -- 从牌组重新填充抽牌堆
    deck_state.draw_pile = {}
    for _, card in ipairs(deck_state.deck) do
        deck_state.draw_pile[#deck_state.draw_pile + 1] = {
            id = card.id,
            name = card.name,
            cost = card.cost,
            attack = card.attack,
            hp = card.hp,
            max_hp = card.max_hp or card.hp,
            sigils = card.sigils or {},
            fused = card.fused,
            rarity = card.rarity,
        }
    end

    -- 洗牌
    Deck.shuffle_draw_pile()
end

-- 强制抽牌（用于特殊效果或奖励）
function Deck.force_draw_card(card_id_or_data)
    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    if #deck_state.hand >= max_hand then
        return false, "Hand is full"
    end

    if type(card_id_or_data) == "string" then
        local template = CardData.cards[card_id_or_data]
        if template then
            deck_state.hand[#deck_state.hand + 1] = {
                id = template.id,
                name = template.name,
                cost = template.cost,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.max_hp or template.hp,
                sigils = template.sigils or {},
            }
            return true, "Added " .. template.name
        end
    elseif type(card_id_or_data) == "table" then
        deck_state.hand[#deck_state.hand + 1] = {
            id = card_id_or_data.id,
            name = card_id_or_data.name,
            cost = card_id_or_data.cost,
            attack = card_id_or_data.attack,
            hp = card_id_or_data.hp,
            max_hp = card_id_or_data.max_hp or card_id_or_data.hp,
            sigils = card_id_or_data.sigils or {},
            fused = card_id_or_data.fused,
        }
        return true, "Added " .. card_id_or_data.name
    end

    return false, "Invalid card data"
end

-- 挖掘弃牌堆（特殊技能）
function Deck.dig_discard_pile(index)
    if index < 1 or index > #deck_state.discard_pile then
        return nil, "Invalid index"
    end

    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    if #deck_state.hand >= max_hand then
        return nil, "Hand is full"
    end

    local card = deck_state.discard_pile[index]
    table.remove(deck_state.discard_pile, index)

    deck_state.hand[#deck_state.hand + 1] = {
        id = card.id,
        name = card.name,
        cost = card.cost,
        attack = card.attack,
        hp = card.hp,
        max_hp = card.max_hp or card.hp,
        sigils = card.sigils or {},
    }

    return card, "Dug up " .. card.name
end

-- 查看弃牌堆内容
function Deck.view_discard_pile()
    return deck_state.discard_pile
end

-- ==================== 融合辅助函数 ====================

-- 从牌库中移除指定ID的卡牌（用于融合）
function Deck.remove_from_deck_by_id(card_id, count)
    count = count or 1
    local removed = 0

    for i = #deck_state.deck, 1, -1 do
        if deck_state.deck[i] and deck_state.deck[i].id == card_id and removed < count then
            table.remove(deck_state.deck, i)
            removed = removed + 1
        end
    end

    return removed
end

-- 添加融合卡牌到牌库
function Deck.add_fused_card(card)
    if not card then return false end

    deck_state.deck[#deck_state.deck + 1] = {
        id = card.id,
        name = card.name,
        cost = card.cost,
        attack = card.attack,
        hp = card.hp,
        max_hp = card.max_hp or card.hp,
        sigils = card.sigils or {},
        fused = true,
        rarity = card.rarity,
    }

    return true
end

return Deck