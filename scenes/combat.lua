-- scenes/combat.lua - 战斗场景（邪恶冥刻风格）
-- 卡牌放置 + 自动攻击

local Combat = {}
local CardData = require("data.cards")
local State = require("core.state")

-- 战斗配置
local BOARD_SLOTS = 4        -- 每边4个格子
local PLAYER_MAX_HP = 10     -- 玩家初始生命

-- 战斗状态
local battle = {
    turn = 1,
    phase = "play",          -- play/sacrifice/battle/result

    player = {
        hp = PLAYER_MAX_HP,
        max_hp = PLAYER_MAX_HP,
        blood = 0,           -- 献祭获得的血量资源
        board = {},          -- 场上卡牌
    },

    enemy = {
        hp = 10,
        max_hp = 10,
        board = {},
    },

    hand = {},               -- 手牌
    selected_card = nil,     -- 选中的手牌
    selected_slot = nil,     -- 选中的格子
    message = "",
}

-- 初始化玩家格子
local function init_board(board)
    for i = 1, BOARD_SLOTS do
        board[i] = nil
    end
end

function Combat.enter()
    -- 重置状态
    battle.turn = 1
    battle.phase = "play"
    battle.player.hp = PLAYER_MAX_HP
    battle.player.blood = 0
    battle.player.max_hp = PLAYER_MAX_HP
    battle.enemy.hp = 10
    battle.enemy.max_hp = 10

    init_board(battle.player.board)
    init_board(battle.enemy.board)

    -- 生成手牌
    battle.hand = {}
    Combat.draw_cards(4)

    -- 生成敌方卡牌
    Combat.spawn_enemy_cards()

    battle.selected_card = nil
    battle.selected_slot = nil
    battle.message = "Place your cards. Press SPACE to battle!"
end

function Combat.exit()
end

function Combat.draw_cards(n)
    local card_types = {"squirrel", "stoat", "wolf", "bullfrog", "raven"}
    for i = 1, n do
        local id = card_types[love.math.random(#card_types)]
        local template = CardData.cards[id]
        if template then
            battle.hand[#battle.hand + 1] = {
                id = template.id,
                name = template.name,
                cost = template.cost,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.hp,
                sigils = template.sigils or {},
            }
        end
    end
end

function Combat.spawn_enemy_cards()
    -- 敌人预设卡牌
    local enemy_cards = {
        {id = "stoat", slot = 1},
        {id = "wolf", slot = 3},
    }

    for _, ec in ipairs(enemy_cards) do
        local template = CardData.cards[ec.id]
        if template then
            battle.enemy.board[ec.slot] = {
                id = template.id,
                name = template.name,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.hp,
            }
        end
    end
end

function Combat.update(dt)
end

function Combat.draw()
    love.graphics.clear(0.08, 0.06, 0.05)

    -- 绘制敌方区域
    Combat.draw_enemy_area()

    -- 绘制玩家区域（格子）
    Combat.draw_player_board()

    -- 绘制手牌
    Combat.draw_hand()

    -- 绘制状态
    Combat.draw_status()

    -- 绘制消息
    if battle.message then
        love.graphics.setColor(0.9, 0.8, 0.6)
        love.graphics.print(battle.message, 400, 50)
    end
end

function Combat.draw_enemy_area()
    -- 敌方生命值
    love.graphics.setColor(0.6, 0.2, 0.2)
    love.graphics.rectangle("fill", 550, 20, 180, 30)
    love.graphics.setColor(0.8, 0.2, 0.2)
    local hp_w = (battle.enemy.hp / battle.enemy.max_hp) * 180
    love.graphics.rectangle("fill", 550, 20, hp_w, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Enemy HP: " .. battle.enemy.hp .. "/" .. battle.enemy.max_hp, 560, 25)

    -- 敌方格子（在上方）
    for i = 1, BOARD_SLOTS do
        local x = 200 + (i - 1) * 130
        local y = 100

        -- 格子背景
        love.graphics.setColor(0.15, 0.12, 0.1)
        love.graphics.rectangle("fill", x, y, 110, 140, 5, 5)

        -- 敌方卡牌
        local card = battle.enemy.board[i]
        if card then
            Combat.draw_card_on_board(card, x, y, false)
        end
    end
end

function Combat.draw_player_board()
    -- 玩家生命值
    love.graphics.setColor(0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", 550, 530, 180, 30)
    love.graphics.setColor(0.2, 0.5, 0.8)
    local hp_w = (battle.player.hp / battle.player.max_hp) * 180
    love.graphics.rectangle("fill", 550, 530, hp_w, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Your HP: " .. battle.player.hp .. "/" .. battle.player.max_hp, 560, 535)

    -- 献祭资源
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.print("Blood: " .. battle.player.blood, 560, 565)

    -- 玩家格子（在下方）
    for i = 1, BOARD_SLOTS do
        local x = 200 + (i - 1) * 130
        local y = 350

        -- 格子背景
        if battle.selected_slot == i then
            love.graphics.setColor(0.3, 0.4, 0.3)
        else
            love.graphics.setColor(0.2, 0.18, 0.15)
        end
        love.graphics.rectangle("fill", x, y, 110, 140, 5, 5)

        -- 格子边框
        love.graphics.setColor(0.4, 0.3, 0.2)
        love.graphics.rectangle("line", x, y, 110, 140, 5, 5)

        -- 格子编号
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.print("[" .. i .. "]", x + 45, y + 115)

        -- 场上卡牌
        local card = battle.player.board[i]
        if card then
            Combat.draw_card_on_board(card, x, y, true)
        end
    end
end

function Combat.draw_card_on_board(card, x, y, is_player)
    -- 卡牌背景
    if is_player then
        love.graphics.setColor(0.25, 0.35, 0.25)
    else
        love.graphics.setColor(0.35, 0.25, 0.25)
    end
    love.graphics.rectangle("fill", x + 5, y + 5, 100, 130, 3, 3)

    -- 卡牌名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(card.name, x + 10, y + 10)

    -- 攻击力（左下）
    love.graphics.setColor(1, 0.8, 0.3)
    love.graphics.print("⚔" .. card.attack, x + 10, y + 105)

    -- 生命值（右下）
    if card.hp <= card.max_hp * 0.3 then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(0.5, 0.9, 0.5)
    end
    love.graphics.print("♥" .. card.hp .. "/" .. card.max_hp, x + 50, y + 105)
end

function Combat.draw_hand()
    love.graphics.setColor(0.9, 0.85, 0.7)
    love.graphics.print("Your Hand (1-" .. #battle.hand .. " to select):", 50, 700)

    for i, card in ipairs(battle.hand) do
        local x = 50 + (i - 1) * 120
        local y = 730

        -- 选中高亮
        if battle.selected_card == i then
            love.graphics.setColor(0.4, 0.5, 0.3)
        else
            love.graphics.setColor(0.3, 0.25, 0.2)
        end
        love.graphics.rectangle("fill", x, y, 110, 130, 5, 5)

        -- 卡牌边框
        love.graphics.setColor(0.6, 0.5, 0.3)
        love.graphics.rectangle("line", x, y, 110, 130, 5, 5)

        -- 卡牌信息
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(card.name, x + 10, y + 10)

        -- 献祭消耗
        love.graphics.setColor(0.8, 0.3, 0.3)
        love.graphics.print("Cost: " .. card.cost, x + 10, y + 35)

        -- 属性
        love.graphics.setColor(1, 0.8, 0.3)
        love.graphics.print("⚔" .. card.attack, x + 10, y + 60)
        love.graphics.setColor(0.5, 0.9, 0.5)
        love.graphics.print("♥" .. card.hp, x + 50, y + 60)

        -- 快捷键
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("[" .. i .. "]", x + 40, y + 100)
    end
end

function Combat.draw_status()
    -- 回合数
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("Turn " .. battle.turn, 50, 20)

    -- 阶段
    local phase_text = {
        play = "PLAY PHASE - Place cards",
        battle = "BATTLE PHASE - Auto combat",
        result = "RESULT",
    }
    love.graphics.print(phase_text[battle.phase] or battle.phase, 50, 40)

    -- 操作提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("[1-4] Select slot  [Q-T] Select hand  [SPACE] Start battle  [R] Restart", 50, 580)
end

function Combat.keypressed(key)
    -- 选择手牌
    if key == "q" then battle.selected_card = 1
    elseif key == "w" then battle.selected_card = 2
    elseif key == "e" then battle.selected_card = 3
    elseif key == "r" and battle.phase == "play" then battle.selected_card = 4
    elseif key == "t" then battle.selected_card = 5
    end

    -- 选择格子放置
    if key == "1" or key == "2" or key == "3" or key == "4" then
        local slot = tonumber(key)
        if battle.selected_card and battle.hand[battle.selected_card] then
            if battle.player.board[slot] == nil then
                Combat.place_card(battle.selected_card, slot)
            else
                battle.message = "Slot " .. slot .. " is occupied!"
            end
        else
            battle.selected_slot = slot
            battle.message = "Select a card first (Q/W/E/R/T)"
        end
    end

    -- 开始战斗
    if key == "space" and battle.phase == "play" then
        Combat.start_battle()
    end

    -- 重新开始
    if key == "r" and battle.phase == "result" then
        Combat.enter()
    end
end

function Combat.place_card(hand_index, slot)
    local card = battle.hand[hand_index]
    if not card then return end

    -- 检查是否有足够资源
    if card.cost > battle.player.blood then
        battle.message = "Need " .. card.cost .. " blood! Sacrifice a card first."
        return
    end

    -- 扣除资源
    battle.player.blood = battle.player.blood - card.cost

    -- 放置到场上
    battle.player.board[slot] = {
        id = card.id,
        name = card.name,
        attack = card.attack,
        hp = card.hp,
        max_hp = card.max_hp,
        sigils = card.sigils,
    }

    -- 从手牌移除
    table.remove(battle.hand, hand_index)
    battle.selected_card = nil

    battle.message = card.name .. " placed in slot " .. slot
end

function Combat.start_battle()
    battle.phase = "battle"
    battle.message = "Battle starts!"

    -- 执行战斗
    Combat.execute_battle()
end

function Combat.execute_battle()
    -- 玩家卡牌攻击
    for i = 1, BOARD_SLOTS do
        local card = battle.player.board[i]
        if card and card.hp > 0 then
            -- 检查对应位置是否有敌人
            local enemy_card = battle.enemy.board[i]
            if enemy_card and enemy_card.hp > 0 then
                -- 攻击敌方卡牌
                enemy_card.hp = enemy_card.hp - card.attack
            else
                -- 直接攻击敌方玩家
                battle.enemy.hp = battle.enemy.hp - card.attack
            end
        end
    end

    -- 敌方卡牌攻击
    for i = 1, BOARD_SLOTS do
        local card = battle.enemy.board[i]
        if card and card.hp > 0 then
            local player_card = battle.player.board[i]
            if player_card and player_card.hp > 0 then
                player_card.hp = player_card.hp - card.attack
            else
                battle.player.hp = battle.player.hp - card.attack
            end
        end
    end

    -- 清理死亡的卡牌
    for i = 1, BOARD_SLOTS do
        if battle.player.board[i] and battle.player.board[i].hp <= 0 then
            battle.player.blood = battle.player.blood + 1
            battle.player.board[i] = nil
        end
        if battle.enemy.board[i] and battle.enemy.board[i].hp <= 0 then
            battle.enemy.board[i] = nil
        end
    end

    -- 检查胜负
    if battle.enemy.hp <= 0 then
        battle.phase = "result"
        battle.message = "VICTORY! Press R to play again."
    elseif battle.player.hp <= 0 then
        battle.phase = "result"
        battle.message = "DEFEAT! Press R to retry."
    else
        -- 下一回合
        battle.turn = battle.turn + 1
        battle.phase = "play"

        -- 抽新牌
        if #battle.hand < 3 then
            Combat.draw_cards(1)
        end

        -- 敌人放置新卡
        Combat.enemy_play_card()

        battle.message = "Turn " .. battle.turn .. " - Place cards or press SPACE to battle!"
    end
end

function Combat.enemy_play_card()
    -- 找空位
    local empty_slots = {}
    for i = 1, BOARD_SLOTS do
        if not battle.enemy.board[i] then
            empty_slots[#empty_slots + 1] = i
        end
    end

    if #empty_slots > 0 then
        local slot = empty_slots[love.math.random(#empty_slots)]
        local card_types = {"stoat", "wolf", "bullfrog"}
        local id = card_types[love.math.random(#card_types)]
        local template = CardData.cards[id]

        if template then
            battle.enemy.board[slot] = {
                id = template.id,
                name = template.name,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.hp,
            }
        end
    end
end

return Combat