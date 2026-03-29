-- scenes/combat.lua - 战斗场景
-- 核心回合制战斗逻辑

local Combat = {}
local Deck = require("systems.deck")
local Enemy = require("systems.enemy")
local I18n = require("core.i18n")
local State = require("core.state")

-- 战斗状态
local battle_state = {
    phase = "player",
    turn = 1,
    player = {
        hp = 80, max_hp = 80,
        block = 0,
        energy = 3, max_energy = 3,
    },
    enemies = {},
    log = {},  -- 战斗日志
}

function Combat.enter()
    -- 重置状态
    battle_state.turn = 1
    battle_state.phase = "player"
    battle_state.player.hp = 80
    battle_state.player.block = 0
    battle_state.player.energy = 3
    battle_state.log = {}

    -- 初始化牌组
    Deck.init()

    -- 生成敌人
    battle_state.enemies = {}
    Enemy.spawn("slime_small", battle_state.enemies)

    -- 显示敌人意图
    for _, enemy in ipairs(battle_state.enemies) do
        Enemy.roll_intent(enemy)
    end

    -- 抽初始手牌
    Deck.draw_cards(5)

    Combat.add_log("Battle Start!")
end

function Combat.exit()
    battle_state.enemies = {}
end

function Combat.update(dt)
    -- 检查胜利状态
    if battle_state.phase == "victory" then
        State.switch("victory")
    end
end

function Combat.draw()
    love.graphics.clear(0.12, 0.1, 0.08)

    -- 渲染敌人
    Enemy.draw(battle_state.enemies)

    -- 渲染玩家状态
    Combat.draw_player_status()

    -- 渲染手牌
    Deck.draw_hand(battle_state.player.energy)

    -- 渲染能量
    love.graphics.setColor(1, 0.85, 0.2)
    love.graphics.print("Energy: " .. battle_state.player.energy .. "/" .. battle_state.player.max_energy, 50, 580)

    -- 操作提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("[1-5] Play Card  [E] End Turn  [ESC] Quit", 50, 620)

    -- 战斗日志
    love.graphics.setColor(0.7, 0.7, 0.7)
    for i, msg in ipairs(battle_state.log) do
        if i > 5 then break end
        love.graphics.print(msg, 50, 100 + (i - 1) * 20)
    end
end

function Combat.draw_player_status()
    -- HP bar
    love.graphics.setColor(0.3, 0.1, 0.1)
    love.graphics.rectangle("fill", 50, 540, 200, 25)
    love.graphics.setColor(0.8, 0.2, 0.2)
    local hp_width = (battle_state.player.hp / battle_state.player.max_hp) * 200
    love.graphics.rectangle("fill", 50, 540, hp_width, 25)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP: " .. battle_state.player.hp .. "/" .. battle_state.player.max_hp, 60, 545)

    -- Block
    if battle_state.player.block > 0 then
        love.graphics.setColor(0.4, 0.7, 1)
        love.graphics.print("Block: " .. battle_state.player.block, 260, 545)
    end
end

function Combat.add_log(msg)
    table.insert(battle_state.log, 1, msg)
    if #battle_state.log > 10 then
        table.remove(battle_state.log)
    end
end

function Combat.play_card(index)
    if battle_state.phase ~= "player" then return end

    local card = Deck.hand[index]
    if not card then return end

    -- 检查能量
    if card.cost > battle_state.player.energy then
        Combat.add_log("Not enough energy!")
        return
    end

    -- 扣除能量
    battle_state.player.energy = battle_state.player.energy - card.cost

    -- 执行卡牌效果
    if card.damage then
        local enemy = battle_state.enemies[1]
        if enemy then
            local dmg = card.damage
            -- 先扣护盾
            if enemy.block > 0 then
                local absorbed = math.min(enemy.block, dmg)
                enemy.block = enemy.block - absorbed
                dmg = dmg - absorbed
            end
            enemy.hp = enemy.hp - dmg
            Combat.add_log("Dealt " .. card.damage .. " damage!")

            -- 检查敌人死亡
            if enemy.hp <= 0 then
                Combat.add_log("Enemy defeated!")
                battle_state.enemies = {}
                -- 延迟进入胜利场景
                battle_state.phase = "victory"
            end
        end
    elseif card.block then
        battle_state.player.block = battle_state.player.block + card.block
        Combat.add_log("Gained " .. card.block .. " block!")
    end

    -- 移除手牌
    Deck.play_card(index)
end

function Combat.end_turn()
    if battle_state.phase ~= "player" then return end

    -- 弃掉所有手牌
    Deck.end_turn()
    battle_state.phase = "enemy"

    -- 敌人行动
    for _, enemy in ipairs(battle_state.enemies) do
        local action = Enemy.get_action(enemy)

        if action.intent == "attack" then
            local dmg = action.damage or 5
            -- 先扣玩家护盾
            if battle_state.player.block > 0 then
                local absorbed = math.min(battle_state.player.block, dmg)
                battle_state.player.block = battle_state.player.block - absorbed
                dmg = dmg - absorbed
            end
            battle_state.player.hp = battle_state.player.hp - dmg
            Combat.add_log("Enemy dealt " .. action.damage .. " damage!")

        elseif action.intent == "defend" then
            enemy.block = enemy.block + (action.block or 6)
            Combat.add_log("Enemy gained block!")

        elseif action.intent == "buff" then
            Combat.add_log("Enemy is strengthening...")
        end

        -- 显示下一个意图
        Enemy.roll_intent(enemy)
    end

    -- 检查玩家死亡
    if battle_state.player.hp <= 0 then
        State.switch("death")
        return
    end

    -- 下一回合
    battle_state.turn = battle_state.turn + 1
    battle_state.phase = "player"
    battle_state.player.block = 0
    battle_state.player.energy = battle_state.player.max_energy
    Deck.draw_cards(5)
    Combat.add_log("Turn " .. battle_state.turn)
end

function Combat.keypressed(key)
    if key == "e" then
        Combat.end_turn()
    elseif key == "1" then
        Combat.play_card(1)
    elseif key == "2" then
        Combat.play_card(2)
    elseif key == "3" then
        Combat.play_card(3)
    elseif key == "4" then
        Combat.play_card(4)
    elseif key == "5" then
        Combat.play_card(5)
    end
end

return Combat