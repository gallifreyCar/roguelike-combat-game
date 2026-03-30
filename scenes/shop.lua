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
local Save = require("systems.save")
local Sound = require("systems.sound")

local selected_tab = "deck"  -- "deck" 或 "shop"
local scroll_offset = 0
local purchase_message = ""
local message_timer = 0

-- 商店卡牌
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

-- 记录商店卡牌位置（用于点击检测）
local shop_card_positions = {}

function Shop.enter()
    selected_tab = "deck"
    scroll_offset = 0
    purchase_message = ""
    message_timer = 0
    shop_card_positions = {}
end

function Shop.exit()
end

function Shop.update(dt)
    -- 消息计时器
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
    Components.text(I18n.t("shop_title"), win_w / 2, 20, {
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
    Components.text(I18n.t("shop_back"), win_w / 2, win_h - 40, {
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
    Components.text(I18n.t("shop_my_deck"), start_x + tab_width / 2, 68, {
        color = deck_active and "accent_gold" or "text_secondary",
        align = "center",
    })

    -- Shop标签
    local shop_active = selected_tab == "shop"
    Theme.setColor(shop_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x + tab_width + tab_gap, 60, tab_width, 35, 6, 6)
    Components.text(I18n.t("shop_shop"), start_x + tab_width + tab_gap + tab_width / 2, 68, {
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
    Components.text(I18n.tf("shop_deck_info", info.deck_size), 70, 120, {color = "text_primary"})
    Components.text(I18n.tf("shop_draw_pile", info.draw_pile_size), 250, 120, {color = "text_secondary"})
    Components.text(I18n.tf("shop_discard", info.discard_pile_size), 400, 120, {color = "text_secondary"})
    Components.text(I18n.tf("shop_hand", info.hand_size), 550, 120, {color = "text_secondary"})

    -- 显示牌库中的卡牌
    if #deck == 0 then
        Components.text(I18n.t("shop_empty"), win_w / 2, 300, {
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

        -- 卡牌信息（使用翻译）
        Components.text(I18n.card_name(data.template.id), x + 10, y + 8, {color = "text_primary"})
        Components.text("x" .. data.count, x + card_width - 30, y + 8, {
            color = "accent_gold",
        })
        Components.text(I18n.t("shop_cost") .. ": " .. (data.template.cost or 0), x + 10, y + 30, {
            color = "accent_red",
            size = 12,
        })
        Components.text(I18n.t("shop_atk") .. ": " .. (data.template.attack or 0), x + 10, y + 50, {
            color = "accent_gold",
            size = 12,
        })
        Components.text(I18n.t("shop_hp") .. ": " .. (data.template.hp or 0), x + 80, y + 50, {
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
    -- 清空并重新记录卡牌位置
    shop_card_positions = {}

    local y = 180
    local card_width = 200
    local cards_per_row = math.floor((win_w - 100) / (card_width + 15))
    local col = 0

    for i, item in ipairs(SHOP_CARDS) do
        local template = CardData.cards[item.id]
        if template then
            local x = 50 + col * (card_width + 15)

            -- 记录卡牌位置和购买信息（用于点击检测）
            shop_card_positions[#shop_card_positions + 1] = {
                index = i,
                item = item,
                template = template,
                x = x,
                y = y,
                width = card_width,
                height = 90,
                buy_btn = {
                    x = x + card_width - 60,
                    y = y + 55,
                    width = 50,
                    height = 25,
                },
            }

            -- 卡牌背景
            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", x, y, card_width, 90, 6, 6)
            Theme.setColor("accent_blue", 0.3)
            love.graphics.rectangle("line", x, y, card_width, 90, 6, 6)

            -- 卡牌信息（使用翻译）
            Components.text(I18n.card_name(template.id), x + 10, y + 8, {color = "text_primary"})
            Components.text(I18n.t("shop_price") .. ": " .. item.price, x + card_width - 60, y + 8, {
                color = "accent_gold",
                size = 12,
            })
            Components.text(I18n.t("shop_cost") .. ": " .. (template.cost or 0), x + 10, y + 35, {
                color = "accent_red",
                size = 12,
            })
            Components.text(I18n.t("shop_atk") .. ": " .. (template.attack or 0), x + 10, y + 55, {
                color = "accent_gold",
                size = 12,
            })
            Components.text(I18n.t("shop_hp") .. ": " .. (template.hp or 0), x + 80, y + 55, {
                color = "accent_green",
                size = 12,
            })

            -- 购买按钮（根据金币状态变色）
            local coins = Save.get_coins()
            local can_afford = coins >= item.price
            Theme.setColor(can_afford and "accent_green" or "bg_slot", can_afford and 0.4 or 0.5)
            love.graphics.rectangle("fill", x + card_width - 60, y + 55, 50, 25, 4, 4)
            Components.text(I18n.t("shop_buy"), x + card_width - 45, y + 60, {
                color = can_afford and "text_value" or "text_hint",
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
            -- 检测点击 BUY 按钮
            if x >= pos.buy_btn.x and x <= pos.buy_btn.x + pos.buy_btn.width and
               y >= pos.buy_btn.y and y <= pos.buy_btn.y + pos.buy_btn.height then

                local item = pos.item
                local coins = Save.get_coins()

                if coins >= item.price then
                    -- 金币足够，执行购买
                    local success = Save.spend_coins(item.price)
                    if success then
                        -- 添加卡牌到牌组
                        Deck.add_to_deck(item.id)
                        -- 播放购买音效
                        Sound.play("reward")
                        -- 显示购买成功消息
                        purchase_message = I18n.t("purchase_success") .. ": " .. pos.template.name .. " (-" .. item.price .. ")"
                        message_timer = 2.0
                    else
                        Sound.play("click")
                        purchase_message = I18n.t("purchase_failed")
                        message_timer = 2.0
                    end
                else
                    -- 金币不足
                    Sound.play("click")
                    purchase_message = I18n.t("not_enough_gold") .. " (need " .. item.price .. ", have " .. coins .. ")"
                    message_timer = 2.0
                end
                return
            end
        end
    end
end

return Shop