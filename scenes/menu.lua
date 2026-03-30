-- scenes/menu.lua - 主菜单场景
-- 使用 Theme 和 Components 重构

local Menu = {}
local State = require("core.state")
local Map = require("systems.map")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")

local buttons = {}

function Menu.enter()
    -- 计算按钮位置
    local btn_w, btn_h = 200, 50
    local btn_x = Layout.center_x(btn_w)
    buttons = {
        start = {x = btn_x, y = 430, width = btn_w, height = btn_h},
        settings = {x = btn_x, y = 500, width = btn_w, height = 40},
    }
end

function Menu.exit()
end

function Menu.update(dt)
end

function Menu.draw()
    -- 背景
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("title"), win_w / 2, 80, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 副标题
    Components.text(I18n.t("subtitle"), win_w / 2, 120, {
        color = "text_secondary",
        align = "center",
    })

    -- 游戏说明
    Components.text(I18n.t("how_to_play"), win_w / 2, 180, {
        color = "text_secondary",
        align = "center",
    })

    local instructions = {"instruction1", "instruction2", "instruction3",
                         "instruction4", "instruction5", "instruction6"}

    Theme.setColor("text_hint")
    for i, key in ipairs(instructions) do
        Fonts.print(I18n.t(key), win_w / 2 - 140, 210 + (i - 1) * 26)
    end

    -- 开始按钮
    local start_hover = Layout.mouse_in_button(buttons.start)
    Components.button(I18n.t("start_game"), buttons.start.x, buttons.start.y,
                      buttons.start.width, buttons.start.height, {
        hover = start_hover,
        style = "primary",
    })

    -- 设置按钮
    local settings_hover = Layout.mouse_in_button(buttons.settings)
    Components.button(I18n.t("settings"), buttons.settings.x, buttons.settings.y,
                      buttons.settings.width, buttons.settings.height, {
        hover = settings_hover,
    })

    -- 操作提示
    Components.text(I18n.t("press_hint"), win_w / 2, 570, {
        color = "text_hint",
        align = "center",
    })

    -- 当前语言
    Components.text("Language: " .. I18n.get_lang_name(), win_w / 2, 620, {
        color = "text_hint",
        align = "center",
    })
end

function Menu.keypressed(key)
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

    if Layout.mouse_in_button(buttons.start) then
        Map.generate()
        State.switch("map")
    elseif Layout.mouse_in_button(buttons.settings) then
        State.push("settings")
    end
end

return Menu