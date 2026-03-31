-- systems/achievements.lua - 成就系统
-- 定义成就、检查解锁条件、显示成就通知、与存档系统集成

local Achievements = {}

-- 导入依赖
local Events = require("core.events")
local Save = require("systems.save")
local Sound = require("systems.sound")

-- ==================== 成就定义 ====================
-- 成就分类: combat(战斗), cards(牌组), fusion(融合), progression(进度), special(特殊)

local ACHIEVEMENTS = {
    -- ========== 战斗成就 ==========
    first_blood = {
        id = "first_blood",
        name = "First Blood",
        desc = "Win your first battle",
        icon = "*",
        category = "combat",
        unlocked = false,
        hidden = false,
    },
    veteran = {
        id = "veteran",
        name = "Veteran",
        desc = "Win 10 battles",
        icon = "**",
        category = "combat",
        unlocked = false,
        hidden = false,
        progress_target = 10,
    },
    slayer = {
        id = "slayer",
        name = "Slayer",
        desc = "Defeat 50 enemies",
        icon = "***",
        category = "combat",
        unlocked = false,
        hidden = false,
        progress_target = 50,
    },
    warlord = {
        id = "warlord",
        name = "Warlord",
        desc = "Defeat 200 enemies",
        icon = "****",
        category = "combat",
        unlocked = false,
        hidden = false,
        progress_target = 200,
    },
    perfect_run = {
        id = "perfect_run",
        name = "Perfect Run",
        desc = "Win a battle without losing any cards",
        icon = "P",
        category = "combat",
        unlocked = false,
        hidden = false,
    },
    bloodless_victory = {
        id = "bloodless_victory",
        name = "Bloodless Victory",
        desc = "Win the game without sacrificing any cards",
        icon = "B",
        category = "special",
        unlocked = false,
        hidden = true,  -- 隐藏成就
    },
    comeback_king = {
        id = "comeback_king",
        name = "Comeback King",
        desc = "Win a battle with 1 HP remaining",
        icon = "C",
        category = "combat",
        unlocked = false,
        hidden = false,
    },
    speed_demon = {
        id = "speed_demon",
        name = "Speed Demon",
        desc = "Complete a battle in 2 turns or less",
        icon = "S",
        category = "combat",
        unlocked = false,
        hidden = false,
    },

    -- ========== 牌组成就 ==========
    collector = {
        id = "collector",
        name = "Collector",
        desc = "Have 20 cards in your deck",
        icon = "[D]",
        category = "cards",
        unlocked = false,
        hidden = false,
        progress_target = 20,
    },
    card_master = {
        id = "card_master",
        name = "Card Master",
        desc = "Collect 30 different card types",
        icon = "[M]",
        category = "cards",
        unlocked = false,
        hidden = false,
        progress_target = 30,
    },
    rare_finder = {
        id = "rare_finder",
        name = "Rare Finder",
        desc = "Obtain 5 rare cards",
        icon = "[R]",
        category = "cards",
        unlocked = false,
        hidden = false,
        progress_target = 5,
    },
    deck_full = {
        id = "deck_full",
        name = "Full Deck",
        desc = "Have 40 cards in your deck",
        icon = "[F]",
        category = "cards",
        unlocked = false,
        hidden = false,
        progress_target = 40,
    },

    -- ========== 融合成就 ==========
    fusion_novice = {
        id = "fusion_novice",
        name = "Fusion Novice",
        desc = "Complete your first fusion",
        icon = "[F1]",
        category = "fusion",
        unlocked = false,
        hidden = false,
    },
    fusion_expert = {
        id = "fusion_expert",
        name = "Fusion Expert",
        desc = "Complete 20 fusions",
        icon = "[F20]",
        category = "fusion",
        unlocked = false,
        hidden = false,
        progress_target = 20,
    },
    fusion_master = {
        id = "fusion_master",
        name = "Fusion Master",
        desc = "Complete 50 fusions",
        icon = "[F50]",
        category = "fusion",
        unlocked = false,
        hidden = false,
        progress_target = 50,
    },
    dice_lucky = {
        id = "dice_lucky",
        name = "Lucky Roller",
        desc = "Succeed in 5 dice fusions",
        icon = "[DICE]",
        category = "fusion",
        unlocked = false,
        hidden = false,
        progress_target = 5,
    },
    mutation_positive = {
        id = "mutation_positive",
        name = "Beneficial Mutation",
        desc = "Get a positive mutation from free fusion",
        icon = "[M+]",
        category = "fusion",
        unlocked = false,
        hidden = false,
    },

    -- ========== 进度成就 ==========
    explorer = {
        id = "explorer",
        name = "Explorer",
        desc = "Complete 5 map floors",
        icon = "[M]",
        category = "progression",
        unlocked = false,
        hidden = false,
        progress_target = 5,
    },
    boss_slayer = {
        id = "boss_slayer",
        name = "Boss Slayer",
        desc = "Defeat the final boss",
        icon = "[B]",
        category = "progression",
        unlocked = false,
        hidden = false,
    },
    first_win = {
        id = "first_win",
        name = "First Victory",
        desc = "Complete your first full run",
        icon = "[V1]",
        category = "progression",
        unlocked = false,
        hidden = false,
    },
    victory_5 = {
        id = "victory_5",
        name = "Five Wins",
        desc = "Complete 5 full runs",
        icon = "[V5]",
        category = "progression",
        unlocked = false,
        hidden = false,
        progress_target = 5,
    },
    victory_10 = {
        id = "victory_10",
        name = "Ten Wins",
        desc = "Complete 10 full runs",
        icon = "[V10]",
        category = "progression",
        unlocked = false,
        hidden = false,
        progress_target = 10,
    },
    streak_3 = {
        id = "streak_3",
        name = "Hot Streak",
        desc = "Win 3 runs in a row",
        icon = "[S3]",
        category = "progression",
        unlocked = false,
        hidden = false,
        progress_target = 3,
    },

    -- ========== 特殊成就 ==========
    sacrifice_king = {
        id = "sacrifice_king",
        name = "Sacrifice King",
        desc = "Sacrifice 10 cards in one run",
        icon = "SK",
        category = "special",
        unlocked = false,
        hidden = false,
    },
    no_damage_win = {
        id = "no_damage_win",
        name = "Untouchable",
        desc = "Win a run without taking any player damage",
        icon = "U",
        category = "special",
        unlocked = false,
        hidden = true,
    },
    hard_mode_win = {
        id = "hard_mode_win",
        name = "Hard Mode Champion",
        desc = "Win on hard mode",
        icon = "H",
        category = "special",
        unlocked = false,
        hidden = true,
    },
    lucky_start = {
        id = "lucky_start",
        name = "Lucky Start",
        desc = "Start with a rare card and win the run",
        icon = "L",
        category = "special",
        unlocked = false,
        hidden = false,
    },
}

-- ==================== 统计数据 ====================
-- 用于追踪成就进度

local stats = {
    -- 战斗统计
    battles_won = 0,          -- 胜利战斗次数
    enemies_defeated = 0,     -- 击杀敌人总数
    turns_in_battle = 0,      -- 当前战斗回合数
    cards_lost_in_run = 0,    -- 本次run中损失的卡牌数
    sacrifices_in_run = 0,    -- 本次run中献祭次数
    player_damage_in_run = 0, -- 本次run中受到的伤害

    -- 牌组统计
    cards_in_deck = 0,        -- 当前牌组大小
    unique_cards_owned = 0,   -- 拥有的不同卡牌类型
    rare_cards_owned = 0,     -- 拥有的稀有卡牌数

    -- 融合统计
    total_fusions = 0,        -- 总融合次数
    dice_fusions_success = 0, -- 骰子融合成功次数
    positive_mutations = 0,   -- 正面变异次数

    -- 进度统计
    floors_completed = 0,     -- 完成的层数
    runs_completed = 0,       -- 通关次数
    current_streak = 0,       -- 当前连胜
    best_streak = 0,          -- 最佳连胜

    -- 特殊条件
    used_sacrifice_in_run = false,  -- 本次run是否使用了献祭
    started_with_rare = false,      -- 是否以稀有卡牌开始
    won_battle_no_card_loss = false, -- 是否无卡牌损失胜利
    hp_at_battle_end = 0,           -- 战斗结束时HP
}

-- 成就通知队列
local notification_queue = {}
local notification_current = nil
local notification_timer = 0
local NOTIFICATION_DURATION = 3.0

-- ==================== 初始化 ====================

function Achievements.init()
    -- 从存档加载成就
    Achievements.load()

    -- 订阅事件
    Achievements.subscribe_events()

    -- 成就系统已初始化（静默模式）
end

-- 订阅游戏事件
function Achievements.subscribe_events()
    -- 战斗事件
    Events.on(Events.BATTLE_END, function(won, enemy_hp, player_hp, turns)
        Achievements.on_battle_end(won, enemy_hp, player_hp, turns)
    end)

    Events.on(Events.CARD_DIED, function(card_id, is_player)
        if is_player then
            stats.cards_lost_in_run = stats.cards_lost_in_run + 1
        end
    end)

    Events.on(Events.DAMAGE_TAKEN, function(amount)
        stats.player_damage_in_run = stats.player_damage_in_run + amount
    end)

    -- 新增事件：击杀敌人
    Events.on("enemy_killed", function()
        stats.enemies_defeated = stats.enemies_defeated + 1
        Achievements.check_progress_achievements()
    end)

    -- 牌组事件
    Events.on("deck_size_changed", function(size)
        stats.cards_in_deck = size
        Achievements.check_progress_achievements()
    end)

    Events.on("card_added", function(card_id, rarity)
        Achievements.track_unique_card(card_id, rarity)
        Achievements.check_progress_achievements()
    end)

    -- 融合事件
    Events.on("fusion_complete", function(result_card, fusion_type, success, mutation_type)
        Achievements.on_fusion_complete(fusion_type, success, mutation_type)
    end)

    -- 献祭事件
    Events.on("sacrifice", function(card_id)
        stats.sacrifices_in_run = stats.sacrifices_in_run + 1
        stats.used_sacrifice_in_run = true
        Achievements.check_progress_achievements()
    end)

    -- 通关事件
    Events.on("run_complete", function(won, stats_data)
        Achievements.on_run_complete(won, stats_data)
    end)

    -- 层数完成事件
    Events.on("floor_complete", function(floor)
        stats.floors_completed = math.max(stats.floors_completed, floor)
        Achievements.check_progress_achievements()
    end)
end

-- ==================== 存档集成 ====================

function Achievements.save()
    local save_data = Save.get_data()
    if save_data then
        save_data.achievements = {
            unlocked = {},
            stats = stats,
        }
        for id, ach in pairs(ACHIEVEMENTS) do
            if ach.unlocked then
                save_data.achievements.unlocked[id] = true
            end
        end
        Save.save()
    end
end

function Achievements.load()
    local save_data = Save.get_data()
    if save_data and save_data.achievements then
        -- 恢复解锁状态
        if save_data.achievements.unlocked then
            for id, _ in pairs(save_data.achievements.unlocked) do
                if ACHIEVEMENTS[id] then
                    ACHIEVEMENTS[id].unlocked = true
                end
            end
        end
        -- 恢复统计（部分）
        if save_data.achievements.stats then
            stats.enemies_defeated = save_data.achievements.stats.enemies_defeated or 0
            stats.total_fusions = save_data.achievements.stats.total_fusions or 0
            stats.dice_fusions_success = save_data.achievements.stats.dice_fusions_success or 0
            stats.runs_completed = save_data.achievements.stats.runs_completed or 0
            stats.best_streak = save_data.achievements.stats.best_streak or 0
            stats.unique_cards_owned = save_data.achievements.stats.unique_cards_owned or 0
            stats.rare_cards_owned = save_data.achievements.stats.rare_cards_owned or 0
        end
    end
end

-- ==================== 成就检查 ====================

-- 检查并解锁成就
function Achievements.check_and_unlock(achievement_id)
    local ach = ACHIEVEMENTS[achievement_id]
    if ach and not ach.unlocked then
        ach.unlocked = true
        Achievements.show_notification(ach)
        Achievements.save()
        -- 成已解锁（静默模式）
        return true
    end
    return false
end

-- 检查进度型成就
function Achievements.check_progress_achievements()
    -- 战斗成就
    if stats.battles_won >= 1 then
        Achievements.check_and_unlock("first_blood")
    end
    if stats.battles_won >= 10 then
        Achievements.check_and_unlock("veteran")
    end
    if stats.enemies_defeated >= 50 then
        Achievements.check_and_unlock("slayer")
    end
    if stats.enemies_defeated >= 200 then
        Achievements.check_and_unlock("warlord")
    end

    -- 牌组成就
    if stats.cards_in_deck >= 20 then
        Achievements.check_and_unlock("collector")
    end
    if stats.cards_in_deck >= 40 then
        Achievements.check_and_unlock("deck_full")
    end
    if stats.unique_cards_owned >= 30 then
        Achievements.check_and_unlock("card_master")
    end
    if stats.rare_cards_owned >= 5 then
        Achievements.check_and_unlock("rare_finder")
    end

    -- 融合成就
    if stats.total_fusions >= 1 then
        Achievements.check_and_unlock("fusion_novice")
    end
    if stats.total_fusions >= 20 then
        Achievements.check_and_unlock("fusion_expert")
    end
    if stats.total_fusions >= 50 then
        Achievements.check_and_unlock("fusion_master")
    end
    if stats.dice_fusions_success >= 5 then
        Achievements.check_and_unlock("dice_lucky")
    end

    -- 进度成就
    if stats.floors_completed >= 5 then
        Achievements.check_and_unlock("explorer")
    end
    if stats.runs_completed >= 1 then
        Achievements.check_and_unlock("first_win")
    end
    if stats.runs_completed >= 5 then
        Achievements.check_and_unlock("victory_5")
    end
    if stats.runs_completed >= 10 then
        Achievements.check_and_unlock("victory_10")
    end
    if stats.current_streak >= 3 then
        Achievements.check_and_unlock("streak_3")
    end

    -- 献祭成就
    if stats.sacrifices_in_run >= 10 then
        Achievements.check_and_unlock("sacrifice_king")
    end
end

-- ==================== 事件处理 ====================

-- 战斗结束处理
function Achievements.on_battle_end(won, enemy_hp, player_hp, turns)
    if won then
        stats.battles_won = stats.battles_won + 1

        -- 记录战斗结束时HP
        stats.hp_at_battle_end = player_hp

        -- 检查完美战斗（无卡牌损失）
        if stats.cards_lost_in_run == 0 then
            stats.won_battle_no_card_loss = true
            Achievements.check_and_unlock("perfect_run")
        end

        -- 检查逆转胜利（1HP）
        if player_hp == 1 then
            Achievements.check_and_unlock("comeback_king")
        end

        -- 检查速战速决
        if turns and turns <= 2 then
            Achievements.check_and_unlock("speed_demon")
        end

        Achievements.check_progress_achievements()
    end
end

-- 融合完成处理
function Achievements.on_fusion_complete(fusion_type, success, mutation_type)
    stats.total_fusions = stats.total_fusions + 1

    if fusion_type == "dice" and success then
        stats.dice_fusions_success = stats.dice_fusions_success + 1
    end

    if mutation_type == "positive" then
        stats.positive_mutations = stats.positive_mutations + 1
        Achievements.check_and_unlock("mutation_positive")
    end

    Achievements.check_progress_achievements()
end

-- 通关处理
function Achievements.on_run_complete(won, run_stats)
    if won then
        stats.runs_completed = stats.runs_completed + 1
        stats.current_streak = stats.current_streak + 1
        stats.best_streak = math.max(stats.best_streak, stats.current_streak)

        -- 检查Boss击杀
        Achievements.check_and_unlock("boss_slayer")

        -- 检查无献祭通关
        if not stats.used_sacrifice_in_run then
            Achievements.check_and_unlock("bloodless_victory")
        end

        -- 检查无伤害通关
        if stats.player_damage_in_run == 0 then
            Achievements.check_and_unlock("no_damage_win")
        end

        -- 检查稀有卡牌开局胜利
        if stats.started_with_rare then
            Achievements.check_and_unlock("lucky_start")
        end

        Achievements.check_progress_achievements()
    else
        stats.current_streak = 0
    end

    -- 保存进度
    Achievements.save()
end

-- 追踪唯一卡牌
local owned_cards = {}
function Achievements.track_unique_card(card_id, rarity)
    if not owned_cards[card_id] then
        owned_cards[card_id] = true
        stats.unique_cards_owned = stats.unique_cards_owned + 1
    end
    if rarity == "rare" or rarity == "uncommon" then
        stats.rare_cards_owned = stats.rare_cards_owned + 1
    end
end

-- ==================== 新Run初始化 ====================

function Achievements.start_new_run()
    -- 重置run级统计
    stats.cards_lost_in_run = 0
    stats.sacrifices_in_run = 0
    stats.player_damage_in_run = 0
    stats.used_sacrifice_in_run = false
    stats.won_battle_no_card_loss = false
    stats.hp_at_battle_end = 0
end

function Achievements.set_started_with_rare(value)
    stats.started_with_rare = value
end

-- ==================== 通知系统 ====================

function Achievements.show_notification(achievement)
    table.insert(notification_queue, achievement)
    if not notification_current then
        Achievements.advance_notification()
    end
end

function Achievements.advance_notification()
    if #notification_queue > 0 then
        notification_current = table.remove(notification_queue, 1)
        notification_timer = NOTIFICATION_DURATION
        Sound.play("victory")  -- 成就解锁音效
    else
        notification_current = nil
    end
end

function Achievements.update_notification(dt)
    if notification_current then
        notification_timer = notification_timer - dt
        if notification_timer <= 0 then
            Achievements.advance_notification()
        end
    end
end

function Achievements.draw_notification()
    if not notification_current then return end

    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
    local panel_w = 300
    local panel_h = 60
    local panel_x = win_w / 2 - panel_w / 2
    local panel_y = 50

    -- 动画效果：淡入淡出
    local alpha = math.min(1, notification_timer)
    if notification_timer < 0.5 then
        alpha = notification_timer * 2
    end

    -- 绘制通知面板
    love.graphics.setColor(0.15, 0.12, 0.08, alpha * 0.95)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    love.graphics.setColor(1, 0.8, 0.3, alpha)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 成就图标
    love.graphics.setColor(1, 0.9, 0.6, alpha)
    local Fonts = require("core.fonts")
    Fonts.print(notification_current.icon, panel_x + 15, panel_y + 15, 24)

    -- 成就名称
    love.graphics.setColor(1, 1, 0.8, alpha)
    Fonts.print(notification_current.name, panel_x + 50, panel_y + 12, 18)

    -- 成就描述
    love.graphics.setColor(0.8, 0.7, 0.6, alpha)
    Fonts.print(notification_current.desc, panel_x + 50, panel_y + 32, 12)

    -- 解锁提示
    love.graphics.setColor(1, 0.8, 0.3, alpha)
    Fonts.print("ACHIEVEMENT UNLOCKED!", panel_x + panel_w - 120, panel_y + 8, 10)
end

-- ==================== API ====================

-- 手动更新统计（用于兼容旧代码）
function Achievements.update_stat(stat_name, value)
    stats[stat_name] = (stats[stat_name] or 0) + value
    Achievements.check_progress_achievements()
end

-- 设置统计值
function Achievements.set_stat(stat_name, value)
    stats[stat_name] = value
    Achievements.check_progress_achievements()
end

-- 获取统计
function Achievements.get_stats()
    return stats
end

-- 获取所有成就
function Achievements.get_all()
    return ACHIEVEMENTS
end

-- 获取分类成就
function Achievements.get_by_category(category)
    local result = {}
    for id, ach in pairs(ACHIEVEMENTS) do
        if ach.category == category then
            result[id] = ach
        end
    end
    return result
end

-- 获取所有分类
function Achievements.get_categories()
    return {
        {id = "combat", name = "Combat", icon = "*"},
        {id = "cards", name = "Cards", icon = "[D]"},
        {id = "fusion", name = "Fusion", icon = "[F]"},
        {id = "progression", name = "Progression", icon = "[M]"},
        {id = "special", name = "Special", icon = "?"},
    }
end

-- 获取已解锁成就数量
function Achievements.get_unlocked_count()
    local count = 0
    for _, achievement in pairs(ACHIEVEMENTS) do
        if achievement.unlocked then
            count = count + 1
        end
    end
    return count
end

-- 获取总成就数量（不含隐藏）
function Achievements.get_total_count(include_hidden)
    local count = 0
    for _, achievement in pairs(ACHIEVEMENTS) do
        if include_hidden or not achievement.hidden then
            count = count + 1
        end
    end
    return count
end

-- 解锁特定成就
function Achievements.unlock(achievement_id)
    return Achievements.check_and_unlock(achievement_id)
end

-- 检查成就是否已解锁
function Achievements.is_unlocked(achievement_id)
    return ACHIEVEMENTS[achievement_id] and ACHIEVEMENTS[achievement_id].unlocked
end

-- 获取成就进度
function Achievements.get_progress(achievement_id)
    local ach = ACHIEVEMENTS[achievement_id]
    if not ach or ach.unlocked then return nil end

    if ach.progress_target then
        local current = 0
        -- 根据成就类型确定当前进度
        if achievement_id == "veteran" then current = stats.battles_won
        elseif achievement_id == "slayer" then current = stats.enemies_defeated
        elseif achievement_id == "warlord" then current = stats.enemies_defeated
        elseif achievement_id == "collector" then current = stats.cards_in_deck
        elseif achievement_id == "card_master" then current = stats.unique_cards_owned
        elseif achievement_id == "rare_finder" then current = stats.rare_cards_owned
        elseif achievement_id == "deck_full" then current = stats.cards_in_deck
        elseif achievement_id == "fusion_expert" then current = stats.total_fusions
        elseif achievement_id == "fusion_master" then current = stats.total_fusions
        elseif achievement_id == "dice_lucky" then current = stats.dice_fusions_success
        elseif achievement_id == "explorer" then current = stats.floors_completed
        elseif achievement_id == "victory_5" then current = stats.runs_completed
        elseif achievement_id == "victory_10" then current = stats.runs_completed
        elseif achievement_id == "streak_3" then current = stats.current_streak
        end

        return {
            current = current,
            target = ach.progress_target,
            percentage = math.min(100, math.floor(current / ach.progress_target * 100)),
        }
    end

    return nil  -- 非进度型成就
end

-- 重置成就（调试用）
function Achievements.reset()
    for _, achievement in pairs(ACHIEVEMENTS) do
        achievement.unlocked = false
    end
    stats = {
        battles_won = 0,
        enemies_defeated = 0,
        turns_in_battle = 0,
        cards_lost_in_run = 0,
        sacrifices_in_run = 0,
        player_damage_in_run = 0,
        cards_in_deck = 0,
        unique_cards_owned = 0,
        rare_cards_owned = 0,
        total_fusions = 0,
        dice_fusions_success = 0,
        positive_mutations = 0,
        floors_completed = 0,
        runs_completed = 0,
        current_streak = 0,
        best_streak = 0,
        used_sacrifice_in_run = false,
        started_with_rare = false,
        won_battle_no_card_loss = false,
        hp_at_battle_end = 0,
    }
    owned_cards = {}
    notification_queue = {}
    notification_current = nil
    Achievements.save()
end

return Achievements