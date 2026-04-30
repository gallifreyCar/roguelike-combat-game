-- systems/meta_progression.lua - Meta Progression System
-- Handles permanent upgrades, card unlocks, and run-to-run progression

local MetaProgression = {}

-- Import dependencies
local Save = require("systems.save")
local CardData = require("data.cards")
local Settings = require("config.settings")

-- ==================== CONSTANTS ====================

-- Upgrade definitions
local UPGRADES = {
    hp_boost = {
        id = "hp_boost",
        name = "HP Boost",
        desc = "+2 starting HP per level",
        max_level = 5,
        costs = {1, 2, 3, 4, 5},
        effect_per_level = 2,
    },
    gold_boost = {
        id = "gold_boost",
        name = "Gold Boost",
        desc = "+10 starting gold per level",
        max_level = 5,
        costs = {1, 1, 2, 2, 3},
        effect_per_level = 10,
    },
    blood_boost = {
        id = "blood_boost",
        name = "Blood Boost",
        desc = "+1 starting blood per level",
        max_level = 3,
        costs = {2, 3, 4},
        effect_per_level = 1,
    },
    better_squirrel = {
        id = "better_squirrel",
        name = "Better Squirrel",
        desc = "Squirrels have +1 HP",
        max_level = 1,
        costs = {3},
        effect_per_level = 1,
    },
    starting_rare = {
        id = "starting_rare",
        name = "Starting Rare",
        desc = "Begin with 1 random rare card",
        max_level = 1,
        costs = {5},
        effect_per_level = 1,
    },
    gold_bonus = {
        id = "gold_bonus",
        name = "Gold Bonus",
        desc = "+10% gold from all sources per level",
        max_level = 5,
        costs = {1, 2, 2, 3, 3},
        effect_per_level = 0.1,  -- 10% per level
    },
}

-- Card unlock conditions
local CARD_UNLOCKS = {
    {card_id = "guardian_dog", runs = 1, desc = "Win 1 run"},
    {card_id = "hydra", runs = 3, desc = "Win 3 runs"},
    {card_id = "deathcard", runs = 5, desc = "Win 5 runs"},
}

-- Sigil unlock conditions (future expansion)
local SIGIL_UNLOCKS = {
    {sigil_id = "vampire", runs = 3, desc = "Win 3 runs"},
}

-- Feature unlock conditions
local FEATURE_UNLOCKS = {
    {feature_id = "hard_mode", runs = 5, desc = "Win 5 runs"},
}

-- ==================== INTERNAL STATE ====================

local meta_data = nil

-- ==================== INITIALIZATION ====================

-- Initialize or load meta progression data
function MetaProgression.init()
    meta_data = Save.get_data().progress
    if not meta_data then
        meta_data = MetaProgression.get_default_progress()
        Save.get_data().progress = meta_data
    end

    -- Ensure all required fields exist
    MetaProgression.validate_data()
end

-- Default progress data structure
function MetaProgression.get_default_progress()
    return {
        -- Currency
        unlock_points = 0,
        total_exp = 0,
        level = 1,

        -- Statistics
        total_runs = 0,
        wins = 0,
        losses = 0,
        best_win_streak = 0,
        current_streak = 0,
        fastest_win = nil,

        -- Upgrades (key = upgrade_id, value = level)
        upgrades = {},

        -- Unlocks
        unlocked_cards = {},
        unlocked_sigils = {},
        unlocked_features = {},
    }
end

-- Validate and fix data structure
function MetaProgression.validate_data()
    if not meta_data then return end

    local defaults = MetaProgression.get_default_progress()
    for key, value in pairs(defaults) do
        if meta_data[key] == nil then
            if type(value) == "table" then
                meta_data[key] = {}
            else
                meta_data[key] = value
            end
        end
    end
end

-- ==================== GETTERS ====================

-- Get unlock points
function MetaProgression.get_points()
    return meta_data and meta_data.unlock_points or 0
end

-- Get player level
function MetaProgression.get_level()
    return meta_data and meta_data.level or 1
end

-- Get total wins
function MetaProgression.get_wins()
    return meta_data and meta_data.wins or 0
end

-- Get upgrade level
function MetaProgression.get_upgrade_level(upgrade_id)
    if not meta_data or not meta_data.upgrades then
        return 0
    end
    return meta_data.upgrades[upgrade_id] or 0
end

-- Get total upgrade level across all upgrades
function MetaProgression.get_total_upgrade_level()
    local total = 0
    if meta_data and meta_data.upgrades then
        for _, level in pairs(meta_data.upgrades) do
            total = total + level
        end
    end
    return total
end

-- Check if card is unlocked
function MetaProgression.is_card_unlocked(card_id)
    if not meta_data or not meta_data.unlocked_cards then
        return false
    end
    for _, id in ipairs(meta_data.unlocked_cards) do
        if id == card_id then
            return true
        end
    end
    return false
end

-- Check if feature is unlocked
function MetaProgression.is_feature_unlocked(feature_id)
    if not meta_data or not meta_data.unlocked_features then
        return false
    end
    for _, id in ipairs(meta_data.unlocked_features) do
        if id == feature_id then
            return true
        end
    end
    return false
end

-- Get all upgrades (for UI)
function MetaProgression.get_upgrades()
    return UPGRADES
end

-- Get upgrade info
function MetaProgression.get_upgrade_info(upgrade_id)
    return UPGRADES[upgrade_id]
end

-- Get unlocked cards list
function MetaProgression.get_unlocked_cards()
    return meta_data and meta_data.unlocked_cards or {}
end

-- ==================== BONUS CALCULATIONS ====================

-- Get starting HP bonus
function MetaProgression.get_hp_bonus()
    local level = MetaProgression.get_upgrade_level("hp_boost")
    return level * UPGRADES.hp_boost.effect_per_level
end

-- Get starting gold bonus
function MetaProgression.get_gold_bonus()
    local level = MetaProgression.get_upgrade_level("gold_boost")
    return level * UPGRADES.gold_boost.effect_per_level
end

-- Get starting blood bonus
function MetaProgression.get_blood_bonus()
    local level = MetaProgression.get_upgrade_level("blood_boost")
    return level * UPGRADES.blood_boost.effect_per_level
end

-- Get gold multiplier (percentage bonus)
function MetaProgression.get_gold_multiplier()
    local level = MetaProgression.get_upgrade_level("gold_bonus")
    return 1 + (level * UPGRADES.gold_bonus.effect_per_level)
end

-- Check if player has better squirrel upgrade
function MetaProgression.has_better_squirrel()
    return MetaProgression.get_upgrade_level("better_squirrel") > 0
end

-- Check if player has starting rare upgrade
function MetaProgression.has_starting_rare()
    return MetaProgression.get_upgrade_level("starting_rare") > 0
end

-- Get all starting bonuses as a table
function MetaProgression.get_starting_bonuses()
    return {
        hp_bonus = MetaProgression.get_hp_bonus(),
        gold_bonus = MetaProgression.get_gold_bonus(),
        blood_bonus = MetaProgression.get_blood_bonus(),
        gold_multiplier = MetaProgression.get_gold_multiplier(),
        better_squirrel = MetaProgression.has_better_squirrel(),
        starting_rare = MetaProgression.has_starting_rare(),
    }
end

-- ==================== PURCHASING UPGRADES ====================

-- Calculate cost for next upgrade level
function MetaProgression.get_upgrade_cost(upgrade_id, current_level)
    local upgrade = UPGRADES[upgrade_id]
    if not upgrade then
        return nil, "Invalid upgrade"
    end

    current_level = current_level or MetaProgression.get_upgrade_level(upgrade_id)

    if current_level >= upgrade.max_level then
        return nil, "Max level reached"
    end

    return upgrade.costs[current_level + 1], nil
end

-- Purchase an upgrade
function MetaProgression.purchase_upgrade(upgrade_id)
    local upgrade = UPGRADES[upgrade_id]
    if not upgrade then
        return false, "Invalid upgrade"
    end

    local current_level = MetaProgression.get_upgrade_level(upgrade_id)
    if current_level >= upgrade.max_level then
        return false, "Max level reached"
    end

    local cost = upgrade.costs[current_level + 1]
    if MetaProgression.get_points() < cost then
        return false, "Not enough points"
    end

    -- Deduct points
    meta_data.unlock_points = meta_data.unlock_points - cost

    -- Increase level
    meta_data.upgrades[upgrade_id] = current_level + 1

    -- Save
    Save.save()

    return true, "Purchased " .. upgrade.name .. " level " .. (current_level + 1)
end

-- ==================== VICTORY PROCESSING ====================

-- Process a completed run
function MetaProgression.process_victory(run_stats)
    run_stats = run_stats or {}

    -- Initialize if needed
    if not meta_data then
        MetaProgression.init()
    end

    local rewards = {
        points = 0,
        exp = 0,
        unlocks = {},
    }

    -- Update statistics
    meta_data.total_runs = (meta_data.total_runs or 0) + 1
    meta_data.wins = (meta_data.wins or 0) + 1
    meta_data.current_streak = (meta_data.current_streak or 0) + 1
    if meta_data.current_streak > (meta_data.best_win_streak or 0) then
        meta_data.best_win_streak = meta_data.current_streak
    end

    -- Calculate base points
    local base_points = 1

    -- Bonus points
    if run_stats.no_deaths then
        base_points = base_points + 1
    end
    if run_stats.hard_mode then
        base_points = base_points + 2
    end
    if meta_data.wins == 1 then
        base_points = base_points + 3  -- First win bonus
    end

    rewards.points = base_points

    -- Calculate experience
    local base_exp = 100
    local bonus_exp = (run_stats.battles_won or 0) * 10
    bonus_exp = bonus_exp + (run_stats.cards_played or 0) * 2
    rewards.exp = base_exp + bonus_exp

    -- Add points and exp
    meta_data.unlock_points = (meta_data.unlock_points or 0) + rewards.points
    meta_data.total_exp = (meta_data.total_exp or 0) + rewards.exp

    -- Check for level up
    local old_level = meta_data.level
    local exp_needed = meta_data.level * 100
    while meta_data.total_exp >= exp_needed do
        meta_data.total_exp = meta_data.total_exp - exp_needed
        meta_data.level = meta_data.level + 1
        exp_needed = meta_data.level * 100
    end
    rewards.leveled_up = meta_data.level > old_level
    rewards.new_level = meta_data.level

    -- Check for unlocks
    rewards.unlocks = MetaProgression.check_and_apply_unlocks()

    -- Track fastest win
    if run_stats.time then
        if not meta_data.fastest_win or run_stats.time < meta_data.fastest_win then
            meta_data.fastest_win = run_stats.time
        end
    end

    -- Save progress
    Save.save()

    return rewards
end

-- Process a loss
function MetaProgression.process_loss()
    if not meta_data then
        MetaProgression.init()
    end

    meta_data.total_runs = (meta_data.total_runs or 0) + 1
    meta_data.losses = (meta_data.losses or 0) + 1
    meta_data.current_streak = 0

    -- Small exp for participation
    meta_data.total_exp = (meta_data.total_exp or 0) + 20

    Save.save()
end

-- Check and apply unlocks based on wins
function MetaProgression.check_and_apply_unlocks()
    local new_unlocks = {}
    local wins = meta_data.wins or 0

    -- Check card unlocks
    for _, unlock in ipairs(CARD_UNLOCKS) do
        if wins >= unlock.runs and not MetaProgression.is_card_unlocked(unlock.card_id) then
            table.insert(meta_data.unlocked_cards, unlock.card_id)
            table.insert(new_unlocks, {
                type = "card",
                id = unlock.card_id,
                name = CardData.cards[unlock.card_id] and CardData.cards[unlock.card_id].name or unlock.card_id,
                desc = unlock.desc,
            })
        end
    end

    -- Check sigil unlocks
    for _, unlock in ipairs(SIGIL_UNLOCKS) do
        if wins >= unlock.runs then
            local already_unlocked = false
            for _, id in ipairs(meta_data.unlocked_sigils) do
                if id == unlock.sigil_id then
                    already_unlocked = true
                    break
                end
            end
            if not already_unlocked then
                table.insert(meta_data.unlocked_sigils, unlock.sigil_id)
                table.insert(new_unlocks, {
                    type = "sigil",
                    id = unlock.sigil_id,
                    name = unlock.sigil_id,
                    desc = unlock.desc,
                })
            end
        end
    end

    -- Check feature unlocks
    for _, unlock in ipairs(FEATURE_UNLOCKS) do
        if wins >= unlock.runs and not MetaProgression.is_feature_unlocked(unlock.feature_id) then
            table.insert(meta_data.unlocked_features, unlock.feature_id)
            table.insert(new_unlocks, {
                type = "feature",
                id = unlock.feature_id,
                name = unlock.feature_id,
                desc = unlock.desc,
            })
        end
    end

    return new_unlocks
end

-- ==================== CARD POOL HELPERS ====================

-- Get available cards for reward/shop pools
-- Returns all cards that are either common or unlocked
function MetaProgression.get_available_card_pool()
    local pool = {}

    for card_id, card in pairs(CardData.cards) do
        -- Squirrels are always available
        if card_id == "squirrel" then
            pool[card_id] = card
        -- Common cards are always available
        elseif card.rarity == "common" then
            pool[card_id] = card
        -- Other rarities need to be unlocked
        elseif MetaProgression.is_card_unlocked(card_id) then
            pool[card_id] = card
        end
    end

    return pool
end

-- Get random rare card for starting_rare bonus
function MetaProgression.get_random_rare_card()
    local rares = {}
    for card_id, card in pairs(CardData.cards) do
        if card.rarity == "rare" or card.rarity == "uncommon" then
            -- Only include if unlocked or not a special unlock card
            if MetaProgression.is_card_unlocked(card_id) or not MetaProgression.is_unlock_card(card_id) then
                table.insert(rares, card_id)
            end
        end
    end

    if #rares > 0 then
        return rares[love.math.random(#rares)]
    end
    return nil
end

-- Check if a card is an unlock-restricted card
function MetaProgression.is_unlock_card(card_id)
    for _, unlock in ipairs(CARD_UNLOCKS) do
        if unlock.card_id == card_id then
            return true
        end
    end
    return false
end

-- ==================== SAVE/LOAD ====================

-- Get next unlockable card (for boss rewards)
function MetaProgression.get_next_unlock_card()
    -- Get all cards that are not yet unlocked and not common
    local unlockable = {}
    for card_id, card in pairs(CardData.cards) do
        if card.rarity and card.rarity ~= "common" and not MetaProgression.is_card_unlocked(card_id) then
            table.insert(unlockable, card_id)
        end
    end

    -- Return random one if available
    if #unlockable > 0 then
        return unlockable[love.math.random(#unlockable)]
    end
    return nil
end

-- Unlock a specific card
function MetaProgression.unlock_card(card_id)
    if not meta_data then
        MetaProgression.init()
    end

    if not meta_data.unlocked_cards then
        meta_data.unlocked_cards = {}
    end

    -- Check if already unlocked
    for _, id in ipairs(meta_data.unlocked_cards) do
        if id == card_id then
            return false, "Already unlocked"
        end
    end

    -- Add to unlocked list
    table.insert(meta_data.unlocked_cards, card_id)
    Save.save()
    return true
end

-- Get full progress data (for save)
function MetaProgression.get_data()
    return meta_data
end

-- Force save
function MetaProgression.save()
    Save.save()
end

-- Reset progress (debug)
function MetaProgression.reset()
    meta_data = MetaProgression.get_default_progress()
    Save.get_data().progress = meta_data
    Save.save()
end

-- ==================== STATISTICS ====================

-- Get full statistics
function MetaProgression.get_stats()
    return {
        total_runs = meta_data.total_runs or 0,
        wins = meta_data.wins or 0,
        losses = meta_data.losses or 0,
        win_rate = meta_data.total_runs > 0 and
                  (meta_data.wins / meta_data.total_runs) or 0,
        best_streak = meta_data.best_win_streak or 0,
        current_streak = meta_data.current_streak or 0,
        fastest_win = meta_data.fastest_win,
        total_exp = meta_data.total_exp or 0,
        level = meta_data.level or 1,
    }
end

return MetaProgression