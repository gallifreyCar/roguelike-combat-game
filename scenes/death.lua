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

    -- 重试按钮
    love.graphics.setColor(0.5, 0.3, 0.3)
    love.graphics.rectangle("fill", 450, 340, 200, 40, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(">> RETRY <<", 490, 350)

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.print("Press ESC to return to menu", 450, 420)
end

function Death.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("combat")
    end
end

function Death.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 点击重试按钮
    if x >= 450 and x <= 650 and y >= 340 and y <= 380 then
        local State = require("core.state")
        State.switch("combat")
    end
end

return Death