-- scenes/victory.lua - 胜利场景

local Victory = {}

function Victory.enter()
end

function Victory.exit()
end

function Victory.update(dt)
end

function Victory.draw()
    love.graphics.clear(0.1, 0.18, 0.1)

    love.graphics.setColor(0.4, 1, 0.4)
    love.graphics.print("VICTORY!", 520, 200)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("You defeated the enemy!", 450, 280)
    love.graphics.print("Press SPACE to continue", 450, 350)
    love.graphics.print("Press ESC to return to menu", 450, 400)
end

function Victory.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")  -- 下一场战斗
    end
end

return Victory