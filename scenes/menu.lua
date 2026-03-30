-- scenes/menu.lua - 主菜单场景
-- 使用 Theme 和 Components 重构，响应式布局

local Menu = {}
local State = require("core.state")
local Map = require("systems.map")
local Deck = require("systems.deck")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")

local buttons = {}

function Menu.enter()
    -- 计算按钮位置（响应式）
    local btn_w, btn_h = 200, 50
    local btn_small_h = 40
    buttons = Layout.menu_buttons(2, btn_w, btn_h, 15)
    -- 调整第二个按钮尺寸
    buttons[2].height = btn_small_h
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

    -- 标题（响应式）
    Components.text(I18n.t("title"), win_w / 2, win_h * 0.11, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 副标题
    Components.text(I18n.t("subtitle"), win_w / 2, win_h * 0.17, {
        color = "text_secondary",
        align = "center",
    })

    -- 游戏说明
    Components.text(I18n.t("how_to_play"), win_w / 2, win_h * 0.25, {
        color = "text_secondary",
        align = "center",
    })

    local instructions = {"instruction1", "instruction2", "instruction3",
                         "instruction4", "instruction5", "instruction6"}

    Theme.setColor("text_hint")
    local instruction_x = win_w / 2 - win_w * 0.11
    local instruction_start_y = win_h * 0.29
    for i, key in ipairs(instructions) do
        Fonts.print(I18n.t(key), instruction_x, instruction_start_y + (i - 1) * win_h * 0.036)
    end

    -- 开始按钮
    local start_hover = Layout.mouse_in_button(buttons[1])
    Components.button(I18n.t("start_game"), buttons[1].x, buttons[1].y,
                      buttons[1].width, buttons[1].height, {
        hover = start_hover,
        style = "primary",
    })

    -- 设置按钮
    local settings_hover = Layout.mouse_in_button(buttons[2])
    Components.button(I18n.t("settings"), buttons[2].x, buttons[2].y,
                      buttons[2].width, buttons[2].height, {
        hover = settings_hover,
    })

    -- 操作提示（响应式）
    Components.text(I18n.t("press_hint"), win_w / 2, win_h * 0.79, {
        color = "text_hint",
        align = "center",
    })

    -- 当前语言
    Components.text("Language: " .. I18n.get_lang_name(), win_w / 2, win_h * 0.86, {
        color = "text_hint",
        align = "center",
    })
end

function Menu.keypressed(key)
    if key == "space" then
        Map.generate()
        Deck.reset()
        State.switch("map")
    elseif key == "s" then
        State.push("settings")
    elseif key == "escape" then
        love.event.quit()
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    if Layout.mouse_in_button(buttons[1]) then
        Map.generate()
        Deck.reset()
        State.switch("map")
    elseif Layout.mouse_in_button(buttons[2]) then
        State.push("settings")
    end
end

return Menu