-- ui/card.lua - 卡牌渲染组件
-- 提供卡牌绘制、悬停效果、拖拽效果

local Fonts = require("core.fonts")
local Colors = require("config.colors")

local CardUI = {}

-- 卡牌尺寸
CardUI.WIDTH = 100
CardUI.HEIGHT = 130
CardUI.SMALL_HEIGHT = 80

-- 绘制完整卡牌
function CardUI.draw_full(card, x, y, is_player, options)
    options = options or {}

    -- 背景
    if is_player then
        love.graphics.setColor(Colors.card_player_bg)
    else
        love.graphics.setColor(Colors.card_enemy_bg)
    end
    love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    -- 边框
    if options.highlight then
        love.graphics.setColor(Colors.card_highlight)
    else
        love.graphics.setColor(Colors.card_border)
    end
    love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    -- 名称
    love.graphics.setColor(Colors.text_primary)
    Fonts.print(card.name, x + 8, y + 8)

    -- Cost（红圈）
    if card.cost then
        love.graphics.setColor(Colors.cost_bg)
        love.graphics.circle("fill", x + 15, y + 28, 12)
        love.graphics.setColor(Colors.cost_text)
        Fonts.print(tostring(card.cost), x + 10, y + 23)
    end

    -- 属性
    love.graphics.setColor(Colors.attack_text)
    Fonts.print("ATK:" .. card.attack, x + 8, y + 50)
    love.graphics.setColor(Colors.hp_text)
    Fonts.print("HP:" .. card.hp, x + 55, y + 50)

    -- 血量条
    love.graphics.setColor(Colors.hp_bar_bg)
    love.graphics.rectangle("fill", x + 8, y + 75, 84, 8)
    love.graphics.setColor(Colors.hp_bar_fill)
    local hp_ratio = card.hp / (card.max_hp or card.hp)
    love.graphics.rectangle("fill", x + 8, y + 75, 84 * hp_ratio, 8)

    -- 印记图标（如有）
    if card.sigils and #card.sigils > 0 then
        love.graphics.setColor(Colors.sigil_text)
        Fonts.print("★", x + 80, y + 8)
    end
end

-- 绘制小型卡牌（手牌列表用）
function CardUI.draw_small(card, x, y, hover)
    if hover then
        love.graphics.setColor(Colors.card_hover_bg)
    else
        love.graphics.setColor(Colors.card_small_bg)
    end
    love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.SMALL_HEIGHT, 4, 4)

    love.graphics.setColor(Colors.card_border)
    love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.SMALL_HEIGHT, 4, 4)

    love.graphics.setColor(Colors.text_primary)
    Fonts.print(card.name, x + 5, y + 5)

    -- Cost用红色突出
    love.graphics.setColor(Colors.cost_text)
    Fonts.print("$" .. card.cost, x + 5, y + 25)

    love.graphics.setColor(Colors.attack_text)
    Fonts.print("A:" .. card.attack, x + 5, y + 45)
    love.graphics.setColor(Colors.hp_text)
    Fonts.print("H:" .. card.hp, x + 45, y + 45)

    if hover then
        love.graphics.setColor(Colors.drag_hint)
        Fonts.print("[drag]", x + 55, y + 60)
    end
end

-- 绘制空格子
function CardUI.draw_slot(x, y, hover_valid, hover_invalid)
    if hover_valid then
        love.graphics.setColor(Colors.slot_valid)
    elseif hover_invalid then
        love.graphics.setColor(Colors.slot_invalid)
    else
        love.graphics.setColor(Colors.slot_empty)
    end
    love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    love.graphics.setColor(Colors.slot_border)
    love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)
end

return CardUI