local Fonts = require("core.fonts")
local I18n = require("core.i18n")
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

    -- 获取动态窗口尺寸
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    -- 标题（居中）
    love.graphics.setColor(0.7, 0.55, 0.3)
    Fonts.print(I18n.t("title"), win_w / 2 - 80, 80)
    love.graphics.setColor(0.45, 0.4, 0.3)
    Fonts.print(I18n.t("subtitle"), win_w / 2 - 120, 120)

    -- 说明（居中）
    love.graphics.setColor(0.7, 0.65, 0.5)
    Fonts.print(I18n.t("how_to_play"), win_w / 2 - 50, 180)

    love.graphics.setColor(0.55, 0.5, 0.45)
    local instructions = {
        "instruction1", "instruction2", "instruction3",
        "instruction4", "instruction5", "instruction6",
    }
    for i, key in ipairs(instructions) do
        local text = I18n.t(key)
        if key == "instruction6" then
            Fonts.print(text, win_w / 2 - 140, 210 + (i - 1) * 26)
        else
            Fonts.print(text, win_w / 2 - 140, 210 + (i - 1) * 26)
        end
    end

    -- 开始按钮（居中）
    love.graphics.setColor(0.3, 0.45, 0.3)
    love.graphics.rectangle("fill", win_w / 2 - 100, 430, 200, 50, 8, 8)
    love.graphics.setColor(0.9, 0.85, 0.5)
    Fonts.print(I18n.t("start_game"), win_w / 2 - 75, 445)

    -- 设置按钮（居中）
    love.graphics.setColor(0.35, 0.35, 0.4)
    love.graphics.rectangle("fill", win_w / 2 - 100, 500, 200, 40, 6, 6)
    love.graphics.setColor(0.8, 0.8, 0.85)
    Fonts.print(I18n.t("settings"), win_w / 2 - 60, 510)

    love.graphics.setColor(0.4, 0.4, 0.4)
    Fonts.print(I18n.t("press_hint"), win_w / 2 - 130, 570)

    -- 显示当前语言
    love.graphics.setColor(0.5, 0.5, 0.5)
    Fonts.print("Language: " .. I18n.get_lang_name(), win_w / 2 - 50, 620)
end

function Menu.keypressed(key)
    local State = require("core.state")
    local Map = require("systems.map")

    if key == "space" then
        Map.generate()
        State.switch("map")
    elseif key == "s" then
        State.push("settings")
    elseif key == "escape" then
        love.event.quit()
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    local State = require("core.state")
    local Map = require("systems.map")

    -- 获取动态窗口尺寸
    local win_w = love.graphics.getWidth()

    -- 开始按钮（居中）
    if x >= win_w / 2 - 100 and x <= win_w / 2 + 100 and y >= 430 and y <= 480 then
        Map.generate()
        State.switch("map")
    end

    -- 设置按钮（居中）
    if x >= win_w / 2 - 100 and x <= win_w / 2 + 100 and y >= 500 and y <= 540 then
        State.push("settings")
    end
end

return Menu