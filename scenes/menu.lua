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
        "1. Click card to select (or Q/W/E/R/T)",
        "2. Click slot to place (or 1-4)",
        "3. Cards with cost need BLOOD (sacrifice your cards)",
        "4. Click BATTLE button to start (or SPACE)",
        "5. Cards attack automatically!",
        "",
        "When your card dies, you gain +1 Blood",
    }
    for i, line in ipairs(instructions) do
        love.graphics.print(line, 400, 310 + (i - 1) * 25)
    end

    -- 开始按钮
    love.graphics.setColor(0.3, 0.5, 0.3)
    love.graphics.rectangle("fill", 450, 500, 200, 50, 8, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(">> START GAME <<", 470, 515)

    -- 退出提示
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.print("Press ESC to Quit", 480, 580)
end

function Menu.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 点击开始按钮
    if x >= 450 and x <= 650 and y >= 500 and y <= 550 then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Menu