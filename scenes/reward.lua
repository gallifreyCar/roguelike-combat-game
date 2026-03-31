-- scenes/reward.lua - 奖励选择场景
-- 战斗胜利后显示可选卡牌奖励
-- 响应式布局，适配不同窗口尺寸

local Reward = {}
local CardData = require("data.cards")
local Deck = require("systems.deck")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Components = require("ui.components")
local Sound = require("systems.sound")
local Assets = require("core.assets")
local CardUI = require("ui.card")

-- 模块私有状态
local choices = {}
local selected = 0

-- 奖励配置
local REWARD_CONFIG = {
    card_count = 3,
    card_width = 180,
    card_height = 240,
    rarity_weights = {
        common = 0.50,
        uncommon = 0.35,
        rare = 0.12,
        legendary = 0.03,
    },
}

function Reward.enter()
    choices = {}
    selected = 0

    for i = 1, REWARD_CONFIG.card_count do
        local card_id = Reward.generate_card_reward()
        local template = CardData.cards[card_id]
        if template then
            choices[i] = {
                type = "card",
                card_id = card_id,
                name = template.name,
                cost = template.cost,
                attack = template.attack,
                hp = template.hp,
                sigils = template.sigils or {},
                rarity = template.rarity or "common",
            }
        end
    end
end

function Reward.exit()
    choices = {}
end

function Reward.generate_card_reward()
    local roll = love.math.random()
    local rarity

    if roll < REWARD_CONFIG.rarity_weights.legendary then
        rarity = "legendary"
    elseif roll < REWARD_CONFIG.rarity_weights.legendary + REWARD_CONFIG.rarity_weights.rare then
        rarity = "rare"
    elseif roll < REWARD_CONFIG.rarity_weights.legendary + REWARD_CONFIG.rarity_weights.rare + REWARD_CONFIG.rarity_weights.uncommon then
        rarity = "uncommon"
    else
        rarity = "common"
    end

    local card_pool = CardData.rarities[rarity] or CardData.rarities.common
    if #card_pool > 0 then
        return card_pool[love.math.random(#card_pool)]
    end
    return "stoat"
end

function Reward.update(dt)
end

function Reward.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
    local card_w = REWARD_CONFIG.card_width
    local card_h = REWARD_CONFIG.card_height
    local card_gap = 30

    -- 计算卡牌居中位置
    local total_width = REWARD_CONFIG.card_count * card_w + (REWARD_CONFIG.card_count - 1) * card_gap
    local start_x = (win_w - total_width) / 2
    local card_y = win_h * 0.25

    -- 标题（居中）
    local title_w = 280
    local title_h = 50
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", (win_w - title_w) / 2, 30, title_w, title_h, 8, 8)
    Components.text(">> VICTORY REWARD <<", win_w / 2, 45, {
        color = "accent_gold",
        size = 20,
        align = "center",
    })

    -- 提示文字
    Components.text(I18n.t("reward_choose"), win_w / 2, 100, {
        color = "text_secondary",
        align = "center",
    })

    -- 绘制卡牌选项
    for i, choice in ipairs(choices) do
        local x = start_x + (i - 1) * (card_w + card_gap)
        local is_selected = (i == selected)

        -- 选中高亮
        if is_selected then
            Theme.setColor("accent_green", 0.3)
            love.graphics.rectangle("fill", x - 8, card_y - 8, card_w + 16, card_h + 16, 10, 10)
        end

        -- 渲染卡牌
        Reward.draw_card(choice, x, card_y, card_w, card_h)

        -- 快捷键提示
        Theme.setColor("bg_panel", 0.9)
        love.graphics.circle("fill", x + 25, card_y + 25, 18)
        Components.text(tostring(i), x + 20, card_y + 18, {
            color = "text_primary",
            size = 16,
        })
    end

    -- 底部区域
    local bottom_y = win_h - 80

    -- 已选择提示和确认按钮
    if selected > 0 and choices[selected] then
        Components.text("Selected: " .. I18n.card_name(choices[selected].card_id), win_w / 2, bottom_y, {
            color = "text_primary",
            align = "center",
        })

        -- 确认按钮
        local btn_w, btn_h = 140, 40
        local btn_x = (win_w - btn_w) / 2
        local btn_y = bottom_y + 25
        Theme.setColor("accent_green", 0.6)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 6, 6)
        Components.text(">> CONFIRM <<", btn_x + btn_w / 2, btn_y + 10, {
            color = "text_value",
            align = "center",
        })
    end

    -- 跳过按钮（左下角）
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", 20, win_h - 50, 100, 35, 5, 5)
    Components.text("[SKIP]", 70, win_h - 42, {
        color = "text_hint",
        align = "center",
    })

    -- 操作提示
    Components.text("Click card to select, click again or button to confirm", win_w / 2, win_h - 20, {
        color = "text_hint",
        align = "center",
        size = 11,
    })
end

function Reward.draw_card(choice, x, y, w, h)
    local cardImage = Assets.getCard(choice.card_id)
    local frameImage = Assets.getFrame(choice.rarity)

    if CardUI.USE_IMAGES and cardImage then
        -- 图片渲染
        love.graphics.setColor(1, 1, 1, 1)
        local scaleX = w / cardImage:getWidth()
        local scaleY = h / cardImage:getHeight()
        love.graphics.draw(cardImage, x, y, 0, scaleX, scaleY)

        if frameImage then
            local fsx = w / frameImage:getWidth()
            local fsy = h / frameImage:getHeight()
            love.graphics.draw(frameImage, x, y, 0, fsx, fsy)
        end

        -- 费用
        love.graphics.setColor(0.7, 0.15, 0.15)
        love.graphics.circle("fill", x + 25, y + 35, 18)
        love.graphics.setColor(1, 1, 1)
        Fonts.print(tostring(choice.cost), x + 18, y + 26, 18)

        -- 攻击力
        Theme.setColor("bg_slot", 0.9)
        love.graphics.rectangle("fill", x + 8, y + h - 45, 60, 30, 5, 5)
        love.graphics.setColor(1, 0.75, 0.3)
        Fonts.print("ATK:" .. choice.attack, x + 12, y + h - 38, 14)

        -- 生命值
        Theme.setColor("bg_slot", 0.9)
        love.graphics.rectangle("fill", x + w - 68, y + h - 45, 60, 30, 5, 5)
        love.graphics.setColor(0.4, 0.9, 0.4)
        Fonts.print("HP:" .. choice.hp, x + w - 62, y + h - 38, 14)

        -- 印记
        if choice.sigils and #choice.sigils > 0 then
            love.graphics.setColor(0.9, 0.7, 0.5)
            Fonts.print("*" .. #choice.sigils, x + w - 30, y + 8, 12)
        end
    else
        -- 纯文字渲染
        local rarity_color = {
            common = {0.4, 0.4, 0.4},
            uncommon = {0.3, 0.5, 0.3},
            rare = {0.4, 0.3, 0.5},
            legendary = {0.6, 0.4, 0.2},
        }
        local rc = rarity_color[choice.rarity] or rarity_color.common

        love.graphics.setColor(rc[1], rc[2], rc[3])
        love.graphics.rectangle("fill", x, y, w, h, 8, 8)
        love.graphics.setColor(0.6, 0.5, 0.4)
        love.graphics.rectangle("line", x, y, w, h, 8, 8)

        Components.text(I18n.card_name(choice.card_id), x + 15, y + 50, {
            color = "text_primary",
            size = 18,
        })

        love.graphics.setColor(1, 0.7, 0.3)
        Fonts.print("$" .. choice.cost, x + 15, y + 90, 14)
        love.graphics.setColor(0.9, 0.5, 0.3)
        Fonts.print("ATK:" .. choice.attack, x + 15, y + 120, 14)
        love.graphics.setColor(0.4, 0.8, 0.4)
        Fonts.print("HP:" .. choice.hp, x + 15, y + 150, 14)

        if choice.sigils and #choice.sigils > 0 then
            love.graphics.setColor(0.9, 0.7, 0.5)
            Fonts.print("*" .. #choice.sigils .. " sigils", x + 15, y + 180, 12)
        end
    end
end

function Reward.keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        local index = tonumber(key)
        if index and choices[index] then
            selected = index
            Sound.play("click")
        end
    elseif key == "return" or key == "space" then
        if selected > 0 and choices[selected] then
            Deck.add_to_deck(choices[selected].card_id)
            Sound.play("reward")
        end
        State.switch("map")
    elseif key == "escape" then
        Sound.play("click")
        State.switch("map")
    end
end

function Reward.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
    local card_w = REWARD_CONFIG.card_width
    local card_h = REWARD_CONFIG.card_height
    local card_gap = 30
    local total_width = REWARD_CONFIG.card_count * card_w + (REWARD_CONFIG.card_count - 1) * card_gap
    local start_x = (win_w - total_width) / 2
    local card_y = win_h * 0.25

    -- 跳过按钮
    if x >= 20 and x <= 120 and y >= win_h - 50 and y <= win_h - 15 then
        Sound.play("click")
        State.switch("map")
        return
    end

    -- 确认按钮
    if selected > 0 then
        local btn_w, btn_h = 140, 40
        local btn_x = (win_w - btn_w) / 2
        local btn_y = win_h - 80 + 25
        if x >= btn_x and x <= btn_x + btn_w and y >= btn_y and y <= btn_y + btn_h then
            if choices[selected] then
                Deck.add_to_deck(choices[selected].card_id)
                Sound.play("reward")
            end
            State.switch("map")
            return
        end
    end

    -- 检测点击卡牌
    for i, choice in ipairs(choices) do
        local cx = start_x + (i - 1) * (card_w + card_gap)
        if x >= cx and x <= cx + card_w and y >= card_y and y <= card_y + card_h then
            if selected == i then
                if choices[i] then
                    Deck.add_to_deck(choices[i].card_id)
                    Sound.play("reward")
                end
                State.switch("map")
            else
                selected = i
                Sound.play("click")
            end
            return
        end
    end
end

return Reward