-- scenes/deck_builder.lua - 牌组构建场景
-- 选择15张牌组成初始牌组，同ID最多2张

local DeckBuilderScene = {}
local DeckBuilder = require("systems.deck_builder")
local CardData = require("data.cards")
local Family = require("systems.family")
local State = require("core.state")
local Fonts = require("core.fonts")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Sound = require("systems.sound")
local Animation = require("systems.animation")
local Deck = require("systems.deck")
local Map = require("systems.map")
local FusionSystem = require("systems.fusion")
local I18n = require("core.i18n")
local MetaProgression = require("systems.meta_progression")
local Save = require("systems.save")

-- UI状态
local state = {
    available_cards = {},    -- 可选卡牌列表
    filter_rarity = "all",   -- 稀有度筛选
    filter_family = "all",   -- 体系筛选
    scroll_offset = 0,       -- 滚动偏移
    selected_card = nil,     -- 选中的卡牌（查看详情）
    hover_card = nil,        -- 悬停的卡牌
    message = "",            -- 提示消息
    message_timer = 0,
}

function DeckBuilderScene.enter()
    DeckBuilder.init()
    state.available_cards = DeckBuilder.get_available_cards()
    state.filter_rarity = "all"
    state.filter_family = "all"
    state.scroll_offset = 0
    state.selected_card = nil
    state.message = ""
    state.message_timer = 0
end

function DeckBuilderScene.exit()
end

function DeckBuilderScene.update(dt)
    if state.message_timer > 0 then
        state.message_timer = state.message_timer - dt
        if state.message_timer <= 0 then
            state.message = ""
        end
    end
end

function DeckBuilderScene.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("deck_builder"), win_w / 2, 15, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 牌组统计
    local stats = DeckBuilder.get_deck_stats()
    local deck_size = DeckBuilder.get_deck_size()
    local size_color = deck_size == 15 and "accent_green" or "accent_gold"

    Components.text(I18n.t("cards_count") .. ": " .. deck_size .. "/" .. DeckBuilder.DECK_SIZE, win_w / 2, 45, {
        color = size_color,
        size = 16,
        align = "center",
    })

    -- 左侧：当前牌组
    DeckBuilderScene.draw_current_deck(win_w, win_h)

    -- 右侧：可选卡牌
    DeckBuilderScene.draw_available_cards(win_w, win_h)

    -- 底部：筛选和操作
    DeckBuilderScene.draw_bottom_bar(win_w, win_h)

    -- 消息提示
    if state.message ~= "" then
        Components.text(state.message, win_w / 2, win_h - 80, {
            color = "accent_gold",
            align = "center",
        })
    end
end

function DeckBuilderScene.draw_current_deck(win_w, win_h)
    local deck = DeckBuilder.get_current_deck()
    local panel_x = 20
    local panel_y = 70
    local panel_w = win_w * 0.35
    local panel_h = win_h - 170

    -- 面板背景
    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 标题
    Components.text(I18n.t("your_deck"), panel_x + panel_w / 2, panel_y + 10, {
        color = "text_secondary",
        align = "center",
    })

    -- 牌组统计
    local stats = DeckBuilder.get_deck_stats()
    local stats_y = panel_y + 35
    Components.text(I18n.t("avg_cost") .. ": " .. stats.avg_cost .. "  ATK: " .. stats.avg_attack .. "  HP: " .. stats.avg_hp,
        panel_x + 10, stats_y, {color = "text_hint", size = 11})

    -- 显示牌组中的卡牌
    local card_w = panel_w - 20
    local card_h = 45
    local y = panel_y + 55

    if #deck == 0 then
        Components.text("Click cards on the right to add", panel_x + panel_w / 2, panel_y + panel_h / 2, {
            color = "text_hint",
            align = "center",
            size = 12,
        })
    else
        for i, card in ipairs(deck) do
            if y + card_h < panel_y + panel_h - 10 then
                local family_info = card.family and Family.FAMILIES[card.family]

                -- 卡牌背景
                Theme.setColor("bg_slot")
                love.graphics.rectangle("fill", panel_x + 10, y, card_w, card_h, 4, 4)

                -- 体系颜色边框
                if family_info then
                    love.graphics.setColor(family_info.color[1], family_info.color[2], family_info.color[3], 0.8)
                else
                    Theme.setColor("border_gold", 0.5)
                end
                love.graphics.rectangle("line", panel_x + 10, y, card_w, card_h, 4, 4)

                -- 卡牌信息
                Components.text(I18n.card_name(card.id), panel_x + 15, y + 5, {color = "text_primary", size = 12})
                Components.text("$" .. card.cost .. " ATK:" .. card.attack .. " HP:" .. card.hp, panel_x + 15, y + 22,
                    {color = "text_secondary", size = 10})

                -- 体系图标
                if family_info then
                    Components.text(family_info.icon, panel_x + card_w - 20, y + 8, {size = 16})
                end

                -- 删除按钮（点击移除）
                Theme.setColor("accent_red", 0.3)
                love.graphics.rectangle("fill", panel_x + card_w - 40, y + 25, 25, 15, 3, 3)
                Components.text("X", panel_x + card_w - 32, y + 27, {color = "text_value", size = 10})

                y = y + card_h + 5
            end
        end
    end
end

function DeckBuilderScene.draw_available_cards(win_w, win_h)
    local panel_x = win_w * 0.38
    local panel_y = 70
    local panel_w = win_w * 0.60
    local panel_h = win_h - 170

    -- 面板背景
    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 标题和筛选
    Components.text(I18n.t("available_cards") .. " (" .. #state.available_cards .. ")", panel_x + 15, panel_y + 10, {
        color = "text_secondary",
    })

    -- 筛选按钮
    local filter_y = panel_y + 8
    local filter_x = panel_x + panel_w - 300

    -- 稀有度筛选
    local rarities = {"all", "common", "uncommon", "rare", "legendary"}
    for i, r in ipairs(rarities) do
        local is_active = state.filter_rarity == r
        Theme.setColor(is_active and "accent_gold" or "bg_slot", is_active and 0.6 or 1)
        love.graphics.rectangle("fill", filter_x + (i - 1) * 55, filter_y, 50, 20, 3, 3)
        Components.text(r:sub(1, 1):upper() .. r:sub(2), filter_x + (i - 1) * 55 + 5, filter_y + 3, {
            color = is_active and "text_value" or "text_secondary",
            size = 10,
        })
    end

    -- 获取筛选后的卡牌
    local filtered = DeckBuilderScene.get_filtered_cards()

    -- 显示卡牌网格
    local card_w = 100
    local card_h = 80
    local gap = 10
    local cols = math.floor((panel_w - 20) / (card_w + gap))
    local start_x = panel_x + 10
    local start_y = panel_y + 40

    state.hover_card = nil

    for i, card_id in ipairs(filtered) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = start_x + col * (card_w + gap)
        local y = start_y + row * (card_h + gap)

        if y + card_h < panel_y + panel_h - 10 then
            local template = CardData.cards[card_id]
            if template then
                local count = DeckBuilder.get_card_count(card_id)
                local can_add = DeckBuilder.can_add_card(card_id)
                local family_info = template.family and Family.FAMILIES[template.family]

                -- 检查悬停
                local mx, my = love.mouse.getPosition()
                local is_hover = mx >= x and mx <= x + card_w and my >= y and my <= y + card_h
                if is_hover then
                    state.hover_card = card_id
                end

                -- 卡牌背景
                if not can_add then
                    Theme.setColor("bg_slot", 0.4)
                elseif is_hover then
                    Theme.setColor("bg_slot_hover", 0.9)
                else
                    Theme.setColor("bg_slot")
                end
                love.graphics.rectangle("fill", x, y, card_w, card_h, 5, 5)

                -- 体系颜色边框
                if family_info then
                    love.graphics.setColor(family_info.color[1], family_info.color[2], family_info.color[3],
                        can_add and 0.8 or 0.3)
                else
                    Theme.setColor("border_gold", can_add and 0.5 or 0.2)
                end
                love.graphics.rectangle("line", x, y, card_w, card_h, 5, 5)

                -- 卡牌信息
                Components.text(I18n.card_name(card_id), x + 5, y + 5, {
                    color = can_add and "text_primary" or "text_hint",
                    size = 11,
                })

                Components.text("$" .. template.cost .. " A:" .. template.attack .. " H:" .. template.hp, x + 5, y + 22, {
                    color = can_add and "text_secondary" or "text_hint",
                    size = 10,
                })

                -- 已选数量
                if count > 0 then
                    Components.text("x" .. count, x + card_w - 25, y + 5, {
                        color = "accent_gold",
                        size = 12,
                    })
                end

                -- 体系图标
                if family_info then
                    Components.text(family_info.icon, x + card_w - 25, y + card_h - 25, {size = 18})
                end
            end
        end
    end
end

function DeckBuilderScene.draw_bottom_bar(win_w, win_h)
    local bar_y = win_h - 60

    -- 返回按钮
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", 20, bar_y, 80, 35, 5, 5)
    Components.text(I18n.t("back"), 40, bar_y + 8, {color = "text_secondary"})

    -- 清空按钮
    Theme.setColor("accent_red", 0.3)
    love.graphics.rectangle("fill", 110, bar_y, 80, 35, 5, 5)
    Components.text(I18n.t("clear"), 135, bar_y + 8, {color = "text_value"})

    -- 随机填充
    Theme.setColor("accent_blue", 0.3)
    love.graphics.rectangle("fill", 200, bar_y, 100, 35, 5, 5)
    Components.text(I18n.t("random_fill"), 215, bar_y + 8, {color = "text_value", size = 12})

    -- 保存牌组
    Theme.setColor("accent_gold", 0.4)
    love.graphics.rectangle("fill", 310, bar_y, 100, 35, 5, 5)
    Components.text(I18n.t("save_deck"), 325, bar_y + 8, {color = "text_value", size = 12})

    -- 开始游戏按钮
    local can_start = DeckBuilder.is_deck_valid()
    Theme.setColor(can_start and "accent_green" or "bg_slot", can_start and 0.6 or 0.5)
    love.graphics.rectangle("fill", win_w - 150, bar_y, 130, 35, 5, 5)
    Components.text(can_start and (I18n.t("start_run") .. " →") or I18n.t("need_15_cards"), win_w - 140, bar_y + 8, {
        color = can_start and "text_value" or "text_hint",
        size = 14,
    })
end

function DeckBuilderScene.get_filtered_cards()
    local filtered = {}

    for _, card_id in ipairs(state.available_cards) do
        local template = CardData.cards[card_id]
        if template then
            -- 稀有度筛选
            if state.filter_rarity ~= "all" and template.rarity ~= state.filter_rarity then
                goto continue
            end

            -- 体系筛选
            if state.filter_family ~= "all" and template.family ~= state.filter_family then
                goto continue
            end

            table.insert(filtered, card_id)
        end
        ::continue::
    end

    return filtered
end

function DeckBuilderScene.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        State.pop()
    end
end

function DeckBuilderScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()
    local bar_y = win_h - 60

    -- 返回按钮
    if x >= 20 and x <= 100 and y >= bar_y and y <= bar_y + 35 then
        Sound.play("click")
        State.pop()
        return
    end

    -- 清空按钮
    if x >= 110 and x <= 190 and y >= bar_y and y <= bar_y + 35 then
        DeckBuilder.clear_deck()
        Sound.play("click")
        state.message = I18n.t("deck_cleared")
        state.message_timer = 1.5
        return
    end

    -- 随机填充
    if x >= 200 and x <= 300 and y >= bar_y and y <= bar_y + 35 then
        DeckBuilder.random_fill()
        Sound.play("reward")
        state.message = I18n.t("deck_filled")
        state.message_timer = 1.5
        return
    end

    -- 保存牌组
    if x >= 310 and x <= 410 and y >= bar_y and y <= bar_y + 35 then
        DeckBuilder.save_deck()
        Sound.play("reward")
        state.message = I18n.t("deck_saved")
        state.message_timer = 1.5
        return
    end

    -- 开始游戏
    if x >= win_w - 150 and x <= win_w - 20 and y >= bar_y and y <= bar_y + 35 then
        if DeckBuilder.is_deck_valid() then
            Sound.play("reward")

            -- 获取局外成长加成
            local bonuses = MetaProgression.get_starting_bonuses()

            -- 应用金币加成
            local base_gold = 50
            Save.set_coins(base_gold + bonuses.gold_bonus)

            -- 应用牌组加成
            Deck.set_meta_bonuses(bonuses)

            -- 应用自定义牌组到Deck系统
            local custom_deck = DeckBuilder.get_current_deck()
            Deck.set_custom_deck(custom_deck)

            -- 生成地图
            Map.generate()

            -- 重置融合计数
            FusionSystem.reset_fusion_count()

            -- 场景过渡并开始游戏
            Animation.fade_out(0.2, function()
                State.switch("map")
            end)
        else
            Sound.play("click")
            state.message = I18n.t("need_15_cards") or "Need exactly 15 cards!"
            state.message_timer = 1.5
        end
        return
    end

    -- 点击可选卡牌添加
    if state.hover_card then
        local success, reason = DeckBuilder.add_card(state.hover_card)
        if success then
            Sound.play("click")
        else
            Sound.play("click")
            state.message = reason
            state.message_timer = 1.5
        end
        return
    end

    -- 点击牌组中的卡牌移除
    local panel_x = 20
    local panel_y = 70
    local panel_w = win_w * 0.35
    local card_w = panel_w - 20
    local card_h = 45
    local deck = DeckBuilder.get_current_deck()

    for i, card in ipairs(deck) do
        local card_y = panel_y + 55 + (i - 1) * (card_h + 5)
        if card_y + card_h < panel_y + win_h - 170 then
            -- 点击删除按钮
            if x >= panel_x + card_w - 30 and x <= panel_x + card_w - 5 and
               y >= card_y + 25 and y <= card_y + 40 then
                DeckBuilder.remove_card(i)
                Sound.play("click")
                return
            end
        end
    end
end

return DeckBuilderScene