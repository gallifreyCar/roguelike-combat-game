-- systems/enemy.lua - 敌人系统
-- 管理：敌人生成、AI 行动、意图显示、渲染
-- 支持多种敌人类型和难度缩放

local Enemy = {}

-- 敌人类型定义（平衡性调整：降低初始强度，提高成长性）
local enemy_types = {
    slime_small = {
        name = "Slime",
        hp = 15,  -- 降低从18到15
        patterns = {
            {intent = "attack", damage = 5, weight = 0.6},  -- 降低从6到5
            {intent = "defend", block = 3, weight = 0.4},  -- 降低从4到3
        },
    },
    cultist = {
        name = "Cultist",
        hp = 25,  -- 降低从30到25
        patterns = {
            {intent = "attack", damage = 5, weight = 0.5},  -- 降低从6到5
            {intent = "buff", effect = "strength", weight = 0.3},
            {intent = "defend", block = 5, weight = 0.2},  -- 降低从6到5
        },
    },
    jaw_worm = {
        name = "Jaw Worm",
        hp = 35,  -- 降低从40到35
        patterns = {
            {intent = "attack", damage = 9, weight = 0.4},  -- 降低从11到9
            {intent = "defend", block = 5, weight = 0.3},  -- 降低从6到5
            {intent = "attack", damage = 6, weight = 0.3},  -- 降低从7到6
        },
    },
}

-- 难度缩放函数：根据关卡调整敌人属性
local function scale_for_level(base_hp, base_damage, level)
    -- 缩放公式：每级增加约10%属性
    local hp_scale = 1 + (level - 1) * 0.1
    local damage_scale = 1 + (level - 1) * 0.08

    return math.floor(base_hp * hp_scale), math.floor(base_damage * damage_scale)
end

function Enemy.spawn(type_id, enemies_list)
    local template = enemy_types[type_id]
    if not template then return end

    local enemy = {
        id = type_id,
        name = template.name,
        hp = template.hp,
        max_hp = template.hp,
        block = 0,
        patterns = template.patterns,
        next_intent = nil,
        x = 700,
        y = 200,
    }

    enemies_list[#enemies_list + 1] = enemy
end

function Enemy.roll_intent(enemy)
    -- 根据权重随机选择意图
    local total = 0
    for _, p in ipairs(enemy.patterns) do
        total = total + (p.weight or 0.5)
    end

    local roll = love.math.random() * total
    for _, p in ipairs(enemy.patterns) do
        roll = roll - (p.weight or 0.5)
        if roll <= 0 then
            enemy.next_intent = p
            break
        end
    end
end

function Enemy.get_action(enemy)
    -- [BUG FIX] 确保 next_intent 有默认值
    if not enemy.next_intent then
        Enemy.roll_intent(enemy)
    end
    local action = enemy.next_intent
    Enemy.roll_intent(enemy)  -- 预判下一步
    return action
end

function Enemy.process_turn(enemies, player)
    for _, enemy in ipairs(enemies) do
        local action = Enemy.get_action(enemy)

        if action.intent == "attack" then
            local damage = action.damage or 5
            -- 先扣玩家护盾
            if player.block > 0 then
                local absorbed = math.min(player.block, damage)
                player.block = player.block - absorbed
                damage = damage - absorbed
            end
            player.hp = player.hp - damage

        elseif action.intent == "defend" then
            enemy.block = enemy.block + (action.block or 6)

        elseif action.intent == "buff" then
            -- TODO: 实现增益效果
        end
    end
end

function Enemy.draw(enemies)
    for _, enemy in ipairs(enemies) do
        -- 敌人背景
        love.graphics.setColor(0.35, 0.25, 0.2)
        love.graphics.rectangle("fill", enemy.x, enemy.y, 100, 120, 8, 8)

        -- 敌人名称
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(enemy.name, enemy.x + 15, enemy.y + 10)

        -- HP bar
        love.graphics.setColor(0.3, 0.1, 0.1)
        love.graphics.rectangle("fill", enemy.x + 10, enemy.y + 90, 80, 12)
        love.graphics.setColor(0.8, 0.2, 0.2)
        -- [BUG FIX] 防止 max_hp 为 nil 导致除零错误
        local max_hp = math.max(1, enemy.max_hp or enemy.hp or 1)
        local hp_width = (enemy.hp / max_hp) * 80
        love.graphics.rectangle("fill", enemy.x + 10, enemy.y + 90, hp_width, 12)

        -- HP text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(enemy.hp .. "/" .. max_hp, enemy.x + 15, enemy.y + 91)

        -- Block
        if enemy.block > 0 then
            love.graphics.setColor(0.4, 0.7, 1)
            love.graphics.print("Block: " .. enemy.block, enemy.x + 10, enemy.y + 70)
        end

        -- 意图显示
        if enemy.next_intent then
            local intent_text = ""
            local intent_color = {1, 1, 1}

            if enemy.next_intent.intent == "attack" then
                intent_text = "ATK " .. (enemy.next_intent.damage or "?")
                intent_color = {1, 0.3, 0.3}
            elseif enemy.next_intent.intent == "defend" then
                intent_text = "DEF"
                intent_color = {0.4, 0.7, 1}
            elseif enemy.next_intent.intent == "buff" then
                intent_text = "BUF"
                intent_color = {1, 0.8, 0.2}
            end

            love.graphics.setColor(intent_color)
            love.graphics.print(intent_text, enemy.x + 30, enemy.y - 20)
        end
    end
end

return Enemy