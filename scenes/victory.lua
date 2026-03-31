-- scenes/victory.lua - 通关结算场景
-- 显示通关奖励、解锁内容、统计数据、局外成长

local Victory = {}
local State = require("core.state")
local Map = require("systems.map")
local Deck = require("systems.deck")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Save = require("systems.save")
local Sound = require("systems.sound")
local MetaProgression = require("systems.meta_progression")

local rewards = { gold = 0, exp = 0, points = 0, unlocks = {}, leveled_up = false, new_level = 1 }
local continue_timer = 0

function Victory.enter()
    rewards = { gold = 0, exp = 0, points = 0, unlocks = {}, leveled_up = false, new_level = 1 }
    continue_timer = 0

    -- 初始化 meta progression
    MetaProgression.init()

    -- 收集本次运行的统计数据
    local stats = Save.get_data().stats or {}
    local run_stats = {
        battles_won = stats.battles_won or 0,
        cards_played = stats.cards_played or 0,
        no_deaths = Save.get_data().player and Save.get_data().player.hp > 0,
    }

    -- 通过 MetaProgression 处理胜利
    rewards = MetaProgression.process_victory(run_stats)

    -- 计算金币奖励（应用金币倍率）
    local base_gold = 50
    local current_gold = Save.get_coins()
    local gold_multiplier = MetaProgression.get_gold_multiplier()
    rewards.gold = math.floor((base_gold + math.floor(current_gold * 0.5)) * gold_multiplier)

    -- 添加金币
    Save.add_coins(rewards.gold)

    -- 播放胜利音效
    Sound.play("victory")
end

function Victory.exit()
end

function Victory.update(dt)
    continue_timer = continue_timer + dt
end

function Victory.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题（响应式）
    Components.text(I18n.t("victory_title"), win_w / 2, win_h * 0.06, {
        color = "accent_gold",
        size = 36,
        align = "center",
    })

    -- 统计面板
    Victory.draw_stats_panel(win_w, win_h)

    -- 奖励面板
    Victory.draw_rewards_panel(win_w, win_h)

    -- 解锁面板
    if #rewards.unlocks > 0 then
        Victory.draw_unlocks_panel(win_w, win_h)
    end

    -- 升级提示（响应式）
    if rewards.leveled_up then
        Components.text("LEVEL UP! Now Level " .. rewards.new_level, win_w / 2, win_h * 0.82, {
            color = "accent_gold",
            size = 20,
            align = "center",
        })
    end

    -- 继续提示（响应式）
    if continue_timer > 1 then
        Components.text("[SPACE] " .. I18n.t("continue_btn"), win_w / 2, win_h * 0.90, {
            color = "text_hint",
            align = "center",
        })
    end
end

function Victory.draw_stats_panel(win_w, win_h)
    local panel_w = math.min(360, win_w * 0.8)
    local panel_x = (win_w - panel_w) / 2
    local panel_y = win_h * 0.12
    local panel_h = win_h * 0.18

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("RUN STATISTICS", panel_x + panel_w / 2, panel_y + 15, {
        color = "text_secondary",
        size = 16,
        align = "center",
    })

    local stats_y = panel_y + 50
    local stats = Save.get_data().stats or {}

    Components.text("Battles Won: " .. (stats.battles_won or 0), panel_x + 30, stats_y, {
        color = "text_primary",
    })
    Components.text("Cards Played: " .. (stats.cards_played or 0), panel_x + panel_w - 150, stats_y, {
        color = "text_primary",
    })
    Components.text("Enemies Defeated: " .. (stats.enemies_defeated or 0), panel_x + 30, stats_y + 30, {
        color = "text_primary",
    })

    -- 等级显示
    Components.text("Player Level: " .. rewards.new_level, panel_x + panel_w - 150, stats_y + 30, {
        color = "accent_gold",
    })
end

function Victory.draw_rewards_panel(win_w, win_h)
    local panel_w = math.min(360, win_w * 0.8)
    local panel_x = (win_w - panel_w) / 2
    local panel_y = win_h * 0.32
    local panel_h = win_h * 0.14

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("REWARDS", panel_x + panel_w / 2, panel_y + 15, {
        color = "accent_gold",
        size = 16,
        align = "center",
    })

    local reward_y = panel_y + 50

    -- 金币奖励
    Components.text(I18n.t("gold") .. ": +" .. rewards.gold, panel_x + 30, reward_y, {
        color = "accent_gold",
    })

    -- 经验奖励
    Components.text("EXP: +" .. rewards.exp, panel_x + panel_w / 2 - 30, reward_y, {
        color = "accent_green",
    })

    -- 解锁点数
    Components.text("Points: +" .. rewards.points, panel_x + panel_w - 100, reward_y, {
        color = "accent_blue",
    })
end

function Victory.draw_unlocks_panel(win_w, win_h)
    local panel_w = math.min(360, win_w * 0.8)
    local panel_x = (win_w - panel_w) / 2
    local panel_y = win_h * 0.48
    local panel_h = 30 + #rewards.unlocks * 30

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("NEW UNLOCKS!", panel_x + panel_w / 2, panel_y + 12, {
        color = "accent_gold",
        size = 14,
        align = "center",
    })

    for i, unlock in ipairs(rewards.unlocks) do
        local icon = unlock.type == "card" and "[CARD]" or
                     unlock.type == "sigil" and "[SIGIL]" or "[NEW!]"
        Components.text(icon .. " " .. unlock.name, panel_x + 30, panel_y + 35 + (i - 1) * 25, {
            color = "text_primary",
        })
    end
end

function Victory.keypressed(key)
    if continue_timer > 1 then
        if key == "space" or key == "return" then
            -- 重置游戏状态，返回主菜单
            Map.reset()
            Deck.reset()
            local FusionSystem = require("systems.fusion")
            FusionSystem.reset_fusion_count()
            State.switch("menu")
        end
    end
end

function Victory.mousepressed(x, y, button)
    if continue_timer > 1 and button == 1 then
        Map.reset()
        Deck.reset()
        local FusionSystem = require("systems.fusion")
        FusionSystem.reset_fusion_count()
        State.switch("menu")
    end
end

return Victory