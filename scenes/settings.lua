-- scenes/settings.lua - 设置场景
-- 游戏设置界面

local SettingsScene = {}
local SettingsManager = require("systems.settings_manager")
local State = require("core.state")
local Fonts = require("core.fonts")

local settings = {}
local selected_option = 1

local options = {
    {key = "master_volume", name = "Master Volume", type = "slider", min = 0, max = 1, step = 0.1},
    {key = "music_volume", name = "Music Volume", type = "slider", min = 0, max = 1, step = 0.1},
    {key = "sfx_volume", name = "SFX Volume", type = "slider", min = 0, max = 1, step = 0.1},
    {key = "fullscreen", name = "Fullscreen", type = "toggle"},
    {key = "language", name = "Language", type = "select", values = {"en", "zh"}},
    {key = "show_tutorial", name = "Show Tutorial", type = "toggle"},
}

function SettingsScene.enter()
    settings = SettingsManager.load()
    selected_option = 1
end

function SettingsScene.exit()
    SettingsManager.save()
end

function SettingsScene.update(dt)
end

function SettingsScene.draw()
    love.graphics.clear(0.06, 0.08, 0.1)

    -- 标题
    love.graphics.setColor(0.3, 0.35, 0.4)
    love.graphics.rectangle("fill", 450, 30, 280, 50, 8, 8)
    love.graphics.setColor(1, 0.95, 0.9)
    Fonts.print("⚙ SETTINGS ⚙", 510, 40, 20)

    -- 设置选项
    for i, opt in ipairs(options) do
        local y = 120 + (i - 1) * 70
        local value = settings[opt.key]

        -- 背景
        if i == selected_option then
            love.graphics.setColor(0.2, 0.25, 0.3)
        else
            love.graphics.setColor(0.15, 0.18, 0.22)
        end
        love.graphics.rectangle("fill", 350, y, 400, 55, 6, 6)

        -- 选项名称
        love.graphics.setColor(0.9, 0.85, 0.8)
        Fonts.print(opt.name, 370, y + 10, 16)

        -- 值显示
        if opt.type == "slider" then
            -- 滑块
            local slider_w = 200
            local slider_x = 500
            local fill_w = value * slider_w

            love.graphics.setColor(0.2, 0.2, 0.25)
            love.graphics.rectangle("fill", slider_x, y + 30, slider_w, 15, 4, 4)
            love.graphics.setColor(0.4, 0.6, 0.8)
            love.graphics.rectangle("fill", slider_x, y + 30, fill_w, 15, 4, 4)

            love.graphics.setColor(1, 1, 1)
            Fonts.print(math.floor(value * 100) .. "%", slider_x + slider_w + 15, y + 28, 14)

        elseif opt.type == "toggle" then
            local toggle_text = value and "ON" or "OFF"
            local toggle_color = value and {0.3, 0.7, 0.4} or {0.6, 0.3, 0.3}
            love.graphics.setColor(toggle_color[1], toggle_color[2], toggle_color[3])
            love.graphics.rectangle("fill", 550, y + 20, 60, 25, 4, 4)
            love.graphics.setColor(1, 1, 1)
            Fonts.print(toggle_text, 560, y + 24, 14)

        elseif opt.type == "select" then
            love.graphics.setColor(0.4, 0.4, 0.5)
            love.graphics.rectangle("fill", 550, y + 20, 80, 25, 4, 4)
            love.graphics.setColor(1, 1, 1)
            Fonts.print(value:upper(), 570, y + 24, 14)
        end
    end

    -- 底部按钮
    love.graphics.setColor(0.3, 0.35, 0.4)
    love.graphics.rectangle("fill", 350, 550, 150, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("Reset", 395, 560, 14)

    love.graphics.setColor(0.4, 0.3, 0.35)
    love.graphics.rectangle("fill", 550, 550, 150, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("[ESC] Back", 575, 560, 14)

    -- 操作提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    Fonts.print("UP/DOWN Select  |  LEFT/RIGHT Change  |  Enter Toggle", 380, 620, 12)
end

function SettingsScene.keypressed(key)
    if key == "escape" then
        SettingsManager.save()
        State.pop()
    elseif key == "up" then
        selected_option = math.max(1, selected_option - 1)
    elseif key == "down" then
        selected_option = math.min(#options, selected_option + 1)
    elseif key == "left" or key == "right" then
        local opt = options[selected_option]
        if opt then
            if opt.type == "slider" then
                local delta = opt.step * (key == "right" and 1 or -1)
                local new_val = math.max(opt.min, math.min(opt.max, settings[opt.key] + delta))
                settings[opt.key] = new_val
                SettingsManager.set(opt.key, new_val)
            elseif opt.type == "toggle" then
                settings[opt.key] = not settings[opt.key]
                SettingsManager.set(opt.key, settings[opt.key])
                if opt.key == "fullscreen" then
                    SettingsManager.toggle_fullscreen()
                end
            elseif opt.type == "select" then
                local idx = 1
                for i, v in ipairs(opt.values) do
                    if v == settings[opt.key] then idx = i break end
                end
                idx = idx + (key == "right" and 1 or -1)
                if idx < 1 then idx = #opt.values end
                if idx > #opt.values then idx = 1 end
                settings[opt.key] = opt.values[idx]
                SettingsManager.set(opt.key, settings[opt.key])
            end
        end
    elseif key == "return" then
        local opt = options[selected_option]
        if opt and opt.type == "toggle" then
            settings[opt.key] = not settings[opt.key]
            SettingsManager.set(opt.key, settings[opt.key])
            if opt.key == "fullscreen" then
                SettingsManager.toggle_fullscreen()
            end
        end
    end
end

function SettingsScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 重置按钮
    if x >= 350 and x <= 500 and y >= 550 and y <= 590 then
        SettingsManager.reset()
        settings = SettingsManager.get_all()
    end

    -- 返回按钮
    if x >= 550 and x <= 700 and y >= 550 and y <= 590 then
        SettingsManager.save()
        State.pop()
    end
end

return SettingsScene