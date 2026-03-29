-- systems/deck.lua - 牌组系统（Blood Cards风格）
-- 管理：牌组、抽牌堆、手牌、弃牌堆

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

-- 初始化牌组（开局默认牌组）
function Deck.init()
    deck_state.deck = {}
    deck_state.draw_pile = {}
    deck_state.hand = {}
    deck_state.discard_pile = {}

    -- 默认初始牌组
    local starter_cards = {
        "squirrel", "squirrel", "squirrel",  -- 3张免费献祭材料
        "stoat", "stoat",                     -- 2张基础攻击
        "wolf",                               -- 1张中坚
        "bullfrog",                           -- 1张肉盾
    }

    for _, card_id in ipairs(starter_cards) do
        Deck.add_to_deck(card_id)
    end

    Deck.shuffle_draw_pile()
end

-- 添加卡牌到牌组
function Deck.add_to_deck(card_id)
    local template = CardData.cards[card_id]
    if template then
        deck_state.deck[#deck_state.deck + 1] = TableUtils.deep_copy(template)
        deck_state.draw_pile[#deck_state.draw_pile + 1] = TableUtils.deep_copy(template)
    end
end

-- 洗抽牌堆
function Deck.shuffle_draw_pile()
    TableUtils.shuffle(deck_state.draw_pile)
end

-- 抽牌到手牌
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
                -- 没牌可抽了
                break
            end
            -- 弃牌堆进入抽牌堆
            for _, card in ipairs(deck_state.discard_pile) do
                deck_state.draw_pile[#deck_state.draw_pile + 1] = TableUtils.deep_copy(card)
            end
            deck_state.discard_pile = {}
            Deck.shuffle_draw_pile()
        end

        if #deck_state.draw_pile > 0 then
            local card = deck_state.draw_pile[#deck_state.draw_pile]
            deck_state.draw_pile[#deck_state.draw_pile] = nil

            -- 添加到手牌（带当前状态）
            deck_state.hand[#deck_state.hand + 1] = {
                id = card.id,
                name = card.name,
                cost = card.cost,
                attack = card.attack,
                hp = card.hp,
                max_hp = card.hp,
                sigils = card.sigils or {},
            }
        end
    end
end

-- 从手牌打出一张牌（返回卡牌数据）
function Deck.play_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)

    -- 加入弃牌堆
    deck_state.discard_pile[#deck_state.discard_pile + 1] = card

    return card
end

-- 献祭手牌（不进入弃牌堆，直接销毁）
function Deck.sacrifice_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)

    -- 不加入弃牌堆（献祭销毁）
    return card
end

-- 放置卡牌（从手牌移到棋盘，不进入弃牌堆）
function Deck.place_card(index)
    if index < 1 or index > #deck_state.hand then return nil end

    local card = deck_state.hand[index]
    table.remove(deck_state.hand, index)

    -- 返回卡牌供战斗场景使用
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
            hp = card.hp,  -- 重置为模板HP
            max_hp = card.max_hp,
            sigils = card.sigils or {},
        }
    end
end

-- 获取手牌列表
function Deck.get_hand()
    return deck_state.hand
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

-- 重置牌组（新游戏）
function Deck.reset()
    Deck.init()
end

return Deck