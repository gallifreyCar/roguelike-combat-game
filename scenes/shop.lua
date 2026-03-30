-- scenes/shop.lua - 商店/牌库查看场景
-- 可以查看牌库、购买卡牌

local Shop = {}
local Deck = require("systems.deck")
local CardData = require("data.cards")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")

local selected_tab = "deck"  -- "deck" 或 "shop"
local scroll_offset = 0

-- 商店卡牌
local SHOP_CARDS = {
    {id = "stoat", price = 1},
    {id = "rat", price = 1},
    {id = "wolf", price = 2},
    {id = "adder", price = 2},
    {id = "raven", price = 2},
    {id = "grizzly", price = 3},
    {id = "mantis", price = 3},
    {id = "cat", price = 4},
}

function Shop.enter()
    selected_tab = "deck"
    scroll_offset = 0
end

function Shop.exit()
end

function Shop.update(dt)
end

function Shop.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text("SHOP & DECK", win_w / 2, 20, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 标签切换
    Shop.draw_tabs(win_w)

    if selected_tab == "deck" then
        Shop.draw_deck_view(win_w, win_h)
    else
        Shop.draw_shop_view(win_w, win_h)
    end

    -- 返回提示
    Components.text("[ESC] Back to Map", win_w / 2, win_h - 40, {
        color = "text_hint",
        align = "center",
    })
end

function Shop.draw_tabs(win_w)
    local tab_width = 120
    local tab_gap = 20
    local start_x = win_w / 2 - tab_width - tab_gap / 2

    -- Deck标签
    local deck_active = selected_tab == "deck"
    Theme.setColor(deck_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x, 60, tab_width, 35, 6, 6)
    Components.text("MY DECK", start_x + tab_width / 2, 68, {
        color = deck_active and "accent_gold" or "text_secondary",
        align = "center",
    })

    -- Shop标签
    local shop_active = selected_tab == "shop"
    Theme.setColor(shop_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x + tab_width + tab_gap, 60, tab_width, 35, 6, 6)
    Components.text("SHOP", start_x + tab_width + tab_gap + tab_width / 2, 68, {
        color = shop_active and "accent_gold" or "text_secondary",
        align = "center",
    })
end

function Shop.draw_deck_view(win_w, win_h)
    local deck = Deck.get_deck()
    local info = Deck.get_info()

    -- 牌库统计
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", 50, 110, win_w - 100, 50, 6, 6)
    Components.text("Deck: " .. info.deck_size .. " cards", 70, 120, {color = "text_primary"})
    Components.text("Draw Pile: " .. info.draw_pile_size, 250, 120, {color = "text_secondary"})
    Components.text("Discard: " .. info.discard_pile_size, 400, 120, {color = "text_secondary"})
    Components.text("Hand: " .. info.hand_size, 550, 120, {color = "text_secondary"})

    -- 显示牌库中的卡牌
    if #deck == 0 then
        Components.text("Your deck is empty. Win battles to add cards!", win_w / 2, 300, {
            color = "text_hint",
            align = "center",
        })
        return
    end

    -- 按卡牌ID统计
    local card_counts = {}
    for _, card in ipairs(deck) do
        if not card_counts[card.id] then
            card_counts[card.id] = {count = 0, template = card}
        end
        card_counts[card.id].count = card_counts[card.id].count + 1
    end

    -- 显示卡牌列表
    local y = 180
    local card_width = 180
    local cards_per_row = math.floor((win_w - 100) / (card_width + 15))
    local col = 0

    for card_id, data in pairs(card_counts) do
        local x = 50 + col * (card_width + 15)

        -- 卡牌背景
        Theme.setColor("bg_slot")
        love.graphics.rectangle("fill", x, y, card_width, 80, 6, 6)
        Theme.setColor("border_gold", 0.3)
        love.graphics.rectangle("line", x, y, card_width, 80, 6, 6)

        -- 卡牌信息
        Components.text(data.template.name, x + 10, y + 8, {color = "text_primary"})
        Components.text("x" .. data.count, x + card_width - 30, y + 8, {
            color = "accent_gold",
        })
        Components.text("Cost: " .. (data.template.cost or 0), x + 10, y + 30, {
            color = "accent_red",
            size = 12,
        })
        Components.text("ATK: " .. (data.template.attack or 0), x + 10, y + 50, {
            color = "accent_gold",
            size = 12,
        })
        Components.text("HP: " .. (data.template.hp or 0), x + 80, y + 50, {
            color = "accent_green",
            size = 12,
        })

        col = col + 1
        if col >= cards_per_row then
            col = 0
            y = y + 95
        end
    end
end

function Shop.draw_shop_view(win_w, win_h)
    Components.text("Click to buy cards (not implemented yet)", win_w / 2, 130, {
        color = "text_hint",
        align = "center",
    })

    local y = 180
    local card_width = 200
    local cards_per_row = math.floor((win_w - 100) / (card_width + 15))
    local col = 0

    for _, item in ipairs(SHOP_CARDS) do
        local template = CardData.cards[item.id]
        if template then
            local x = 50 + col * (card_width + 15)

            -- 卡牌背景
            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", x, y, card_width, 90, 6, 6)
            Theme.setColor("accent_blue", 0.3)
            love.graphics.rectangle("line", x, y, card_width, 90, 6, 6)

            -- 卡牌信息
            Components.text(template.name, x + 10, y + 8, {color = "text_primary"})
            Components.text("Price: " .. item.price, x + card_width - 60, y + 8, {
                color = "accent_gold",
                size = 12,
            })
            Components.text("Cost: " .. (template.cost or 0), x + 10, y + 35, {
                color = "accent_red",
                size = 12,
            })
            Components.text("ATK: " .. (template.attack or 0), x + 10, y + 55, {
                color = "accent_gold",
                size = 12,
            })
            Components.text("HP: " .. (template.hp or 0), x + 80, y + 55, {
                color = "accent_green",
                size = 12,
            })

            -- 购买按钮
            Theme.setColor("accent_green", 0.3)
            love.graphics.rectangle("fill", x + card_width - 60, y + 55, 50, 25, 4, 4)
            Components.text("BUY", x + card_width - 45, y + 60, {
                color = "text_value",
                size = 12,
            })

            col = col + 1
            if col >= cards_per_row then
                col = 0
                y = y + 105
            end
        end
    end
end

function Shop.keypressed(key)
    if key == "escape" then
        State.pop()
    elseif key == "tab" or key == "left" or key == "right" then
        selected_tab = selected_tab == "deck" and "shop" or "deck"
    end
end

function Shop.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()

    -- 标签切换
    local tab_width = 120
    local tab_gap = 20
    local start_x = win_w / 2 - tab_width - tab_gap / 2

    if y >= 60 and y <= 95 then
        if x >= start_x and x <= start_x + tab_width then
            selected_tab = "deck"
            return
        elseif x >= start_x + tab_width + tab_gap and x <= start_x + 2 * tab_width + tab_gap then
            selected_tab = "shop"
            return
        end
    end

    -- TODO: 商店购买功能
end

return Shop