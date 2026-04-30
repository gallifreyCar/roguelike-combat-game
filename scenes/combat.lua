-- scenes/combat.lua - 战斗场景
-- 卡牌放置 + 自动攻击 + 拖拽 + 献祭系统 + 关卡系统 + 牌组系统 + 印记系统 + 特效系统 + 敌人意图 + 体系联动

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
local Save = require("systems.save")
local Sound = require("systems.sound")
local Animation = require("systems.animation")
local MetaProgression = require("systems.meta_progression")
local Assets = require("core.assets")
local CardUI = require("ui.card")
local Family = require("systems.family")  -- 体系联动系统

-- 【性能优化】鼠标位置缓存（避免多次调用 getPosition）
local cached_mouse_x = 0
local cached_mouse_y = 0

-- 从 Settings 获取配置
local BOARD_SLOTS = Settings.board_slots
local PLAYER_MAX_HP = Settings.player_max_hp
local MAX_BLOOD = Settings.max_blood

-- 卡牌尺寸从 Settings
local CARD_WIDTH = Settings.card_width
local CARD_HEIGHT = Settings.card_height

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

    -- 【新】连击系统：记录费用减免
    cost_reduction = 0,

    -- 【新】UI状态
    show_deck = false,  -- 是否显示牌库
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
    -- 场景过渡动画
    Animation.fade_in(0.15)

    -- 从地图系统获取当前层数（同步状态）
    local current_row = Map.get_current_row()
    if current_row and current_row > 1 then
        battle.level = current_row
    else
        battle.level = 1
    end

    battle.turn = 1
    battle.phase = "play"

    -- 【性能优化】清理上一局的状态标记
    battle.victory_particles = nil
    battle.cost_reduction = 0

    -- 应用局外成长加成
    local bonuses = MetaProgression.get_starting_bonuses()
    local actual_max_hp = PLAYER_MAX_HP + bonuses.hp_bonus
    local actual_starting_blood = Settings.starting_blood + bonuses.blood_bonus

    battle.player.hp = actual_max_hp
    battle.player.max_hp = actual_max_hp
    battle.player.blood = actual_starting_blood
    battle.player.max_blood = MAX_BLOOD

    init_board(battle.player.board)
    init_board(battle.enemy.board)

    -- 重置牌库（每场战斗重新洗牌）
    Deck.reset_for_battle()

    -- 第一回合抽牌（稳定抽3张）
    Deck.draw_cards(3)

    -- 根据关卡生成敌人
    Combat.spawn_level_enemies()

    battle.dragging = false
    battle.dragging_index = nil

    -- 清除之前的动画和粒子
    Animation.clear()

    -- 【性能优化】清理 UI 组件动画缓存（防止内存泄漏）
    Components.clear_all()

    local level_info = LevelData.get_level(battle.level)
    local level_name = level_info and level_info.name or "Level " .. battle.level
    battle.message = level_name .. " - Blood: " .. battle.player.blood .. "/" .. MAX_BLOOD
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
    local enemies, elite_enemies, boss = Map.get_chapter_enemies(battle.level)
    local is_boss = Map.is_chapter_boss(battle.level)
    local current_node = Map.get_current()
    local is_elite = current_node and current_node.type == "elite"

    -- 设置敌方主生命值。前几层更温和，Boss/精英更有压迫感。
    if is_boss or (level_info and level_info.boss) then
        battle.enemy.hp = 20 + battle.level * 3
        battle.enemy.max_hp = battle.enemy.hp
        battle.enemy.is_boss = true
    elseif is_elite then
        battle.enemy.hp = 14 + battle.level * 2
        battle.enemy.max_hp = battle.enemy.hp
        battle.enemy.is_boss = false
    else
        battle.enemy.hp = 8 + battle.level * 2
        battle.enemy.max_hp = battle.enemy.hp
        battle.enemy.is_boss = false
    end

    local function create_enemy_card(card_id)
        local template = CardData.cards[card_id]
        if not template then return nil end

        local level_bonus = math.max(0, math.floor((battle.level - 1) / 3))
        local hp_bonus = level_bonus * 2
        local attack_bonus = level_bonus

        local card = {
            id = template.id,
            name = template.name,
            attack = (template.attack or 0) + attack_bonus,
            hp = (template.hp or 1) + hp_bonus,
            max_hp = (template.max_hp or template.hp or 1) + hp_bonus,
            sigils = template.sigils or {},
            family = template.family,
            intent = Combat.roll_enemy_intent((template.attack or 0) + attack_bonus),
        }
        Sigils.apply_spawn_effects(card)
        return card
    end

    -- 优先使用关卡表的手工配置，保证教学和难度曲线稳定。
    if level_info and level_info.enemies and not is_elite and not is_boss then
        for _, enemy_config in ipairs(level_info.enemies) do
            if enemy_config.slot and enemy_config.card and enemy_config.slot >= 1 and enemy_config.slot <= BOARD_SLOTS then
                battle.enemy.board[enemy_config.slot] = create_enemy_card(enemy_config.card)
            end
        end
        return
    end

    local enemy_pool = enemies
    if is_elite then
        enemy_pool = elite_enemies
    elseif is_boss then
        enemy_pool = {boss}
    end

    -- 随机放置1-2个敌人
    local enemy_count = is_boss and 1 or love.math.random(1, 2)
    local used_slots = {}

    for i = 1, enemy_count do
        local enemy_id = enemy_pool[love.math.random(#enemy_pool)]
        local enemy_card = create_enemy_card(enemy_id)
        if enemy_card then
            local slot
            repeat
                slot = love.math.random(1, BOARD_SLOTS)
            until not used_slots[slot]
            used_slots[slot] = true
            battle.enemy.board[slot] = enemy_card
        end
    end
end

-- 随机敌人意图
function Combat.roll_enemy_intent(base_attack)
    base_attack = math.max(1, base_attack or 1)
    local roll = love.math.random()
    if roll < 0.6 then
        return {type = "attack", value = base_attack}
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
    -- 【性能优化】在 update 中缓存鼠标位置（避免 draw 中多次调用）
    cached_mouse_x, cached_mouse_y = love.mouse.getPosition()

    -- 更新战斗日志计时
    for i = #battle.combat_log, 1, -1 do
        battle.combat_log[i].time = battle.combat_log[i].time - dt
        if battle.combat_log[i].time <= 0 then
            table.remove(battle.combat_log, i)
        end
    end

    -- 更新特效
    Effects.update(dt)

    -- 注意：Animation系统在main.lua中全局更新，这里不需要重复调用
end

function Combat.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 绘制标题栏（响应式）
    local title_bar = Layout.title_bar()
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", title_bar.x, title_bar.y, title_bar.width, title_bar.height)
    local level_info = LevelData.get_level(battle.level)
    local level_name = level_info and level_info.name or "Level " .. battle.level
    Components.text(">> " .. level_name .. " <<", win_w / 2, title_bar.y + 12, {
        color = "text_secondary",
        size = 18,
        align = "center",
    })

    -- 分隔线（响应式）
    local separator = Layout.separator()
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", separator.x, separator.y, separator.width, separator.height)
    Components.text("─── " .. I18n.t("your_board") .. " ───", win_w / 2, separator.y + 8, {
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

    -- 消息显示（响应式）
    if battle.message then
        local msg_x, msg_y = Layout.message_position()
        Components.text(battle.message, msg_x, msg_y, {color = "text_secondary"})
    end

    -- 绘制特效
    Effects.draw()

    -- 【新】绘制UI按钮
    Combat.draw_ui_buttons()

    -- 【新】绘制牌库面板
    if battle.show_deck then
        Combat.draw_deck_panel()
    end

    -- 【新】悬停显示卡牌详情
    Combat.draw_hover_tooltip()
end

function Combat.draw_enemy_area()
    local win_w, win_h = Layout.get_size()

    -- 敌方HP（响应式）
    local hp_bar = Layout.enemy_hp_bar()
    Theme.setColor("accent_red", 0.3)
    love.graphics.rectangle("fill", hp_bar.x, hp_bar.y, hp_bar.width, hp_bar.height, 4, 4)
    Theme.setColor("accent_red")
    local max_hp = math.max(1, battle.enemy.max_hp or 1)
    local hp_w = (battle.enemy.hp / max_hp) * hp_bar.width
    love.graphics.rectangle("fill", hp_bar.x, hp_bar.y, hp_w, hp_bar.height, 4, 4)
    Components.text(I18n.t("enemy") .. ": " .. battle.enemy.hp .. "/" .. max_hp,
                    hp_bar.x + 8, hp_bar.y + 5, {
        color = "text_value",
    })

    -- 敌方格子（响应式）
    local enemy_area = Layout.enemy_area()
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local y = enemy_area.y

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
    -- 玩家格子（响应式）
    local player_board = Layout.player_board()
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local y = player_board.y

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

    -- 标题相对于 panel 位置
    Components.text("YOUR HAND", panel.x + 25, panel.y + 10, {color = "text_secondary"})
    Components.text("(" .. Deck.hand_size() .. " " .. I18n.t("cards") .. ")", panel.x + 30, panel.y + 30, {
        color = "text_hint",
    })

    local hand = Deck.get_hand()
    for i, card in ipairs(hand) do
        local x = panel.x + 30
        local y = panel.y + 55 + (i - 1) * Settings.card_small_height  -- 与 Settings 同步

        if not (battle.dragging and battle.dragging_index == i) then
            local mx, my = love.mouse.getPosition()
            local hover = mx >= x and mx <= x + Settings.card_small_width and my >= y and my <= y + Settings.card_small_height
            Combat.draw_card_small(card, x, y, hover)
        end
    end
end

function Combat.draw_card(card, x, y, is_player)
    -- 尝试使用图片渲染
    local cardImage = Assets.getCard(card.id)

    if CardUI.USE_IMAGES and cardImage then
        -- 使用 CardUI 的图片渲染
        CardUI.draw_full(card, x, y, is_player, {
            hover = false,
            animate = false,
        })
    else
        -- 回退到纯文字渲染
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
        local max_hp = math.max(1, card.max_hp or card.hp or 1)
        local hp_ratio = card.hp / max_hp
        local hp_color = hp_ratio > 0.5 and "hp_high" or (hp_ratio > 0.25 and "hp_mid" or "hp_low")
        Components.progress_bar(x + 8, y + 95, 84, 10, card.hp, max_hp, {
            fill = hp_color,
            bg = "bg_slot",
            radius = 2,
        })

        -- 印记指示
        if card.sigils and #card.sigils > 0 then
            love.graphics.setColor(0.8, 0.6, 0.4)
            Fonts.print("*" .. #card.sigils, x + 75, y + 110, 12)
        end
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
    -- 尝试使用图片渲染
    local cardImage = Assets.getCard(card.id)

    if CardUI.USE_IMAGES and cardImage then
        -- 使用 CardUI 的小型渲染
        CardUI.draw_small(card, x, y, hover)
    else
        -- 回退到纯文字渲染
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
end

function Combat.draw_status_bar()
    local win_w, win_h = Layout.get_size()

    -- 状态栏（响应式）
    local status_bar = Layout.status_bar()
    love.graphics.setColor(0.12, 0.1, 0.08)
    love.graphics.rectangle("fill", status_bar.x, status_bar.y, status_bar.width, status_bar.height, 4, 4)

    -- 计算状态栏内各元素的位置（相对布局）
    local bar_padding = status_bar.width * 0.02
    local hp_bar_width = status_bar.width * 0.18
    local blood_bar_width = status_bar.width * 0.13
    local info_gap = status_bar.width * 0.06

    -- 玩家HP
    local hp_x = status_bar.x + bar_padding
    love.graphics.setColor(0.15, 0.15, 0.35)
    love.graphics.rectangle("fill", hp_x, status_bar.y + 5, hp_bar_width, 25, 4, 4)
    love.graphics.setColor(0.2, 0.5, 0.7)
    local player_max_hp = math.max(1, battle.player.max_hp or 1)
    local hp_w = (battle.player.hp / player_max_hp) * hp_bar_width
    love.graphics.rectangle("fill", hp_x, status_bar.y + 5, hp_w, 25, 4, 4)
    love.graphics.setColor(1, 1, 1)
    Fonts.print(I18n.t("hp") .. ": " .. battle.player.hp .. "/" .. player_max_hp, hp_x + 10, status_bar.y + 8)

    -- Blood
    local blood_x = hp_x + hp_bar_width + info_gap
    love.graphics.setColor(0.6, 0.2, 0.2)
    love.graphics.rectangle("fill", blood_x, status_bar.y + 5, blood_bar_width, 25, 4, 4)
    love.graphics.setColor(1, 0.8, 0.3)
    Fonts.print(I18n.t("blood") .. ": " .. battle.player.blood .. "/" .. MAX_BLOOD, blood_x + 10, status_bar.y + 8)

    -- 回合信息
    local turn_x = blood_x + blood_bar_width + info_gap
    love.graphics.setColor(0.7, 0.6, 0.4)
    Fonts.print(I18n.t("turn") .. ": " .. battle.turn, turn_x, status_bar.y + 8)

    -- 牌组信息
    local deck_x = turn_x + info_gap
    local deck_info = Deck.get_info()
    love.graphics.setColor(0.5, 0.5, 0.7)
    Fonts.print(I18n.t("deck") .. ": " .. deck_info.draw_pile_size, deck_x, status_bar.y + 8)
    love.graphics.setColor(0.6, 0.5, 0.4)
    Fonts.print(I18n.t("discard") .. ": " .. deck_info.discard_pile_size, deck_x + info_gap, status_bar.y + 8)

    -- 金币显示
    local coins_x = deck_x + 2 * info_gap
    love.graphics.setColor(1, 0.8, 0.2)  -- 金色
    Fonts.print(I18n.t("gold") .. ": " .. Save.get_coins(), coins_x, status_bar.y + 8)

    -- 操作提示（响应式）
    local hint_x, hint_y = Layout.hint_position()
    love.graphics.setColor(0.5, 0.45, 0.4)
    Fonts.print(I18n.t("combat_hint"), hint_x, hint_y, 13)

    -- 战斗日志（响应式）
    local log_pos = Layout.combat_log()
    if #battle.combat_log > 0 then
        for i, log in ipairs(battle.combat_log) do
            local alpha = math.min(1, log.time)
            love.graphics.setColor(1, 1, 0.8, alpha)
            Fonts.print(log.text, log_pos.x, log_pos.y + (i - 1) * 22, 14)
        end
    end
end

function Combat.draw_battle_button()
    -- 战斗按钮（响应式）
    local btn = Layout.battle_button()
    local btn_x, btn_y, btn_w, btn_h = btn.x, btn.y, btn.width, btn.height

    -- 检测鼠标悬停
    local hover = Layout.mouse_in_button(btn)

    if battle.phase == "play" then
        -- 按钮背景（悬停时发光）
        if hover then
            -- 发光效果
            love.graphics.setColor(1, 1, 0.9, 0.15)
            love.graphics.rectangle("fill", btn_x - 4, btn_y - 4, btn_w + 8, btn_h + 8, 10, 10)
            love.graphics.setColor(0.35, 0.55, 0.35)
        else
            love.graphics.setColor(0.2, 0.35, 0.2)
        end
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)

        -- 边框（悬停时高亮）
        if hover then
            love.graphics.setColor(1, 1, 0.8)
        else
            love.graphics.setColor(0.5, 0.7, 0.5)
        end
        love.graphics.rectangle("line", btn_x, btn_y, btn_w, btn_h, 8, 8)

        -- 文字
        love.graphics.setColor(1, 0.95, 0.7)
        Fonts.print(I18n.t("battle_btn"), btn_x + btn_w * 0.2, btn_y + 18, 18)

        -- 快捷键提示
        love.graphics.setColor(0.6, 0.6, 0.5)
        Fonts.print("[Space]", btn_x + btn_w * 0.3, btn_y + 40, 12)

    elseif battle.phase == "battle" then
        -- 战斗进行中（带脉冲效果）
        local pulse = math.sin(love.timer.getTime() * 4) * 0.1 + 0.9
        love.graphics.setColor(0.4 * pulse, 0.35 * pulse, 0.25 * pulse)
        love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
        love.graphics.setColor(0.8, 0.7, 0.5)
        Fonts.print(I18n.t("battle_progress"), btn_x + btn_w * 0.12, btn_y + 20, 14)

    elseif battle.phase == "result" then
        local max_levels = LevelData.get_max_levels()
        if battle.enemy.hp <= 0 and battle.level < max_levels then
            -- 胜利可继续（带发光效果）
            local glow_pulse = math.sin(love.timer.getTime() * 3) * 0.2 + 0.3
            love.graphics.setColor(1, 1, 0.8, glow_pulse)
            love.graphics.rectangle("fill", btn_x - 5, btn_y - 5, btn_w + 10, btn_h + 10, 10, 10)
            love.graphics.setColor(0.3, 0.5, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.9, 0.6)
            Fonts.print("→ " .. I18n.t("next_level"), btn_x + btn_w * 0.2, btn_y + 20, 16)
        elseif battle.enemy.hp <= 0 then
            -- 全部通关（庆祝效果）
            -- 发射胜利粒子
            if not battle.victory_particles then
                Animation.spawn_victory_particles(btn_x + btn_w / 2, btn_y)
                battle.victory_particles = true
            end
            love.graphics.setColor(0.4, 0.6, 0.4)
            love.graphics.rectangle("fill", btn_x - 20, btn_y, btn_w + 40, btn_h, 8, 8)
            love.graphics.setColor(1, 1, 0.8)
            Fonts.print(I18n.t("victory"), btn_x + btn_w * 0.2, btn_y + 18, 18)
        else
            -- 失败（暗红色）
            love.graphics.setColor(0.5, 0.3, 0.3)
            love.graphics.rectangle("fill", btn_x, btn_y, btn_w, btn_h, 8, 8)
            love.graphics.setColor(1, 0.6, 0.6)
            Fonts.print(I18n.t("retry_level"), btn_x + btn_w * 0.2, btn_y + 20, 16)
        end
    end
end

function Combat.draw_hover_tooltip()
    -- 【性能优化】使用缓存的鼠标位置和 CardUI
    local mx, my = cached_mouse_x, cached_mouse_y

    -- 检查手牌悬停
    local hand = Deck.get_hand()
    local panel = Layout.hand_panel()
    local hand_start_y = panel.y + 55  -- 与 draw_hand_panel 同步

    for i, card in ipairs(hand) do
        local y = hand_start_y + (i - 1) * Settings.card_small_height
        local x = panel.x + 30  -- 与 draw_hand_panel 同步

        if mx >= x and mx <= x + Settings.card_small_width and my >= y and my <= y + Settings.card_small_height then
            -- 显示卡牌详情
            CardUI.draw_tooltip(card, mx, my)
            return
        end
    end

    -- 检查玩家棋盘上的卡牌悬停
    local player_board = Layout.player_board()
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local card = battle.player.board[i]

        if card and mx >= x and mx <= x + CARD_WIDTH and
           my >= player_board.y and my <= player_board.y + CARD_HEIGHT then
            -- 显示卡牌详情
            CardUI.draw_tooltip(card, mx, my)
            return
        end
    end

    -- 检查敌方卡牌悬停
    for i = 1, BOARD_SLOTS do
        local x = Layout.card_slot(i, BOARD_SLOTS)
        local card = battle.enemy.board[i]
        local enemy_area = Layout.enemy_area()

        if card and mx >= x and mx <= x + CARD_WIDTH and
           my >= enemy_area.y and my <= enemy_area.y + CARD_HEIGHT then
            -- 显示卡牌详情（敌方）
            CardUI.draw_tooltip(card, mx, my)
            return
        end
    end
end

function Combat.keypressed(key)
    if key == "space" and battle.phase == "play" then
        Combat.start_battle()
    end
    if key == "tab" then
        -- 【新】Tab键切换牌库显示
        battle.show_deck = not battle.show_deck
    end
    if key == "r" and battle.phase == "result" then
        Combat.enter()
    end
    if key == "escape" then
        if battle.show_deck then
            -- 牌库打开时，ESC关闭牌库
            battle.show_deck = false
        else
            -- ESC 返回主菜单
            Map.reset()
            State.switch("menu")
        end
    end
end

function Combat.mousepressed(x, y, button)
    local win_w, win_h = Layout.get_size()
    local player_board = Layout.player_board()
    local enemy_area = Layout.enemy_area()

    -- 【新】牌库面板打开时，点击任意位置关闭
    if battle.show_deck then
        battle.show_deck = false
        return
    end

    -- 【新】左键检测UI按钮
    if button == 1 then
        -- 牌库按钮（右上角）
        local deck_btn_x = win_w - 90
        local deck_btn_y = 10
        if x >= deck_btn_x and x <= deck_btn_x + 80 and y >= deck_btn_y and y <= deck_btn_y + 30 then
            battle.show_deck = true
            Sound.play("click")
            return
        end

        -- 返回按钮（左上角）
        local back_btn_x = 10
        local back_btn_y = 10
        if x >= back_btn_x and x <= back_btn_x + 70 and y >= back_btn_y and y <= back_btn_y + 30 then
            Sound.play("click")
            Map.reset()
            State.switch("menu")
            return
        end
    end

    -- 右键献祭场上的牌
    if button == 2 and battle.phase == "play" then
        for i = 1, BOARD_SLOTS do
            local slot_x = Layout.card_slot(i, BOARD_SLOTS)
            local slot_y = player_board.y

            if x >= slot_x and x <= slot_x + CARD_WIDTH and y >= slot_y and y <= slot_y + CARD_HEIGHT then
                local card = battle.player.board[i]
                if card then
                    -- 献祭：移除卡牌并加血
                    -- 献祭的血可以超出上限（只是回合开始给的血有上限）
                    battle.player.blood = battle.player.blood + 1
                    Sound.play("sacrifice")
                    battle.message = I18n.tf("sacrifice_msg", I18n.card_name(card.id))
                    battle.player.board[i] = nil
                    Save.update_stat("sacrifices", 1)
                    Save.update_achievement_stat("sacrifices", 1)
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
            local card_y = panel.y + 55 + (i - 1) * Settings.card_small_height  -- 与 Settings 同步

            if x >= card_x and x <= card_x + Settings.card_small_width and y >= card_y and y <= card_y + Settings.card_small_height then
                battle.dragging = true
                battle.dragging_index = i
                battle.drag_x = x
                battle.drag_y = y
                battle.drag_offset_x = x - card_x
                battle.drag_offset_y = y - card_y
                battle.message = I18n.tf("dragging", I18n.card_name(hand[i].id))
                return
            end
        end

        -- 检测点击战斗按钮
        if Layout.mouse_in_button(btn) then
            Sound.play("click")
            Combat.start_battle()
            return
        end

    elseif battle.phase == "result" then
        -- 检测点击结果按钮
        if Layout.mouse_in_button(btn) then
            Sound.play("click")
            local max_levels = LevelData.get_max_levels()
            if battle.enemy.hp <= 0 and battle.level < max_levels then
                -- 胜利：进入奖励场景（使用push以便返回）
                State.push("reward")
            elseif battle.enemy.hp <= 0 then
                -- 全部通关：进入胜利结算
                Map.reset()
                Deck.reset()
                State.switch("victory")
            else
                -- 失败：进入死亡场景
                State.switch("death")
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

    local player_board = Layout.player_board()

    if battle.dragging and battle.dragging_index then
        for i = 1, BOARD_SLOTS do
            local slot_x = Layout.card_slot(i, BOARD_SLOTS)
            local slot_y = player_board.y

            if x >= slot_x and x <= slot_x + CARD_WIDTH and y >= slot_y and y <= slot_y + CARD_HEIGHT then
                if battle.player.board[i] == nil then
                    Combat.place_card(battle.dragging_index, i)
                else
                    battle.message = I18n.t("slot_occupied")
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

    -- 【连击】应用费用减免
    local actual_cost = math.max(0, card.cost - battle.cost_reduction)

    -- 先检查费用
    if actual_cost > battle.player.blood then
        battle.message = I18n.tf("need_blood", actual_cost)
        return
    end

    -- 费用足够，执行放置
    local placed_card = Deck.place_card(hand_index)
    if not placed_card then return end

    -- 扣除费用（扣除实际费用），然后重置连击
    battle.player.blood = battle.player.blood - actual_cost
    battle.cost_reduction = 0  -- 连击只影响下一张牌

    -- 获取卡牌模板（包含family字段）
    local template = CardData.cards[placed_card.id]
    local board_card = {
        id = placed_card.id,
        name = placed_card.name,
        attack = placed_card.attack,
        hp = placed_card.hp,
        max_hp = placed_card.max_hp or placed_card.hp,
        sigils = placed_card.sigils or {},
        family = template and template.family,  -- 添加体系字段
    }

    -- 触发印记生成效果
    Sigils.apply_spawn_effects(board_card)

    battle.player.board[slot] = board_card

    -- 【体系联动】应用体系加成
    board_card = Family.apply_bonuses(board_card, battle.player.board)
    if board_card.family_bonus then
        add_log(board_card.name .. " [" .. (Family.FAMILIES[board_card.family] and Family.FAMILIES[board_card.family].name_cn or board_card.family) .. "] " .. board_card.family_bonus)
    end

    -- 触发放置时的印记效果（过牌、连击等）
    local place_results = Sigils.process_place(board_card)
    for _, result in ipairs(place_results) do
        if result.result.draw_cards then
            Deck.draw_cards(result.result.draw_cards)
            add_log(board_card.name .. " [DRAW] +" .. result.result.draw_cards .. " cards!")
        end
        if result.result.cost_reduction then
            battle.cost_reduction = result.result.cost_reduction
            add_log(board_card.name .. " [COMBO] Next card -" .. result.result.cost_reduction .. " cost!")
        end
    end

    -- 播放放置卡牌音效和动画
    Sound.play("play_card")
    local slot_x = Layout.card_slot(slot, BOARD_SLOTS)
    local player_board = Layout.player_board()
    Animation.card_place(slot_x, player_board.y, CARD_WIDTH, CARD_HEIGHT)

    battle.message = I18n.tf("placed", I18n.card_name(placed_card.id))
    Save.update_stat("cards_played", 1)
end

function Combat.start_battle()
    battle.phase = "battle"
    battle.combat_log = {}
    -- 播放战斗开始音效
    Sound.play("attack")
    add_log("=== BATTLE START ===")
    Combat.execute_battle()
end

function Combat.execute_battle()
    local player_board = Layout.player_board()
    local enemy_area = Layout.enemy_area()
    local status_bar = Layout.status_bar()
    local enemy_hp_bar = Layout.enemy_hp_bar()

    -- 玩家攻击（处理印记）
    for i = 1, BOARD_SLOTS do
        local card = battle.player.board[i]
        if card and card.hp > 0 then
            local enemy_card = battle.enemy.board[i]
            local attack_count = Sigils.get_attack_count(card)

            -- 计算卡牌位置（响应式）
            local card_x = Layout.card_slot(i, BOARD_SLOTS)

            for _ = 1, attack_count do
                if enemy_card and enemy_card.hp > 0 then
                    -- 该列有敌人卡
                    if Sigils.has(card, "air_strike") then
                        -- 飞行印记：绕过敌人直接攻击Boss
                        local dmg = card.attack
                        battle.enemy.hp = battle.enemy.hp - dmg
                        add_log(card.name .. " [AIR] → Boss (-" .. dmg .. " HP)")

                        -- 播放飞行攻击音效
                        Sound.play("attack")

                        Effects.damage(dmg, enemy_hp_bar.x + enemy_hp_bar.width * 0.5, enemy_hp_bar.y + 16)
                        -- 攻击动画
                        Animation.card_attack(card_x, player_board.y, CARD_WIDTH, CARD_HEIGHT, -1)
                        Animation.damage_number(dmg, enemy_hp_bar.x + enemy_hp_bar.width * 0.5, enemy_hp_bar.y + 16)
                    else
                        -- 普通攻击：攻击敌人卡
                        local dmg = card.attack
                        enemy_card.hp = enemy_card.hp - dmg
                        add_log(card.name .. " → " .. enemy_card.name .. " (-" .. dmg .. " HP)")

                        -- 播放攻击音效
                        Sound.play("attack")

                        -- 【击杀加攻】如果击杀敌人，+1攻击
                        if enemy_card.hp <= 0 and Sigils.has(card, "kill_bonus") then
                            card.attack = card.attack + 1
                            add_log(card.name .. " [KILL BONUS] +1 ATK!")
                        end

                        -- 攻击动画
                        Animation.card_attack(card_x, player_board.y, CARD_WIDTH, CARD_HEIGHT, -1)
                        -- 伤害数字特效
                        Effects.damage(dmg, card_x + 50, enemy_area.y + 30)
                        Animation.damage_number(dmg, card_x + 50, enemy_area.y + 30)
                        Effects.attack_flash(card_x, enemy_area.y, CARD_WIDTH, CARD_HEIGHT)

                        -- 处理毒印记
                        if Sigils.has(card, "poison") then
                            enemy_card.poisoned = (enemy_card.poisoned or 0) + 1
                        end
                    end
                else
                    -- 空列：直接攻击Boss
                    local dmg = card.attack
                    battle.enemy.hp = battle.enemy.hp - dmg
                    add_log(card.name .. " → Boss (-" .. dmg .. " HP)")

                    -- 播放攻击音效
                    Sound.play("hit")

                    -- 攻击动画和伤害数字
                    Animation.card_attack(card_x, player_board.y, CARD_WIDTH, CARD_HEIGHT, -1)
                    Effects.damage(dmg, enemy_hp_bar.x + enemy_hp_bar.width * 0.5, enemy_hp_bar.y + 16)
                    Animation.damage_number(dmg, enemy_hp_bar.x + enemy_hp_bar.width * 0.5, enemy_hp_bar.y + 16)
                    Effects.attack_flash(enemy_hp_bar.x, enemy_hp_bar.y, enemy_hp_bar.width, enemy_hp_bar.height)
                end
            end
        end
    end

    -- 敌方攻击
    for i = 1, BOARD_SLOTS do
        local card = battle.enemy.board[i]
        if card and card.hp > 0 then
            local intent = card.intent or {type = "attack", value = card.attack or 0}

            if intent.type == "defend" then
                local before = card.hp
                card.hp = math.min(card.max_hp or card.hp, card.hp + (intent.value or 0))
                add_log(card.name .. " guards (+" .. (card.hp - before) .. " HP)")
                card.intent = Combat.roll_enemy_intent(card.attack)
            elseif intent.type == "buff" then
                card.attack = (card.attack or 0) + (intent.value or 1)
                add_log(card.name .. " enrages (+" .. (intent.value or 1) .. " ATK)")
                card.intent = Combat.roll_enemy_intent(card.attack)
            else
                local player_card = battle.player.board[i]

                -- 计算卡牌位置（响应式）
                local card_x = Layout.card_slot(i, BOARD_SLOTS)

                if player_card and player_card.hp > 0 then
                    local dmg = intent.value or card.attack or 0
                    -- 恶臭减攻击
                    if player_card.stinky_debuff then
                        dmg = math.max(0, dmg - player_card.stinky_debuff)
                    end
                    player_card.hp = player_card.hp - dmg
                    add_log(card.name .. " → " .. player_card.name .. " (-" .. dmg .. " HP)")

                    -- 播放受击音效和动画
                    Sound.play("hit")
                    Animation.card_shake(card_x, player_board.y, CARD_WIDTH, CARD_HEIGHT)
                    Effects.damage(dmg, card_x + 50, player_board.y + 30)
                    Animation.damage_number(dmg, card_x + 50, player_board.y + 30)
                    Effects.attack_flash(card_x, player_board.y, CARD_WIDTH, CARD_HEIGHT)
                else
                    local dmg = intent.value or card.attack or 0
                    battle.player.hp = battle.player.hp - dmg
                    add_log(card.name .. " → YOU (-" .. dmg .. " HP)")

                    -- 玩家HP伤害数字（响应式）
                    Effects.damage(dmg, status_bar.x + status_bar.width * 0.1, status_bar.y)
                    Animation.damage_number(dmg, status_bar.x + status_bar.width * 0.1, status_bar.y)
                end
                card.intent = Combat.roll_enemy_intent(card.attack)
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

    -- 清理死亡（处理不死印记 + 亡语抽牌 + 击杀特效）
    for i = 1, BOARD_SLOTS do
        if battle.player.board[i] and battle.player.board[i].hp <= 0 then
            local card = battle.player.board[i]
            if Sigils.has(card, "undead") and not card.revived then
                card.revived = true
                card.hp = 1
                add_log(I18n.card_name(card.id) .. " revived!")
            else
                -- 【亡语抽牌】死亡时抽牌
                if Sigils.has(card, "death_draw") then
                    Deck.draw_cards(2)
                    add_log(card.name .. " [DEATH DRAW] +2 cards!")
                end
                add_log(I18n.tf("your_card_died", I18n.card_name(card.id)))

                -- 播放死亡音效
                Sound.play("death")

                -- 【新增】卡牌死亡动画特效
                local slot_x = Layout.card_slot(i, BOARD_SLOTS)
                Animation.card_death(slot_x, player_board.y, CARD_WIDTH, CARD_HEIGHT)

                battle.player.board[i] = nil
            end
        end
        if battle.enemy.board[i] and battle.enemy.board[i].hp <= 0 then
            local card = battle.enemy.board[i]
            if Sigils.has(card, "undead") and not card.revived then
                card.revived = true
                card.hp = 1
                add_log(I18n.tf("enemy_card_revived", I18n.card_name(card.id)))
            else
                add_log(I18n.tf("enemy_card_died", I18n.card_name(card.id)))

                -- 播放死亡音效
                Sound.play("death")

                -- 【新增】敌方卡牌死亡动画特效
                local slot_x = Layout.card_slot(i, BOARD_SLOTS)
                Animation.card_death(slot_x, enemy_area.y, CARD_WIDTH, CARD_HEIGHT)

                battle.enemy.board[i] = nil
            end
        end
    end

    -- 胜负判定
    if battle.enemy.hp <= 0 then
        battle.phase = "result"
        -- 播放胜利音效
        Sound.play("victory")

        -- 【改进】使用关卡定义的金币奖励
        local level_info = LevelData.get_level(battle.level)
        local base_reward = (level_info and level_info.gold_reward) or 5
        local level_bonus = battle.level * 2  -- 额外关卡加成

        -- 应用局外成长金币加成
        local gold_multiplier = MetaProgression.get_gold_multiplier()
        local total_reward = math.floor((base_reward + level_bonus) * gold_multiplier)

        Save.add_coins(total_reward)
        Save.update_stat("battles_won", 1)
        Save.update_stat("floors_completed", 1)
        Save.update_achievement_stat("battles_won", 1)
        Save.update_achievement_stat("floors_completed", 1)
        add_log(I18n.t("gold") .. " +" .. total_reward .. "!")

        -- 播放奖励音效
        Sound.play("reward")

        -- 金币弹出动画
        Animation.gold_popup(total_reward, status_bar.x + status_bar.width * 0.5, status_bar.y - 20)

        -- 胜利粒子特效
        Animation.spawn_victory_particles(status_bar.x + status_bar.width * 0.5, status_bar.y - 10)

        local max_levels = LevelData.get_max_levels()
        if battle.level >= max_levels then
            battle.message = I18n.t("victory") .. " " .. I18n.t("all_levels") .. " (+" .. total_reward .. " " .. I18n.t("gold") .. ")"
        else
            battle.message = I18n.t("victory") .. " " .. I18n.tf("next_level") .. " (+" .. total_reward .. " " .. I18n.t("gold") .. ")"
        end
    elseif battle.player.hp <= 0 then
        battle.phase = "result"
        -- 播放失败音效
        Sound.play("defeat")
        battle.message = I18n.t("defeated") .. " " .. I18n.t("retry_level")
    else
        -- 下一回合：Blood 按回合数增长（上限3）
        battle.turn = battle.turn + 1
        battle.phase = "play"

        -- 每回合Blood = min(回合数, 3)
        -- 第1回合1血，第2回合2血，第3回合及以后3血
        battle.player.blood = math.min(battle.turn, MAX_BLOOD)

        -- 【回合加血】检查场上卡牌的回合加血印记
        for i = 1, BOARD_SLOTS do
            local card = battle.player.board[i]
            if card and card.hp > 0 and Sigils.has(card, "turn_blood") then
                battle.player.blood = math.min(battle.player.blood + 1, MAX_BLOOD)
                add_log(card.name .. " [TURN BLOOD] +1 Blood!")
            end
        end

        -- 【重构】每回合固定抽2张牌（稳定过牌机制）
        Deck.draw_cards(2)

        Combat.enemy_play_card()

        -- 更新回合消息
        battle.message = string.format(I18n.t("turn_blood"), battle.turn, battle.player.blood, MAX_BLOOD)
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
            card_pool = {"wolf", "grizzly", "moose", "mantis"}  -- [BUG FIX] "mant" 改为 "mantis"
        end

        local id = card_pool[love.math.random(#card_pool)]
        local template = CardData.cards[id]

        if template then
            local enemy_card = {
                id = template.id,
                name = template.name,
                attack = template.attack,
                hp = template.hp,
                max_hp = template.hp,
                sigils = template.sigils or {},  -- 复制印记
                intent = Combat.roll_enemy_intent(template.attack),
            }

            -- 触发印记生成效果
            Sigils.apply_spawn_effects(enemy_card)

            battle.enemy.board[slot] = enemy_card
        end
    end
end

-- ==================== 【新】UI按钮函数 ====================

-- 绘制UI按钮（牌库查看、返回）- 增强动画效果
function Combat.draw_ui_buttons()
    local win_w, win_h = Layout.get_size()

    -- 牌库按钮（右上角）
    local deck_btn_x = win_w - 90
    local deck_btn_y = 10
    local deck_btn_w = 80
    local deck_btn_h = 30

    local deck_hover = love.mouse.getX() >= deck_btn_x and love.mouse.getX() <= deck_btn_x + deck_btn_w and
                       love.mouse.getY() >= deck_btn_y and love.mouse.getY() <= deck_btn_y + deck_btn_h

    -- 悬停时发光效果
    if deck_hover then
        love.graphics.setColor(1, 1, 0.9, 0.2)
        love.graphics.rectangle("fill", deck_btn_x - 3, deck_btn_y - 3, deck_btn_w + 6, deck_btn_h + 6, 6, 6)
    end

    Theme.setColor(deck_hover and "bg_slot_hover" or "bg_panel")
    love.graphics.rectangle("fill", deck_btn_x, deck_btn_y, deck_btn_w, deck_btn_h, 4, 4)
    Theme.setColor(deck_hover and "border_highlight" or "border_gold", 0.5)
    love.graphics.rectangle("line", deck_btn_x, deck_btn_y, deck_btn_w, deck_btn_h, 4, 4)
    Theme.setColor("text_primary")
    Fonts.print("DECK", deck_btn_x + 22, deck_btn_y + 7, 14)

    -- 返回按钮（左上角）
    local back_btn_x = 10
    local back_btn_y = 10
    local back_btn_w = 70
    local back_btn_h = 30

    local back_hover = love.mouse.getX() >= back_btn_x and love.mouse.getX() <= back_btn_x + back_btn_w and
                       love.mouse.getY() >= back_btn_y and love.mouse.getY() <= back_btn_y + back_btn_h

    -- 悬停时发光效果（红色警告）
    if back_hover then
        love.graphics.setColor(1, 0.4, 0.4, 0.2)
        love.graphics.rectangle("fill", back_btn_x - 3, back_btn_y - 3, back_btn_w + 6, back_btn_h + 6, 6, 6)
    end

    Theme.setColor(back_hover and "accent_red" or "bg_panel", back_hover and 0.5 or 1)
    love.graphics.rectangle("fill", back_btn_x, back_btn_y, back_btn_w, back_btn_h, 4, 4)
    Theme.setColor("text_primary")
    Fonts.print("← ESC", back_btn_x + 12, back_btn_y + 7, 14)
end

-- 绘制牌库面板
function Combat.draw_deck_panel()
    local win_w, win_h = Layout.get_size()

    -- 半透明背景
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    -- 面板
    local panel_w = win_w * 0.8
    local panel_h = win_h * 0.8
    local panel_x = (win_w - panel_w) / 2
    local panel_y = (win_h - panel_h) / 2

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)
    Theme.setColor("border_gold")
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 标题
    Components.text("YOUR DECK", panel_x + panel_w / 2, panel_y + 15, {
        color = "accent_gold",
        size = 20,
        align = "center",
    })

    -- 牌组信息
    local deck_info = Deck.get_info()
    Components.text("Draw Pile: " .. deck_info.draw_pile_size .. "  |  Discard: " .. deck_info.discard_pile_size .. "  |  Total: " .. deck_info.deck_size,
                    panel_x + panel_w / 2, panel_y + 45, {
        color = "text_secondary",
        align = "center",
    })

    -- 显示牌组中的卡牌
    local deck = Deck.get_deck()
    if #deck == 0 then
        Components.text("No cards in deck", panel_x + panel_w / 2, panel_y + panel_h / 2, {
            color = "text_hint",
            align = "center",
        })
    else
        -- 按卡牌ID统计
        local card_counts = {}
        for _, card in ipairs(deck) do
            if not card_counts[card.id] then
                card_counts[card.id] = {count = 0, template = card}
            end
            card_counts[card.id].count = card_counts[card.id].count + 1
        end

        -- 显示卡牌
        local card_width = 140
        local card_height = 70
        local cards_per_row = math.floor((panel_w - 40) / (card_width + 10))
        local col = 0
        local row = 0

        for card_id, data in pairs(card_counts) do
            local x = panel_x + 20 + col * (card_width + 10)
            local y = panel_y + 80 + row * (card_height + 10)

            -- 卡牌背景
            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", x, y, card_width, card_height, 4, 4)
            Theme.setColor("border_gold", 0.3)
            love.graphics.rectangle("line", x, y, card_width, card_height, 4, 4)

            -- 卡牌信息
            Components.text(I18n.card_name(data.template.id), x + 8, y + 8, {color = "text_primary", size = 12})
            Components.text("x" .. data.count, x + card_width - 25, y + 8, {color = "accent_gold", size = 12})
            Components.text("$" .. (data.template.cost or 0), x + 8, y + 28, {color = "accent_red", size = 11})
            Components.text("A:" .. (data.template.attack or 0), x + 35, y + 28, {color = "accent_gold", size = 11})
            Components.text("H:" .. (data.template.hp or 0), x + 70, y + 28, {color = "accent_green", size = 11})

            -- 印记
            if data.template.sigils and #data.template.sigils > 0 then
                Components.text("*" .. #data.template.sigils, x + 100, y + 28, {color = "text_hint", size = 11})
            end

            col = col + 1
            if col >= cards_per_row then
                col = 0
                row = row + 1
            end
        end
    end

    -- 关闭提示
    Components.text("Click anywhere to close", panel_x + panel_w / 2, panel_y + panel_h - 30, {
        color = "text_hint",
        align = "center",
    })
end

return Combat
