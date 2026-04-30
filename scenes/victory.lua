-- scenes/victory.lua - 胜利结算场景

local Victory = {}
local State = require("core.state")
local Save = require("systems.save")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local I18n = require("core.i18n")
local Sound = require("systems.sound")

function Victory.enter()
    Save.update_stat("wins", 1)
end

function Victory.exit()
end

function Victory.update(dt)
end

function Victory.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()
    local stats = Save.get_stats()

    Components.text(I18n.t("victory_title"), win_w / 2, win_h * 0.2, {
        color = "accent_gold",
        size = 34,
        align = "center",
    })

    Components.text(I18n.t("all_levels"), win_w / 2, win_h * 0.29, {
        color = "text_secondary",
        size = 18,
        align = "center",
    })

    local panel_w = 360
    local panel_h = 170
    local panel_x = (win_w - panel_w) / 2
    local panel_y = win_h * 0.39
    Components.panel(panel_x, panel_y, panel_w, panel_h, {bg = "bg_panel", radius = 8})

    Components.text(I18n.t("run_statistics"), win_w / 2, panel_y + 18, {
        color = "text_title",
        align = "center",
    })
    Components.text(I18n.t("battles_won") .. ": " .. (stats.battles_won or 0), panel_x + 36, panel_y + 58, {
        color = "text_primary",
    })
    Components.text(I18n.t("cards_sacrificed") .. ": " .. (stats.sacrifices or 0), panel_x + 36, panel_y + 88, {
        color = "text_primary",
    })
    Components.text(I18n.t("gold") .. ": " .. Save.get_coins(), panel_x + 36, panel_y + 118, {
        color = "accent_gold",
    })

    Components.text("SPACE: " .. I18n.t("start_game") .. "  |  ESC: " .. I18n.t("main_menu"),
        win_w / 2, win_h * 0.75, {
        color = "text_hint",
        align = "center",
    })
end

function Victory.keypressed(key)
    if key == "space" then
        Sound.play("click")
        State.switch("menu")
    elseif key == "escape" then
        Sound.play("click")
        State.switch("menu")
    end
end

return Victory
