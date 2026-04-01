-- scenes/death.lua - 死亡结算场景

local Death = {}
local I18n = require("core.i18n")

function Death.enter()
    -- 进入死亡场景
end

function Death.exit()
    -- 退出
end

function Death.update(dt)
end

function Death.draw()
    love.graphics.clear(0.2, 0.05, 0.05)

    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.print(I18n.t("you_died"), 500, 250)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(I18n.t("restart"), 450, 350)
    love.graphics.print(I18n.t("press_quit"), 450, 400)
end

function Death.keypressed(key)
    if key == "space" then
        local State = require("core.state")
        State.switch("menu")
    end
end

return Death