-- systems/deck.lua - 牌组系统（Blood Cards风格）
-- 管理：牌组、抽牌堆、手牌、弃牌堆 + 兜底机制

local CardData = require("data.cards")
local TableUtils = require("utils.table")

local Deck = {}

-- 牌组状态
local deck_state = {
    deck = {},           -- 玩家牌组（永久）
    draw_pile = {},      -- 抽牌堆
    hand = {},           -- 当前手牌
    discard_pile = {},   -- 弃牌堆
    desperation_mode = false,  -- 绝望模式标记
    free_squirrels = 0,        -- 已获得的免费松鼠数量
}

-- ==================== 兜底机制配置 ====================
local FALLBACK_CONFIG = {
    -- 每回合自动获得免费松鼠的手牌阈值
    hand_threshold = 2,

    -- 绝望模式阈值（抽牌堆+弃牌堆都空时）
    activate_desperation = true,

    -- 免费松鼠上限（防止无限刷）
    max_free_squirrels = 3,

    -- 绝望时刻：空手时可获得特殊"末日牌"
    doom_card_enabled = true,
}

-- 初始化牌组（开局默认牌组）
function Deck.init()
    deck_state.deck = {}
    deck_state.draw_pile = {}
    deck_state.hand = {}
    deck_state.discard_pile = {}
    deck_state.desperation_mode = false
    deck_state.free_squirrels = 0

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
            -- 弃牌堆进入抽牌堆（直接移动引用，无需深拷贝）
            for _, card in ipairs(deck_state.discard_pile) do
                deck_state.draw_pile[#deck_state.draw_pile + 1] = card
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
                max_hp = card.max_hp or card.hp,  -- 确保 max_hp 有值
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

-- 获取所有卡牌（手牌+牌库中，用于融合选择）
function Deck.get_all_cards_for_fusion()
    local all_cards = {}
    local added_ids = {}

    -- 添加手牌
    for _, card in ipairs(deck_state.hand) do
        if not added_ids[card.id] then
            table.insert(all_cards, card)
            added_ids[card.id] = true
        end
    end

    -- 添加牌库中的卡牌
    for _, card in ipairs(deck_state.deck) do
        if not added_ids[card.id] then
            table.insert(all_cards, card)
            added_ids[card.id] = true
        end
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
        desperation_mode = deck_state.desperation_mode,
        free_squirrels = deck_state.free_squirrels,
    }
end

-- 重置牌组（新游戏）
function Deck.reset()
    Deck.init()
end

-- ==================== 兜底机制 ====================

-- 检查是否处于绝望状态（牌堆都空）
function Deck.is_desperate()
    return #deck_state.draw_pile == 0 and #deck_state.discard_pile == 0
end

-- 获得一张免费松鼠（不消耗牌组）
-- 注意：改为"战斗松鼠"，有1攻，可以实际战斗
function Deck.grant_free_squirrel()
    if deck_state.free_squirrels >= FALLBACK_CONFIG.max_free_squirrels then
        return false, "Maximum free squirrels reached"
    end

    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    if #deck_state.hand >= max_hand then
        return false, "Hand is full"
    end

    -- 创建一张"战斗松鼠"（有攻击力！）
    local squirrel = {
        id = "battle_squirrel",
        name = "Battle Squirrel",
        cost = 0,
        attack = 1,       -- 有攻击力！
        hp = 2,           -- 稍微增加血量
        max_hp = 2,
        sigils = {},
        free = true,      -- 标记为免费获得
    }

    deck_state.hand[#deck_state.hand + 1] = squirrel
    deck_state.free_squirrels = deck_state.free_squirrels + 1

    return true, "Granted a Battle Squirrel! (1 ATK, 2 HP)"
end

-- 回合开始时的兜底检查
-- 返回：是否触发了兜底，消息
function Deck.turn_start_fallback()
    local messages = {}
    local triggered = false

    -- 检查1：手牌过少，自动补充战斗松鼠
    if #deck_state.hand < FALLBACK_CONFIG.hand_threshold then
        if deck_state.free_squirrels < FALLBACK_CONFIG.max_free_squirrels then
            local success, msg = Deck.grant_free_squirrel()
            if success then
                triggered = true
                messages[#messages + 1] = msg
            end
        end
    end

    -- 检查2：牌堆全空（绝望模式）
    if Deck.is_desperate() then
        deck_state.desperation_mode = true

        -- 确保至少有一张可用卡
        if #deck_state.hand == 0 then
            -- 优先给末日牌（更强）
            if FALLBACK_CONFIG.doom_card_enabled then
                local doom_card = Deck.grant_doom_card()
                if doom_card then
                    triggered = true
                    messages[#messages + 1] = "DOOM CARD! 3 ATK, can revive once!"
                end
            end

            -- 末日牌失败时，给战斗松鼠
            if not triggered and deck_state.free_squirrels < FALLBACK_CONFIG.max_free_squirrels then
                local success, msg = Deck.grant_free_squirrel()
                if success then
                    triggered = true
                    messages[#messages + 1] = "DESPERATION! " .. msg
                end
            end
        end
    else
        deck_state.desperation_mode = false
    end

    return triggered, messages
end

-- 获得末日牌（终极兜底）
function Deck.grant_doom_card()
    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    if #deck_state.hand >= max_hand then
        return nil
    end

    -- 末日牌：一次性强力效果
    local doom_card = {
        id = "doom_card",
        name = "Doom Card",
        cost = 0,
        attack = 3,
        hp = 1,
        max_hp = 1,
        sigils = {"undead"},  -- 可以复活一次
        rarity = "legendary",
        doom = true,  -- 特殊标记
        one_time = true,  -- 使用后销毁
    }

    deck_state.hand[#deck_state.hand + 1] = doom_card

    return doom_card
end

-- 检查并移除末日牌（使用后销毁，不进入弃牌堆）
function Deck.consume_doom_card(card)
    if card and card.doom then
        -- 末日牌使用后完全销毁，不回收
        return true
    end
    return false
end

-- 强制抽牌（无视牌堆状态）
-- 用于特殊效果或奖励
-- card_id_or_data: 可以是卡牌ID字符串，或者完整的卡牌数据表
function Deck.force_draw_card(card_id_or_data)
    local Settings = require("config.settings")
    local max_hand = Settings.max_hand_size or 8

    if #deck_state.hand >= max_hand then
        return false, "Hand is full"
    end

    -- 判断是ID还是卡牌数据
    if type(card_id_or_data) == "string" then
        -- 字符串ID：从卡牌数据模板创建
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
        -- 直接是卡牌数据（融合卡牌等特殊卡）
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

-- 获取绝望模式状态
function Deck.get_desperation_mode()
    return deck_state.desperation_mode
end

-- 获取已使用免费松鼠数量
function Deck.get_free_squirrels_used()
    return deck_state.free_squirrels
end

-- 重置回合计数（新回合开始时）
function Deck.new_turn_reset()
    -- 每回合可以重置免费松鼠计数（可选）
    -- 当前设计：整个游戏最多3张免费松鼠
    -- 如果需要每回合重置，取消下面注释：
    -- deck_state.free_squirrels = 0
end

-- 挖掘弃牌堆（特殊技能）
-- 允许从弃牌堆选择一张牌返回手牌
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

    -- 从牌库中移除
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