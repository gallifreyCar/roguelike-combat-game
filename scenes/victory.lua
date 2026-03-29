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
    love.graphics.print("Press SPACE to continue", 470, 350)
    love.graphics.print("Press ESC to return to menu", 450, 400)
end

function Victory.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Victory