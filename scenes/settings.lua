-- scenes/settings.lua - 设置场景
-- 游戏设置界面

local SettingsScene = {}
local SettingsManager = require("systems.settings_manager")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")

local settings = {}
local selected_option = 1

local function get_options()
    return {
        {key = "master_volume", name = I18n.t("master_volume"), type = "slider", min = 0, max = 1, step = 0.1},
        {key = "music_volume", name = I18n.t("music_volume"), type = "slider", min = 0, max = 1, step = 0.1},
        {key = "sfx_volume", name = I18n.t("sfx_volume"), type = "slider", min = 0, max = 1, step = 0.1},
        {key = "fullscreen", name = I18n.t("fullscreen"), type = "toggle"},
        {key = "language", name = I18n.t("language"), type = "select", values = {"en", "zh", "ja", "ko"}},
        {key = "show_tutorial", name = I18n.t("show_tutorial"), type = "toggle"},
    }
end

function SettingsScene.enter()
    settings = SettingsManager.load()
    selected_option = 1
    -- 同步语言设置到 I18n
    if settings.language then
        I18n.set_lang(settings.language)
    end
end

function SettingsScene.exit()
    SettingsManager.save()
end

function SettingsScene.update(dt)
end

function SettingsScene.draw()
    love.graphics.clear(0.06, 0.08, 0.1)

    -- 获取动态窗口尺寸
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    -- 标题（居中）
    local title_w = 280
    love.graphics.setColor(0.3, 0.35, 0.4)
    love.graphics.rectangle("fill", (win_w - title_w) / 2, 30, title_w, 50, 8, 8)
    love.graphics.setColor(1, 0.95, 0.9)
    Fonts.print(I18n.t("settings_title"), (win_w - title_w) / 2 + 100, 40, 20)

    -- 设置选项（居中）
    local opt_w = 400
    local start_x = (win_w - opt_w) / 2
    local options = get_options()

    for i, opt in ipairs(options) do
        local y = 120 + (i - 1) * 70
        local value = settings[opt.key]

        -- 背景
        if i == selected_option then
            love.graphics.setColor(0.2, 0.25, 0.3)
        else
            love.graphics.setColor(0.15, 0.18, 0.22)
        end
        love.graphics.rectangle("fill", start_x, y, opt_w, 55, 6, 6)

        -- 选项名称
        love.graphics.setColor(0.9, 0.85, 0.8)
        Fonts.print(opt.name, start_x + 20, y + 10, 16)

        -- 值显示
        local value_x = start_x + opt_w - 150
        if opt.type == "slider" then
            -- 滑块
            local slider_w = 100
            local fill_w = value * slider_w

            love.graphics.setColor(0.2, 0.2, 0.25)
            love.graphics.rectangle("fill", value_x, y + 30, slider_w, 15, 4, 4)
            love.graphics.setColor(0.4, 0.6, 0.8)
            love.graphics.rectangle("fill", value_x, y + 30, fill_w, 15, 4, 4)

            love.graphics.setColor(1, 1, 1)
            Fonts.print(math.floor(value * 100) .. "%", value_x + slider_w + 15, y + 28, 14)

        elseif opt.type == "toggle" then
            local toggle_text = value and I18n.t("on") or I18n.t("off")
            local toggle_color = value and {0.3, 0.7, 0.4} or {0.6, 0.3, 0.3}
            love.graphics.setColor(toggle_color[1], toggle_color[2], toggle_color[3])
            love.graphics.rectangle("fill", value_x, y + 20, 60, 25, 4, 4)
            love.graphics.setColor(1, 1, 1)
            Fonts.print(toggle_text, value_x + 10, y + 24, 14)

        elseif opt.type == "select" then
            love.graphics.setColor(0.4, 0.4, 0.5)
            love.graphics.rectangle("fill", value_x, y + 20, 80, 25, 4, 4)
            love.graphics.setColor(1, 1, 1)
            -- 显示语言名称而不是代码
            local lang_names = {en = "EN", zh = "CN", ja = "JP", ko = "KR"}
            Fonts.print(lang_names[value] or value:upper(), value_x + 30, y + 24, 14)
        end
    end

    -- 底部按钮（居中）
    local btn_w = 150
    love.graphics.setColor(0.3, 0.35, 0.4)
    love.graphics.rectangle("fill", (win_w - btn_w * 2 - 50) / 2, 550, btn_w, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    Fonts.print(I18n.t("reset"), (win_w - btn_w * 2 - 50) / 2 + 50, 560, 14)

    love.graphics.setColor(0.4, 0.3, 0.35)
    love.graphics.rectangle("fill", (win_w - btn_w * 2 - 50) / 2 + btn_w + 50, 550, btn_w, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    Fonts.print(I18n.t("back"), (win_w - btn_w * 2 - 50) / 2 + btn_w + 70, 560, 14)

    -- 操作提示（居中）
    love.graphics.setColor(0.5, 0.5, 0.5)
    Fonts.print(I18n.t("settings_hint"), win_w / 2 - 130, 620, 12)
end

function SettingsScene.keypressed(key)
    local options = get_options()

    if key == "escape" then
        SettingsManager.save()
        State.pop()
    elseif key == "return" then
        -- 回车键：保存并返回
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
                -- 同步更新语言
                if opt.key == "language" then
                    I18n.set_lang(settings[opt.key])
                end
            end
        end
    end
end

function SettingsScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 获取动态窗口尺寸
    local win_w = love.graphics.getWidth()
    local btn_w = 150

    -- 重置按钮（居中）
    local reset_x = (win_w - btn_w * 2 - 50) / 2
    if x >= reset_x and x <= reset_x + btn_w and y >= 550 and y <= 590 then
        SettingsManager.reset()
        settings = SettingsManager.get_all()
    end

    -- 返回按钮（居中）
    local back_x = reset_x + btn_w + 50
    if x >= back_x and x <= back_x + btn_w and y >= 550 and y <= 590 then
        SettingsManager.save()
        State.pop()
    end
end

return SettingsScene