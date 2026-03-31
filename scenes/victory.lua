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

local rewards = { gold = 0, exp = 0, unlock_points = 0 }
local unlocks = {}
local player_level = 1
local leveled_up = false
local continue_timer = 0

function Victory.enter()
    rewards = { gold = 0, exp = 0, unlock_points = 0 }
    unlocks = {}
    leveled_up = false
    continue_timer = 0

    -- 计算通关奖励
    local base_gold = 50
    local current_gold = Save.get_coins()
    rewards.gold = base_gold + math.floor(current_gold * 0.5)  -- 基础奖励 + 50%当前金币

    -- 计算经验
    local base_exp = 100
    local stats = Save.get_data().stats or {}
    local battles_bonus = (stats.battles_won or 0) * 10
    rewards.exp = base_exp + battles_bonus

    -- 解锁点数
    rewards.unlock_points = 1

    -- 检查升级和解锁
    Victory.process_progress(rewards)

    -- 播放胜利音效
    Sound.play("victory")
end

function Victory.process_progress(rewards)
    local data = Save.get_data()
    if not data.progress then
        data.progress = {
            total_runs = 0,
            total_exp = 0,
            level = 1,
            unlocks = {},
        }
    end

    local old_level = data.progress.level

    data.progress.total_runs = (data.progress.total_runs or 0) + 1
    data.progress.total_exp = (data.progress.total_exp or 0) + rewards.exp

    -- 升级检查
    local exp_needed = data.progress.level * 100
    while data.progress.total_exp >= exp_needed do
        data.progress.total_exp = data.progress.total_exp - exp_needed
        data.progress.level = data.progress.level + 1
        exp_needed = data.progress.level * 100
    end

    player_level = data.progress.level
    leveled_up = data.progress.level > old_level

    -- 检查解锁
    unlocks = Victory.check_unlocks(data.progress)

    -- 保存解锁
    for _, unlock in ipairs(unlocks) do
        table.insert(data.progress.unlocks, unlock)
    end

    -- 保存
    Save.add_coins(rewards.gold)
end

function Victory.check_unlocks(progress)
    local unlocked = {}
    local runs = progress.total_runs or 0

    -- 首次通关解锁
    if runs == 1 then
        table.insert(unlocked, {
            type = "card",
            id = "guardian_dog",
            name = "Guardian Dog",
            desc = "A loyal protector",
        })
    end

    -- 3次通关解锁印记
    if runs == 3 then
        table.insert(unlocked, {
            type = "sigil",
            id = "vampire",
            name = "Vampire",
            desc = "Heals on kill",
        })
    end

    -- 5次通关解锁新角色槽
    if runs == 5 then
        table.insert(unlocked, {
            type = "feature",
            id = "hard_mode",
            name = "Hard Mode",
            desc = "Increased challenge",
        })
    end

    return unlocked
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

    -- 标题
    Components.text(I18n.t("victory_title"), win_w / 2, 40, {
        color = "accent_gold",
        size = 36,
        align = "center",
    })

    -- 统计面板
    Victory.draw_stats_panel(win_w, win_h)

    -- 奖励面板
    Victory.draw_rewards_panel(win_w, win_h)

    -- 解锁面板
    if #unlocks > 0 then
        Victory.draw_unlocks_panel(win_w, win_h)
    end

    -- 升级提示
    if leveled_up then
        Components.text("LEVEL UP! Now Level " .. player_level, win_w / 2, win_h - 120, {
            color = "accent_gold",
            size = 20,
            align = "center",
        })
    end

    -- 继续提示
    if continue_timer > 1 then
        Components.text("[SPACE] " .. I18n.t("continue_btn"), win_w / 2, win_h - 50, {
            color = "text_hint",
            align = "center",
        })
    end
end

function Victory.draw_stats_panel(win_w, win_h)
    local panel_x = win_w / 2 - 180
    local panel_y = 100
    local panel_w = 360
    local panel_h = 130

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
    Components.text("Cards Played: " .. (stats.cards_played or 0), panel_x + 200, stats_y, {
        color = "text_primary",
    })
    Components.text("Enemies Defeated: " .. (stats.enemies_defeated or 0), panel_x + 30, stats_y + 30, {
        color = "text_primary",
    })

    -- 等级显示
    Components.text("Player Level: " .. player_level, panel_x + 200, stats_y + 30, {
        color = "accent_gold",
    })
end

function Victory.draw_rewards_panel(win_w, win_h)
    local panel_x = win_w / 2 - 180
    local panel_y = 250
    local panel_w = 360
    local panel_h = 100

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
    Components.text("EXP: +" .. rewards.exp, panel_x + 150, reward_y, {
        color = "accent_green",
    })

    -- 解锁点数
    Components.text("Unlock: +" .. rewards.unlock_points, panel_x + 270, reward_y, {
        color = "accent_blue",
    })
end

function Victory.draw_unlocks_panel(win_w, win_h)
    local panel_x = win_w / 2 - 180
    local panel_y = 370
    local panel_w = 360
    local panel_h = 30 + #unlocks * 30

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    Components.text("NEW UNLOCKS!", panel_x + panel_w / 2, panel_y + 12, {
        color = "accent_gold",
        size = 14,
        align = "center",
    })

    for i, unlock in ipairs(unlocks) do
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
            State.switch("menu")
        end
    end
end

function Victory.mousepressed(x, y, button)
    if continue_timer > 1 and button == 1 then
        Map.reset()
        Deck.reset()
        State.switch("menu")
    end
end

return Victory