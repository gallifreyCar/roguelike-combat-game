-- ui/card.lua - 卡牌渲染组件
-- 提供卡牌绘制、悬停效果、拖拽效果（增强动画效果）
-- 支持图片渲染（如有）和纯文字回退

local Fonts = require("core.fonts")
local Colors = require("config.colors")
local Assets = require("core.assets")
local Animation = require("systems.animation")
local Settings = require("config.settings")
local I18n = require("core.i18n")

local CardUI = {}

-- 卡牌尺寸（从 Settings 读取）
CardUI.WIDTH = Settings.card_width or 120
CardUI.HEIGHT = Settings.card_height or 160
CardUI.SMALL_WIDTH = Settings.card_small_width or 120
CardUI.SMALL_HEIGHT = Settings.card_small_height or 90

-- 图片模式开关（可配置）
CardUI.USE_IMAGES = true  -- 设为false禁用图片渲染

-- 卡牌动画状态缓存
local card_anim_states = {}

-- 获取卡牌动画状态
local function get_card_state(card_id, x, y)
    local state_id = card_id .. "_" .. x .. "_" .. y
    if not card_anim_states[state_id] then
        card_anim_states[state_id] = {
            hover_progress = 0,
            scale = 1,
            pulse_offset = 0,
        }
    end
    return card_anim_states[state_id], state_id
end

-- 绘制完整卡牌（增强动画效果）
function CardUI.draw_full(card, x, y, is_player, options)
    options = options or {}
    local hover = options.hover or false
    local dragging = options.dragging or false
    local animate = options.animate or true

    -- 获取动画状态
    local state, state_id = get_card_state(card.id or "unknown", x, y)

    -- 悬停动画
    if animate then
        if hover or dragging then
            state.hover_progress = math.min(1, state.hover_progress + 0.2)
            state.scale = 1 + state.hover_progress * 0.1
        else
            state.hover_progress = math.max(0, state.hover_progress - 0.15)
            state.scale = 1 + state.hover_progress * 0.1
        end
    end

    -- 应用变换
    local draw_x, draw_y = x, y
    local scale = state.scale

    if dragging then
        -- 拖拽时额外的放大和偏移
        scale = scale + 0.05
        draw_y = draw_y - 5  -- 略微上移
    end

    love.graphics.push()

    -- 悬停/拖拽时的发光效果
    if state.hover_progress > 0 then
        local glow_alpha = state.hover_progress * 0.3
        if is_player then
            love.graphics.setColor(0.8, 1, 0.8, glow_alpha)
        else
            love.graphics.setColor(1, 0.6, 0.6, glow_alpha)
        end
        love.graphics.rectangle("fill", draw_x - 5, draw_y - 5, CardUI.WIDTH + 10, CardUI.HEIGHT + 10, 10, 10)
    end

    -- 尝试绘制图片卡牌
    if CardUI.USE_IMAGES and Assets.getCard(card.id) then
        CardUI._draw_image_card(card, draw_x, draw_y, is_player, options, scale)
    else
        -- 回退到纯文字渲染
        CardUI._draw_text_card(card, draw_x, draw_y, is_player, options, scale)
    end

    love.graphics.pop()
end

-- 绘制图片卡牌
function CardUI._draw_image_card(card, x, y, is_player, options, scale)
    scale = scale or 1
    local cardImage = Assets.getCard(card.id)
    local frameImage = Assets.getFrame(card.rarity)
    local attackIcon = Assets.ui and Assets.ui.attack_icon
    local hpIcon = Assets.ui and Assets.ui.hp_icon

    -- 应用缩放变换
    if scale ~= 1 then
        love.graphics.push()
        love.graphics.translate(x + CardUI.WIDTH / 2, y + CardUI.HEIGHT / 2)
        love.graphics.scale(scale, scale)
        love.graphics.translate(-CardUI.WIDTH / 2, -CardUI.HEIGHT / 2)
        x, y = 0, 0
    end

    -- 绘制卡牌背景图
    if cardImage then
        love.graphics.setColor(1, 1, 1, 1)
        local scaleX = CardUI.WIDTH / cardImage:getWidth()
        local scaleY = CardUI.HEIGHT / cardImage:getHeight()
        love.graphics.draw(cardImage, x, y, 0, scaleX, scaleY)
    end

    -- 绘制卡框（叠加层）
    if frameImage then
        love.graphics.setColor(1, 1, 1, 1)
        local scaleX = CardUI.WIDTH / frameImage:getWidth()
        local scaleY = CardUI.HEIGHT / frameImage:getHeight()
        love.graphics.draw(frameImage, x, y, 0, scaleX, scaleY)
    end

    -- ========== 叠加UI元素（优化布局）==========

    -- 1. 费用红圈白字（左上角）
    if card.cost then
        love.graphics.setColor(0.7, 0.15, 0.15)
        love.graphics.circle("fill", x + 18, y + 32, 16)
        love.graphics.setColor(0.9, 0.3, 0.3)
        love.graphics.circle("line", x + 18, y + 32, 16)
        love.graphics.setColor(1, 1, 1, 1)
        Fonts.print(tostring(card.cost), x + 12, y + 24, 18)
    end

    -- 2. 攻击力（左下角，橙色背景+图标）
    love.graphics.setColor(0.5, 0.3, 0.1, 0.9)
    love.graphics.rectangle("fill", x + 6, y + CardUI.HEIGHT - 36, 48, 28, 5, 5)
    love.graphics.setColor(1, 0.75, 0.3, 1)
    if attackIcon then
        local iconScale = 16 / attackIcon:getHeight()
        love.graphics.draw(attackIcon, x + 10, y + CardUI.HEIGHT - 32, 0, iconScale, iconScale)
    else
        Fonts.print("ATK", x + 8, y + CardUI.HEIGHT - 32, 10)
    end
    love.graphics.setColor(1, 1, 1, 1)
    Fonts.print(tostring(card.attack or 0), x + 30, y + CardUI.HEIGHT - 32, 14)

    -- 3. 生命值（右下角，绿色背景+图标）
    love.graphics.setColor(0.15, 0.35, 0.15, 0.9)
    love.graphics.rectangle("fill", x + CardUI.WIDTH - 54, y + CardUI.HEIGHT - 36, 48, 28, 5, 5)
    love.graphics.setColor(0.4, 0.9, 0.4, 1)
    if hpIcon then
        local iconScale = 16 / hpIcon:getHeight()
        love.graphics.draw(hpIcon, x + CardUI.WIDTH - 50, y + CardUI.HEIGHT - 32, 0, iconScale, iconScale)
    else
        Fonts.print("HP", x + CardUI.WIDTH - 52, y + CardUI.HEIGHT - 32, 10)
    end
    love.graphics.setColor(1, 1, 1, 1)
    Fonts.print(tostring(card.hp or 0), x + CardUI.WIDTH - 30, y + CardUI.HEIGHT - 32, 14)

    -- 4. 血量条（底部边缘）
    local max_hp = math.max(1, card.max_hp or card.hp or 1)
    local hp_ratio = (card.hp or 0) / max_hp
    -- 血条背景
    love.graphics.setColor(0.15, 0.15, 0.15, 0.85)
    love.graphics.rectangle("fill", x + 6, y + CardUI.HEIGHT - 6, CardUI.WIDTH - 12, 4, 2, 2)
    -- 血条填充
    local hp_color = hp_ratio > 0.5 and {0.3, 0.7, 0.3} or (hp_ratio > 0.25 and {0.7, 0.7, 0.2} or {0.7, 0.3, 0.3})
    love.graphics.setColor(hp_color[1], hp_color[2], hp_color[3], 0.9)
    love.graphics.rectangle("fill", x + 6, y + CardUI.HEIGHT - 6, (CardUI.WIDTH - 12) * hp_ratio, 4, 2, 2)

    -- 5. 印记图标（右上角区域）
    if card.sigils and #card.sigils > 0 then
        local iconSize = 20
        local startX = x + CardUI.WIDTH - 6
        local startY = y + 6

        for i, sigilId in ipairs(card.sigils) do
            local sigilImage = Assets.getSigil(sigilId)
            if sigilImage then
                -- 印记背景
                love.graphics.setColor(0.15, 0.15, 0.2, 0.85)
                love.graphics.circle("fill", startX - (i - 1) * (iconSize + 4) - iconSize/2, startY + iconSize/2, iconSize/2 + 2)
                -- 印记图标
                love.graphics.setColor(1, 1, 1, 1)
                local s = iconSize / sigilImage:getWidth()
                love.graphics.draw(sigilImage, startX - (i - 1) * (iconSize + 4) - iconSize, startY, 0, s, s)
            end
        end
    end

    -- 6. 高亮边框
    if options and options.highlight then
        love.graphics.setColor(Colors.card_highlight)
        love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.HEIGHT, 6, 6)
    end

    if scale ~= 1 then
        love.graphics.pop()
    end
end

-- 绘制纯文字卡牌（原有逻辑 + scale支持）
function CardUI._draw_text_card(card, x, y, is_player, options, scale)
    scale = scale or 1

    -- 应用缩放变换
    if scale ~= 1 then
        love.graphics.push()
        love.graphics.translate(x + CardUI.WIDTH / 2, y + CardUI.HEIGHT / 2)
        love.graphics.scale(scale, scale)
        love.graphics.translate(-CardUI.WIDTH / 2, -CardUI.HEIGHT / 2)
        x, y = 0, 0
    end

    -- 背景
    if is_player then
        love.graphics.setColor(Colors.card_player_bg)
    else
        love.graphics.setColor(Colors.card_enemy_bg)
    end
    love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    -- 边框
    if options.highlight then
        love.graphics.setColor(Colors.card_highlight)
    else
        love.graphics.setColor(Colors.card_border)
    end
    love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    -- 名称
    love.graphics.setColor(Colors.text_primary)
    Fonts.print(card.name, x + 8, y + 8)

    -- Cost（红圈）
    if card.cost then
        love.graphics.setColor(Colors.cost_bg)
        love.graphics.circle("fill", x + 15, y + 28, 12)
        love.graphics.setColor(Colors.cost_text)
        Fonts.print(tostring(card.cost), x + 10, y + 23)
    end

    -- 属性
    love.graphics.setColor(Colors.attack_text)
    Fonts.print("ATK:" .. card.attack, x + 8, y + 50)
    love.graphics.setColor(Colors.hp_text)
    Fonts.print("HP:" .. card.hp, x + 55, y + 50)

    -- 血量条
    love.graphics.setColor(Colors.hp_bar_bg)
    love.graphics.rectangle("fill", x + 8, y + 75, 84, 8)
    love.graphics.setColor(Colors.hp_bar_fill)
    -- [BUG FIX] 防止 max_hp 为 0 或 nil 导致除零错误
    local safe_max_hp = math.max(1, card.max_hp or card.hp or 1)
    local hp_ratio = card.hp / safe_max_hp
    love.graphics.rectangle("fill", x + 8, y + 75, 84 * hp_ratio, 8)

    -- 印记图标（如有）
    if card.sigils and #card.sigils > 0 then
        love.graphics.setColor(Colors.sigil_text)
        Fonts.print("*", x + 80, y + 8)
    end

    if scale ~= 1 then
        love.graphics.pop()
    end
end

-- 绘制印记图标
function CardUI._draw_sigils(sigils, x, y)
    local iconSize = 16
    local startX = x + CardUI.WIDTH - iconSize - 5
    local startY = y + CardUI.HEIGHT - iconSize - 5

    for i, sigilId in ipairs(sigils) do
        local sigilImage = Assets.getSigil(sigilId)
        if sigilImage then
            love.graphics.setColor(1, 1, 1, 1)
            local scale = iconSize / sigilImage:getWidth()
            love.graphics.draw(sigilImage, startX - (i - 1) * (iconSize + 2), startY, 0, scale, scale)
        end
    end
end

-- 获取印记说明文本（支持i18n）
function CardUI.get_sigil_description(sigil_id)
    -- 尝试从i18n获取翻译
    local name_key = "sigil_" .. sigil_id .. "_name"
    local desc_key = "sigil_" .. sigil_id .. "_desc"

    local name = I18n.t(name_key)
    local desc = I18n.t(desc_key)

    -- 如果没有找到翻译，回退到原始数据
    if name == name_key then
        local CardData = require("data.cards")
        local sigil = CardData.sigils and CardData.sigils[sigil_id]
        if sigil then
            name = sigil.name or sigil_id
            desc = sigil.desc or ""
        else
            name = sigil_id:gsub("_", " "):gsub("^%l", string.upper)
            desc = ""
        end
    end

    return name, desc
end

-- 绘制卡牌详情（悬停时显示，包含印记说明+快捷键提示）
function CardUI.draw_tooltip(card, x, y, options)
    if not card then return end
    options = options or {}

    local tooltip_width = 180
    local tooltip_height = 80  -- 增加高度以容纳快捷键提示
    local padding = 8

    -- 计算高度（根据印记数量）
    if card.sigils and #card.sigils > 0 then
        tooltip_height = tooltip_height + #card.sigils * 18
    end

    -- 调整位置避免超出屏幕
    local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
    local draw_x = x + 20
    local draw_y = y
    if draw_x + tooltip_width > win_w then
        draw_x = x - tooltip_width - 10
    end
    if draw_y + tooltip_height > win_h then
        draw_y = win_h - tooltip_height - 10
    end

    -- 绘制背景
    love.graphics.setColor(0.1, 0.1, 0.12, 0.95)
    love.graphics.rectangle("fill", draw_x, draw_y, tooltip_width, tooltip_height, 6, 6)
    love.graphics.setColor(0.5, 0.45, 0.35, 1)
    love.graphics.rectangle("line", draw_x, draw_y, tooltip_width, tooltip_height, 6, 6)

    -- 卡牌名称（使用i18n）
    local card_name = I18n.card_name(card.id or card.name or "unknown")
    love.graphics.setColor(1, 0.9, 0.6, 1)
    Fonts.print(card_name, draw_x + padding, draw_y + padding)

    -- 费用提示
    love.graphics.setColor(0.9, 0.3, 0.3, 1)
    Fonts.print("$" .. (card.cost or 0), draw_x + tooltip_width - 25, draw_y + padding)

    -- 属性
    love.graphics.setColor(1, 0.75, 0.3, 1)
    Fonts.print("ATK: " .. (card.attack or 0), draw_x + padding, draw_y + padding + 18)
    love.graphics.setColor(0.4, 0.8, 0.4, 1)
    Fonts.print("HP: " .. (card.hp or 0), draw_x + 80, draw_y + padding + 18)

    -- 快捷键提示（新增）
    love.graphics.setColor(0.5, 0.7, 0.9, 1)
    Fonts.print(I18n.t("tooltip_drag_hint"), draw_x + padding, draw_y + padding + 36)

    -- 印记说明
    local sigil_y = draw_y + padding + 52
    if card.sigils and #card.sigils > 0 then
        for i, sigil_id in ipairs(card.sigils) do
            local name, desc = CardUI.get_sigil_description(sigil_id)
            -- 印记名称
            love.graphics.setColor(0.9, 0.7, 0.5, 1)
            Fonts.print("★ " .. name, draw_x + padding, sigil_y)
            -- 印记说明
            love.graphics.setColor(0.7, 0.65, 0.55, 1)
            Fonts.print(desc, draw_x + padding + 10, sigil_y + 12)
            sigil_y = sigil_y + 24
        end
    else
        -- 无印记提示
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        Fonts.print(I18n.t("tooltip_sigil_hint") .. ": None", draw_x + padding, sigil_y)
    end
end

-- 绘制小型卡牌（手牌列表用）- 增强动画效果 + 统一视觉风格
function CardUI.draw_small(card, x, y, hover)
    -- 获取动画状态
    local state, state_id = get_card_state(card.id or "unknown", x, y)

    -- 悬停动画
    if hover then
        state.hover_progress = math.min(1, state.hover_progress + 0.25)
        state.scale = 1 + state.hover_progress * 0.03
    else
        state.hover_progress = math.max(0, state.hover_progress - 0.2)
        state.scale = 1 + state.hover_progress * 0.03
    end

    local scale = state.scale

    love.graphics.push()
    love.graphics.translate(x + CardUI.WIDTH / 2, y + CardUI.SMALL_HEIGHT / 2)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-CardUI.WIDTH / 2, -CardUI.SMALL_HEIGHT / 2)

    -- 悬停发光效果
    if state.hover_progress > 0 then
        love.graphics.setColor(0.8, 1, 0.8, state.hover_progress * 0.2)
        love.graphics.rectangle("fill", -3, -3, CardUI.WIDTH + 6, CardUI.SMALL_HEIGHT + 6, 6, 6)
    end

    -- 卡牌背景
    if hover then
        love.graphics.setColor(Colors.card_hover_bg)
    else
        love.graphics.setColor(Colors.card_small_bg)
    end
    love.graphics.rectangle("fill", 0, 0, CardUI.WIDTH, CardUI.SMALL_HEIGHT, 4, 4)

    -- 边框
    love.graphics.setColor(Colors.card_border)
    love.graphics.rectangle("line", 0, 0, CardUI.WIDTH, CardUI.SMALL_HEIGHT, 4, 4)

    -- 1. 费用红圈白字（左上角，与draw_full一致）
    if card.cost then
        love.graphics.setColor(0.7, 0.15, 0.15)
        love.graphics.circle("fill", 18, 12, 14)
        love.graphics.setColor(0.9, 0.3, 0.3)
        love.graphics.circle("line", 18, 12, 14)
        love.graphics.setColor(1, 1, 1, 1)
        Fonts.print(tostring(card.cost), 12, 5, 16)
    end

    -- 2. 卡牌名称（中间）
    love.graphics.setColor(Colors.text_primary)
    local name = card.name or I18n and I18n.card_name(card.id) or card.id or "Unknown"
    Fonts.print(name, 40, 5, 12)

    -- 3. 攻击力（左下角，橙色背景）
    love.graphics.setColor(0.5, 0.3, 0.1, 0.9)
    love.graphics.rectangle("fill", 6, CardUI.SMALL_HEIGHT - 26, 40, 20, 4, 4)
    love.graphics.setColor(1, 0.75, 0.3, 1)
    Fonts.print("ATK", 8, CardUI.SMALL_HEIGHT - 24, 9)
    love.graphics.setColor(1, 1, 1, 1)
    Fonts.print(tostring(card.attack or 0), 32, CardUI.SMALL_HEIGHT - 24, 12)

    -- 4. 生命值（右下角，绿色背景）
    love.graphics.setColor(0.15, 0.35, 0.15, 0.9)
    love.graphics.rectangle("fill", CardUI.WIDTH - 46, CardUI.SMALL_HEIGHT - 26, 40, 20, 4, 4)
    love.graphics.setColor(0.4, 0.9, 0.4, 1)
    Fonts.print("HP", CardUI.WIDTH - 44, CardUI.SMALL_HEIGHT - 24, 9)
    love.graphics.setColor(1, 1, 1, 1)
    Fonts.print(tostring(card.hp or 0), CardUI.WIDTH - 20, CardUI.SMALL_HEIGHT - 24, 12)

    -- 5. 血量条（底部边缘）
    local max_hp = math.max(1, card.max_hp or card.hp or 1)
    local hp_ratio = (card.hp or 0) / max_hp
    -- 血条背景
    love.graphics.setColor(0.15, 0.15, 0.15, 0.85)
    love.graphics.rectangle("fill", 6, CardUI.SMALL_HEIGHT - 4, CardUI.WIDTH - 12, 3, 2, 2)
    -- 血条填充
    local hp_color = hp_ratio > 0.5 and {0.3, 0.7, 0.3} or (hp_ratio > 0.25 and {0.7, 0.7, 0.2} or {0.7, 0.3, 0.3})
    love.graphics.setColor(hp_color[1], hp_color[2], hp_color[3], 0.9)
    love.graphics.rectangle("fill", 6, CardUI.SMALL_HEIGHT - 4, (CardUI.WIDTH - 12) * hp_ratio, 3, 2, 2)

    -- 6. 印记图标（右上角区域）
    if card.sigils and #card.sigils > 0 then
        local iconSize = 16
        local startX = CardUI.WIDTH - 6
        local startY = 6

        for i, sigilId in ipairs(card.sigils) do
            local sigilImage = Assets.getSigil(sigilId)
            if sigilImage then
                -- 印记背景
                love.graphics.setColor(0.15, 0.15, 0.2, 0.85)
                love.graphics.circle("fill", startX - (i - 1) * (iconSize + 4) - iconSize/2, startY + iconSize/2, iconSize/2 + 2)
                -- 印记图标
                love.graphics.setColor(1, 1, 1, 1)
                local s = iconSize / sigilImage:getWidth()
                love.graphics.draw(sigilImage, startX - (i - 1) * (iconSize + 4) - iconSize, startY, 0, s, s)
            else
                -- 没有图片时显示★
                love.graphics.setColor(0.9, 0.7, 0.5, 1)
                Fonts.print("★", startX - (i - 1) * (iconSize + 4) - iconSize, startY, 12)
            end
        end
    end

    -- 7. 悬停提示
    if hover then
        love.graphics.setColor(Colors.drag_hint)
        Fonts.print(I18n and I18n.t("tooltip_drag_hint") or "[drag]", CardUI.WIDTH / 2 - 20, CardUI.SMALL_HEIGHT + 2, 9)
    end

    love.graphics.pop()
end

-- 绘制空格子（增强悬停效果）
function CardUI.draw_slot(x, y, hover_valid, hover_invalid)
    -- 获取动画状态
    local state, state_id = get_card_state("slot", x, y)

    -- 悬停动画
    if hover_valid or hover_invalid then
        state.hover_progress = math.min(1, state.hover_progress + 0.3)
    else
        state.hover_progress = math.max(0, state.hover_progress - 0.2)
    end

    -- 发光效果
    if state.hover_progress > 0 then
        if hover_valid then
            love.graphics.setColor(0.5, 1, 0.5, state.hover_progress * 0.3)
        elseif hover_invalid then
            love.graphics.setColor(1, 0.4, 0.4, state.hover_progress * 0.3)
        end
        love.graphics.rectangle("fill", x - 4, y - 4, CardUI.WIDTH + 8, CardUI.HEIGHT + 8, 8, 8)
    end

    if hover_valid then
        love.graphics.setColor(Colors.slot_valid)
    elseif hover_invalid then
        love.graphics.setColor(Colors.slot_invalid)
    else
        love.graphics.setColor(Colors.slot_empty)
    end
    love.graphics.rectangle("fill", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    love.graphics.setColor(Colors.slot_border)
    love.graphics.rectangle("line", x, y, CardUI.WIDTH, CardUI.HEIGHT, 5, 5)

    -- 可放置提示
    if hover_valid then
        love.graphics.setColor(0.3, 0.8, 0.3, 0.5)
        local pulse = math.sin(love.timer.getTime() * 4) * 2 + 2
        love.graphics.rectangle("line", x + pulse, y + pulse, CardUI.WIDTH - pulse * 2, CardUI.HEIGHT - pulse * 2, 3, 3)
    end
end

return CardUI