-- scenes/fusion.lua - 卡牌融合场景
-- 选择两张相同卡牌进行融合升级

local Fusion = {}
local FusionSystem = require("systems.fusion")
local Deck = require("systems.deck")
local State = require("core.state")
local Fonts = require("core.fonts")
local CardData = require("data.cards")

local selected_cards = {}
local fusible_pairs = {}
local preview_result = nil

function Fusion.enter()
    selected_cards = {}
    preview_result = nil

    -- 查找可融合的卡牌
    fusible_pairs = FusionSystem.find_fusible_pairs(Deck.get_hand())
end

function Fusion.exit()
    selected_cards = {}
    fusible_pairs = {}
    preview_result = nil
end

function Fusion.update(dt)
end

function Fusion.draw()
    love.graphics.clear(0.08, 0.06, 0.1)

    -- 标题
    love.graphics.setColor(0.4, 0.3, 0.5)
    love.graphics.rectangle("fill", 420, 30, 280, 50, 8, 8)
    love.graphics.setColor(1, 0.9, 0.7)
    Fonts.print("⚗ CARD FUSION ⚗", 470, 40, 18)

    if #fusible_pairs == 0 then
        love.graphics.setColor(0.7, 0.6, 0.5)
        Fonts.print("No cards available for fusion", 450, 300, 16)
        love.graphics.setColor(0.5, 0.5, 0.5)
        Fonts.print("You need 2 of the same card to fuse", 430, 340, 14)
    else
        -- 显示可融合的卡牌对
        love.graphics.setColor(0.7, 0.65, 0.55)
        Fonts.print("Select a pair to fuse:", 450, 100, 14)

        for i, pair in ipairs(fusible_pairs) do
            local y = 150 + (i - 1) * 100
            local template = CardData.cards[pair.card_id]

            if template then
                -- 卡牌背景
                love.graphics.setColor(0.2, 0.18, 0.25)
                love.graphics.rectangle("fill", 350, y, 400, 80, 6, 6)

                -- 卡牌名称和数量
                love.graphics.setColor(1, 1, 1)
                Fonts.print(template.name .. " x" .. pair.count, 370, y + 10, 16)

                -- 属性
                love.graphics.setColor(1, 0.7, 0.3)
                Fonts.print("ATK: " .. template.attack .. " → " .. (template.attack + 1), 370, y + 35, 12)
                love.graphics.setColor(0.4, 0.8, 0.4)
                Fonts.print("HP: " .. template.hp .. " → " .. (template.hp + 2), 500, y + 35, 12)

                -- 融合按钮
                love.graphics.setColor(0.3, 0.4, 0.5)
                love.graphics.rectangle("fill", 600, y + 20, 100, 40, 4, 4)
                love.graphics.setColor(1, 1, 1)
                Fonts.print("[FUSE]", 620, y + 30, 14)
            end
        end
    end

    -- 返回按钮
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", 550, 500, 120, 40, 6, 6)
    love.graphics.setColor(0.8, 0.8, 0.8)
    Fonts.print("[ESC] Back", 570, 510, 14)
end

function Fusion.keypressed(key)
    if key == "escape" then
        State.pop()
    end
end

function Fusion.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 检测点击融合按钮
    for i, pair in ipairs(fusible_pairs) do
        local btn_y = 150 + (i - 1) * 100 + 20
        if x >= 600 and x <= 700 and y >= btn_y and y <= btn_y + 40 then
            -- 执行融合
            -- TODO: 实际融合逻辑
            print("Fusing " .. pair.card_id)
        end
    end

    -- 返回按钮
    if x >= 550 and x <= 670 and y >= 500 and y <= 540 then
        State.pop()
    end
end

return Fusion