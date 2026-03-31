-- scenes/reward.lua - 奖励选择场景
local Reward = {}
local CardData = require("data.cards")
local Deck = require("systems.deck")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Map = require("systems.map")  -- 添加地图模块
local Components = require("ui.components")  -- [BUG FIX] 添加缺失的 Components 模块导入

local choices = {}
local selected = 0
local reward_type = "card"  -- card / gold / heal

-- 奖励配置
local REWARD_CONFIG = {
    card_count = 3,       -- 可选卡牌数量
    rarity_weights = {
        common = 0.50,
        uncommon = 0.35,
        rare = 0.12,
        legendary = 0.03,
    },
}

function Reward.enter(prev_state)
    -- 根据上一状态生成奖励
    choices = {}
    selected = 0

    -- 生成3张随机卡牌作为奖励
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

-- 生成随机卡牌奖励
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

    -- 从该稀有度的卡牌中随机选择
    local card_pool = CardData.rarities[rarity] or CardData.rarities.common
    if #card_pool > 0 then
        return card_pool[love.math.random(#card_pool)]
    end

    return "stoat"  -- fallback
end

function Reward.update(dt)
end

function Reward.draw()
    love.graphics.clear(0.08, 0.1, 0.08)

    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    -- 标题
    love.graphics.setColor(0.2, 0.4, 0.2)
    love.graphics.rectangle("fill", 420, 40, 280, 60, 8, 8)
    love.graphics.setColor(1, 0.9, 0.5)
    Fonts.print(">> VICTORY REWARD <<", 450, 55, 20)

    love.graphics.setColor(0.7, 0.65, 0.5)
    Fonts.print(I18n.t("reward_choose"), 440, 120, 14)

    -- 绘制卡牌选项
    for i, choice in ipairs(choices) do
        local x = 200 + (i - 1) * 300
        local y = 200
        local w = 180
        local h = 240

        -- 卡牌背景
        local is_selected = (i == selected)
        if is_selected then
            love.graphics.setColor(0.3, 0.5, 0.3)
            love.graphics.rectangle("fill", x - 10, y - 10, w + 20, h + 20, 10, 10)
        end

        -- 稀有度颜色
        local rarity_color = {
            common = {0.4, 0.4, 0.4},
            uncommon = {0.3, 0.5, 0.3},
            rare = {0.4, 0.3, 0.5},
            legendary = {0.6, 0.4, 0.2},
        }
        local rc = rarity_color[choice.rarity] or rarity_color.common

        love.graphics.setColor(rc[1], rc[2], rc[3])
        love.graphics.rectangle("fill", x, y, w, h, 8, 8)

        -- 边框
        love.graphics.setColor(0.6, 0.5, 0.4)
        love.graphics.rectangle("line", x, y, w, h, 8, 8)

        -- 快捷键提示
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.circle("fill", x + 20, y + 20, 15)
        love.graphics.setColor(1, 1, 1)
        Fonts.print(tostring(i), x + 15, y + 13, 16)

        -- 卡牌名称（使用翻译）
        Components.text(I18n.card_name(choice.card_id), x + 15, y + 50, {
            color = "text_primary", size = 18
        })

        -- 属性
        love.graphics.setColor(1, 0.7, 0.3)
        Fonts.print(I18n.t("reward_cost") .. ": " .. choice.cost, x + 15, y + 90, 14)
        love.graphics.setColor(0.9, 0.5, 0.3)
        Fonts.print(I18n.t("reward_atk") .. ": " .. choice.attack, x + 15, y + 120, 14)
        love.graphics.setColor(0.4, 0.8, 0.4)
        Fonts.print(I18n.t("reward_hp") .. ": " .. choice.hp, x + 15, y + 150, 14)

        -- 印记
        if #choice.sigils > 0 then
            love.graphics.setColor(0.9, 0.7, 0.5)
            local sigil_text = "* " .. #choice.sigils .. " sigil(s)"
            Fonts.print(sigil_text, x + 15, y + 180, 12)
        end

        -- 稀有度标签
        love.graphics.setColor(rc[1] + 0.2, rc[2] + 0.2, rc[3] + 0.2)
        local rarity_label = choice.rarity:upper()
        Fonts.print(rarity_label, x + 15, y + 210, 12)
    end

    -- 操作提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    Fonts.print(I18n.t("reward_hint"), 350, 480, 14)

    -- 已选择提示
    if selected > 0 and choices[selected] then
        Theme.setColor("text_primary")
        Fonts.print("Selected: " .. I18n.card_name(choices[selected].card_id), 480, 460, 16)

        -- 确认按钮
        love.graphics.setColor(0.2, 0.5, 0.2)
        love.graphics.rectangle("fill", 520, 490, 140, 40, 6, 6)
        love.graphics.setColor(1, 1, 1)
        Fonts.print(">> CONFIRM <<", 545, 500, 14)
    end

    -- 跳过按钮
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 30, win_h - 50, 100, 35, 5, 5)
    love.graphics.setColor(0.7, 0.7, 0.7)
    Fonts.print("[SKIP]", 55, win_h - 42, 14)

    -- 操作提示（移到底部，不遮挡）
    love.graphics.setColor(0.4, 0.4, 0.4)
    Fonts.print("Click card to select, click again or button to confirm", 400, win_h - 25, 12)
end

function Reward.keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        local index = tonumber(key)
        if index and choices[index] then
            selected = index
        end
    elseif key == "return" or key == "space" then
        if selected > 0 and choices[selected] then
            -- 添加选中的卡牌到牌组
            Deck.add_to_deck(choices[selected].card_id)
            print("Added " .. choices[selected].name .. " to deck!")
        end
        -- 奖励结束，返回地图选择下一关
        State.switch("map")
    elseif key == "escape" then
        -- 跳过奖励，返回地图
        State.switch("map")
    end
end

function Reward.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 跳过按钮
    local win_h = love.graphics.getHeight()
    if x >= 30 and x <= 130 and y >= win_h - 50 and y <= win_h - 15 then
        State.switch("map")
        return
    end

    -- 确认按钮
    if selected > 0 then
        if x >= 520 and x <= 660 and y >= 490 and y <= 530 then
            if choices[selected] then
                Deck.add_to_deck(choices[selected].card_id)
            end
            State.switch("map")
            return
        end
    end

    -- 检测点击卡牌
    for i, choice in ipairs(choices) do
        local cx = 200 + (i - 1) * 300
        local cy = 200
        local cw = 180
        local ch = 240

        if x >= cx and x <= cx + cw and y >= cy and y <= cy + ch then
            if selected == i then
                -- 双击确认
                if choices[i] then
                    Deck.add_to_deck(choices[i].card_id)
                end
                State.switch("map")
            else
                selected = i
            end
            return
        end
    end
end

return Reward