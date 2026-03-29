-- systems/deck.lua - 牌组系统
-- 管理：抽牌堆、手牌、弃牌堆

local Deck = {
    draw_pile = {},
    hand = {},
    discard_pile = {},
}

-- 初始牌组（Starter Deck）
local starter_deck = {
    {id = "strike", cost = 1, type = "attack", damage = 6},
    {id = "strike", cost = 1, type = "attack", damage = 6},
    {id = "strike", cost = 1, type = "attack", damage = 6},
    {id = "strike", cost = 1, type = "attack", damage = 6},
    {id = "defend", cost = 1, type = "skill", block = 5},
    {id = "defend", cost = 1, type = "skill", block = 5},
    {id = "defend", cost = 1, type = "skill", block = 5},
    {id = "defend", cost = 1, type = "skill", block = 5},
    {id = "bash", cost = 2, type = "attack", damage = 8},
}

-- 卡牌名称
local card_names = {
    strike = "Strike",
    defend = "Defend",
    bash = "Bash",
}

function Deck.init()
    -- 复制初始牌组到抽牌堆
    Deck.draw_pile = {}
    for _, card in ipairs(starter_deck) do
        Deck.draw_pile[#Deck.draw_pile + 1] = {id = card.id, cost = card.cost, type = card.type, damage = card.damage, block = card.block}
    end

    -- 洗牌
    Deck.shuffle()

    Deck.hand = {}
    Deck.discard_pile = {}
end

function Deck.shuffle()
    -- Fisher-Yates shuffle
    for i = #Deck.draw_pile, 2, -1 do
        local j = love.math.random(1, i)
        Deck.draw_pile[i], Deck.draw_pile[j] = Deck.draw_pile[j], Deck.draw_pile[i]
    end
end

function Deck.draw_cards(n)
    for i = 1, n do
        if #Deck.draw_pile == 0 then
            -- 抽牌堆空了，洗弃牌堆
            for _, card in ipairs(Deck.discard_pile) do
                Deck.draw_pile[#Deck.draw_pile + 1] = card
            end
            Deck.discard_pile = {}
            Deck.shuffle()
        end

        if #Deck.draw_pile > 0 then
            local card = Deck.draw_pile[#Deck.draw_pile]
            Deck.draw_pile[#Deck.draw_pile] = nil
            Deck.hand[#Deck.hand + 1] = card
        end
    end
end

function Deck.play_card(index)
    if index < 1 or index > #Deck.hand then return nil end

    local card = Deck.hand[index]

    -- 移除手牌
    table.remove(Deck.hand, index)

    -- 加入弃牌堆
    Deck.discard_pile[#Deck.discard_pile + 1] = card

    return card
end

function Deck.end_turn()
    -- 弃掉所有手牌
    for _, card in ipairs(Deck.hand) do
        Deck.discard_pile[#Deck.discard_pile + 1] = card
    end
    Deck.hand = {}
end

function Deck.draw_hand(current_energy)
    -- 计算手牌位置（居中）
    local card_width = 90
    local card_gap = 10
    local total_width = #Deck.hand * card_width + (#Deck.hand - 1) * card_gap
    local start_x = (1280 - total_width) / 2
    local y = 450

    for i, card in ipairs(Deck.hand) do
        local x = start_x + (i - 1) * (card_width + card_gap)

        -- 判断是否可以打出
        local playable = card.cost <= current_energy

        -- 卡牌背景
        if card.type == "attack" then
            if playable then
                love.graphics.setColor(0.7, 0.25, 0.2)
            else
                love.graphics.setColor(0.4, 0.2, 0.18)
            end
        elseif card.type == "skill" then
            if playable then
                love.graphics.setColor(0.25, 0.4, 0.65)
            else
                love.graphics.setColor(0.18, 0.25, 0.35)
            end
        else
            if playable then
                love.graphics.setColor(0.3, 0.55, 0.3)
            else
                love.graphics.setColor(0.2, 0.3, 0.2)
            end
        end

        love.graphics.rectangle("fill", x, y, card_width, 120, 6, 6)

        -- 卡牌边框（可打出时高亮）
        if playable then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.rectangle("line", x, y, card_width, 120, 6, 6)

        -- 能量消耗（左上角圆圈）
        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.circle("fill", x + 15, y + 15, 12)
        love.graphics.setColor(1, 0.85, 0.2)
        love.graphics.print(tostring(card.cost), x + 10, y + 8)

        -- 卡牌名称
        love.graphics.setColor(1, 1, 1)
        local name = card_names[card.id] or card.id
        love.graphics.print(name, x + 8, y + 35)

        -- 效果描述
        love.graphics.setColor(0.8, 0.8, 0.8)
        if card.damage then
            love.graphics.print("Deal " .. card.damage .. " damage", x + 8, y + 55)
        elseif card.block then
            love.graphics.print("Gain " .. card.block .. " block", x + 8, y + 55)
        end

        -- 快捷键提示
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("[" .. i .. "]", x + card_width - 25, y + 95)
    end

    -- 显示抽牌堆和弃牌堆数量
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("Draw: " .. #Deck.draw_pile, 1100, 550)
    love.graphics.print("Discard: " .. #Deck.discard_pile, 1100, 570)
end

return Deck