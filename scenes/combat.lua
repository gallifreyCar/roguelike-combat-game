-- scenes/combat.lua - 战斗场景
-- 卡牌放置 + 自动攻击 + 拖拽 + 献祭系统 + 关卡系统 + 牌组系统 + 印记系统 + 特效系统

local Combat = {}
local CardData = require("data.cards")
local LevelData = require("data.levels")
local State = require("core.state")
local Fonts = require("core.fonts")
local Deck = require("systems.deck")
local Settings = require("config.settings")
local Sigils = require("systems.sigils")
local Effects = require("systems.effects")

-- 从 Settings 获取配置
local BOARD_SLOTS = Settings.board_slots
local PLAYER_MAX_HP = Settings.player_max_hp
local MAX_BLOOD = Settings.max_blood

-- UI布局从 Settings
local HAND_X = Settings.hand_x
local HAND_Y = Settings.hand_y
local CARD_WIDTH = Settings.card_width
local CARD_HEIGHT = Settings.card_height

local UI_TITLE_HEIGHT = Settings.ui_title_height
local UI_ENEMY_AREA_Y = Settings.ui_enemy_area_y
local UI_SEPARATOR_Y = Settings.ui_separator_y
local UI_PLAYER_BOARD_Y = Settings.ui_player_board_y
local UI_BUTTON_AREA_Y = Settings.ui_button_area_y
local UI_STATUS_BAR_Y = Settings.ui_status_bar_y
local UI_HINT_Y = Settings.ui_hint_y

-- 战斗状态
local battle = {
    level = 1,           -- 当前关卡
    turn = 1,
    phase = "play",

    player = {
        hp = PLAYER_MAX_HP,
        max_hp = PLAYER_MAX_HP,
        blood = 1,
        max_blood = 1,
        board = {},
    },

    enemy = {
        hp = 10,
        max_hp = 10,
        board = {},
    },

    message = "",

    -- 战斗日志
    combat_log = {},
    log_timer = 0,

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

-- 添加战斗日志
local function add_log(msg)
    battle.combat_log[#battle.combat_log + 1] = {
        text = msg,
        time = 2.0,  -- 显示2秒
    }
    if #battle.combat_log > 5 then
        table.remove(battle.combat_log, 1)
    end
end

function Combat.enter()
    battle.turn = 1
    battle.phase = "play"
    battle.player.hp = PLAYER_MAX_HP
    battle.player.max_hp = PLAYER_MAX_HP
    battle.player.blood = 1
    battle.player.max_blood = 1

    init_board(battle.player.board)
    init_board(battle.enemy.board)

    -- 使用 Deck 模块初始化牌组
    if battle.level == 1 then
        Deck.reset()  -- 新游戏重置牌组
    end

    -- 第一回合抽3张牌
    Deck.draw_cards(3)

    -- 根据关卡生成敌人
    Combat.spawn_level_enemies()

    battle.dragging = false
    battle.dragging_index = nil

    local level_info = LevelData.get_level(battle.level)
    local level_name = level_info and level_info.name or "Level " .. battle.level
    battle.message = level_name .. " - Blood: 1/" .. MAX_BLOOD
end

function Combat.exit()
end

-- 抽牌（使用 Deck 模块）
function Combat.draw_cards(n)
    Deck.draw_cards(n)
end

function Combat.spawn_level_enemies()
    local level_info = LevelData.get_level(battle.level)
    if not level_info then return end

    -- 设置敌人HP
    battle.enemy.hp = 10 + battle.level * 2
    battle.enemy.max_hp = battle.enemy.hp

    -- 放置关卡定义的敌人
    for _, enemy in ipairs(level_info.enemies) do
        local template = CardData.cards[enemy.card]
        if template and enemy.slot then
            battle.enemy.board[enemy.slot] = {
                id = template.id,
                name = template.name,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.hp,
            }
        end
    end
end

-- 旧函数保留兼容
function Combat.spawn_enemy_cards()
    -- 第一回合只放1个弱敌
    local enemy_cards = {
        {id = "stoat", slot = 2},
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
    -- 更新战斗日志计时
    for i = #battle.combat_log, 1, -1 do
        battle.combat_log[i].time = battle.combat_log[i].time - dt
        if battle.combat_log[i].time <= 0 then
            table.remove(battle.combat_log, i)
        end
    end

    -- 更新特效
    Effects.update(dt)
end

function Combat.draw()
    love.graphics.clear(0.08, 0.06, 0.05)

    -- 绘制标题栏
    love.graphics.setColor(0.15, 0.12, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1280, UI_TITLE_HEIGHT)
    local level_info = LevelData.get_level(battle.level)
    local level_name = level_info and level_info.name or "Level " .. battle.level
    love.graphics.setColor(0.8, 0.7, 0.5)
    Fonts.print("⚔ " .. level_name .. " ⚔", 450, 12, 18)

    -- 分隔线
    love.graphics.setColor(0.25, 0.2, 0.15)
    love.graphics.rectangle("fill", 100, UI_SEPARATOR_Y, 870, 30)
    love.graphics.setColor(0.6, 0.5, 0.3)
    Fonts.print("─── YOUR BOARD ───", 420, UI_SEPARATOR_Y + 8, 14)

    Combat.draw_enemy_area()
    Combat.draw_player_board()
    Combat.draw_hand_panel()
    Combat.draw_status_bar()
    Combat.draw_battle_button()

    -- 绘制正在拖拽的卡牌
    local hand = Deck.get_hand()
    if battle.dragging and hand[battle.dragging_index] then
        Combat.draw_card(hand[battle.dragging_index],
                         battle.drag_x - battle.drag_offset_x,
                         battle.drag_y - battle.drag_offset_y,
                         true)
    end

    -- 消息显示在分隔线上方
    if battle.message then
        love.graphics.setColor(0.9, 0.8, 0.6)
        Fonts.print(battle.message, 300, 60)
    end

    -- 绘制特效
    Effects.draw()
end

function Combat.draw_enemy_area()
    -- 敌方HP（放在标题栏右侧）
    love.graphics.setColor(0.5, 0.15, 0.15)
    love.graphics.rectangle("fill", 1050, 8, 180, 32, 4, 4)
    love.graphics.setColor(0.8, 0.2, 0.2)
    local hp_w = (battle.enemy.hp / battle.enemy.max_hp) * 180
    love.graphics.rectangle("fill", 1050, 8, hp_w, 32, 4, 4)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("Enemy: " .. battle.enemy.hp .. "/" .. battle.enemy.max_hp, 1058, 13)

    -- 敌方格子（使用新的Y坐标）
    for i = 1, BOARD_SLOTS do
        local x = 150 + (i - 1) * 130
        local y = UI_ENEMY_AREA_Y

        love.graphics.setColor(0.12, 0.1, 0.08)
        love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        -- 边框
        love.graphics.setColor(0.4, 0.3, 0.2)
        love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        local card = battle.enemy.board[i]
        if card then
            Combat.draw_card(card, x, y, false)
        end
    end
end

function Combat.draw_player_board()
    -- 玩家格子（使用新的Y坐标）
    for i = 1, BOARD_SLOTS do
        local x = 150 + (i - 1) * 130
        local y = UI_PLAYER_BOARD_Y

        -- 格子高亮
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
            -- 提示可以献祭
            love.graphics.setColor(0.6, 0.5, 0.3)
            Fonts.print("右键献祭", x + 15, y + 115)
        end
    end
end

function Combat.draw_hand_panel()
    -- 右侧手牌面板
    love.graphics.setColor(0.1, 0.08, 0.06)
    love.graphics.rectangle("fill", 1070, 50, 180, 500, 8, 8)

    love.graphics.setColor(0.7, 0.6, 0.4)
    Fonts.print("YOUR HAND", 1095, 60)
    Fonts.print("(" .. Deck.hand_size() .. " cards)", 1100, 80)

    local hand = Deck.get_hand()
    for i, card in ipairs(hand) do
        local x = HAND_X
        local y = HAND_Y + (i - 1) * 90

        if not (battle.dragging and battle.dragging_index == i) then
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
    Fonts.print(card.name, x + 8, y + 8)

    -- Cost
    if card.cost then
        love.graphics.setColor(0.9, 0.4, 0.3)
        Fonts.print("Cost:" .. card.cost, x + 8, y + 28)
    end

    -- 属性
    love.graphics.setColor(1, 0.75, 0.3)
    Fonts.print("ATK:" .. card.attack, x + 8, y + 50)
    love.graphics.setColor(0.4, 0.8, 0.4)
    Fonts.print("HP:" .. card.hp, x + 55, y + 50)

    -- 血量条
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x + 8, y + 75, 84, 8)
    love.graphics.setColor(0.3, 0.7, 0.3)
    local hp_bar = (card.hp / card.max_hp) * 84
    love.graphics.rectangle("fill", x + 8, y + 75, hp_bar, 8)
end

function Combat.draw_card_small(card, x, y, hover)
    if hover then
        love.graphics.setColor(0.35, 0.45, 0.35)
    else
        love.graphics.setColor(0.25, 0.22, 0.18)
    end
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, 80, 4, 4)

    love.graphics.setColor(0.5, 0.4, 0.25)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, 80, 4, 4)

    love.graphics.setColor(1, 1, 1)
    Fonts.print(card.name, x + 5, y + 5)

    -- Cost用红色突出
    love.graphics.setColor(0.9, 0.3, 0.3)
    Fonts.print("$" .. card.cost, x + 5, y + 25)

    love.graphics.setColor(1, 0.75, 0.3)
    Fonts.print("A:" .. card.attack, x + 5, y + 45)
    love.graphics.setColor(0.4, 0.8, 0.4)
    Fonts.print("H:" .. card.hp, x + 45, y + 45)

    if hover then
        love.graphics.setColor(0.6, 0.6, 0.4)
        Fonts.print("[drag]", x + 55, y + 60)
    end
end

function Combat.draw_status_bar()
    -- 状态栏背景
    love.graphics.setColor(0.12, 0.1, 0.08)
    love.graphics.rectangle("fill", 50, UI_STATUS_BAR_Y, 920, 35, 4, 4)

    -- 玩家HP
    love.graphics.setColor(0.15, 0.15, 0.35)
    love.graphics.rectangle("fill", 60, UI_STATUS_BAR_Y + 5, 160, 25, 4, 4)
    love.graphics.setColor(0.2, 0.5, 0.7)
    local hp_w = (battle.player.hp / battle.player.max_hp) * 160
    love.graphics.rectangle("fill", 60, UI_STATUS_BAR_Y + 5, hp_w, 25, 4, 4)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("HP: " .. battle.player.hp .. "/" .. battle.player.max_hp, 70, UI_STATUS_BAR_Y + 8)

    -- Blood
    love.graphics.setColor(0.6, 0.2, 0.2)
    love.graphics.rectangle("fill", 240, UI_STATUS_BAR_Y + 5, 120, 25, 4, 4)
    love.graphics.setColor(1, 0.8, 0.3)
    Fonts.print("Blood: " .. battle.player.blood .. "/" .. MAX_BLOOD, 250, UI_STATUS_BAR_Y + 8)

    -- 回合信息
    love.graphics.setColor(0.7, 0.6, 0.4)
    Fonts.print("Turn: " .. battle.turn, 380, UI_STATUS_BAR_Y + 8)

    -- 牌组信息
    local deck_info = Deck.get_info()
    love.graphics.setColor(0.5, 0.5, 0.7)
    Fonts.print("Deck: " .. deck_info.draw_pile_size, 460, UI_STATUS_BAR_Y + 8)
    love.graphics.setColor(0.6, 0.5, 0.4)
    Fonts.print("Discard: " .. deck_info.discard_pile_size, 550, UI_STATUS_BAR_Y + 8)

    -- 操作提示（底部）
    love.graphics.setColor(0.5, 0.45, 0.4)
    Fonts.print("Left-click: drag  |  Right-click: sacrifice  |  Space: battle", 50, UI_HINT_Y + 20, 13)

    -- 战斗日志（右侧悬浮）
    if #battle.combat_log > 0 then
        for i, log in ipairs(battle.combat_log) do
            local alpha = math.min(1, log.time)
            love.graphics.setColor(1, 1, 0.8, alpha)
            Fonts.print(log.text, 700, 150 + (i - 1) * 22, 14)
        end
    end
end

function Combat.draw_battle_button()
    -- 战斗按钮区域
    local btn_x = 600
    local btn_y = UI_BUTTON_AREA_Y + 5
    local btn_w = 160
    local btn_h = 55

    if battle.phase == "play" then
        -- 检测鼠标悬停
        local mx, my = love.mouse.getPosition()
        local hover = mx >= btn_x and mx <= btn_x + btn_w and my >= btn_y and my <= btn_y + btn_h

        -- 按钮背景（悬停时高亮）
        if hover then
            love.graphics.setColor(0.3, 0.5, 0.3)
        else
            love.graphics.setColor(0.2, 0.35, 0.2)
        end
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)

        -- 边框
        love.graphics.setColor(0.5, 0.7, 0.5)
        love.graphics.rectangle("line", btn_x, btn_y, btn_w, btn_h, 8, 8)

        -- 文字
        love.graphics.setColor(1, 0.95, 0.7)
        Fonts.print("⚔ BATTLE ⚔", btn_x + 35, btn_y + 18, 18)

        -- 快捷键提示
        love.graphics.setColor(0.6, 0.6, 0.5)
        Fonts.print("[Space]", btn_x + 50, btn_y + 40, 12)

    elseif battle.phase == "battle" then
        love.graphics.setColor(0.4, 0.35, 0.25)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
        love.graphics.setColor(0.8, 0.7, 0.5)
        Fonts.print("Battle in progress...", btn_x + 20, btn_y + 20, 14)

    elseif battle.phase == "result" then
        local max_levels = LevelData.get_max_levels()
        if battle.enemy.hp <= 0 and battle.level < max_levels then
            love.graphics.setColor(0.3, 0.5, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.9, 0.6)
            Fonts.print("→ Next Level", btn_x + 30, btn_y + 20, 16)
        elseif battle.enemy.hp <= 0 then
            love.graphics.setColor(0.4, 0.6, 0.4)
            love.graphics.rectangle("fill", btn_x - 20, btn_y, btn_w + 40, btn_h, 8, 8)
            love.graphics.setColor(1, 1, 0.8)
            Fonts.print("🏆 VICTORY! 🏆", btn_x + 10, btn_y + 18, 18)
        else
            love.graphics.setColor(0.5, 0.3, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.6, 0.6)
            Fonts.print("Retry Level 1", btn_x + 30, btn_y + 20, 16)
        end
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
    -- 右键献祭场上的牌
    if button == 2 and battle.phase == "play" then
        for i = 1, BOARD_SLOTS do
            local slot_x = 150 + (i - 1) * 130
            local slot_y = UI_PLAYER_BOARD_Y

            if x >= slot_x and x <= slot_x + CARD_WIDTH and y >= slot_y and y <= slot_y + CARD_HEIGHT then
                local card = battle.player.board[i]
                if card then
                    -- 献祭：获得blood（有上限）
                    if battle.player.blood < MAX_BLOOD then
                        battle.player.blood = battle.player.blood + 1
                        battle.message = "Sacrificed " .. card.name .. " for +1 Blood!"
                        battle.player.board[i] = nil
                    else
                        battle.message = "Blood already at max (" .. MAX_BLOOD .. ")!"
                    end
                    return
                end
            end
        end
    end

    if button ~= 1 then return end

    -- 战斗按钮区域
    local btn_x = 600
    local btn_y = UI_BUTTON_AREA_Y + 5
    local btn_w = 160
    local btn_h = 55

    if battle.phase == "play" then
        -- 检测点击手牌
        local hand = Deck.get_hand()
        for i = 1, #hand do
            local card_x = HAND_X
            local card_y = HAND_Y + (i - 1) * 90

            if x >= card_x and x <= card_x + CARD_WIDTH and y >= card_y and y <= card_y + 80 then
                battle.dragging = true
                battle.dragging_index = i
                battle.drag_x = x
                battle.drag_y = y
                battle.drag_offset_x = x - card_x
                battle.drag_offset_y = y - card_y
                battle.message = "Dragging " .. hand[i].name
                return
            end
        end

        -- 检测点击战斗按钮
        if x >= btn_x and x <= btn_x + btn_w and y >= btn_y and y <= btn_y + btn_h then
            Combat.start_battle()
            return
        end

    elseif battle.phase == "result" then
        -- 检测点击结果按钮
        if x >= btn_x and x <= btn_x + btn_w and y >= btn_y and y <= btn_y + btn_h then
            local max_levels = LevelData.get_max_levels()
            if battle.enemy.hp <= 0 and battle.level < max_levels then
                -- 进入下一关
                battle.level = battle.level + 1
                Combat.enter()
            else
                -- 重新开始
                battle.level = 1
                Combat.enter()
            end
        end
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
        for i = 1, BOARD_SLOTS do
            local slot_x = 150 + (i - 1) * 130
            local slot_y = UI_PLAYER_BOARD_Y

            if x >= slot_x and x <= slot_x + CARD_WIDTH and y >= slot_y and y <= slot_y + CARD_HEIGHT then
                if battle.player.board[i] == nil then
                    Combat.place_card(battle.dragging_index, i)
                else
                    battle.message = "Slot occupied! Sacrifice first with RIGHT-click."
                end
                break
            end
        end

        battle.dragging = false
        battle.dragging_index = nil
    end
end

function Combat.place_card(hand_index, slot)
    local card = Deck.place_card(hand_index)
    if not card then return end

    if card.cost > battle.player.blood then
        battle.message = "Need " .. card.cost .. " Blood! Right-click a card to sacrifice."
        -- 放回手牌
        Deck.draw_cards(0)  -- 什么都不做，只是占位
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

    battle.message = card.name .. " placed!"
end

function Combat.start_battle()
    battle.phase = "battle"
    battle.combat_log = {}
    add_log("=== BATTLE START ===")
    Combat.execute_battle()
end

function Combat.execute_battle()
    -- 玩家攻击（处理印记）
    for i = 1, BOARD_SLOTS do
        local card = battle.player.board[i]
        if card and card.hp > 0 then
            local enemy_card = battle.enemy.board[i]
            local attack_count = Sigils.get_attack_count(card)

            -- 计算卡牌位置
            local card_x = 150 + (i - 1) * 130
            local enemy_x = 150 + (i - 1) * 130

            for _ = 1, attack_count do
                if enemy_card and enemy_card.hp > 0 then
                    local dmg = card.attack
                    enemy_card.hp = enemy_card.hp - dmg
                    add_log(card.name .. " → " .. enemy_card.name .. " (-" .. dmg .. " HP)")

                    -- 伤害数字特效
                    Effects.damage(dmg, enemy_x + 50, UI_ENEMY_AREA_Y + 30)
                    Effects.attack_flash(enemy_x, UI_ENEMY_AREA_Y, CARD_WIDTH, CARD_HEIGHT)

                    -- 处理毒印记
                    if Sigils.has(card, "poison") then
                        enemy_card.poisoned = (enemy_card.poisoned or 0) + 1
                    end
                else
                    -- 空列，检查是否有飞行印记
                    if Sigils.has(card, "air_strike") or not enemy_card then
                        local dmg = card.attack
                        battle.enemy.hp = battle.enemy.hp - dmg
                        add_log(card.name .. " → Enemy (-" .. dmg .. " HP)")

                        -- 敌方HP伤害数字
                        Effects.damage(dmg, 1100, 20)
                    end
                end
            end
        end
    end

    -- 敌方攻击
    for i = 1, BOARD_SLOTS do
        local card = battle.enemy.board[i]
        if card and card.hp > 0 then
            local player_card = battle.player.board[i]

            -- 计算卡牌位置
            local card_x = 150 + (i - 1) * 130

            if player_card and player_card.hp > 0 then
                local dmg = card.attack
                -- 恶臭减攻击
                if player_card.stinky_debuff then
                    dmg = math.max(0, dmg - player_card.stinky_debuff)
                end
                player_card.hp = player_card.hp - dmg
                add_log(card.name .. " → " .. player_card.name .. " (-" .. dmg .. " HP)")

                -- 伤害数字特效
                Effects.damage(dmg, card_x + 50, UI_PLAYER_BOARD_Y + 30)
                Effects.attack_flash(card_x, UI_PLAYER_BOARD_Y, CARD_WIDTH, CARD_HEIGHT)
            else
                local dmg = card.attack
                battle.player.hp = battle.player.hp - dmg
                add_log(card.name .. " → YOU (-" .. dmg .. " HP)")

                -- 玩家HP伤害数字
                Effects.damage(dmg, 100, UI_STATUS_BAR_Y)
            end
        end
    end

    -- 处理毒伤害（回合结束）
    for i = 1, BOARD_SLOTS do
        local card = battle.player.board[i]
        if card and card.poisoned and card.poisoned > 0 then
            card.hp = card.hp - card.poisoned
            add_log(card.name .. " takes " .. card.poisoned .. " poison damage!")
            card.poisoned = card.poisoned - 1
        end
        local ecard = battle.enemy.board[i]
        if ecard and ecard.poisoned and ecard.poisoned > 0 then
            ecard.hp = ecard.hp - ecard.poisoned
            add_log(ecard.name .. " takes " .. ecard.poisoned .. " poison damage!")
            ecard.poisoned = ecard.poisoned - 1
        end
    end

    -- 清理死亡（处理不死印记）
    for i = 1, BOARD_SLOTS do
        if battle.player.board[i] and battle.player.board[i].hp <= 0 then
            local card = battle.player.board[i]
            if Sigils.has(card, "undead") and not card.revived then
                card.revived = true
                card.hp = 1
                add_log(card.name .. " revived!")
            else
                add_log("Your " .. card.name .. " died!")
                battle.player.board[i] = nil
            end
        end
        if battle.enemy.board[i] and battle.enemy.board[i].hp <= 0 then
            local card = battle.enemy.board[i]
            if Sigils.has(card, "undead") and not card.revived then
                card.revived = true
                card.hp = 1
                add_log("Enemy " .. card.name .. " revived!")
            else
                add_log("Enemy " .. card.name .. " died!")
                battle.enemy.board[i] = nil
            end
        end
    end

    -- 胜负判定
    if battle.enemy.hp <= 0 then
        battle.phase = "result"
        local max_levels = LevelData.get_max_levels()
        if battle.level >= max_levels then
            battle.message = "VICTORY! All levels cleared! Click to restart."
        else
            battle.message = "VICTORY! Click to enter Level " .. (battle.level + 1)
        end
    elseif battle.player.hp <= 0 then
        battle.phase = "result"
        battle.message = "DEFEAT! Click to retry from Level 1."
    else
        -- 下一回合：Blood +1（有上限）
        battle.turn = battle.turn + 1
        battle.phase = "play"

        -- 每回合+1 blood，最多MAX_BLOOD
        battle.player.blood = math.min(battle.player.blood + 1, MAX_BLOOD)

        if Deck.hand_size() < 3 then
            Combat.draw_cards(1)
        end

        Combat.enemy_play_card()
        battle.message = "Turn " .. battle.turn .. " - Blood: " .. battle.player.blood .. "/" .. MAX_BLOOD
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

        -- 敌人卡牌按难度递增
        local card_pool
        if battle.turn <= 2 then
            card_pool = {"stoat", "rat", "bullfrog"}
        elseif battle.turn <= 4 then
            card_pool = {"stoat", "wolf", "adder", "skunk"}
        else
            card_pool = {"wolf", "grizzly", "moose", "mant"}
        end

        local id = card_pool[love.math.random(#card_pool)]
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