-- scenes/shop.lua - 商店/牌库查看场景
-- 统一使用 CardUI 组件渲染卡牌

local Shop = {}
local Deck = require("systems.deck")
local CardData = require("data.cards")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Save = require("systems.save")
local Sound = require("systems.sound")
local CardUI = require("ui.card")
local Settings = require("config.settings")

-- 卡牌尺寸
local CARD_WIDTH = Settings.card_width
local CARD_HEIGHT = Settings.card_height

-- 模块私有状态
local selected_tab = "deck"
local scroll_offset = 0
local purchase_message = ""
local message_timer = 0
local hover_card = nil

-- 商店卡牌配置
local SHOP_CARDS = {
    {id = "stoat", price = 10},
    {id = "rat", price = 10},
    {id = "wolf", price = 15},
    {id = "adder", price = 15},
    {id = "raven", price = 20},
    {id = "grizzly", price = 25},
    {id = "mantis", price = 25},
    {id = "cat", price = 30},
}

-- 商店卡牌位置（用于点击检测）
local shop_card_positions = {}

function Shop.enter()
    if not Save.exists(1) then
        Save.init_new_slot(1)
    end
    Save.load(1)

    selected_tab = "deck"
    scroll_offset = 0
    purchase_message = ""
    message_timer = 0
    shop_card_positions = {}
    hover_card = nil
end

function Shop.exit()
end

function Shop.update(dt)
    if message_timer > 0 then
        message_timer = message_timer - dt
        if message_timer <= 0 then
            purchase_message = ""
        end
    end
end

function Shop.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("shop_title") or "SHOP", win_w / 2, 20, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 金币显示
    local coins = Save.get_coins()
    Components.text(I18n.t("gold") .. ": " .. coins, win_w - 100, 20, {
        color = "accent_gold",
        size = 18,
    })

    -- 标签切换
    Shop.draw_tabs(win_w)

    if selected_tab == "deck" then
        Shop.draw_deck_view(win_w, win_h)
    else
        Shop.draw_shop_view(win_w, win_h)
    end

    -- 购买消息提示
    if purchase_message ~= "" then
        local alpha = message_timer > 1.5 and 1 or (message_timer / 1.5)
        Theme.setColor("bg_panel", alpha * 0.9)
        love.graphics.rectangle("fill", win_w / 2 - 150, win_h / 2 - 30, 300, 60, 8, 8)
        Theme.setColor("text_primary", alpha)
        Components.text(purchase_message, win_w / 2, win_h / 2 - 10, {
            color = "text_primary",
            align = "center",
            size = 16,
        })
    end

    -- 返回提示
    Components.text(I18n.t("shop_back") or "ESC to return", win_w / 2, win_h - 40, {
        color = "text_hint",
        align = "center",
    })
end

function Shop.draw_tabs(win_w)
    local tab_width = 120
    local tab_gap = 20
    local start_x = win_w / 2 - tab_width - tab_gap / 2

    local deck_active = selected_tab == "deck"
    Theme.setColor(deck_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x, 60, tab_width, 35, 6, 6)
    Components.text(I18n.t("shop_my_deck") or "My Deck", start_x + tab_width / 2, 68, {
        color = deck_active and "accent_gold" or "text_secondary",
        align = "center",
    })

    local shop_active = selected_tab == "shop"
    Theme.setColor(shop_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x + tab_width + tab_gap, 60, tab_width, 35, 6, 6)
    Components.text(I18n.t("shop_shop") or "Shop", start_x + tab_width + tab_gap + tab_width / 2, 68, {
        color = shop_active and "accent_gold" or "text_secondary",
        align = "center",
    })
end

function Shop.draw_deck_view(win_w, win_h)
    local deck = Deck.get_deck() or {}
    local info = Deck.get_info() or {deck_size = 0, draw_pile_size = 0, discard_pile_size = 0, hand_size = 0}

    -- 牌库统计
    local stats_w = win_w - 100
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", 50, 110, stats_w, 50, 6, 6)

    local stat_width = stats_w / 4
    Components.text("Deck: " .. info.deck_size, 70, 120, {color = "text_primary"})
    Components.text("Draw: " .. info.draw_pile_size, 70 + stat_width, 120, {color = "text_secondary"})
    Components.text("Discard: " .. info.discard_pile_size, 70 + stat_width * 2, 120, {color = "text_secondary"})
    Components.text("Hand: " .. info.hand_size, 70 + stat_width * 3, 120, {color = "text_secondary"})

    if #deck == 0 then
        Components.text("Deck is empty", win_w / 2, win_h / 2, {
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

    -- 显示卡牌网格（使用CardUI）
    local gap = 20
    local cards_per_row = math.max(1, math.floor((win_w - 100 + gap) / (CARD_WIDTH + gap)))
    local total_width = cards_per_row * CARD_WIDTH + (cards_per_row - 1) * gap
    local start_x = (win_w - total_width) / 2
    local start_y = 180

    local col = 0
    local row_idx = 0
    local mx, my = love.mouse.getPosition()
    hover_card = nil

    for card_id, data in pairs(card_counts) do
        local x = start_x + col * (CARD_WIDTH + gap)
        local y = start_y + row_idx * (CARD_HEIGHT + 40)

        -- 复制模板数据供CardUI使用
        local display_card = {
            id = card_id,
            name = I18n.card_name(card_id),
            cost = data.template.cost,
            attack = data.template.attack,
            hp = data.template.hp,
            max_hp = data.template.max_hp or data.template.hp,
            sigils = data.template.sigils or {},
        }

        local is_hover = mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + CARD_HEIGHT
        if is_hover then
            hover_card = {card = display_card, x = x, y = y}
        end

        -- 使用CardUI渲染卡牌
        CardUI.draw_full(display_card, x, y, true, {
            hover = is_hover,
        })

        -- 数量标记
        Components.text("x" .. data.count, x + CARD_WIDTH - 30, y + CARD_HEIGHT + 5, {
            color = "accent_gold",
            size = 14,
        })

        col = col + 1
        if col >= cards_per_row then
            col = 0
            row_idx = row_idx + 1
        end
    end

    -- 显示悬停详情
    if hover_card then
        CardUI.draw_tooltip(hover_card.card, mx, my)
    end
end

function Shop.draw_shop_view(win_w, win_h)
    shop_card_positions = {}

    local gap = 20
    local cards_per_row = math.max(1, math.floor((win_w - 100 + gap) / (CARD_WIDTH + gap)))
    local total_width = cards_per_row * CARD_WIDTH + (cards_per_row - 1) * gap
    local start_x = (win_w - total_width) / 2
    local start_y = 120

    local col = 0
    local row_idx = 0
    local mx, my = love.mouse.getPosition()
    hover_card = nil

    for i, item in ipairs(SHOP_CARDS) do
        local template = CardData.cards[item.id]
        if template then
            local x = start_x + col * (CARD_WIDTH + gap)
            local y = start_y + row_idx * (CARD_HEIGHT + 50)

            -- 复制模板数据供CardUI使用
            local display_card = {
                id = item.id,
                name = I18n.card_name(item.id),
                cost = template.cost,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.max_hp or template.hp,
                sigils = template.sigils or {},
            }

            local is_hover = mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + CARD_HEIGHT

            -- 记录位置用于购买按钮
            shop_card_positions[#shop_card_positions + 1] = {
                index = i,
                item = item,
                template = template,
                x = x,
                y = y,
                width = CARD_WIDTH,
                height = CARD_HEIGHT,
            }

            -- 使用CardUI渲染卡牌
            CardUI.draw_full(display_card, x, y, true, {
                hover = is_hover,
            })

            -- 价格标签
            Theme.setColor("accent_gold", 0.8)
            love.graphics.rectangle("fill", x + CARD_WIDTH - 50, y - 15, 45, 20, 4, 4)
            Theme.setColor("text_value")
            Fonts.print("$" .. item.price, x + CARD_WIDTH - 42, y - 12, 12)

            -- 购买按钮
            local btn_y = y + CARD_HEIGHT + 5
            local coins = Save.get_coins()
            local can_afford = coins >= item.price
            local btn_hover = mx >= x and mx <= x + CARD_WIDTH and my >= btn_y and my <= btn_y + 25

            Theme.setColor(can_afford and (btn_hover and "accent_green" or "accent_green") or "bg_slot",
                           can_afford and (btn_hover and 0.5 or 0.3) or 0.5)
            love.graphics.rectangle("fill", x, btn_y, CARD_WIDTH, 25, 4, 4)
            Components.text(can_afford and "BUY" or "Need $" .. item.price, x + CARD_WIDTH / 2, btn_y + 5, {
                color = can_afford and "text_value" or "text_hint",
                align = "center",
                size = 12,
            })

            if is_hover then
                hover_card = {card = display_card, x = x, y = y}
            end

            col = col + 1
            if col >= cards_per_row then
                col = 0
                row_idx = row_idx + 1
            end
        end
    end

    -- 显示悬停详情
    if hover_card then
        CardUI.draw_tooltip(hover_card.card, mx, my)
    end
end

function Shop.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        State.pop()
    elseif key == "tab" or key == "left" or key == "right" then
        Sound.play("click")
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
            Sound.play("click")
            return
        elseif x >= start_x + tab_width + tab_gap and x <= start_x + 2 * tab_width + tab_gap then
            selected_tab = "shop"
            Sound.play("click")
            return
        end
    end

    -- 商店购买功能
    if selected_tab == "shop" then
        for _, pos in ipairs(shop_card_positions) do
            local btn_y = pos.y + CARD_HEIGHT + 5
            if x >= pos.x and x <= pos.x + CARD_WIDTH and y >= btn_y and y <= btn_y + 25 then
                local item = pos.item
                local coins = Save.get_coins()

                if coins >= item.price then
                    local success, err = pcall(function()
                        Save.spend_coins(item.price)
                        Deck.add_to_deck(item.id)
                    end)
                    if success then
                        Sound.play("reward")
                        purchase_message = "Purchased: " .. I18n.card_name(item.id) .. " (-$" .. item.price .. ")"
                        message_timer = 2.0
                    else
                        Sound.play("click")
                        purchase_message = "Purchase failed"
                        message_timer = 2.0
                    end
                else
                    Sound.play("click")
                    purchase_message = "Not enough gold (need $" .. item.price .. ", have $" .. coins .. ")"
                    message_timer = 2.0
                end
                return
            end
        end
    end
end

return Shop