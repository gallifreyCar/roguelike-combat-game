-- scenes/reward.lua - 奖励选择场景
-- 统一使用 CardUI 组件渲染卡牌

local Reward = {}
local State = require("core.state")
local Deck = require("systems.deck")
local Save = require("systems.save")
local CardData = require("data.cards")
local Map = require("systems.map")
local Fonts = require("core.fonts")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local I18n = require("core.i18n")
local Sound = require("systems.sound")
local CardUI = require("ui.card")
local Settings = require("config.settings")

-- 卡牌尺寸
local CARD_WIDTH = Settings.card_width
local CARD_HEIGHT = Settings.card_height

-- 奖励选项
local choices = {}
local selected_index = 1
local hover_index = nil
local reward_type = "card"
local return_scene = nil

-- 生成卡牌奖励
local function generate_card_rewards()
    local available_cards = {}
    local current_row = Map.get_current_row()
    local enemies, elite_enemies, boss = Map.get_chapter_enemies(current_row)

    for _, enemy_id in ipairs(enemies or {}) do
        if CardData.cards[enemy_id] then
            table.insert(available_cards, enemy_id)
        end
    end
    for _, enemy_id in ipairs(elite_enemies or {}) do
        if CardData.cards[enemy_id] then
            table.insert(available_cards, enemy_id)
        end
    end

    local basic_cards = {"stoat", "rat", "wolf", "raven", "bullfrog", "turtle", "adder", "cat", "skunk", "wolf"}
    for _, card_id in ipairs(basic_cards) do
        table.insert(available_cards, card_id)
    end

    local rewards = {}
    local used = {}

    for i = 1, 3 do
        local attempts = 0
        while attempts < 50 do
            local idx = love.math.random(1, #available_cards)
            local card_id = available_cards[idx]
            if not used[card_id] then
                used[card_id] = true
                local template = CardData.cards[card_id]
                if template then
                    table.insert(rewards, {
                        type = "card",
                        id = card_id,
                        name = I18n.card_name(card_id),
                        template = template,
                        -- 复制模板数据供CardUI使用
                        cost = template.cost,
                        attack = template.attack,
                        hp = template.hp,
                        max_hp = template.max_hp or template.hp,
                        sigils = template.sigils or {},
                    })
                end
                break
            end
            attempts = attempts + 1
        end
    end

    return rewards
end

-- 生成属性奖励
local function generate_stat_rewards()
    local current_row = Map.get_current_row() or 1
    local gold_amount = 20 + current_row * 5

    return {
        {
            type = "gold",
            name = I18n.t("gold") or "Gold",
            amount = gold_amount,
        },
        {
            type = "hp",
            name = "Max HP",
            hp_bonus = 5,
        },
    }
end

-- 生成奖励
local function generate_rewards()
    if love.math.random() < 0.7 then
        choices = generate_card_rewards()
        reward_type = "card"
    else
        choices = generate_stat_rewards()
        reward_type = "stat"
    end
    selected_index = 1
end

-- 应用奖励
local function apply_reward_and_continue(choice)
    if choice.type == "card" then
        Deck.add_to_deck(choice.id)
        Sound.play("reward")
    elseif choice.type == "gold" then
        Save.add_coins(choice.amount or 20)
        Sound.play("reward")
    elseif choice.type == "hp" then
        local player = Save.get_player()
        if player then
            player.max_hp = player.max_hp + (choice.hp_bonus or 5)
            player.hp = math.min(player.hp + (choice.hp_bonus or 5), player.max_hp)
        end
        Sound.play("reward")
    end

    local came_from_combat = return_scene == "combat"
    if came_from_combat then
        State.switch("map")
    else
        State.pop()
    end

    if not came_from_combat and State.name() ~= "map" then
        State.switch("map")
    end
end

function Reward.enter()
    return_scene = State.previous_name()
    generate_rewards()
    hover_index = nil
end

function Reward.exit()
    choices = {}
    return_scene = nil
end

function Reward.update(dt)
end

function Reward.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("choose_reward"), win_w / 2, 30, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 副标题
    local hint = reward_type == "card" and "Select a card to add to your deck" or "Select a bonus"
    Components.text(hint, win_w / 2, 60, {
        color = "text_secondary",
        align = "center",
    })

    -- 卡牌布局
    local gap = 30
    local total_width = #choices * CARD_WIDTH + (#choices - 1) * gap
    local start_x = (win_w - total_width) / 2
    local card_y = win_h * 0.28

    hover_index = nil
    local mx, my = love.mouse.getPosition()
    local hover_card_data = nil  -- 收集悬停卡牌数据，最后绘制tooltip

    for i, choice in ipairs(choices) do
        local x = start_x + (i - 1) * (CARD_WIDTH + gap)
        local is_selected = (i == selected_index)
        local is_hover = mx >= x and mx <= x + CARD_WIDTH and my >= card_y and my <= card_y + CARD_HEIGHT

        if is_hover then
            hover_index = i
            if choice.type == "card" then
                hover_card_data = {choice = choice, mx = mx, my = my}
            end
        end

        if choice.type == "card" then
            -- 使用 CardUI 渲染卡牌
            CardUI.draw_full(choice, x, card_y, true, {
                hover = is_hover,
                highlight = is_selected,
            })
        else
            -- 金币/HP奖励 - 简单卡片样式
            Theme.setColor("bg_primary", 0.4)
            love.graphics.rectangle("fill", x + 3, card_y + 3, CARD_WIDTH, CARD_HEIGHT, 5, 5)

            local bg_color = choice.type == "gold" and "accent_gold" or "accent_green"
            Theme.setColor(bg_color, is_selected and 0.4 or (is_hover and 0.3 or 0.2))
            love.graphics.rectangle("fill", x, card_y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

            Theme.setColor(is_selected and "accent_gold" or "border_gold")
            love.graphics.rectangle("line", x, card_y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

            -- 类型标签
            local type_label = choice.type == "gold" and "[GOLD]" or "[HP]"
            Components.text(type_label, x + CARD_WIDTH / 2, card_y + 20, {
                color = "text_secondary",
                size = 12,
                align = "center",
            })

            -- 数值
            local value = choice.type == "gold" and ("+" .. choice.amount) or ("+" .. choice.hp_bonus)
            Components.text(value, x + CARD_WIDTH / 2, card_y + 60, {
                color = bg_color,
                size = 32,
                align = "center",
            })

            Components.text(choice.type == "gold" and "Coins" or "Max HP", x + CARD_WIDTH / 2, card_y + 100, {
                color = "text_secondary",
                align = "center",
            })
        end

        -- 快捷键提示
        Theme.setColor("text_hint")
        Fonts.print("[" .. i .. "]", x + CARD_WIDTH / 2 - 8, card_y + CARD_HEIGHT + 10, 12)
    end

    -- 所有卡牌绘制完成后，最后绘制tooltip（确保在最上层）
    if hover_card_data then
        CardUI.draw_tooltip(hover_card_data.choice, hover_card_data.mx, hover_card_data.my)
    end

    -- 底部提示
    Components.text("Click or press 1-" .. #choices .. " to select, ESC to skip", win_w / 2, win_h - 40, {
        color = "text_hint",
        align = "center",
    })
end

function Reward.keypressed(key)
    local num = tonumber(key)
    if num and num >= 1 and num <= #choices then
        selected_index = num
        apply_reward_and_continue(choices[num])
    elseif key == "escape" then
        Sound.play("click")
        local came_from_combat = return_scene == "combat"
        if came_from_combat then
            State.switch("map")
        else
            State.pop()
        end
        if not came_from_combat and State.name() ~= "map" then
            State.switch("map")
        end
    elseif key == "return" or key == "space" then
        if choices[selected_index] then
            apply_reward_and_continue(choices[selected_index])
        end
    end
end

function Reward.mousepressed(x, y, button)
    if button ~= 1 then return end

    if hover_index and hover_index >= 1 and hover_index <= #choices then
        selected_index = hover_index
        apply_reward_and_continue(choices[hover_index])
    end
end

return Reward
