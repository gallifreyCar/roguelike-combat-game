-- scenes/fusion.lua - 卡牌融合场景
-- 统一使用 CardUI 组件渲染卡牌

local Fusion = {}
local FusionSystem = require("systems.fusion")
local Deck = require("systems.deck")
local State = require("core.state")
local Fonts = require("core.fonts")
local CardData = require("data.cards")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Sound = require("systems.sound")
local I18n = require("core.i18n")
local Family = require("systems.family")
local CardUI = require("ui.card")
local Settings = require("config.settings")

local CARD_WIDTH = Settings.card_width or 120
local CARD_HEIGHT = Settings.card_height or 160

-- 模块私有状态
local selected_cards = {}
local cached_all_cards = {}
local preview_result = nil
local message = ""
local message_timer = 0
local mutation_result = nil
local hover_card = nil

function Fusion.enter()
    selected_cards = {}
    preview_result = nil
    message = ""
    message_timer = 0
    mutation_result = nil
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}
    hover_card = nil

    if not FusionSystem.can_fuse_more() then
        message = I18n.t("fusion_limit_reached") or ("Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)")
        message_timer = 3.0
    end
end

function Fusion.exit()
    selected_cards = {}
    cached_all_cards = {}
    preview_result = nil
    mutation_result = nil
end

function Fusion.update(dt)
    if message_timer > 0 then
        message_timer = message_timer - dt
        if message_timer <= 0 then
            message = ""
        end
    end
end

function Fusion.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 返回按钮
    local mx, my = love.mouse.getPosition()
    local back_hover = mx >= 10 and mx <= 80 and my >= 10 and my <= 40
    Theme.setColor(back_hover and "accent_red" or "bg_panel", back_hover and 0.5 or 1)
    love.graphics.rectangle("fill", 10, 10, 70, 30, 4, 4)
    Theme.setColor("text_primary")
    Fonts.print(I18n.t("back") or "← ESC", 22, 17, 14)

    -- 标题
    Components.text(I18n.t("fusion_title") or "CARD FUSION", win_w / 2, 20, {
        color = "accent_gold",
        size = 22,
        align = "center",
    })

    -- 融合次数
    local remaining = FusionSystem.get_remaining_fusions()
    local count_color = remaining > 2 and "accent_green" or (remaining > 0 and "accent_gold" or "accent_red")
    Components.text((I18n.t("fusion_count") or "Fusions") .. ": " .. remaining .. "/" .. FusionSystem.MAX_FUSIONS, win_w - 100, 22, {
        color = count_color,
        size = 14,
    })

    -- 提示
    Components.text(I18n.t("fusion_hint") or "Select 2 cards to fuse (only way to reduce deck size)", win_w / 2, 50, {
        color = "text_hint",
        align = "center",
        size = 12,
    })

    -- 绘制卡牌列表
    Fusion.draw_card_list(win_w, win_h)

    -- 融合预览
    if #selected_cards == 2 then
        Fusion.draw_fusion_preview(win_w, win_h)
    end

    -- 消息
    if message ~= "" then
        local msg_y = win_h * 0.75
        Theme.setColor("bg_panel", 0.9)
        love.graphics.rectangle("fill", win_w / 2 - 200, msg_y, 400, 40, 6, 6)
        Components.text(message, win_w / 2, msg_y + 10, {
            color = "accent_gold",
            align = "center",
        })
    end

    -- 变异结果
    if mutation_result then
        local mut_y = win_h * 0.82
        Theme.setColor("bg_panel", 0.9)
        local mut_color = mutation_result.type == "positive" and "accent_green" or
                          (mutation_result.type == "negative" and "accent_red" or "accent_gold")
        love.graphics.rectangle("fill", win_w / 2 - 150, mut_y, 300, 30, 4, 4)
        Components.text((I18n.t("mutation") or "Mutation") .. ": " .. mutation_result.desc, win_w / 2, mut_y + 8, {
            color = mut_color,
            align = "center",
            size = 12,
        })
    end

    -- 悬停详情（最后绘制，确保在最上层）
    if hover_card then
        CardUI.draw_tooltip(hover_card, mx, my)
    end
end

function Fusion.draw_card_list(win_w, win_h)
    local all_cards = cached_all_cards

    if not all_cards or #all_cards < 2 then
        Components.text(I18n.t("fusion_need_cards") or "Need at least 2 cards to fuse!", win_w / 2, win_h / 2, {
            color = "text_secondary",
            align = "center",
        })
        return
    end

    -- 使用CardUI的尺寸
    local small_width = CardUI.WIDTH
    local small_height = CardUI.SMALL_HEIGHT

    local gap = 15
    local cards_per_row = math.min(5, math.floor((win_w - 100) / (small_width + gap)))
    local total_width = cards_per_row * small_width + (cards_per_row - 1) * gap
    local start_x = (win_w - total_width) / 2
    local start_y = 80

    local mx, my = love.mouse.getPosition()
    hover_card = nil

    for i, card in ipairs(all_cards) do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local x = start_x + col * (small_width + gap)
        local y = start_y + row * (small_height + 20)

        -- 检查是否已选中
        local is_selected = false
        for _, idx in ipairs(selected_cards) do
            if idx == i then
                is_selected = true
                break
            end
        end

        local is_hover = mx >= x and mx <= x + small_width and my >= y and my <= y + small_height

        if is_hover then
            hover_card = card
        end

        -- 选中高亮
        if is_selected then
            Theme.setColor("accent_gold", 0.25)
            love.graphics.rectangle("fill", x - 5, y - 5, small_width + 10, small_height + 10, 8, 8)
        end

        -- 复制卡牌数据供CardUI使用
        local display_card = {
            id = card.id,
            name = I18n.card_name(card.id),
            cost = card.cost,
            attack = card.attack,
            hp = card.hp,
            max_hp = card.max_hp or card.hp,
            sigils = card.sigils or {},
        }

        -- 使用CardUI小型卡牌渲染
        CardUI.draw_small(display_card, x, y, is_hover or is_selected)

        -- 选中标记
        if is_selected then
            Theme.setColor("accent_gold")
            Fonts.print("[SELECTED]", x + small_width / 2 - 30, y + small_height + 3, 9)
        end
    end
end

function Fusion.draw_fusion_preview(win_w, win_h)
    local card1 = cached_all_cards[selected_cards[1]]
    local card2 = cached_all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    local preview_y = win_h * 0.55
    local mx, my = love.mouse.getPosition()

    -- 预览面板
    Theme.setColor("bg_panel", 0.95)
    love.graphics.rectangle("fill", win_w / 2 - 220, preview_y - 10, 440, 130, 8, 8)

    Components.text(I18n.t("fusion_preview") or "FUSION PREVIEW", win_w / 2, preview_y, {
        color = "accent_gold",
        align = "center",
        size = 14,
    })

    -- 融合结果预览
    local avg_atk = math.floor((card1.attack + card2.attack) / 2)
    local avg_hp = math.floor((card1.hp + card2.hp) / 2)
    local avg_cost = math.max(1, math.floor((card1.cost + card2.cost) / 2))

    local left_x = win_w / 2 - 150
    local right_x = win_w / 2 + 50

    -- 被融合的卡
    Components.text(I18n.card_name(card1.id) .. " + " .. I18n.card_name(card2.id), left_x, preview_y + 25, {
        color = "text_secondary",
        size = 11,
    })
    Components.text(I18n.t("attack") .. ":" .. card1.attack .. "+" .. card2.attack, left_x, preview_y + 45, {
        color = "accent_gold",
        size = 10,
    })
    Components.text(I18n.t("hp") .. ":" .. card1.hp .. "+" .. card2.hp, left_x, preview_y + 60, {
        color = "accent_green",
        size = 10,
    })

    -- 箭头
    Components.text("→", win_w / 2 - 20, preview_y + 50, {
        color = "accent_gold",
        size = 20,
    })

    -- 结果
    Components.text(I18n.t("fusion_result") or "RESULT", right_x, preview_y + 25, {
        color = "accent_gold",
        size = 12,
    })
    Components.text(I18n.t("attack") .. ":" .. avg_atk .. " " .. I18n.t("hp") .. ":" .. avg_hp .. " $" .. avg_cost, right_x, preview_y + 50, {
        color = "text_primary",
        size = 11,
    })

    -- 融合按钮
    local btn_x = win_w / 2 - 70
    local btn_y = preview_y + 85
    local can_fuse = FusionSystem.can_fuse_more()
    local btn_hover = mx >= btn_x and mx <= btn_x + 140 and my >= btn_y and my <= btn_y + 30

    Theme.setColor(can_fuse and (btn_hover and "accent_green" or "accent_green") or "bg_slot",
                   can_fuse and (btn_hover and 0.7 or 0.5) or 0.5)
    love.graphics.rectangle("fill", btn_x, btn_y, 140, 30, 5, 5)
    Components.text(can_fuse and (I18n.t("fuse") or "FUSE") or (I18n.t("fusion_limit") or "LIMIT REACHED"), btn_x + 70, btn_y + 8, {
        color = can_fuse and "text_value" or "text_hint",
        align = "center",
        size = 11,
    })
end

function Fusion.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        State.pop()
    elseif key == "return" or key == "f" then
        if #selected_cards == 2 and FusionSystem.can_fuse_more() then
            Fusion.do_fusion()
        end
    end
end

function Fusion.do_fusion()
    local card1 = cached_all_cards[selected_cards[1]]
    local card2 = cached_all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    -- 执行融合（使用正确的函数名）
    local result = FusionSystem.free_fuse(card1, card2)

    if result then
        -- 从牌库移除原图卡牌
        Deck.remove_from_deck_by_id(card1.id, 1)
        Deck.remove_from_deck_by_id(card2.id, 1)

        -- 添加融合结果
        Deck.add_fused_card(result)

        Sound.play("reward")
        message = I18n.t("fusion_success") or "Fusion successful! Created new card."
        mutation_result = {
            type = result.mutation_type or "neutral",
            desc = result.mutation_desc or ""
        }
        message_timer = 2.0

        -- 重置选择
        selected_cards = {}
        cached_all_cards = Deck.get_all_cards_for_fusion() or {}
    else
        Sound.play("click")
        message = I18n.t("fusion_failed") or "Fusion failed"
        message_timer = 2.0
    end
end

function Fusion.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()

    -- 返回按钮
    if x >= 10 and x <= 80 and y >= 10 and y <= 40 then
        Sound.play("click")
        State.pop()
        return
    end

    -- 融合按钮
    if #selected_cards == 2 then
        local preview_y = win_h * 0.55
        local btn_x = win_w / 2 - 70
        local btn_y = preview_y + 85
        if x >= btn_x and x <= btn_x + 140 and y >= btn_y and y <= btn_y + 30 then
            if FusionSystem.can_fuse_more() then
                Fusion.do_fusion()
            end
            return
        end
    end

    -- 选择卡牌
    local all_cards = cached_all_cards
    if not all_cards then return end

    -- 使用CardUI的尺寸
    local small_width = CardUI.WIDTH
    local small_height = CardUI.SMALL_HEIGHT
    local gap = 15
    local cards_per_row = math.min(5, math.floor((win_w - 100) / (small_width + gap)))
    local total_width = cards_per_row * small_width + (cards_per_row - 1) * gap
    local start_x = (win_w - total_width) / 2
    local start_y = 80

    for i, card in ipairs(all_cards) do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local cx = start_x + col * (small_width + gap)
        local cy = start_y + row * (small_height + 20)

        if x >= cx and x <= cx + small_width and y >= cy and y <= cy + small_height then
            -- 检查是否已选中
            local already_selected = false
            local selected_idx = nil
            for j, idx in ipairs(selected_cards) do
                if idx == i then
                    already_selected = true
                    selected_idx = j
                    break
                end
            end

            if already_selected then
                -- 取消选择
                table.remove(selected_cards, selected_idx)
                Sound.play("click")
            elseif #selected_cards < 2 then
                -- 添加选择
                table.insert(selected_cards, i)
                Sound.play("click")
            end
            return
        end
    end
end

return Fusion