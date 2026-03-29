-- scenes/combat.lua - 战斗场景（邪恶冥刻风格）
-- 卡牌放置 + 自动攻击 + 拖拽功能

local Combat = {}
local CardData = require("data.cards")
local State = require("core.state")

-- 战斗配置
local BOARD_SLOTS = 4
local PLAYER_MAX_HP = 10

-- 手牌区域（右侧）
local HAND_X = 1100
local HAND_Y = 100
local CARD_WIDTH = 100
local CARD_HEIGHT = 130

-- 战斗状态
local battle = {
    turn = 1,
    phase = "play",

    player = {
        hp = PLAYER_MAX_HP,
        max_hp = PLAYER_MAX_HP,
        blood = 0,
        board = {},
    },

    enemy = {
        hp = 10,
        max_hp = 10,
        board = {},
    },

    hand = {},
    message = "",

    -- 拖拽状态
    dragging = false,
    dragging_index = nil,
    drag_x = 0,
    drag_y = 0,
    drag_offset_x = 0,
    drag_offset_y = 0,
}

local function init_board(board)
    for i = 1, BOARD_SLOTS do
        board[i] = nil
    end
end

function Combat.enter()
    battle.turn = 1
    battle.phase = "play"
    battle.player.hp = PLAYER_MAX_HP
    battle.player.blood = 0
    battle.player.max_hp = PLAYER_MAX_HP
    battle.enemy.hp = 10
    battle.enemy.max_hp = 10

    init_board(battle.player.board)
    init_board(battle.enemy.board)

    battle.hand = {}
    Combat.draw_cards(4)

    Combat.spawn_enemy_cards()

    battle.dragging = false
    battle.dragging_index = nil
    battle.message = "Drag cards from right panel to your slots!"
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

    Combat.draw_enemy_area()
    Combat.draw_player_board()
    Combat.draw_hand_panel()
    Combat.draw_status()

    -- 绘制正在拖拽的卡牌（最后绘制，在最上层）
    if battle.dragging and battle.hand[battle.dragging_index] then
        Combat.draw_card(battle.hand[battle.dragging_index],
                         battle.drag_x - battle.drag_offset_x,
                         battle.drag_y - battle.drag_offset_y,
                         true)
    end

    if battle.message then
        love.graphics.setColor(0.9, 0.8, 0.6)
        love.graphics.print(battle.message, 300, 50)
    end
end

function Combat.draw_enemy_area()
    -- 敌方HP
    love.graphics.setColor(0.5, 0.15, 0.15)
    love.graphics.rectangle("fill", 50, 15, 180, 25)
    love.graphics.setColor(0.8, 0.2, 0.2)
    local hp_w = (battle.enemy.hp / battle.enemy.max_hp) * 180
    love.graphics.rectangle("fill", 50, 15, hp_w, 25)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Enemy: " .. battle.enemy.hp .. "/" .. battle.enemy.max_hp, 55, 18)

    -- 敌方格子
    for i = 1, BOARD_SLOTS do
        local x = 150 + (i - 1) * 130
        local y = 80

        love.graphics.setColor(0.12, 0.1, 0.08)
        love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        local card = battle.enemy.board[i]
        if card then
            Combat.draw_card(card, x, y, false)
        end
    end
end

function Combat.draw_player_board()
    -- 玩家HP和Blood
    love.graphics.setColor(0.15, 0.15, 0.35)
    love.graphics.rectangle("fill", 50, 460, 180, 25)
    love.graphics.setColor(0.2, 0.4, 0.7)
    local hp_w = (battle.player.hp / battle.player.max_hp) * 180
    love.graphics.rectangle("fill", 50, 460, hp_w, 25)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("You: " .. battle.player.hp .. "/" .. battle.player.max_hp, 55, 463)

    -- Blood
    love.graphics.setColor(0.6, 0.15, 0.15)
    love.graphics.print("Blood: " .. battle.player.blood, 250, 463)

    -- 玩家格子
    for i = 1, BOARD_SLOTS do
        local x = 150 + (i - 1) * 130
        local y = 280

        -- 格子高亮（拖拽悬停时）
        if battle.dragging then
            local mx, my = love.mouse.getPosition()
            if mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + CARD_HEIGHT then
                if battle.player.board[i] == nil then
                    love.graphics.setColor(0.25, 0.35, 0.25)
                else
                    love.graphics.setColor(0.35, 0.25, 0.25)
                end
            else
                love.graphics.setColor(0.18, 0.15, 0.12)
            end
        else
            love.graphics.setColor(0.18, 0.15, 0.12)
        end
        love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        -- 边框
        love.graphics.setColor(0.35, 0.28, 0.2)
        love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        local card = battle.player.board[i]
        if card then
            Combat.draw_card(card, x, y, true)
        end
    end
end

function Combat.draw_hand_panel()
    -- 右侧手牌面板背景
    love.graphics.setColor(0.1, 0.08, 0.06)
    love.graphics.rectangle("fill", 1070, 50, 180, 500, 8, 8)

    love.graphics.setColor(0.7, 0.6, 0.4)
    love.graphics.print("YOUR HAND", 1095, 60)
    love.graphics.print("(" .. #battle.hand .. " cards)", 1100, 80)

    -- 绘制手牌（垂直排列）
    for i, card in ipairs(battle.hand) do
        local x = HAND_X
        local y = HAND_Y + (i - 1) * 90

        -- 跳过正在拖拽的卡
        if not (battle.dragging and battle.dragging_index == i) then
            -- 检查鼠标悬停
            local mx, my = love.mouse.getPosition()
            local hover = mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + 80

            Combat.draw_card_small(card, x, y, hover)
        end
    end
end

function Combat.draw_card(card, x, y, is_player)
    -- 背景
    if is_player then
        love.graphics.setColor(0.22, 0.32, 0.22)
    else
        love.graphics.setColor(0.32, 0.22, 0.22)
    end
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

    -- 边框
    love.graphics.setColor(0.5, 0.4, 0.25)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

    -- 名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(card.name, x + 8, y + 8)

    -- Cost (只有玩家卡牌有)
    if card.cost then
        love.graphics.setColor(0.7, 0.25, 0.25)
        love.graphics.print("Cost:" .. card.cost, x + 8, y + 28)
    end

    -- 属性
    love.graphics.setColor(1, 0.75, 0.3)
    love.graphics.print("ATK:" .. card.attack, x + 8, y + 50)
    love.graphics.setColor(0.4, 0.8, 0.4)
    love.graphics.print("HP:" .. card.hp, x + 55, y + 50)

    -- 血量条
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x + 8, y + 75, 84, 8)
    love.graphics.setColor(0.3, 0.7, 0.3)
    local hp_bar = (card.hp / card.max_hp) * 84
    love.graphics.rectangle("fill", x + 8, y + 75, hp_bar, 8)
end

function Combat.draw_card_small(card, x, y, hover)
    -- 小卡牌（手牌列表用）
    if hover then
        love.graphics.setColor(0.35, 0.45, 0.35)
    else
        love.graphics.setColor(0.25, 0.22, 0.18)
    end
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, 80, 4, 4)

    love.graphics.setColor(0.5, 0.4, 0.25)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, 80, 4, 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(card.name, x + 5, y + 5)

    love.graphics.setColor(0.7, 0.25, 0.25)
    love.graphics.print("$" .. card.cost, x + 5, y + 25)

    love.graphics.setColor(1, 0.75, 0.3)
    love.graphics.print("A:" .. card.attack, x + 5, y + 45)
    love.graphics.setColor(0.4, 0.8, 0.4)
    love.graphics.print("H:" .. card.hp, x + 45, y + 45)

    if hover then
        love.graphics.setColor(0.6, 0.6, 0.4)
        love.graphics.print("[drag]", x + 55, y + 60)
    end
end

function Combat.draw_status()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("Turn " .. battle.turn, 50, 50)

    local phase_text = {
        play = "Place cards then click BATTLE",
        battle = "Fighting...",
        result = "Game Over",
    }
    love.graphics.print(phase_text[battle.phase] or "", 50, 70)

    -- 战斗按钮
    if battle.phase == "play" then
        love.graphics.setColor(0.25, 0.4, 0.25)
        love.graphics.rectangle("fill", 400, 430, 150, 40, 5, 5)
        love.graphics.setColor(0.9, 0.85, 0.5)
        love.graphics.print(">> BATTLE <<", 430, 442)
    end
end

function Combat.keypressed(key)
    if key == "space" and battle.phase == "play" then
        Combat.start_battle()
    end
    if key == "r" and battle.phase == "result" then
        Combat.enter()
    end
end

function Combat.mousepressed(x, y, button)
    if button ~= 1 then return end

    if battle.phase == "play" then
        -- 检测点击手牌
        for i = 1, #battle.hand do
            local card_x = HAND_X
            local card_y = HAND_Y + (i - 1) * 90

            if x >= card_x and x <= card_x + CARD_WIDTH and y >= card_y and y <= card_y + 80 then
                battle.dragging = true
                battle.dragging_index = i
                battle.drag_x = x
                battle.drag_y = y
                battle.drag_offset_x = x - card_x
                battle.drag_offset_y = y - card_y
                battle.message = "Dragging " .. battle.hand[i].name .. " - drop on a slot!"
                return
            end
        end

        -- 检测点击战斗按钮
        if x >= 400 and x <= 550 and y >= 430 and y <= 470 then
            Combat.start_battle()
            return
        end

    elseif battle.phase == "result" then
        Combat.enter()
    end
end

function Combat.mousemoved(x, y, dx, dy)
    if battle.dragging then
        battle.drag_x = x
        battle.drag_y = y
    end
end

function Combat.mousereleased(x, y, button)
    if button ~= 1 then return end

    if battle.dragging and battle.dragging_index then
        -- 检测放到哪个格子
        for i = 1, BOARD_SLOTS do
            local slot_x = 150 + (i - 1) * 130
            local slot_y = 280

            if x >= slot_x and x <= slot_x + CARD_WIDTH and y >= slot_y and y <= slot_y + CARD_HEIGHT then
                if battle.player.board[i] == nil then
                    Combat.place_card(battle.dragging_index, i)
                else
                    battle.message = "Slot " .. i .. " is occupied!"
                end
                break
            end
        end

        battle.dragging = false
        battle.dragging_index = nil
    end
end

function Combat.place_card(hand_index, slot)
    local card = battle.hand[hand_index]
    if not card then return end

    if card.cost > battle.player.blood then
        battle.message = "Need " .. card.cost .. " Blood! Your cards must die first."
        return
    end

    battle.player.blood = battle.player.blood - card.cost

    battle.player.board[slot] = {
        id = card.id,
        name = card.name,
        attack = card.attack,
        hp = card.hp,
        max_hp = card.max_hp,
        sigils = card.sigils,
    }

    table.remove(battle.hand, hand_index)
    battle.message = card.name .. " placed! (-" .. card.cost .. " Blood)"
end

function Combat.start_battle()
    battle.phase = "battle"
    battle.message = "Battle!"

    Combat.execute_battle()
end

function Combat.execute_battle()
    -- 玩家攻击
    for i = 1, BOARD_SLOTS do
        local card = battle.player.board[i]
        if card and card.hp > 0 then
            local enemy_card = battle.enemy.board[i]
            if enemy_card and enemy_card.hp > 0 then
                enemy_card.hp = enemy_card.hp - card.attack
            else
                battle.enemy.hp = battle.enemy.hp - card.attack
            end
        end
    end

    -- 敌方攻击
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

    -- 清理死亡
    for i = 1, BOARD_SLOTS do
        if battle.player.board[i] and battle.player.board[i].hp <= 0 then
            battle.player.blood = battle.player.blood + 1
            battle.player.board[i] = nil
        end
        if battle.enemy.board[i] and battle.enemy.board[i].hp <= 0 then
            battle.enemy.board[i] = nil
        end
    end

    -- 胜负判定
    if battle.enemy.hp <= 0 then
        battle.phase = "result"
        battle.message = "VICTORY! Click to play again."
    elseif battle.player.hp <= 0 then
        battle.phase = "result"
        battle.message = "DEFEAT! Click to retry."
    else
        battle.turn = battle.turn + 1
        battle.phase = "play"

        if #battle.hand < 3 then
            Combat.draw_cards(1)
        end

        Combat.enemy_play_card()
        battle.message = "Turn " .. battle.turn .. " - Drag cards to fight!"
    end
end

function Combat.enemy_play_card()
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