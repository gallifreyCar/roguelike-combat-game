-- scenes/settings.lua - 设置场景
-- 使用 Theme 和 Components 重构

local SettingsScene = {}
local SettingsManager = require("systems.settings_manager")
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")

local settings = {}
local selected_option = 1
local buttons = {}

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
    if settings.language then
        I18n.set_lang(settings.language)
    end

    -- 计算按钮位置
    local btn_w, btn_h = 150, 40
    buttons = Layout.bottom_buttons(2, btn_w, btn_h, 50)
end

function SettingsScene.exit()
    SettingsManager.save()
end

function SettingsScene.update(dt)
end

function SettingsScene.draw()
    -- 背景
    Theme.setColor("bg_secondary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题面板
    local title_w = 280
    Components.panel(Layout.center_x(title_w), 30, title_w, 50, {
        bg = "bg_button",
    })
    Components.text(I18n.t("settings_title"), win_w / 2, 40, {
        color = "text_primary",
        size = 20,
        align = "center",
    })

    -- 设置选项
    local opt_w = 400
    local start_x = Layout.center_x(opt_w)
    local options = get_options()

    for i, opt in ipairs(options) do
        local y = 120 + (i - 1) * 70
        local value = settings[opt.key]

        -- 选项背景
        local bg_color = (i == selected_option) and "bg_button_hover" or "bg_slot"
        Components.panel(start_x, y, opt_w, 55, {bg = bg_color, radius = 6})

        -- 选项名称
        Components.text(opt.name, start_x + 20, y + 10, {color = "text_primary"})

        -- 值显示
        local value_x = start_x + opt_w - 150

        if opt.type == "slider" then
            Components.progress_bar(value_x, y + 30, 100, 15, value, 1, {
                fill = "accent_blue",
                bg = "bg_slot",
                radius = 4,
            })
            Components.text(math.floor(value * 100) .. "%", value_x + 115, y + 28, {
                color = "text_value",
                size = 14,
            })

        elseif opt.type == "toggle" then
            local toggle_text = value and I18n.t("on") or I18n.t("off")
            local toggle_style = value and "primary" or "danger"
            Components.button(toggle_text, value_x, y + 20, 60, 25, {
                style = toggle_style,
                radius = 4,
                font_size = 14,
            })

        elseif opt.type == "select" then
            local lang_names = {en = "EN", zh = "CN", ja = "JP", ko = "KR"}
            -- [BUG FIX] 确保 value 不为 nil，防止 :upper() 调用失败
            local display_value = value or "en"
            Components.button(lang_names[display_value] or display_value:upper(), value_x, y + 20, 80, 25, {
                radius = 4,
                font_size = 14,
            })
        end
    end

    -- 底部按钮
    Components.button(I18n.t("reset"), buttons[1].x, buttons[1].y,
                      buttons[1].width, buttons[1].height, {})
    Components.button(I18n.t("back"), buttons[2].x, buttons[2].y,
                      buttons[2].width, buttons[2].height, {})

    -- 操作提示
    Components.text(I18n.t("settings_hint"), win_w / 2, 620, {
        color = "text_hint",
        align = "center",
    })
end

function SettingsScene.keypressed(key)
    local options = get_options()

    if key == "escape" or key == "return" then
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
                if opt.key == "language" then
                    I18n.set_lang(settings[opt.key])
                end
            end
        end
    end
end

function SettingsScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    if Layout.mouse_in_button(buttons[1]) then
        SettingsManager.reset()
        settings = SettingsManager.get_all()
    elseif Layout.mouse_in_button(buttons[2]) then
        SettingsManager.save()
        State.pop()
    end
end

return SettingsScene