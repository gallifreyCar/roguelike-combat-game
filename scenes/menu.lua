local Fonts = require("core.fonts")
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
    Fonts.print("CARD SACRIFICE", win_w / 2 - 80, 80)
    love.graphics.setColor(0.45, 0.4, 0.3)
    Fonts.print("A Roguelike Auto-Battler", win_w / 2 - 120, 120)

    -- 说明（居中）
    love.graphics.setColor(0.7, 0.65, 0.5)
    Fonts.print("HOW TO PLAY:", win_w / 2 - 50, 180)

    love.graphics.setColor(0.55, 0.5, 0.45)
    local instructions = {
        "1. DRAG cards from right panel",
        "2. DROP on empty slots",
        "3. Cards need BLOOD (cost)",
        "4. Dead cards = +1 Blood",
        "5. Click BATTLE to fight!",
        "",
        "Cards attack automatically each turn.",
    }
    for i, line in ipairs(instructions) do
        Fonts.print(line, win_w / 2 - 140, 210 + (i - 1) * 26)
    end

    -- 开始按钮（居中）
    love.graphics.setColor(0.3, 0.45, 0.3)
    love.graphics.rectangle("fill", win_w / 2 - 100, 430, 200, 50, 8, 8)
    love.graphics.setColor(0.9, 0.85, 0.5)
    Fonts.print(">> START GAME <<", win_w / 2 - 75, 445)

    -- 设置按钮（居中）
    love.graphics.setColor(0.35, 0.35, 0.4)
    love.graphics.rectangle("fill", win_w / 2 - 100, 500, 200, 40, 6, 6)
    love.graphics.setColor(0.8, 0.8, 0.85)
    Fonts.print("[ SETTINGS ]", win_w / 2 - 60, 510)

    love.graphics.setColor(0.4, 0.4, 0.4)
    Fonts.print("Press SPACE to start, S for settings", win_w / 2 - 130, 570)
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