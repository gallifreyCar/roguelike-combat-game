-- systems/sigils.lua - 印记系统
-- 处理卡牌印记的各种效果
-- 支持生成效果、攻击效果、死亡效果、回合效果等

local Sigils = {}

-- 印记效果定义
-- 每个印记可包含: name, desc, on_spawn, on_attack, on_death, on_hit, on_hit_received, get_attack_count
local SIGIL_EFFECTS = {
    -- 飞行：空列直接攻击玩家
    air_strike = {
        name = "Air Strike",
        desc = "Flying - attacks directly if lane empty",
        on_attack = function(card, target, battle_state)
            if not target then
                -- 空列，直接攻击敌方HP
                return {direct_damage = card.attack}
            end
            return {}
        end,
    },

    -- 坚韧：+2最大HP
    tough = {
        name = "Tough",
        desc = "+2 Max HP",
        on_spawn = function(card)
            card.max_hp = card.max_hp + 2
            card.hp = card.hp + 2
        end,
    },

    -- 不死：死亡后复活一次
    undead = {
        name = "Undead",
        desc = "Revive once after death",
        on_death = function(card, battle_state, board, slot)
            if not card.revived then
                card.revived = true
                card.hp = 1
                return {revived = true, card = card}
            end
            return {}
        end,
    },

    -- 毒：命中后敌人每回合-1HP
    poison = {
        name = "Poison",
        desc = "Poisoned enemy loses 1 HP/turn",
        on_hit = function(card, target)
            if target then
                target.poisoned = (target.poisoned or 0) + 1
            end
        end,
    },

    -- 恶臭：降低对面敌人攻击力
    stinky = {
        name = "Stinky",
        desc = "Reduce opposite enemy ATK",
        on_spawn = function(card)
            card.stinky_debuff = 1
        end,
    },

    -- 冲锋：同时攻击相邻两列
    charge = {
        name = "Charge",
        desc = "Attack adjacent lanes too",
        on_attack = function(card, target, battle_state, slot)
            return {charge_attack = true, slot = slot}
        end,
    },

    -- 双击：攻击两次
    double_strike = {
        name = "Double Strike",
        desc = "Attack twice per turn",
        get_attack_count = function()
            return 2
        end,
    },

    -- 践踏：溢出伤害打玩家
    trample = {
        name = "Trample",
        desc = "Overflow damage hits player",
        on_kill = function(card, target, overkill_damage)
            return {overkill = overkill_damage}
        end,
    },

    -- 尖刺：被攻击时反伤
    sharp_quills = {
        name = "Sharp Quills",
        desc = "Deal damage when attacked",
        on_hit_received = function(card, attacker, damage)
            return {thorns = math.floor(damage / 2)}
        end,
    },

    -- 骨蛇：死亡时留下1/1蛇
    bone_snake = {
        name = "Bone Snake",
        desc = "Leave a 1/1 snake on death",
        on_death = function(card, battle_state, board, slot)
            return {spawn_card = {
                id = "bone_snake_minion",
                name = "Bone Snake",
                attack = 1,
                hp = 1,
                max_hp = 1,
                slot = slot,
            }}
        end,
    },

    -- 九头蛇：死亡时分裂成2个小蛇
    hydra = {
        name = "Hydra",
        desc = "Split into 2 snakes on death",
        on_death = function(card, battle_state, board, slot)
            return {spawn_cards = {
                {id = "hydra_head", name = "Hydra Head", attack = 2, hp = 2, max_hp = 2},
                {id = "hydra_head", name = "Hydra Head", attack = 2, hp = 2, max_hp = 2},
            }, slot = slot}
        end,
    },

    -- 守护：保护相邻卡牌
    guardian = {
        name = "Guardian",
        desc = "Protect adjacent cards",
        on_adjacent_damage = function(card, adjacent_card, damage)
            -- 可以为相邻卡牌挡伤害
            return {redirect_damage = damage}
        end,
    },

    -- 分叉：攻击两列
    bifurcated = {
        name = "Bifurcated",
        desc = "Attack 2 lanes",
        on_attack = function(card, target, battle_state, slot)
            return {bifurcated = true, slot = slot}
        end,
    },

    -- 【新】过牌：放置时抽2张牌
    draw = {
        name = "Draw",
        desc = "Draw 2 cards when placed",
        on_place = function(card)
            return {draw_cards = 2}
        end,
    },

    -- 【新】连击：打出后下张牌费用-1
    combo = {
        name = "Combo",
        desc = "Next card costs -1",
        on_place = function(card)
            return {cost_reduction = 1}
        end,
    },

    -- 【新】亡语抽牌：死亡时抽2张牌
    death_draw = {
        name = "Death Draw",
        desc = "Draw 2 cards on death",
        on_death = function(card, battle_state, board, slot)
            return {draw_cards = 2}
        end,
    },

    -- 【新】击杀加攻：击杀敌人时+1攻击
    kill_bonus = {
        name = "Kill Bonus",
        desc = "+1 ATK when killing enemy",
        on_kill = function(card, target)
            return {atk_bonus = 1}
        end,
    },

    -- 【新】回合加血：回合开始+1Blood
    turn_blood = {
        name = "Turn Blood",
        desc = "+1 Blood each turn",
        on_turn_start = function(card)
            return {blood_bonus = 1}
        end,
    },
}

-- 检查卡牌是否有某个印记
function Sigils.has(card, sigil_name)
    if not card.sigils then return false end
    for _, sigil in ipairs(card.sigils) do
        if sigil == sigil_name then
            return true
        end
    end
    return false
end

-- 应用印记的生成效果
function Sigils.apply_spawn_effects(card)
    if not card then return end
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_spawn then
            effect.on_spawn(card)
        end
    end
end

-- 【新】处理放置时的印记效果（如过牌）
function Sigils.process_place(card)
    local results = {}
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_place then
            local result = effect.on_place(card)
            if result then
                table.insert(results, {sigil = sigil_name, result = result})
            end
        end
    end
    return results
end

-- 处理攻击时的印记效果
function Sigils.process_attack(card, target, battle_state, slot)
    local results = {}
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_attack then
            local result = effect.on_attack(card, target, battle_state, slot)
            if result then
                table.insert(results, {sigil = sigil_name, result = result})
            end
        end
    end
    return results
end

-- 处理死亡时的印记效果
function Sigils.process_death(card, battle_state, board, slot)
    local results = {}
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_death then
            local result = effect.on_death(card, battle_state, board, slot)
            if result then
                table.insert(results, {sigil = sigil_name, result = result})
            end
        end
    end
    return results
end

-- 获取攻击次数（双击等）
function Sigils.get_attack_count(card)
    local count = 1
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.get_attack_count then
            count = effect.get_attack_count()
        end
    end
    return count
end

-- 处理命中时的印记效果（如毒）
function Sigils.process_hit(card, target)
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_hit then
            effect.on_hit(card, target)
        end
    end
end

-- 处理受到伤害时的印记效果（如尖刺）
function Sigils.process_hit_received(card, attacker, damage)
    local results = {}
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect and effect.on_hit_received then
            local result = effect.on_hit_received(card, attacker, damage)
            if result then
                table.insert(results, {sigil = sigil_name, result = result})
            end
        end
    end
    return results
end

-- 处理回合结束时的效果（如毒伤害）
function Sigils.process_turn_end(card)
    if card.poisoned and card.poisoned > 0 then
        local damage = card.poisoned
        card.poisoned = math.max(0, card.poisoned - 1)
        return {poison_damage = damage}
    end
    return nil
end

-- 获取印记名称列表
function Sigils.get_names(card)
    local names = {}
    for _, sigil_name in ipairs(card.sigils or {}) do
        local effect = SIGIL_EFFECTS[sigil_name]
        if effect then
            table.insert(names, effect.name)
        end
    end
    return names
end

-- 获取印记描述
function Sigils.get_description(sigil_name)
    local effect = SIGIL_EFFECTS[sigil_name]
    return effect and effect.desc or ""
end

return Sigils