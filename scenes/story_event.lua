-- scenes/story_event.lua - 剧情事件场景
-- 显示事件描述、选择分支、处理结果

local StoryEvent = {}
local State = require("core.state")
local I18n = require("core.i18n")
local Fonts = require("core.fonts")
local Colors = require("config.colors")
local Layout = require("config.layout")
local Components = require("ui.components")
local StoryEvents = require("data.story_events")
local CardData = require("data.cards")
local Deck = require("systems.deck")
local Save = require("systems.save")

-- 场景状态
local state = {
    event = nil,
    selected_choice = nil,
    result = nil,
    showing_result = false,
    new_card = nil,
    animation_timer = 0,
}

-- 初始化场景
function StoryEvent.enter(event_id)
    -- 确保事件数据存在
    if event_id then
        state.event = StoryEvents.getById and StoryEvents.getById(event_id)
    end

    if not state.event then
        state.event = StoryEvents.getRandom and StoryEvents.getRandom()
    end

    -- 如果还是没有事件数据，创建默认事件
    if not state.event then
        state.event = {
            id = "default",
            title = "Mysterious Event",
            title_cn = "神秘事件",
            description = "Something unusual happens...",
            description_cn = "发生了一些不寻常的事...",
            emoji = "❓",
            choices = {
                {
                    text = "Continue",
                    text_cn = "继续",
                    effect = function(player, deck)
                        return {
                            success = true,
                            message = "You move on.",
                            message_cn = "你继续前进。",
                            reward_type = "none",
                        }
                    end,
                },
            },
        }
    end

    state.selected_choice = nil
    state.result = nil
    state.showing_result = false
    state.new_card = nil
    state.animation_timer = 0
end

-- 更新场景
function StoryEvent.update(dt)
    if state.animation_timer > 0 then
        state.animation_timer = state.animation_timer - dt
    end
end

-- 绘制场景
function StoryEvent.draw()
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()

    -- 背景遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    if not state.event then
        -- 错误状态
        love.graphics.setColor(1, 1, 1, 1)
        Fonts.print("No event data", win_w / 2 - 50, win_h / 2)
        return
    end

    -- 事件面板
    local panel_w = math.min(400, win_w - 40)
    local panel_h = state.showing_result and 300 or 400
    local panel_x = (win_w - panel_w) / 2
    local panel_y = (win_h - panel_h) / 2

    -- 面板背景
    love.graphics.setColor(0.12, 0.12, 0.15, 0.98)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 10, 10)
    love.graphics.setColor(0.4, 0.35, 0.25, 1)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 10, 10)

    local padding = 20
    local y = panel_y + padding

    -- 事件标题
    local title = (I18n.current_lang == "zh" and state.event.title_cn) or state.event.title or "Event"
    love.graphics.setColor(1, 0.9, 0.6, 1)
    Fonts.print_large((state.event.emoji or "?") .. " " .. title, panel_x + padding, y)
    y = y + 40

    -- 事件描述
    local desc = (I18n.current_lang == "zh" and state.event.description_cn) or state.event.description or ""
    love.graphics.setColor(0.85, 0.8, 0.75, 1)
    Fonts.print_wrapped(desc, panel_x + padding, y, panel_w - padding * 2)
    y = y + 60

    if state.showing_result then
        -- 显示结果
        StoryEvent._draw_result(panel_x, panel_y, panel_w, panel_h, padding, y)
    else
        -- 显示选择
        StoryEvent._draw_choices(panel_x, panel_y, panel_w, panel_h, padding, y)
    end
end

-- 绘制选择
function StoryEvent._draw_choices(panel_x, panel_y, panel_w, panel_h, padding, y)
    local choices = state.event.choices
    local button_h = 45
    local button_gap = 10

    for i, choice in ipairs(choices) do
        local button_y = y + (i - 1) * (button_h + button_gap)
        local is_hovered = state.selected_choice == i
        local is_disabled = choice.condition and not choice.condition(StoryEvent._getPlayer())

        -- 按钮背景
        if is_disabled then
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
        elseif is_hovered then
            love.graphics.setColor(0.3, 0.4, 0.3, 1)
        else
            love.graphics.setColor(0.25, 0.28, 0.25, 1)
        end
        love.graphics.rectangle("fill", panel_x + padding, button_y, panel_w - padding * 2, button_h, 6, 6)

        -- 按钮边框
        if is_hovered and not is_disabled then
            love.graphics.setColor(0.6, 0.8, 0.6, 1)
        else
            love.graphics.setColor(0.4, 0.45, 0.4, 1)
        end
        love.graphics.rectangle("line", panel_x + padding, button_y, panel_w - padding * 2, button_h, 6, 6)

        -- 按钮文字
        local text = (I18n.current_lang == "zh" and choice.text_cn) or choice.text or "Option"
        if is_disabled then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            text = text .. " (Unavailable)"
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        Fonts.print(text, panel_x + padding + 10, button_y + 12)
    end

    -- 提示
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    Fonts.print_small("Click to select, press ENTER to confirm", panel_x + padding, panel_y + panel_h - 30)
end

-- 绘制结果
function StoryEvent._draw_result(panel_x, panel_y, panel_w, panel_h, padding, y)
    if not state.result then return end

    -- 结果文字
    local msg = (I18n.current_lang == "zh" and state.result.message_cn) or state.result.message or "Done."
    love.graphics.setColor(1, 0.95, 0.8, 1)
    Fonts.print_wrapped(msg, panel_x + padding, y, panel_w - padding * 2)
    y = y + 60

    -- 显示奖励
    if state.result.reward_type == "card" and state.new_card then
        love.graphics.setColor(0.8, 0.7, 0.5, 1)
        local card_name = I18n.card_name(state.new_card.id)
        Fonts.print("Obtained: " .. card_name, panel_x + padding, y)
        y = y + 25

        -- 显示卡牌属性
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        Fonts.print_small("ATK: " .. state.new_card.attack .. "  HP: " .. state.new_card.hp, panel_x + padding, y)
    elseif state.result.reward_type == "gold" then
        love.graphics.setColor(1, 0.85, 0.3, 1)
        Fonts.print("Gold: +" .. state.result.gold, panel_x + padding, y)
    elseif state.result.reward_type == "heal" then
        love.graphics.setColor(0.5, 1, 0.5, 1)
        Fonts.print("HP: +" .. state.result.heal, panel_x + padding, y)
    elseif state.result.hp_penalty then
        love.graphics.setColor(1, 0.4, 0.4, 1)
        Fonts.print("HP: -" .. state.result.hp_penalty, panel_x + padding, y)
    end

    -- 继续按钮
    local btn_y = panel_y + panel_h - 60
    love.graphics.setColor(0.3, 0.5, 0.3, 1)
    love.graphics.rectangle("fill", panel_x + padding, btn_y, panel_w - padding * 2, 40, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    Fonts.print("Continue", panel_x + panel_w / 2 - 30, btn_y + 10)
end

-- 获取玩家数据
function StoryEvent._getPlayer()
    return {
        gold = Save.get_coins(),
        hp = 20,  -- 简化：使用默认值
        max_hp = 20,
    }
end

-- 获取牌组
function StoryEvent._getDeck()
    local all_cards = Deck.get_all_cards_for_fusion()
    return all_cards or {}
end

-- 鼠标移动
function StoryEvent.mousemoved(x, y)
    if state.showing_result then return end

    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
    local panel_w = math.min(400, win_w - 40)
    local panel_x = (win_w - panel_w) / 2
    local padding = 20
    local start_y = (win_h - 400) / 2 + 120
    local button_h = 45
    local button_gap = 10

    state.selected_choice = nil
    for i, choice in ipairs(state.event.choices) do
        local button_y = start_y + (i - 1) * (button_h + button_gap)
        if x >= panel_x + padding and x <= panel_x + panel_w - padding and
           y >= button_y and y <= button_y + button_h then
            state.selected_choice = i
            break
        end
    end
end

-- 鼠标点击
function StoryEvent.mousepressed(x, y, button)
    if button ~= 1 then return end

    if state.showing_result then
        -- 点击继续按钮
        local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
        local panel_w = math.min(400, win_w - 40)
        local panel_h = 300
        local panel_x = (win_w - panel_w) / 2
        local panel_y = (win_h - panel_h) / 2
        local padding = 20
        local btn_y = panel_y + panel_h - 60

        if x >= panel_x + padding and x <= panel_x + panel_w - padding and
           y >= btn_y and y <= btn_y + 40 then
            -- 应用奖励后退出
            StoryEvent._apply_result()
            State.pop()
        end
    else
        -- 点击选择
        if state.selected_choice then
            StoryEvent._select_choice(state.selected_choice)
        end
    end
end

-- 选择分支
function StoryEvent._select_choice(index)
    local choice = state.event.choices[index]
    if not choice then return end

    -- 检查条件
    if choice.condition and not choice.condition(StoryEvent._getPlayer()) then
        return
    end

    -- 执行效果
    local player = StoryEvent._getPlayer()
    local deck = StoryEvent._getDeck()

    -- 安全执行 effect
    local success, result = pcall(function()
        return choice.effect(player, deck)
    end)

    if not success then
        -- effect 执行失败，使用默认结果
        state.result = {
            success = true,
            message = "Something happened...",
            message_cn = "发生了一些事情...",
            reward_type = "none",
        }
    else
        state.result = result
    end

    -- 处理奖励
    if state.result and state.result.reward_type == "card" then
        local rarity = state.result.card_rarity or "common"
        state.new_card = CardData.getRandomCardByRarity(rarity)
    end

    -- 应用金币变化
    if state.result and state.result.gold then
        Save.add_coins(state.result.gold)
    end

    -- 应用金币扣除（effect 中直接修改 player.gold 的情况）
    if player.gold ~= Save.get_coins() then
        Save.set_coins(player.gold)
    end

    state.showing_result = true
end

-- 应用结果并退出
function StoryEvent._apply_result()
    if not state.result then return end

    -- 添加新卡牌到牌组
    if state.new_card then
        Deck.add_to_deck(state.new_card.id)
    end

    -- 移除卡牌（如果需要）- 简化处理
    if state.result.remove_card then
        -- 不删除卡牌，融合是唯一删牌方式
    end

    -- 升级随机卡牌 - 简化处理
    if state.result.upgrade_random then
        -- 暂不实现升级
    end
end

-- 键盘事件
function StoryEvent.keypressed(key)
    if key == "escape" then
        if state.showing_result then
            StoryEvent._apply_result()
        end
        State.pop()
    elseif key == "return" then
        if state.showing_result then
            StoryEvent._apply_result()
            State.pop()
        elseif state.selected_choice then
            StoryEvent._select_choice(state.selected_choice)
        end
    elseif key == "up" then
        if not state.showing_result and state.event then
            state.selected_choice = ((state.selected_choice or 2) - 2) % #state.event.choices + 1
        end
    elseif key == "down" then
        if not state.showing_result and state.event then
            state.selected_choice = ((state.selected_choice or 0) % #state.event.choices) + 1
        end
    end
end

return StoryEvent