-- scenes/progression.lua - 局外成长中心
-- 显示永久升级、解锁内容、统计数据

local Progression = {}
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local MetaProgression = require("systems.meta_progression")
local Sound = require("systems.sound")

local buttons = {}
local selected_upgrade = nil
local scroll_offset = 0

function Progression.enter()
    -- 初始化 meta progression
    MetaProgression.init()

    -- 计算按钮位置
    local win_w, win_h = Layout.get_size()
    local btn_w = 200
    local btn_h = 40
    local btn_x = win_w / 2 - btn_w / 2

    buttons = {
        back = {x = btn_x, y = win_h - 80, width = btn_w, height = btn_h},
    }

    selected_upgrade = nil
    scroll_offset = 0
end

function Progression.exit()
end

function Progression.update(dt)
end

function Progression.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text("META PROGRESSION", win_w / 2, 30, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 解锁点数显示
    local points = MetaProgression.get_points()
    Components.text("Unlock Points: " .. points, win_w / 2, 60, {
        color = "accent_blue",
        size = 18,
        align = "center",
    })

    -- 绘制各个面板
    Progression.draw_stats_panel(win_w, win_h)
    Progression.draw_upgrades_panel(win_w, win_h)
    Progression.draw_unlocks_panel(win_w, win_h)

    -- 返回按钮
    local back_hover = Layout.mouse_in_button(buttons.back)
    Components.button(I18n.t("back"), buttons.back.x, buttons.back.y,
                      buttons.back.width, buttons.back.height, {
        hover = back_hover,
    })

    -- 操作提示
    Components.text("Click upgrades to purchase | ESC to return", win_w / 2, win_h - 30, {
        color = "text_hint",
        align = "center",
    })
end

function Progression.draw_stats_panel(win_w, win_h)
    local panel_x = 40
    local panel_y = 90
    local panel_w = 250
    local panel_h = 140

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("STATISTICS", panel_x + panel_w / 2, panel_y + 15, {
        color = "accent_gold",
        size = 14,
        align = "center",
    })

    local stats = MetaProgression.get_stats()
    local stats_y = panel_y + 40

    Components.text("Total Runs: " .. stats.total_runs, panel_x + 15, stats_y, {
        color = "text_primary",
    })
    Components.text("Wins: " .. stats.wins, panel_x + 15, stats_y + 25, {
        color = "accent_green",
    })
    Components.text("Losses: " .. stats.losses, panel_x + 15, stats_y + 50, {
        color = "accent_red",
    })
    Components.text("Best Streak: " .. stats.best_streak, panel_x + 15, stats_y + 75, {
        color = "text_primary",
    })
    Components.text("Player Level: " .. stats.level, panel_x + 15, stats_y + 100, {
        color = "accent_gold",
    })
end

function Progression.draw_upgrades_panel(win_w, win_h)
    local panel_x = 310
    local panel_y = 90
    local panel_w = 350
    local panel_h = 300

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("UPGRADES", panel_x + panel_w / 2, panel_y + 15, {
        color = "accent_gold",
        size = 14,
        align = "center",
    })

    local upgrades = MetaProgression.get_upgrades()
    local upgrade_y = panel_y + 45
    local row_height = 50
    local current_points = MetaProgression.get_points()

    local i = 0
    for upgrade_id, upgrade in pairs(upgrades) do
        i = i + 1
        if i > 5 then break end  -- 最多显示5个升级

        local current_level = MetaProgression.get_upgrade_level(upgrade_id)
        local cost, err = MetaProgression.get_upgrade_cost(upgrade_id, current_level)
        local can_purchase = cost and current_points >= cost

        -- 绘制升级条目
        local row_x = panel_x + 15

        -- 名称和等级
        local level_text = current_level > 0 and (" Lv." .. current_level) or ""
        Components.text(upgrade.name .. level_text, row_x, upgrade_y, {
            color = current_level > 0 and "accent_green" or "text_primary",
        })

        -- 描述
        Components.text(upgrade.desc, row_x, upgrade_y + 20, {
            color = "text_hint",
            size = 12,
        })

        -- 购买按钮/状态
        local btn_w = 80
        local btn_h = 30
        local btn_x = panel_x + panel_w - btn_w - 15
        local btn_y = upgrade_y + 5

        if current_level >= upgrade.max_level then
            Components.text("MAXED", btn_x + btn_w / 2, btn_y + 8, {
                color = "accent_gold",
                align = "center",
            })
        else
            local btn_hover = Layout.mouse_in_rect(btn_x, btn_y, btn_w, btn_h)
            local btn_color = can_purchase and "accent_green" or "text_disabled"

            Theme.setColor(btn_color, btn_hover and 1.0 or 0.8)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 4, 4)

            Components.text(cost .. " PTS", btn_x + btn_w / 2, btn_y + 8, {
                color = "text_primary",
                align = "center",
                size = 12,
            })

            -- 存储按钮位置用于点击检测
            buttons[upgrade_id] = {x = btn_x, y = btn_y, width = btn_w, height = btn_h}
        end

        upgrade_y = upgrade_y + row_height
    end
end

function Progression.draw_unlocks_panel(win_w, win_h)
    local panel_x = 680
    local panel_y = 90
    local panel_w = 250
    local panel_h = 200

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("UNLOCKS", panel_x + panel_w / 2, panel_y + 15, {
        color = "accent_gold",
        size = 14,
        align = "center",
    })

    -- 已解锁卡牌
    local unlocked_cards = MetaProgression.get_unlocked_cards()
    local unlock_y = panel_y + 40

    Components.text("Cards (" .. #unlocked_cards .. ")", panel_x + 15, unlock_y, {
        color = "text_secondary",
    })

    unlock_y = unlock_y + 25
    for i, card_id in ipairs(unlocked_cards) do
        if i > 3 then
            Components.text("...", panel_x + 15, unlock_y, {
                color = "text_hint",
            })
            break
        end
        Components.text(card_id, panel_x + 15, unlock_y, {
            color = "text_primary",
        })
        unlock_y = unlock_y + 20
    end

    -- 解锁的功能
    local features = MetaProgression.is_feature_unlocked("hard_mode")
    unlock_y = unlock_y + 10

    Components.text("Features", panel_x + 15, unlock_y, {
        color = "text_secondary",
    })

    unlock_y = unlock_y + 25
    if features then
        Components.text("Hard Mode", panel_x + 15, unlock_y, {
            color = "accent_green",
        })
    else
        Components.text("Hard Mode (5 wins)", panel_x + 15, unlock_y, {
            color = "text_hint",
        })
    end
end

function Progression.keypressed(key)
    if key == "escape" then
        State.pop()
    end
end

function Progression.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 返回按钮
    if Layout.mouse_in_button(buttons.back) then
        Sound.play("click")
        State.pop()
        return
    end

    -- 检查升级购买按钮
    local upgrades = MetaProgression.get_upgrades()
    for upgrade_id, _ in pairs(upgrades) do
        local btn = buttons[upgrade_id]
        if btn and Layout.mouse_in_rect(btn.x, btn.y, btn.width, btn.height) then
            local success, msg = MetaProgression.purchase_upgrade(upgrade_id)
            if success then
                Sound.play("purchase")
            else
                Sound.play("error")
            end
            return
        end
    end
end

return Progression