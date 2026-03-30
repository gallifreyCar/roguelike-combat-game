-- scenes/combat.lua - 战斗场景
-- 卡牌放置 + 自动攻击 + 拖拽 + 献祭系统 + 关卡系统 + 牌组系统 + 印记系统 + 特效系统 + 敌人意图

local Combat = {}
local CardData = require("data.cards")
local LevelData = require("data.levels")
local State = require("core.state")
local Fonts = require("core.fonts")
local Deck = require("systems.deck")
local Settings = require("config.settings")
local Sigils = require("systems.sigils")
local Effects = require("systems.effects")
local Enemy = require("systems.enemy")
local Map = require("systems.map")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Events = require("core.events")

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

-- 从奖励场景返回后继续下一关
function Combat.resume()
    battle.level = battle.level + 1
    Combat.enter()
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
                -- 敌人意图
                intent = Combat.roll_enemy_intent(),
            }
        end
    end
end

-- 随机敌人意图
function Combat.roll_enemy_intent()
    local roll = love.math.random()
    if roll < 0.6 then
        return {type = "attack", value = love.math.random(2, 4)}
    elseif roll < 0.85 then
        return {type = "defend", value = love.math.random(2, 3)}
    else
        return {type = "buff", value = 1}
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
    Theme.setColor("bg_primary")
    love.graphics.clear()

    -- 绘制标题栏
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", 0, 0, Layout.get_size(), UI_TITLE_HEIGHT)
    local level_info = LevelData.get_level(battle.level)
    local level_name = level_info and level_info.name or "Level " .. battle.level
    Components.text(">> " .. level_name .. " <<", Layout.get_size() / 2, 12, {
        color = "text_secondary",
        size = 18,
        align = "center",
    })

    -- 分隔线
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", 100, UI_SEPARATOR_Y, 870, 30)
    Components.text("─── " .. I18n.t("your_board") .. " ───", Layout.get_size() / 2, UI_SEPARATOR_Y + 8, {
        color = "text_secondary",
        align = "center",
    })

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

    -- 消息显示
    if battle.message then
        Components.text(battle.message, 300, 60, {color = "text_secondary"})
    end

    -- 绘制特效
    Effects.draw()
end

function Combat.draw_enemy_area()
    -- 敌方HP
    Theme.setColor("accent_red", 0.3)
    love.graphics.rectangle("fill", Settings.enemy_hp_bar_x, Settings.enemy_hp_bar_y,
                            Settings.enemy_hp_bar_width, Settings.enemy_hp_bar_height, 4, 4)
    Theme.setColor("accent_red")
    local hp_w = (battle.enemy.hp / battle.enemy.max_hp) * Settings.enemy_hp_bar_width
    love.graphics.rectangle("fill", Settings.enemy_hp_bar_x, Settings.enemy_hp_bar_y, hp_w,
                            Settings.enemy_hp_bar_height, 4, 4)
    Components.text("Enemy: " .. battle.enemy.hp .. "/" .. battle.enemy.max_hp,
                    Settings.enemy_hp_bar_x + 8, Settings.enemy_hp_bar_y + 5, {
        color = "text_value",
    })

    -- 敌方格子
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local y = UI_ENEMY_AREA_Y

        Theme.setColor("bg_slot")
        love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)
        Theme.setColor("border_gold", 0.5)
        love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        local card = battle.enemy.board[i]
        if card then
            Combat.draw_card(card, x, y, false)
        end
    end
end

function Combat.draw_player_board()
    -- 玩家格子
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local y = UI_PLAYER_BOARD_Y

        -- 格子高亮
        if battle.dragging then
            local mx, my = love.mouse.getPosition()
            if mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + CARD_HEIGHT then
                Theme.setColor(battle.player.board[i] == nil and "bg_slot_hover" or "accent_red", 0.3)
            else
                Theme.setColor("bg_slot")
            end
        else
            Theme.setColor("bg_slot")
        end
        love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        -- 边框
        Theme.setColor("border_gold", 0.5)
        love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

        local card = battle.player.board[i]
        if card then
            Combat.draw_card(card, x, y, true)
            -- 提示可以献祭
            Components.text(I18n.t("right_click_sacrifice"), x + 15, y + 115, {
                color = "text_hint",
                size = 12,
            })
        end
    end
end

function Combat.draw_hand_panel()
    -- 右侧手牌面板
    local panel = Layout.hand_panel()
    Components.panel(panel.x, panel.y, panel.width, panel.height, {
        bg = "bg_panel",
    })

    Components.text("YOUR HAND", panel.x + 25, 60, {color = "text_secondary"})
    Components.text("(" .. Deck.hand_size() .. " " .. I18n.t("cards") .. ")", panel.x + 30, 80, {
        color = "text_hint",
    })

    local hand = Deck.get_hand()
    for i, card in ipairs(hand) do
        local x = panel.x + 30
        local y = HAND_Y + (i - 1) * 90

        if not (battle.dragging and battle.dragging_index == i) then
            local mx, my = love.mouse.getPosition()
            local hover = mx >= x and mx <= x + CARD_WIDTH and my >= y and my <= y + 80
            Combat.draw_card_small(card, x, y, hover)
        end
    end
end

function Combat.draw_card(card, x, y, is_player)
    -- 卡牌阴影
    Theme.setColor("bg_primary", 0.3)
    love.graphics.rectangle("fill", x + 3, y + 3, CARD_WIDTH, CARD_HEIGHT, 5, 5)

    -- 背景
    Theme.setColor(is_player and "bg_card" or "bg_card_enemy")
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

    -- 金色边框
    Theme.setColor("border_gold")
    love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 5, 5)

    -- 卡牌头部区域
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", x + 2, y + 2, CARD_WIDTH - 4, 25, 3, 3)

    -- 名称（使用翻译）
    Components.text(I18n.card_name(card.id), x + 8, y + 6, {color = "text_primary", size = 14})

    -- Cost（红圈白字）
    Theme.setColor("accent_red")
    love.graphics.circle("fill", x + 15, y + 45, 14)
    Components.text(tostring(card.cost), x + 11, y + 38, {color = "text_value", size = 14})

    -- 属性
    Components.text("ATK:", x + 8, y + 50, {color = "accent_gold", size = 11})
    Components.text(tostring(card.attack), x + 40, y + 50, {color = "text_value", size = 14})

    Components.text("HP:", x + 55, y + 50, {color = "accent_red", size = 11})
    Components.text(tostring(card.hp), x + 78, y + 50, {color = "text_value", size = 14})

    -- 血量条
    local hp_ratio = card.hp / (card.max_hp or card.hp)
    local hp_color = hp_ratio > 0.5 and "hp_high" or (hp_ratio > 0.25 and "hp_mid" or "hp_low")
    Components.progress_bar(x + 8, y + 95, 84, 10, card.hp, card.max_hp or card.hp, {
        fill = hp_color,
        bg = "bg_slot",
        radius = 2,
    })

    -- 印记指示
    if card.sigils and #card.sigils > 0 then
        love.graphics.setColor(0.8, 0.6, 0.4)
        Fonts.print("*" .. #card.sigils, x + 75, y + 110, 12)
    end

    -- 敌人意图显示（敌方卡牌）
    if not is_player and card.intent then
        local intent = card.intent
        local intent_text, intent_color

        if intent.type == "attack" then
            intent_text = "ATK:" .. intent.value
            intent_color = {1, 0.3, 0.3}
        elseif intent.type == "defend" then
            intent_text = "DEF:" .. intent.value
            intent_color = {0.3, 0.6, 1}
        elseif intent.type == "buff" then
            intent_text = "BUF"
            intent_color = {1, 0.8, 0.3}
        else
            intent_text = "?"
            intent_color = {0.7, 0.7, 0.7}
        end

        -- 意图背景
        love.graphics.setColor(0.1, 0.1, 0.15, 0.8)
        love.graphics.rectangle("fill", x + CARD_WIDTH - 35, y + 2, 32, 18, 3, 3)
        love.graphics.setColor(intent_color[1], intent_color[2], intent_color[3])
        Fonts.print(intent_text, x + CARD_WIDTH - 32, y + 4, 12)
    end
end

function Combat.draw_card_small(card, x, y, hover)
    if hover then
        Theme.setColor("bg_slot_hover")
    else
        Theme.setColor("bg_slot")
    end
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, 80, 4, 4)

    Theme.setColor("border_gold", 0.5)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, 80, 4, 4)

    -- 名称（使用翻译）
    Components.text(I18n.card_name(card.id), x + 5, y + 5, {color = "text_primary"})

    -- Cost
    Components.text("$" .. card.cost, x + 5, y + 25, {color = "accent_red"})

    Components.text("A:" .. card.attack, x + 5, y + 45, {color = "accent_gold"})
    Components.text("H:" .. card.hp, x + 45, y + 45, {color = "accent_green"})

    if hover then
        Components.text("[drag]", x + 55, y + 60, {color = "text_hint"})
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
    Fonts.print(I18n.t("hp") .. ": " .. battle.player.hp .. "/" .. battle.player.max_hp, 70, UI_STATUS_BAR_Y + 8)

    -- Blood
    love.graphics.setColor(0.6, 0.2, 0.2)
    love.graphics.rectangle("fill", 240, UI_STATUS_BAR_Y + 5, 120, 25, 4, 4)
    love.graphics.setColor(1, 0.8, 0.3)
    Fonts.print(I18n.t("blood") .. ": " .. battle.player.blood .. "/" .. MAX_BLOOD, 250, UI_STATUS_BAR_Y + 8)

    -- 回合信息
    love.graphics.setColor(0.7, 0.6, 0.4)
    Fonts.print(I18n.t("turn") .. ": " .. battle.turn, 380, UI_STATUS_BAR_Y + 8)

    -- 牌组信息
    local deck_info = Deck.get_info()
    love.graphics.setColor(0.5, 0.5, 0.7)
    Fonts.print(I18n.t("deck") .. ": " .. deck_info.draw_pile_size, 460, UI_STATUS_BAR_Y + 8)
    love.graphics.setColor(0.6, 0.5, 0.4)
    Fonts.print(I18n.t("discard") .. ": " .. deck_info.discard_pile_size, 550, UI_STATUS_BAR_Y + 8)

    -- 操作提示（底部）
    love.graphics.setColor(0.5, 0.45, 0.4)
    Fonts.print(I18n.t("combat_hint"), 50, UI_HINT_Y + 20, 13)

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
        Fonts.print(I18n.t("battle_btn"), btn_x + 30, btn_y + 18, 18)

        -- 快捷键提示
        love.graphics.setColor(0.6, 0.6, 0.5)
        Fonts.print("[Space]", btn_x + 50, btn_y + 40, 12)

    elseif battle.phase == "battle" then
        love.graphics.setColor(0.4, 0.35, 0.25)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
        love.graphics.setColor(0.8, 0.7, 0.5)
        Fonts.print(I18n.t("battle_progress"), btn_x + 20, btn_y + 20, 14)

    elseif battle.phase == "result" then
        local max_levels = LevelData.get_max_levels()
        if battle.enemy.hp <= 0 and battle.level < max_levels then
            love.graphics.setColor(0.3, 0.5, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.9, 0.6)
            Fonts.print("→ " .. I18n.t("next_level"), btn_x + 30, btn_y + 20, 16)
        elseif battle.enemy.hp <= 0 then
            love.graphics.setColor(0.4, 0.6, 0.4)
            love.graphics.rectangle("fill", btn_x - 20, btn_y, btn_w + 40, btn_h, 8, 8)
            love.graphics.setColor(1, 1, 0.8)
            Fonts.print(I18n.t("victory"), btn_x + 30, btn_y + 18, 18)
        else
            love.graphics.setColor(0.5, 0.3, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.6, 0.6)
            Fonts.print(I18n.t("retry_level"), btn_x + 30, btn_y + 20, 16)
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
    if key == "escape" then
        -- ESC 返回主菜单
        Map.reset()
        State.switch("menu")
    end
end

function Combat.mousepressed(x, y, button)
    -- 右键献祭场上的牌
    if button == 2 and battle.phase == "play" then
        for i = 1, BOARD_SLOTS do
            local slot_x = Layout.card_slot(i, BOARD_SLOTS)
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
    local btn = Layout.battle_button()
    local btn_x, btn_y, btn_w, btn_h = btn.x, btn.y, btn.width, btn.height

    if battle.phase == "play" then
        -- 检测点击手牌
        local hand = Deck.get_hand()
        local panel = Layout.hand_panel()
        for i = 1, #hand do
            local card_x = panel.x + 30
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
                -- 胜利：进入奖励场景
                State.push("reward")
            elseif battle.enemy.hp <= 0 then
                -- 全部通关：显示胜利后重置
                battle.level = 1
                Combat.enter()
            else
                -- 失败：重新开始
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
            local slot_x = Layout.card_slot(i, BOARD_SLOTS)
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
    local hand = Deck.get_hand()
    local card = hand[hand_index]
    if not card then return end

    -- 先检查费用，不够的话不放牌
    if card.cost > battle.player.blood then
        battle.message = I18n.tf("need_blood", card.cost)
        return
    end

    -- 费用足够，执行放置
    local placed_card = Deck.place_card(hand_index)
    if not placed_card then return end

    battle.player.blood = battle.player.blood - placed_card.cost

    battle.player.board[slot] = {
        id = placed_card.id,
        name = placed_card.name,
        attack = placed_card.attack,
        hp = placed_card.hp,
        max_hp = placed_card.max_hp,
        sigils = placed_card.sigils,
    }

    battle.message = I18n.tf("placed", I18n.card_name(placed_card.id))
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
                intent = Combat.roll_enemy_intent(),  -- 添加意图
            }
        end
    end
end

return Combat