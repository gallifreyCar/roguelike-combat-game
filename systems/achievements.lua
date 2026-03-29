-- systems/achievements.lua - 成就系统
-- 定义成就、检查解锁条件、显示成就

local Achievements = {}

-- 成就定义
local ACHIEVEMENTS = {
    -- 战斗成就
    first_blood = {
        name = "First Blood",
        desc = "Win your first battle",
        icon = "*",
        unlocked = false,
    },
    veteran = {
        name = "Veteran",
        desc = "Win 10 battles",
        icon = "**",
        unlocked = false,
    },
    slayer = {
        name = "Slayer",
        desc = "Defeat 50 enemies",
        icon = "***",
        unlocked = false,
    },

    -- 牌组成就
    collector = {
        name = "Collector",
        desc = "Have 20 cards in your deck",
        icon = "[D]",
        unlocked = false,
    },
    fusion_master = {
        name = "Fusion Master",
        desc = "Fuse 5 cards",
        icon = "[F]",
        unlocked = false,
    },

    -- 关卡成就
    explorer = {
        name = "Explorer",
        desc = "Complete 5 map floors",
        icon = "[M]",
        unlocked = false,
    },
    boss_slayer = {
        name = "Boss Slayer",
        desc = "Defeat the final boss",
        icon = "[B]",
        unlocked = false,
    },

    -- 特殊成就
    perfect_run = {
        name = "Perfect Run",
        desc = "Win without taking damage",
        icon = "✨",
        unlocked = false,
    },
    sacrifice_king = {
        name = "Sacrifice King",
        desc = "Sacrifice 10 cards in one run",
        icon = "🔥",
        unlocked = false,
    },
}

-- 统计数据
local stats = {
    battles_won = 0,
    enemies_defeated = 0,
    cards_in_deck = 0,
    cards_fused = 0,
    floors_completed = 0,
    sacrifices = 0,
}

-- 检查成就解锁
local function check_achievements()
    -- 检查战斗成就
    if stats.battles_won >= 1 then
        ACHIEVEMENTS.first_blood.unlocked = true
    end
    if stats.battles_won >= 10 then
        ACHIEVEMENTS.veteran.unlocked = true
    end
    if stats.enemies_defeated >= 50 then
        ACHIEVEMENTS.slayer.unlocked = true
    end

    -- 检查牌组成就
    if stats.cards_in_deck >= 20 then
        ACHIEVEMENTS.collector.unlocked = true
    end
    if stats.cards_fused >= 5 then
        ACHIEVEMENTS.fusion_master.unlocked = true
    end

    -- 检查关卡成就
    if stats.floors_completed >= 5 then
        ACHIEVEMENTS.explorer.unlocked = true
    end
end

-- 更新统计
function Achievements.update_stat(stat_name, value)
    stats[stat_name] = (stats[stat_name] or 0) + value
    check_achievements()
end

-- 设置统计值
function Achievements.set_stat(stat_name, value)
    stats[stat_name] = value
    check_achievements()
end

-- 获取统计
function Achievements.get_stats()
    return stats
end

-- 获取所有成就
function Achievements.get_all()
    return ACHIEVEMENTS
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

-- 获取总成就数量
function Achievements.get_total_count()
    local count = 0
    for _ in pairs(ACHIEVEMENTS) do
        count = count + 1
    end
    return count
end

-- 解锁特定成就
function Achievements.unlock(achievement_id)
    if ACHIEVEMENTS[achievement_id] then
        ACHIEVEMENTS[achievement_id].unlocked = true
        print("Achievement Unlocked: " .. ACHIEVEMENTS[achievement_id].name)
        return true
    end
    return false
end

-- 重置成就
function Achievements.reset()
    for _, achievement in pairs(ACHIEVEMENTS) do
        achievement.unlocked = false
    end
    stats = {
        battles_won = 0,
        enemies_defeated = 0,
        cards_in_deck = 0,
        cards_fused = 0,
        floors_completed = 0,
        sacrifices = 0,
    }
end

return Achievements