-- systems/enemy.lua - 敌人系统
-- 管理：敌人生成、AI 行动、意图显示、渲染

local Enemy = {}

-- 敌人定义
local enemy_types = {
    slime_small = {
        name = "Slime",
        hp = 18,
        patterns = {
            {intent = "attack", damage = 6, weight = 0.6},
            {intent = "defend", block = 4, weight = 0.4},
        },
    },
    cultist = {
        name = "Cultist",
        hp = 30,
        patterns = {
            {intent = "attack", damage = 6, weight = 0.5},
            {intent = "buff", effect = "strength", weight = 0.3},
            {intent = "defend", block = 6, weight = 0.2},
        },
    },
    jaw_worm = {
        name = "Jaw Worm",
        hp = 40,
        patterns = {
            {intent = "attack", damage = 11, weight = 0.4},
            {intent = "defend", block = 6, weight = 0.3},
            {intent = "attack", damage = 7, weight = 0.3},
        },
    },
}

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
        local hp_width = (enemy.hp / enemy.max_hp) * 80
        love.graphics.rectangle("fill", enemy.x + 10, enemy.y + 90, hp_width, 12)

        -- HP text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(enemy.hp .. "/" .. enemy.max_hp, enemy.x + 15, enemy.y + 91)

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