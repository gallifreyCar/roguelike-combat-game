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
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.print("CARD SACRIFICE", 480, 150)
    love.graphics.setColor(0.4, 0.35, 0.25)
    love.graphics.print("A Roguelike Auto-Battler", 450, 190)

    -- 游戏说明
    love.graphics.setColor(0.7, 0.65, 0.5)
    love.graphics.print("HOW TO PLAY:", 450, 280)

    love.graphics.setColor(0.5, 0.5, 0.5)
    local instructions = {
        "1. Select card from hand (Q/W/E/R/T)",
        "2. Place on board (1-4)",
        "3. Cards with cost need BLOOD (sacrifice your cards)",
        "4. Press SPACE to start battle",
        "5. Cards attack automatically!",
        "",
        "When your card dies, you gain +1 Blood",
    }
    for i, line in ipairs(instructions) do
        love.graphics.print(line, 400, 310 + (i - 1) * 25)
    end

    -- 开始提示
    love.graphics.setColor(0.8, 0.7, 0.4)
    love.graphics.print("Press SPACE to Start", 480, 520)

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.print("Press ESC to Quit", 500, 560)
end

function Menu.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Menu