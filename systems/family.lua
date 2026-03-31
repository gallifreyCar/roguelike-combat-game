-- systems/family.lua - 体系联动系统
-- 2/3/4张阶梯式联动效果
-- 设计理念：4张一组，但支持2/3/4张不同阈值

local Family = {}

-- 体系定义（4张一组）
Family.FAMILIES = {
    flying = {
        name = "Flying",
        name_cn = "飞行组",
        cards = {"raven", "eagle", "owl", "bat"},  -- 4张
        color = {0.6, 0.8, 1.0},  -- 天蓝色
        icon = "🦅",
        bonuses = {
            [2] = {desc = "First strike", effect = "first_strike"},
            [3] = {desc = "+1 ATK all flying", effect = "attack_boost", value = 1},
            [4] = {desc = "Ignore blockers", effect = "ignore_block"},
        },
    },
    beast = {
        name = "Beast",
        name_cn = "猛兽组",
        cards = {"wolf", "grizzly", "lion", "bear"},  -- 4张核心
        color = {0.8, 0.5, 0.3},  -- 棕色
        icon = "🐺",
        bonuses = {
            [2] = {desc = "+1 ATK", effect = "self_attack", value = 1},
            [3] = {desc = "First attack x2", effect = "first_double"},
            [4] = {desc = "All beasts +2 ATK", effect = "team_attack", value = 2},
        },
    },
    insect = {
        name = "Insect",
        name_cn = "昆虫组",
        cards = {"bee", "mantis", "spider", "scorpion"},  -- 4张
        color = {0.5, 0.7, 0.3},  -- 虫绿
        icon = "🐝",
        bonuses = {
            [2] = {desc = "Poison +1", effect = "poison_boost", value = 1},
            [3] = {desc = "Poison damage x2", effect = "poison_double"},
            [4] = {desc = "All enemies poisoned", effect = "aoe_poison"},
        },
    },
    reptile = {
        name = "Reptile",
        name_cn = "爬行组",
        cards = {"bullfrog", "adder", "hydra", "turtle"},  -- 4张
        color = {0.3, 0.6, 0.4},  -- 爬虫绿
        icon = "🐍",
        bonuses = {
            [2] = {desc = "Heal 1 HP/turn", effect = "regen", value = 1},
            [3] = {desc = "Poison +2", effect = "poison_boost", value = 2},
            [4] = {desc = "Revive once", effect = "team_revive"},
        },
    },
    ocean = {
        name = "Ocean",
        name_cn = "海洋组",
        cards = {"shark", "kraken", "gem_crab", "blood_worm"},  -- 4张
        color = {0.2, 0.4, 0.7},  -- 海蓝
        icon = "🦈",
        bonuses = {
            [2] = {desc = "+1 HP", effect = "self_hp", value = 1},
            [3] = {desc = "Enemy -1 ATK", effect = "enemy_weaken", value = 1},
            [4] = {desc = "Control enemy slot", effect = "control"},
        },
    },
    mythic = {
        name = "Mythic",
        name_cn = "神话组",
        cards = {"dragon", "phoenix", "titan", "deathcard"},  -- 4张
        color = {0.7, 0.4, 0.8},  -- 神秘紫
        icon = "🐉",
        bonuses = {
            [2] = {desc = "+1/+1", effect = "stats_boost", attack = 1, hp = 1},
            [3] = {desc = "Gain random sigil", effect = "random_sigil"},
            [4] = {desc = "Boss slayer", effect = "boss_damage", value = 3},
        },
    },
}

-- 计算场上各体系的数量
function Family.count_families(board)
    local counts = {}

    for _, card in ipairs(board) do
        if card and card.family then
            counts[card.family] = (counts[card.family] or 0) + 1
        end
    end

    return counts
end

-- 获取当前激活的联动效果
function Family.get_active_bonuses(board)
    local counts = Family.count_families(board)
    local active = {}

    for family_id, count in pairs(counts) do
        local family = Family.FAMILIES[family_id]
        if family then
            -- 检查每个阈值
            for threshold = 2, 4 do
                if count >= threshold and family.bonuses[threshold] then
                    active[#active + 1] = {
                        family = family_id,
                        family_name = family.name_cn,
                        count = count,
                        threshold = threshold,
                        bonus = family.bonuses[threshold],
                        color = family.color,
                        icon = family.icon,
                    }
                end
            end
        end
    end

    return active
end

-- 获取卡牌所属体系
function Family.get_card_family(card_id)
    for family_id, family in pairs(Family.FAMILIES) do
        for _, card_id_in_family in ipairs(family.cards) do
            if card_id_in_family == card_id then
                return family_id
            end
        end
    end
    return nil
end

-- 检查卡牌是否属于某体系
function Family.is_in_family(card_id, family_id)
    local family = Family.FAMILIES[family_id]
    if not family then return false end

    for _, id in ipairs(family.cards) do
        if id == card_id then return true end
    end
    return false
end

-- 获取体系的进度（0-4）
function Family.get_family_progress(board, family_id)
    local count = 0
    local family = Family.FAMILIES[family_id]
    if not family then return 0, 4 end

    for _, card in ipairs(board) do
        if card and card.family == family_id then
            count = count + 1
        end
    end

    return count, #family.cards
end

-- 应用联动效果到卡牌
function Family.apply_bonuses(card, board)
    if not card or not card.family then return card end

    local counts = Family.count_families(board)
    local family_count = counts[card.family] or 0
    local family = Family.FAMILIES[card.family]

    if not family then return card end

    -- 应用2张效果
    if family_count >= 2 and family.bonuses[2] then
        local bonus = family.bonuses[2]
        if bonus.effect == "self_attack" then
            card.attack = card.attack + bonus.value
            card.family_bonus = (card.family_bonus or "") .. "+" .. bonus.value .. "ATK "
        elseif bonus.effect == "self_hp" then
            card.hp = card.hp + bonus.value
            card.max_hp = card.max_hp + bonus.value
            card.family_bonus = (card.family_bonus or "") .. "+" .. bonus.value .. "HP "
        elseif bonus.effect == "first_strike" then
            card.first_strike = true
            card.family_bonus = (card.family_bonus or "") .. "先手 "
        elseif bonus.effect == "regen" then
            card.regen = (card.regen or 0) + bonus.value
            card.family_bonus = (card.family_bonus or "") .. "回血 "
        elseif bonus.effect == "poison_boost" then
            card.poison_bonus = (card.poison_bonus or 0) + bonus.value
            card.family_bonus = (card.family_bonus or "") .. "毒+" .. bonus.value .. " "
        elseif bonus.effect == "stats_boost" then
            card.attack = card.attack + bonus.attack
            card.hp = card.hp + bonus.hp
            card.max_hp = card.max_hp + bonus.hp
            card.family_bonus = (card.family_bonus or "") .. "+1/+1 "
        end
    end

    -- 应用3张效果（在战斗开始时触发）
    if family_count >= 3 and family.bonuses[3] then
        local bonus = family.bonuses[3]
        card.family_bonus_3 = bonus
    end

    -- 应用4张效果（最强效果）
    if family_count >= 4 and family.bonuses[4] then
        local bonus = family.bonuses[4]
        card.family_bonus_4 = bonus
    end

    return card
end

-- 获取所有体系的UI显示数据
function Family.get_family_ui_data()
    local data = {}
    for family_id, family in pairs(Family.FAMILIES) do
        data[#data + 1] = {
            id = family_id,
            name = family.name_cn,
            cards = family.cards,
            color = family.color,
            icon = family.icon,
            bonuses = family.bonuses,
        }
    end
    return data
end

return Family