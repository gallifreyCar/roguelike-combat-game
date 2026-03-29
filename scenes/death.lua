-- scenes/death.lua - 死亡场景

local Death = {}

function Death.enter()
end

function Death.exit()
end

function Death.update(dt)
end

function Death.draw()
    love.graphics.clear(0.15, 0.05, 0.05)

    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.print("DEFEATED", 520, 200)

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Your cards have fallen...", 450, 280)
    love.graphics.print("Press SPACE to retry", 480, 350)
    love.graphics.print("Press ESC to return to menu", 450, 400)
end

function Death.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Death