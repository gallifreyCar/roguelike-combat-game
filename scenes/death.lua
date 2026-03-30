-- scenes/death.lua - 死亡场景

local Death = {}
local State = require("core.state")
local Map = require("systems.map")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")

function Death.enter()
end

function Death.exit()
end

function Death.update(dt)
end

function Death.draw()
    love.graphics.clear(0.15, 0.05, 0.05)

    -- 获取动态窗口尺寸
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.setColor(0.8, 0.3, 0.3)
    Fonts.print(I18n.t("defeated"), win_w / 2 - 50, 200)

    love.graphics.setColor(0.7, 0.7, 0.7)
    Fonts.print(I18n.t("fallen"), win_w / 2 - 90, 280)

    -- 重试按钮（居中）
    local btn_w = 200
    local btn_h = 40
    local btn_x = (win_w - btn_w) / 2
    local btn_y = 340

    love.graphics.setColor(0.5, 0.3, 0.3)
    love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 5, 5)
    love.graphics.setColor(1, 1, 1)
    Fonts.print(I18n.t("retry"), btn_x + 50, btn_y + 10)

    -- 返回菜单按钮
    local menu_btn_y = 400
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", btn_x, menu_btn_y, btn_w, btn_h, 5, 5)
    love.graphics.setColor(0.8, 0.8, 0.8)
    Fonts.print(I18n.t("menu_btn"), btn_x + 60, menu_btn_y + 10)

    -- 操作提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    Fonts.print(I18n.t("death_hint"), win_w / 2 - 100, 480)
end

function Death.keypressed(key)
    if key == "space" then
        -- 重试：重置地图并重新开始战斗
        Map.reset()
        Map.generate()
        State.switch("map")
    elseif key == "escape" then
        -- 返回主菜单
        Map.reset()
        State.switch("menu")
    end
end

function Death.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 获取动态窗口尺寸
    local win_w = love.graphics.getWidth()
    local btn_w = 200
    local btn_x = (win_w - btn_w) / 2

    -- 点击重试按钮
    if x >= btn_x and x <= btn_x + btn_w and y >= 340 and y <= 380 then
        Map.reset()
        Map.generate()
        State.switch("map")
    end

    -- 点击返回菜单按钮
    if x >= btn_x and x <= btn_x + btn_w and y >= 400 and y <= 440 then
        Map.reset()
        State.switch("menu")
    end
end

return Death