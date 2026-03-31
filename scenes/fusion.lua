-- scenes/fusion.lua - 卡牌融合场景（简化版）
-- 只有自由融合：选择2张卡融合成1张
-- 融合是唯一减少卡牌的方式

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

-- 模块私有状态
local selected_cards = {}
local cached_all_cards = {}
local preview_result = nil
local message = ""
local message_timer = 0
local mutation_result = nil

function Fusion.enter()
    selected_cards = {}
    preview_result = nil
    message = ""
    message_timer = 0
    mutation_result = nil
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}

    -- 检查融合次数
    if not FusionSystem.can_fuse_more() then
        message = "Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)"
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
    local back_hover = love.mouse.getX() >= 10 and love.mouse.getX() <= 80 and
                       love.mouse.getY() >= 10 and love.mouse.getY() <= 40
    Theme.setColor(back_hover and "accent_red" or "bg_panel", back_hover and 0.5 or 1)
    love.graphics.rectangle("fill", 10, 10, 70, 30, 4, 4)
    Theme.setColor("text_primary")
    Fonts.print("← ESC", 22, 17, 14)

    -- 标题栏
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", 0, 0, win_w, 50, 0, 0)
    Components.text("CARD FUSION", win_w / 2, 12, {
        color = "accent_gold",
        size = 20,
        align = "center",
    })

    -- 融合次数显示
    local remaining = FusionSystem.get_remaining_fusions()
    local count_color = remaining > 2 and "accent_green" or (remaining > 0 and "accent_gold" or "accent_red")
    Components.text("Fusions: " .. remaining .. "/" .. FusionSystem.MAX_FUSIONS, win_w - 100, 15, {
        color = count_color,
        size = 14,
    })

    -- 提示文字
    Components.text("Select 2 cards to fuse into 1 (only way to reduce deck size)", win_w / 2, 60, {
        color = "text_hint",
        align = "center",
        size = 12,
    })

    -- 绘制卡牌列表
    Fusion.draw_card_list(win_w, win_h)

    -- 如果选中了2张卡，显示融合预览
    if #selected_cards == 2 then
        Fusion.draw_fusion_preview(win_w, win_h)
    end

    -- 消息显示
    if message ~= "" then
        local msg_y = win_h * 0.75
        Theme.setColor("bg_panel", 0.9)
        love.graphics.rectangle("fill", win_w / 2 - 200, msg_y, 400, 40, 6, 6)
        Components.text(message, win_w / 2, msg_y + 10, {
            color = "accent_gold",
            align = "center",
        })
    end

    -- 变异结果提示
    if mutation_result then
        local mut_y = win_h * 0.82
        Theme.setColor("bg_panel", 0.9)
        local mut_color = mutation_result.type == "positive" and "accent_green" or
                          (mutation_result.type == "negative" and "accent_red" or "accent_gold")
        love.graphics.rectangle("fill", win_w / 2 - 150, mut_y, 300, 30, 4, 4)
        Components.text("Mutation: " .. mutation_result.desc, win_w / 2, mut_y + 8, {
            color = mut_color,
            align = "center",
            size = 12,
        })
    end

    -- 底部提示
    Components.text("Fusion = Delete 2 cards + Get 1 card = Net -1 card", win_w / 2, win_h - 30, {
        color = "text_hint",
        align = "center",
        size = 11,
    })
end

function Fusion.draw_card_list(win_w, win_h)
    local all_cards = cached_all_cards

    if not all_cards or #all_cards < 2 then
        Components.text("Need at least 2 cards to fuse!", win_w / 2, win_h / 2, {
            color = "text_secondary",
            align = "center",
        })
        return
    end

    local card_width = 90
    local card_height = 110
    local gap = 12
    local cards_per_row = math.min(6, #all_cards)
    local start_x = win_w / 2 - (cards_per_row * (card_width + gap)) / 2
    local start_y = 90

    for i, card in ipairs(all_cards) do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local x = start_x + col * (card_width + gap)
        local y = start_y + row * (card_height + gap + 5)

        -- 检查是否已选中
        local is_selected = false
        for _, idx in ipairs(selected_cards) do
            if idx == i then
                is_selected = true
                break
            end
        end

        -- 获取体系信息
        local template = CardData.cards[card.id]
        local family_info = template and template.family and Family.FAMILIES[template.family]

        -- 卡牌背景
        if is_selected then
            Theme.setColor("accent_gold", 0.3)
            love.graphics.rectangle("fill", x - 4, y - 4, card_width + 8, card_height + 8, 8, 8)
        end

        Theme.setColor(is_selected and "bg_slot_hover" or "bg_slot")
        love.graphics.rectangle("fill", x, y, card_width, card_height, 5, 5)

        -- 体系颜色边框
        if family_info then
            love.graphics.setColor(family_info.color[1], family_info.color[2], family_info.color[3], 0.8)
            love.graphics.rectangle("line", x, y, card_width, card_height, 5, 5)
        else
            Theme.setColor(is_selected and "accent_gold" or "border_gold", 0.5)
            love.graphics.rectangle("line", x, y, card_width, card_height, 5, 5)
        end

        -- 卡牌信息
        Components.text(I18n.card_name(card.id), x + 5, y + 5, {color = "text_primary", size = 11})
        Components.text("$" .. card.cost, x + 5, y + 22, {color = "accent_red", size = 10})
        Components.text("ATK:" .. card.attack, x + 5, y + 40, {color = "accent_gold", size = 10})
        Components.text("HP:" .. card.hp, x + 50, y + 40, {color = "accent_green", size = 10})

        -- 体系图标
        if family_info then
            Components.text(family_info.icon, x + card_width - 20, y + 5, {size = 14})
        end

        -- 印记数量
        if card.sigils and #card.sigils > 0 then
            Components.text("*" .. #card.sigils, x + card_width - 20, y + card_height - 20, {
                color = "accent_gold",
                size = 10,
            })
        end

        -- 选中标记
        if is_selected then
            Components.text("[SELECTED]", x + card_width / 2 - 30, y + card_height - 18, {
                color = "accent_gold",
                size = 9,
            })
        end
    end
end

function Fusion.draw_fusion_preview(win_w, win_h)
    local card1 = cached_all_cards[selected_cards[1]]
    local card2 = cached_all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    local preview_y = win_h * 0.55

    -- 预览面板背景
    Theme.setColor("bg_panel", 0.95)
    love.graphics.rectangle("fill", win_w / 2 - 220, preview_y - 10, 440, 120, 8, 8)

    -- 标题
    Components.text("FUSION PREVIEW", win_w / 2, preview_y, {
        color = "accent_gold",
        align = "center",
        size = 14,
    })

    -- 计算融合结果
    local avg_atk = math.floor((card1.attack + card2.attack) / 2)
    local avg_hp = math.floor((card1.hp + card2.hp) / 2)
    local avg_cost = math.max(1, math.floor((card1.cost + card2.cost) / 2))

    -- 显示两张卡 -> 箭头 -> 结果
    local left_x = win_w / 2 - 150
    local right_x = win_w / 2 + 80

    -- 左边：被融合的卡
    Components.text(I18n.card_name(card1.id) .. " + " .. I18n.card_name(card2.id), left_x, preview_y + 25, {
        color = "text_secondary",
        size = 11,
    })
    Components.text("ATK:" .. card1.attack .. "+" .. card2.attack .. "=" .. (card1.attack + card2.attack), left_x, preview_y + 45, {
        color = "accent_gold",
        size = 10,
    })
    Components.text("HP:" .. card1.hp .. "+" .. card2.hp .. "=" .. (card1.hp + card2.hp), left_x, preview_y + 60, {
        color = "accent_green",
        size = 10,
    })

    -- 箭头
    Components.text("→", win_w / 2 - 20, preview_y + 45, {
        color = "accent_gold",
        size = 20,
    })

    -- 右边：融合结果
    Components.text("FUSED RESULT", right_x, preview_y + 25, {
        color = "accent_gold",
        size = 12,
    })
    Components.text("ATK:" .. avg_atk .. " (±1)", right_x, preview_y + 45, {
        color = "accent_gold",
        size = 10,
    })
    Components.text("HP:" .. avg_hp .. " (±1)", right_x, preview_y + 60, {
        color = "accent_green",
        size = 10,
    })
    Components.text("Cost:" .. avg_cost, right_x + 80, preview_y + 45, {
        color = "accent_red",
        size = 10,
    })

    -- 融合按钮
    local btn_x = win_w / 2 - 60
    local btn_y = preview_y + 80
    local can_fuse = FusionSystem.can_fuse_more()

    Theme.setColor(can_fuse and "accent_green" or "bg_slot", can_fuse and 0.6 or 0.5)
    love.graphics.rectangle("fill", btn_x, btn_y, 120, 30, 5, 5)
    Components.text(can_fuse and "[FUSE]" .. " (-2 cards, +1 card)" or "LIMIT REACHED", btn_x + 60, btn_y + 8, {
        color = can_fuse and "text_value" or "text_hint",
        align = "center",
        size = 11,
    })
end

function Fusion.keypressed(key)
    if key == "escape" then
        State.pop()
    end
end

function Fusion.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 返回按钮
    if x >= 10 and x <= 80 and y >= 10 and y <= 40 then
        State.pop()
        return
    end

    local win_w, win_h = Layout.get_size()

    -- 卡牌选择
    local all_cards = cached_all_cards
    local card_width = 90
    local card_height = 110
    local gap = 12
    local cards_per_row = math.min(6, #all_cards)
    local start_x = win_w / 2 - (cards_per_row * (card_width + gap)) / 2
    local start_y = 90

    for i, card in ipairs(all_cards) do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local card_x = start_x + col * (card_width + gap)
        local card_y = start_y + row * (card_height + gap + 5)

        if x >= card_x and x <= card_x + card_width and y >= card_y and y <= card_y + card_height then
            -- 检查是否已选中
            local already_selected = false
            for j, idx in ipairs(selected_cards) do
                if idx == i then
                    already_selected = true
                    table.remove(selected_cards, j)
                    break
                end
            end

            if not already_selected and #selected_cards < 2 then
                table.insert(selected_cards, i)
            end
            Sound.play("click")
            return
        end
    end

    -- 融合按钮
    if #selected_cards == 2 then
        local preview_y = win_h * 0.55
        local btn_x = win_w / 2 - 60
        local btn_y = preview_y + 80

        if x >= btn_x and x <= btn_x + 120 and y >= btn_y and y <= btn_y + 30 then
            Fusion.execute_fusion()
            return
        end
    end
end

function Fusion.execute_fusion()
    if #selected_cards ~= 2 then return end

    if not FusionSystem.can_fuse_more() then
        message = "Fusion limit reached!"
        message_timer = 2.0
        Sound.play("click")
        return
    end

    local card1 = cached_all_cards[selected_cards[1]]
    local card2 = cached_all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    -- 执行融合
    local result_card = FusionSystem.free_fuse(card1, card2)

    -- 增加融合计数
    FusionSystem.increment_fusion_count()

    if result_card then
        -- 从牌库中移除两张原卡牌
        Deck.remove_from_deck_by_id(card1.id, 1)
        Deck.remove_from_deck_by_id(card2.id, 1)

        -- 添加融合卡牌到牌库
        Deck.add_fused_card(result_card)

        -- 播放融合音效
        Sound.play("fuse")

        -- 显示结果
        message = "Created " .. result_card.name .. "! Deck size: -1"
        message_timer = 2.5

        -- 记录变异结果
        if result_card.mutation then
            mutation_result = {
                name = result_card.mutation,
                desc = result_card.mutation_desc,
                type = result_card.mutation_type,
            }
        else
            mutation_result = nil
        end
    else
        message = "Fusion failed!"
        message_timer = 1.5
        Sound.play("click")
    end

    -- 重置选择
    selected_cards = {}

    -- 刷新缓存
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}
end

return Fusion