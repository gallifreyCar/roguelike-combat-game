local Fonts = require("core.fonts")
-- scenes/menu.lua - 主菜单场景

local Menu = {}

function Menu.enter()
end

function Menu.exit()
end

function Menu.update(dt)
end

function Menu.draw()
    love.graphics.clear(0.08, 0.06, 0.04)

    -- 标题
    love.graphics.setColor(0.7, 0.55, 0.3)
    Fonts.print("CARD SACRIFICE", 440, 100)
    love.graphics.setColor(0.45, 0.4, 0.3)
    Fonts.print("A Roguelike Auto-Battler", 420, 140)

    -- 说明
    love.graphics.setColor(0.7, 0.65, 0.5)
    Fonts.print("HOW TO PLAY:", 420, 220)

    love.graphics.setColor(0.55, 0.5, 0.45)
    local instructions = {
        "1. DRAG cards from right panel",
        "2. DROP on empty slots",
        "3. Cards need BLOOD (cost)",
        "4. Dead cards = +1 Blood",
        "5. Click BATTLE to fight!",
        "",
        "Cards attack automatically each turn.",
    }
    for i, line in ipairs(instructions) do
        Fonts.print(line, 380, 250 + (i - 1) * 28)
    end

    -- 开始按钮
    love.graphics.setColor(0.3, 0.45, 0.3)
    love.graphics.rectangle("fill", 420, 480, 200, 50, 8, 8)
    love.graphics.setColor(0.9, 0.85, 0.5)
    Fonts.print(">> START GAME <<", 445, 495)

    love.graphics.setColor(0.4, 0.4, 0.4)
    Fonts.print("Press SPACE or click button to start", 370, 560)
end

function Menu.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    if x >= 420 and x <= 620 and y >= 480 and y <= 530 then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Menu