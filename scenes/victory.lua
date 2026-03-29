-- scenes/victory.lua - 胜利场景

local Victory = {}

function Victory.enter()
end

function Victory.exit()
end

function Victory.update(dt)
end

function Victory.draw()
    love.graphics.clear(0.1, 0.15, 0.1)

    love.graphics.setColor(0.4, 0.8, 0.4)
    love.graphics.print("VICTORY!", 520, 200)

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Your cards have conquered!", 450, 280)

    -- 继续按钮
    love.graphics.setColor(0.3, 0.5, 0.3)
    love.graphics.rectangle("fill", 450, 340, 200, 40, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(">> CONTINUE <<", 480, 350)

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.print("Press ESC to return to menu", 450, 420)
end

function Victory.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

function Victory.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 点击继续按钮
    if x >= 450 and x <= 650 and y >= 340 and y <= 380 then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Victory