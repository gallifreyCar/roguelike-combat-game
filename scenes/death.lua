-- scenes/death.lua - 死亡结算场景
-- 显示死亡统计，允许重新开始或返回菜单

local Death = {}
local State = require("core.state")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Fonts = require("core.fonts")
local Sound = require("systems.sound")
local Animation = require("systems.animation")
local Save = require("systems.save")
local Map = require("systems.map")
local Deck = require("systems.deck")
local FusionSystem = require("systems.fusion")
local MetaProgression = require("systems.meta_progression")

-- 死亡统计
local death_stats = {}

function Death.enter()
    -- 收集统计数据
    local stats = Save.get_stats and Save.get_stats() or {}
    local player = Save.get_player and Save.get_player() or {}

    death_stats = {
        floor = Map.get_current_row and Map.get_current_row() or 1,
        battles = stats.battles_won or 0,
        enemies = stats.enemies_defeated or 0,
        sacrifices = stats.sacrifices or 0,
        cards_played = stats.cards_played or 0,
        deck_size = #(Deck.get_deck and Deck.get_deck() or {}),
    }
end

function Death.exit()
end

function Death.update(dt)
end

function Death.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 暗红色背景叠加
    love.graphics.setColor(0.15, 0.05, 0.05, 0.8)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    -- 标题
    Components.text(I18n.t("you_died") or "YOU DIED", win_w / 2, 80, {
        color = "accent_red",
        size = 36,
        align = "center",
    })

    -- 统计面板
    local panel_w = 300
    local panel_h = 250
    local panel_x = (win_w - panel_w) / 2
    local panel_y = 150

    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 10, 10)
    Theme.setColor("accent_red", 0.5)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 10, 10)

    -- 统计标题
    Components.text(I18n.t("run_statistics") or "Run Statistics", win_w / 2, panel_y + 15, {
        color = "text_secondary",
        align = "center",
    })

    -- 统计数据（使用i18n）
    local stats_display = {
        {label = I18n.t("floor_reached") or "Floor Reached", value = death_stats.floor},
        {label = I18n.t("battles_won") or "Battles Won", value = death_stats.battles},
        {label = I18n.t("enemies_defeated") or "Enemies Defeated", value = death_stats.enemies},
        {label = I18n.t("cards_sacrificed") or "Cards Sacrificed", value = death_stats.sacrifices},
        {label = I18n.t("deck_size") or "Deck Size", value = death_stats.deck_size},
    }

    local stat_y = panel_y + 45
    for _, stat in ipairs(stats_display) do
        Components.text(stat.label, panel_x + 20, stat_y, {
            color = "text_secondary",
            size = 13,
        })
        Components.text(tostring(stat.value), panel_x + panel_w - 50, stat_y, {
            color = "text_primary",
            size = 13,
        })
        stat_y = stat_y + 35
    end

    -- 按钮区域
    local btn_y = win_h - 120
    local btn_w = 180
    local btn_h = 45
    local btn_gap = 30

    -- 重新开始按钮
    local restart_x = win_w / 2 - btn_w - btn_gap / 2
    local mx, my = love.mouse.getPosition()
    local restart_hover = mx >= restart_x and mx <= restart_x + btn_w and my >= btn_y and my <= btn_y + btn_h

    Theme.setColor(restart_hover and "accent_gold" or "bg_slot", restart_hover and 0.4 or 1)
    love.graphics.rectangle("fill", restart_x, btn_y, btn_w, btn_h, 8, 8)
    Theme.setColor(restart_hover and "border_glow" or "border_normal")
    love.graphics.rectangle("line", restart_x, btn_y, btn_w, btn_h, 8, 8)
    Components.text(I18n.t("try_again") or "Try Again", restart_x + btn_w / 2, btn_y + 12, {
        color = restart_hover and "text_value" or "text_primary",
        align = "center",
    })
    Fonts.print("[Space]", restart_x + btn_w / 2 - 20, btn_y + 30, 10)

    -- 返回菜单按钮
    local menu_x = win_w / 2 + btn_gap / 2
    local menu_hover = mx >= menu_x and mx <= menu_x + btn_w and my >= btn_y and my <= btn_y + btn_h

    Theme.setColor(menu_hover and "accent_blue" or "bg_slot", menu_hover and 0.4 or 1)
    love.graphics.rectangle("fill", menu_x, btn_y, btn_w, btn_h, 8, 8)
    Theme.setColor(menu_hover and "border_glow" or "border_normal")
    love.graphics.rectangle("line", menu_x, btn_y, btn_w, btn_h, 8, 8)
    Components.text(I18n.t("main_menu") or "Main Menu", menu_x + btn_w / 2, btn_y + 12, {
        color = menu_hover and "text_value" or "text_primary",
        align = "center",
    })
    Fonts.print("[ESC]", menu_x + btn_w / 2 - 15, btn_y + 30, 10)
end

-- 重置游戏状态
local function reset_game()
    -- 重置地图
    if Map.reset then Map.reset() end

    -- 重置牌组
    if Deck.reset then Deck.reset() end

    -- 重置融合计数
    if FusionSystem.reset_fusion_count then FusionSystem.reset_fusion_count() end

    -- 重置存档统计
    if Save.reset_stats then Save.reset_stats() end
end

local function start_new_run()
    reset_game()

    MetaProgression.init()
    local bonuses = MetaProgression.get_starting_bonuses()
    local base_gold = 50
    Save.set_coins(base_gold + bonuses.gold_bonus)
    Deck.set_meta_bonuses(bonuses)
    Map.generate()
    Deck.reset()

    Animation.fade_out(0.2, function()
        State.switch("map")
    end)
end

function Death.keypressed(key)
    if key == "space" then
        Sound.play("click")
        start_new_run()
    elseif key == "escape" then
        Sound.play("click")
        reset_game()
        Animation.fade_out(0.2, function()
            State.switch("menu")
        end)
    end
end

function Death.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()
    local btn_y = win_h - 120
    local btn_w = 180
    local btn_h = 45
    local btn_gap = 30

    -- 重新开始
    local restart_x = win_w / 2 - btn_w - btn_gap / 2
    if x >= restart_x and x <= restart_x + btn_w and y >= btn_y and y <= btn_y + btn_h then
        Sound.play("click")
        start_new_run()
        return
    end

    -- 返回菜单
    local menu_x = win_w / 2 + btn_gap / 2
    if x >= menu_x and x <= menu_x + btn_w and y >= btn_y and y <= btn_y + btn_h then
        Sound.play("click")
        reset_game()
        Animation.fade_out(0.2, function()
            State.switch("menu")
        end)
        return
    end
end

return Death
